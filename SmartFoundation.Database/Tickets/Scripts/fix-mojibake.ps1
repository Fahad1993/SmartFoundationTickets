param(
    [ValidateSet('preview', 'update')]
    [string]$Mode = 'preview'
)

$connectionString = 'Server=appstest;Database=DATACORETi;Integrated Security=True;TrustServerCertificate=True;'

# Reverse map for CP1252 special characters (0x80-0x9F)
$cp1252Reverse = @{
    0x20AC = 0x80
    0x201A = 0x82
    0x0192 = 0x83
    0x201E = 0x84
    0x2026 = 0x85
    0x2020 = 0x86
    0x2021 = 0x87
    0x02C6 = 0x88
    0x2030 = 0x89
    0x0160 = 0x8A
    0x2039 = 0x8B
    0x0152 = 0x8C
    0x017D = 0x8E
    0x2018 = 0x91
    0x2019 = 0x92
    0x201C = 0x93
    0x201D = 0x94
    0x2022 = 0x95
    0x2013 = 0x96
    0x2014 = 0x97
    0x02DC = 0x98
    0x2122 = 0x99
    0x0161 = 0x9A
    0x203A = 0x9B
    0x0153 = 0x9C
    0x017E = 0x9E
    0x0178 = 0x9F
}

function Test-IsMojibake {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $false
    }

    # Typical Arabic mojibake starts with bytes shown as U+00D8/U+00D9 characters.
    return ($Value -match '[\u00D8\u00D9]')
}

function Convert-FromMojibake {
    param([string]$Value)

    if ([string]::IsNullOrEmpty($Value)) {
        return $Value
    }

    $bytes = New-Object System.Collections.Generic.List[byte]

    foreach ($ch in $Value.ToCharArray()) {
        $cp = [int]$ch

        if ($cp -le 255) {
            [void]$bytes.Add([byte]$cp)
            continue
        }

        if ($cp1252Reverse.ContainsKey($cp)) {
            [void]$bytes.Add([byte]$cp1252Reverse[$cp])
            continue
        }

        # Not a byte-like code point, keep it as UTF-8 bytes.
        $fallback = [System.Text.Encoding]::UTF8.GetBytes([string]$ch)
        foreach ($b in $fallback) {
            [void]$bytes.Add($b)
        }
    }

    return [System.Text.Encoding]::UTF8.GetString($bytes.ToArray())
}

function Clip {
    param([string]$Text)
    if ($null -eq $Text) { return '<NULL>' }
    if ($Text.Length -le 80) { return $Text }
    return $Text.Substring(0, 80) + '...'
}

$query = @'
SELECT
    serviceCatalogSuggestionID,
    proposedServiceName_A,
    proposedServiceName_E,
    proposedServiceDesc,
    approvalNotes
FROM Tickets.ServiceCatalogSuggestion
ORDER BY serviceCatalogSuggestionID;
'@

$conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$conn.Open()

try {
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $query

    $reader = $cmd.ExecuteReader()
    $rows = New-Object System.Collections.Generic.List[object]

    while ($reader.Read()) {
        $rows.Add([pscustomobject]@{
            ID = [int]$reader['serviceCatalogSuggestionID']
            proposedServiceName_A = if ($reader.IsDBNull(1)) { $null } else { [string]$reader['proposedServiceName_A'] }
            proposedServiceName_E = if ($reader.IsDBNull(2)) { $null } else { [string]$reader['proposedServiceName_E'] }
            proposedServiceDesc = if ($reader.IsDBNull(3)) { $null } else { [string]$reader['proposedServiceDesc'] }
            approvalNotes = if ($reader.IsDBNull(4)) { $null } else { [string]$reader['approvalNotes'] }
        })
    }

    $reader.Close()

    $totalRows = 0

    foreach ($row in $rows) {
        $changes = @{}

        foreach ($col in @('proposedServiceName_A', 'proposedServiceName_E', 'proposedServiceDesc', 'approvalNotes')) {
            $value = $row.$col
            if (Test-IsMojibake -Value $value) {
                $fixed = Convert-FromMojibake -Value $value
                if ($fixed -ne $value) {
                    $changes[$col] = $fixed
                }
            }
        }

        if ($changes.Count -eq 0) {
            continue
        }

        $totalRows++

        if ($Mode -eq 'preview') {
            Write-Host "ID=$($row.ID)"
            foreach ($k in $changes.Keys) {
                Write-Host "  $k"
                Write-Host "    corrupted: $(Clip -Text $row.$k)"
                Write-Host "    fixed:     $(Clip -Text $changes[$k])"
            }
            Write-Host ''
        }
        else {
            $setParts = New-Object System.Collections.Generic.List[string]
            $updateCmd = $conn.CreateCommand()

            foreach ($k in $changes.Keys) {
                $paramName = "@$k"
                [void]$setParts.Add("$k = $paramName")
                [void]$updateCmd.Parameters.Add($paramName, [System.Data.SqlDbType]::NVarChar, -1)
                $updateCmd.Parameters[$paramName].Value = $changes[$k]
            }

            [void]$updateCmd.Parameters.Add('@id', [System.Data.SqlDbType]::Int)
            $updateCmd.Parameters['@id'].Value = $row.ID

            $updateCmd.CommandText = "UPDATE Tickets.ServiceCatalogSuggestion SET $($setParts -join ', ') WHERE serviceCatalogSuggestionID = @id"
            [void]$updateCmd.ExecuteNonQuery()

            Write-Host "Updated ID=$($row.ID): $($changes.Keys -join ', ')"
        }
    }

    if ($Mode -eq 'preview') {
        Write-Host "Preview complete. Rows needing fix: $totalRows"
    }
    else {
        Write-Host "Update complete. Rows fixed: $totalRows"
    }
}
finally {
    $conn.Close()
}
