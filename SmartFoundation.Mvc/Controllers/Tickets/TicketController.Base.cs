using Microsoft.AspNetCore.Mvc;
using SmartFoundation.Application.Services;
using SmartFoundation.Mvc.Controllers;
using SmartFoundation.UI.ViewModels.SmartForm;
using SmartFoundation.UI.ViewModels.SmartPage;
using SmartFoundation.UI.ViewModels.SmartTable;
using Microsoft.Data.SqlClient;
using System.Data;
using System.Text;
using System.Text.Json;

namespace SmartFoundation.Mvc.Controllers.Tickets
{
    public partial class TicketController : Controller
    {
        private readonly MastersServies _mastersServies;
        private readonly CrudController _CrudController;
        private readonly IWebHostEnvironment _env;

        protected string? ControllerName;
        protected string? PageName;

        protected string? usersId;
        protected string? FullName;
        protected string? OrganizationId;
        protected string? OrganizationName;
        protected string? IdaraId;
        protected string? IdaraName;
        protected string? DepartmentId;
        protected string? DepartmentName;
        protected string? SectionId;
        protected string? SectionName;
        protected string? DivisionId;
        protected string? DivisionName;
        protected string? PhotoBase64;
        protected string? ThameName;
        protected string? DeptCode;
        protected string? NationalId;
        protected string? IdNumber;
        protected string? UserActive;
        protected string? HostName;
        protected string? LastActivityUtc;

        protected DataTable? permissionTable;
        protected DataTable? dt1;
        protected DataTable? dt2;
        protected DataTable? dt3;
        protected DataTable? dt4;
        protected DataTable? dt5;
        protected DataTable? dt6;
        protected DataTable? dt7;
        protected DataTable? dt8;
        protected DataTable? dt9;

        public TicketController(MastersServies mastersServies, CrudController crudController, IWebHostEnvironment env)
        {
            _mastersServies = mastersServies;
            _CrudController = crudController;
            _env = env;
        }

        public IActionResult Index()
        {
            return View();
        }

        protected bool InitPageContext(out IActionResult? redirectResult)
        {
            redirectResult = null;

            if (string.IsNullOrWhiteSpace(HttpContext.Session.GetString("usersID")))
            {
                redirectResult = RedirectToAction("Index", "Login", new { logout = 1 });
                return false;
            }

            usersId = HttpContext.Session.GetString("usersID");
            FullName = HttpContext.Session.GetString("fullName");
            OrganizationId = HttpContext.Session.GetString("OrganizationID");
            OrganizationName = HttpContext.Session.GetString("OrganizationName");
            IdaraId = HttpContext.Session.GetString("IdaraID");
            IdaraName = HttpContext.Session.GetString("IdaraName");
            DepartmentId = HttpContext.Session.GetString("DepartmentID");
            DepartmentName = HttpContext.Session.GetString("DepartmentName");
            SectionId = HttpContext.Session.GetString("SectionID");
            SectionName = HttpContext.Session.GetString("SectionName");
            DivisionId = HttpContext.Session.GetString("DivisonID");
            DivisionName = HttpContext.Session.GetString("DivisonName");
            PhotoBase64 = HttpContext.Session.GetString("photoBase64");
            ThameName = HttpContext.Session.GetString("ThameName");
            DeptCode = HttpContext.Session.GetString("DeptCode");
            NationalId = HttpContext.Session.GetString("nationalID");
            IdNumber = HttpContext.Session.GetString("IDNumber") ?? NationalId;
            UserActive = HttpContext.Session.GetString("useractive");
            HostName = HttpContext.Session.GetString("HostName");
            LastActivityUtc = HttpContext.Session.GetString("LastActivityUtc");

            return true;
        }

        protected void SplitDataSet(DataSet ds)
        {
            permissionTable = (ds?.Tables?.Count ?? 0) > 0 ? ds.Tables[0] : null;
            dt1 = (ds?.Tables?.Count ?? 0) > 1 ? ds.Tables[1] : null;
            dt2 = (ds?.Tables?.Count ?? 0) > 2 ? ds.Tables[2] : null;
            dt3 = (ds?.Tables?.Count ?? 0) > 3 ? ds.Tables[3] : null;
            dt4 = (ds?.Tables?.Count ?? 0) > 4 ? ds.Tables[4] : null;
            dt5 = (ds?.Tables?.Count ?? 0) > 5 ? ds.Tables[5] : null;
            dt6 = (ds?.Tables?.Count ?? 0) > 6 ? ds.Tables[6] : null;
            dt7 = (ds?.Tables?.Count ?? 0) > 7 ? ds.Tables[7] : null;
            dt8 = (ds?.Tables?.Count ?? 0) > 8 ? ds.Tables[8] : null;
            dt9 = (ds?.Tables?.Count ?? 0) > 9 ? ds.Tables[9] : null;
        }

        protected async Task<List<OptionItem>> GetTicketDdlOptionsAsync(
            string textCol,
            string valueCol,
            string tableIndex,
            string pageName,
            string? firstOption = null)
        {
            if (string.Equals(pageName, "ResidentDDL", StringComparison.OrdinalIgnoreCase))
            {
                try
                {
                    var residentTable = await GetResidentsWithHousing();
                    var residentOptions = BuildResidentOptionItems(residentTable, firstOption);
                    if (HasUsableOptions(residentOptions))
                        return residentOptions;
                }
                catch
                {
                    // Fall back to the generic DDL path if the resident-specific source is unavailable.
                }

                return await LoadTicketDdlOptionsFallbackAsync(pageName, textCol, valueCol, firstOption);
            }

            var ddlResult = await _CrudController.GetDDLValues(
                textCol,
                valueCol,
                tableIndex,
                pageName,
                usersId,
                IdaraId,
                HostName,
                FirstOption: firstOption
            ) as JsonResult;

            var options = ddlResult?.Value != null
                ? JsonSerializer.Deserialize<List<OptionItem>>(JsonSerializer.Serialize(ddlResult.Value)) ?? new List<OptionItem>()
                : new List<OptionItem>();

            if (HasUsableOptions(options))
                return options;

            return await LoadTicketDdlOptionsFallbackAsync(pageName, textCol, valueCol, firstOption);
        }

        private async Task<List<OptionItem>> LoadTicketDdlOptionsFallbackAsync(
            string pageName,
            string textCol,
            string valueCol,
            string? firstOption)
        {
            try
            {
                if (string.Equals(pageName, "ResidentDDL", StringComparison.OrdinalIgnoreCase))
                {
                    var residentSql = GetTicketDdlFallbackSql(pageName, valueCol);
                    if (!string.IsNullOrWhiteSpace(residentSql))
                    {
                        var residentTable = await ExecuteTicketFallbackQueryAsync(residentSql);
                        return BuildResidentOptionItems(residentTable, firstOption);
                    }

                    return BuildResidentOptionItems(null, firstOption);
                }

                var sql = GetTicketDdlFallbackSql(pageName, valueCol);
                if (string.IsNullOrWhiteSpace(sql))
                    return BuildOptionItems(null, valueCol, textCol, firstOption);

                var table = await ExecuteTicketFallbackQueryAsync(sql);
                return BuildOptionItems(table, valueCol, textCol, firstOption);
            }
            catch
            {
                return BuildOptionItems(null, valueCol, textCol, firstOption);
            }
        }

        private string? GetTicketDdlFallbackSql(string pageName, string valueCol)
        {
            if (string.Equals(pageName, "TicketList", StringComparison.OrdinalIgnoreCase))
            {
                if (string.Equals(valueCol, "ticketStatusID", StringComparison.OrdinalIgnoreCase))
                {
                    return @"
SELECT [ticketStatusID], [ticketStatusName_A], [ticketStatusName_E]
FROM [Tickets].[TicketStatus]
WHERE [ticketStatusActive] = 1
ORDER BY [ticketStatusID];";
                }

                if (string.Equals(valueCol, "serviceID", StringComparison.OrdinalIgnoreCase))
                {
                    return @"
SELECT [serviceID], [serviceName_A], [serviceName_E]
FROM [Tickets].[Service]
WHERE [serviceActive] = 1
  AND ([idaraID_FK] = @idaraID OR @idaraID IS NULL OR [idaraID_FK] IS NULL)
ORDER BY [serviceID];";
                }
            }

            return pageName switch
            {
                "ResidentDDL" => @"
;WITH ResidentHousing AS
(
    SELECT
        r.[residentInfoID] AS [residentInfoID],
        r.[NationalID] AS [NationalID],
        r.[generalNo_FK] AS [generalNo_FK],
        r.[FullName_A] AS [ResidentName_A],
        r.[FullName_A] AS [FullName_A],
        CASE
            WHEN ba.[BuildingNo] IS NULL
              OR LTRIM(RTRIM(CONVERT(NVARCHAR(100), ba.[BuildingNo]))) = N''
              OR CONVERT(NVARCHAR(100), ba.[BuildingNo]) = N'No_house'
            THEN N'بدون سكن'
            ELSE CONVERT(NVARCHAR(100), ba.[BuildingNo])
        END AS [BuildingNo],
        ROW_NUMBER() OVER
        (
            PARTITION BY r.[residentInfoID]
            ORDER BY
                CASE
                    WHEN ba.[BuildingNo] IS NULL
                      OR LTRIM(RTRIM(CONVERT(NVARCHAR(100), ba.[BuildingNo]))) = N''
                      OR CONVERT(NVARCHAR(100), ba.[BuildingNo]) = N'No_house'
                    THEN 1 ELSE 0
                END,
                ba.[BuildingAssignDate] DESC,
                ba.[BuildingAssignID] DESC
        ) AS [rn]
    FROM [Housing].[V_GetFullResidentDetails] r
    INNER JOIN [DATACORE].[Housing].[BuildingAssign] ba
        ON r.[generalNo_FK] = ba.[GeneralNo]
    INNER JOIN [DATACORE].[Housing].[BuildingAssignStatus] bas
        ON ba.[BuildingAssignStatusID_FK] = bas.[BuildingAssignStatusID]
    WHERE r.[IdaraID] = @idaraID
      AND bas.[Active] = 1
)
SELECT
    [residentInfoID],
    [NationalID],
    [generalNo_FK],
    [ResidentName_A],
    [FullName_A],
    [BuildingNo]
FROM ResidentHousing
WHERE [rn] = 1
ORDER BY [ResidentName_A] ASC;",
                "RequesterTypeDDL" => @"
SELECT [requesterTypeID], [requesterTypeCode], [requesterTypeName_A], [requesterTypeName_E]
FROM [Tickets].[RequesterType]
WHERE [requesterTypeActive] = 1
ORDER BY [requesterTypeID];",
                "TicketClassDDL" => @"
SELECT [ticketClassID], [ticketClassCode], [ticketClassName_A], [ticketClassName_E]
FROM [Tickets].[TicketClass]
WHERE [ticketClassActive] = 1
ORDER BY [ticketClassID];",
                "PriorityDDL" => @"
SELECT [priorityID], [priorityCode], [priorityName_A], [priorityName_E]
FROM [Tickets].[Priority]
WHERE [priorityActive] = 1
ORDER BY [priorityID];",
                "PauseReasonDDL" => @"
SELECT [pauseReasonID], [pauseReasonCode], [pauseReasonName_A], [pauseReasonName_E]
FROM [Tickets].[PauseReason]
WHERE [pauseReasonActive] = 1
ORDER BY [pauseReasonID];",
                "ArbitrationReasonDDL" => @"
SELECT [arbitrationReasonID], [arbitrationReasonCode], [arbitrationReasonName_A], [arbitrationReasonName_E]
FROM [Tickets].[ArbitrationReason]
WHERE [arbitrationReasonActive] = 1
ORDER BY [arbitrationReasonID];",
                "QualityReviewResultDDL" => @"
SELECT [qualityReviewResultID], [qualityReviewResultCode], [qualityReviewResultName_A], [qualityReviewResultName_E]
FROM [Tickets].[QualityReviewResult]
WHERE [qualityReviewResultActive] = 1
ORDER BY [qualityReviewResultID];",
                "BuildingDDL" => @"
SELECT
    bd.[buildingDetailsID] AS [buildingDetailsID],
    bd.[buildingDetailsNo] AS [buildingDetailsNo],
    bd.[buildingDetailsRooms] AS [buildingDetailsRooms],
    bt.[buildingTypeName_A] AS [buildingTypeName_A],
    m.[militaryLocationName_A] AS [militaryLocationName_A],
    bc.[buildingClassName_A] AS [buildingClassName_A]
FROM [DATACORE].[Housing].[BuildingDetails] bd
INNER JOIN [DATACORE].[Housing].[BuildingType] bt ON bd.[buildingTypeID_FK] = bt.[buildingTypeID]
INNER JOIN [DATACORE].[Housing].[MilitaryLocation] m ON bd.[militaryLocationID_FK] = m.[militaryLocationID]
INNER JOIN [DATACORE].[Housing].[BuildingClass] bc ON bd.[buildingClassID_FK] = bc.[buildingClassID]
WHERE bd.[buildingDetailsActive] = 1
  AND bd.[IdaraId_FK] = @idaraID
  AND bt.[buildingTypeActive] = 1
  AND m.[militaryLocationActive] = 1
  AND bc.[buildingClassActive] = 1
ORDER BY bd.[buildingDetailsNo] ASC;",
                "TicketReasonDDL" => @"
SELECT [ticketReasonID], [ticketReasonCode], [ticketReasonName_A], [ticketReasonName_E], [priorityID_FK]
FROM [Tickets].[TicketReason]
WHERE [ticketReasonActive] = 1
  AND ([idaraID_FK] = @idaraID OR [idaraID_FK] IS NULL)
ORDER BY [displayOrder] ASC, [ticketReasonID] ASC;",
                "TicketDescriptionTemplateDDL" => @"
SELECT [templateID], [templateCode], [templateName_A], [templateName_E], [templateContent_A]
FROM [Tickets].[TicketDescriptionTemplate]
WHERE [templateActive] = 1
  AND ([idaraID_FK] = @idaraID OR [idaraID_FK] IS NULL)
ORDER BY [displayOrder] ASC, [templateID] ASC;",
                _ => null
            };
        }

        private async Task<DataTable> ExecuteTicketFallbackQueryAsync(string sql)
        {
            var dt = new DataTable();
            var connectionString = GetDefaultConnectionString();

            using var connection = new SqlConnection(connectionString);
            await connection.OpenAsync();

            using var command = new SqlCommand(sql, connection);
            command.Parameters.AddWithValue("@idaraID", string.IsNullOrWhiteSpace(IdaraId) ? DBNull.Value : int.Parse(IdaraId));

            using var reader = await command.ExecuteReaderAsync();
            dt.Load(reader);
            return dt;
        }

        private string GetDefaultConnectionString()
        {
            var builder = new ConfigurationBuilder()
                .SetBasePath(_env.ContentRootPath)
                .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
                .AddJsonFile($"appsettings.{_env.EnvironmentName}.json", optional: true, reloadOnChange: true);

            var configuration = builder.Build();
            return configuration.GetConnectionString("Default")
                ?? throw new InvalidOperationException("Default connection string is not configured.");
        }

        private List<OptionItem> BuildOptionItems(
            DataTable? table,
            string valueCol,
            string textCol,
            string? firstOption)
        {
            var options = new List<OptionItem>();

            if (!string.IsNullOrWhiteSpace(firstOption))
            {
                options.Add(new OptionItem { Value = "-1", Text = firstOption });
            }

            if (table != null && table.Columns.Contains(valueCol) && table.Columns.Contains(textCol))
            {
                foreach (DataRow row in table.Rows)
                {
                    var value = row[valueCol]?.ToString()?.Trim();
                    var text = row[textCol]?.ToString()?.Trim();

                    if (!string.IsNullOrWhiteSpace(value))
                    {
                        options.Add(new OptionItem
                        {
                            Value = value,
                            Text = string.IsNullOrWhiteSpace(text) ? value : text
                        });
                    }
                }
            }

            if (!HasUsableOptions(options))
            {
                options.Add(new OptionItem { Value = "-1", Text = "لاتوجد خيارات" });
            }

            return options;
        }

        private List<OptionItem> BuildResidentOptionItems(DataTable? table, string? firstOption)
        {
            var options = new List<OptionItem>();

            if (!string.IsNullOrWhiteSpace(firstOption))
            {
                options.Add(new OptionItem { Value = "-1", Text = firstOption });
            }

            if (table != null)
            {
                var seenResidents = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

                foreach (DataRow row in table.Rows)
                {
                    var residentId = GetTrimmedCell(row, "residentInfoID");
                    if (string.IsNullOrWhiteSpace(residentId) || !seenResidents.Add(residentId))
                        continue;

                    var residentName = GetTrimmedCell(row, "ResidentName_A", "FullName_A");
                    var nationalId = GetTrimmedCell(row, "NationalID");
                    var generalNo = GetTrimmedCell(row, "generalNo_FK");
                    var housing = NormalizeResidentHousing(GetTrimmedCell(row, "BuildingNo"));

                    var identity = !string.IsNullOrWhiteSpace(nationalId)
                        ? nationalId
                        : !string.IsNullOrWhiteSpace(generalNo)
                            ? generalNo
                            : "-";

                    if (string.IsNullOrWhiteSpace(residentName))
                        residentName = identity;

                    options.Add(new OptionItem
                    {
                        Value = residentId,
                        Text = FormatResidentOptionText(residentName, identity, housing)
                    });
                }
            }

            if (!HasUsableOptions(options))
            {
                options.Add(new OptionItem { Value = "-1", Text = "لاتوجد خيارات" });
            }

            return options;
        }

        private static string GetTrimmedCell(DataRow row, params string[] columnNames)
        {
            foreach (var columnName in columnNames)
            {
                if (!row.Table.Columns.Contains(columnName))
                    continue;

                var value = row[columnName]?.ToString()?.Trim();
                if (!string.IsNullOrWhiteSpace(value))
                    return NormalizeResidentText(value);
            }

            return string.Empty;
        }

        private static string NormalizeResidentHousing(string? buildingNo)
        {
            var rawBuildingNo = buildingNo?.Trim() ?? string.Empty;
            var normalizedBuildingNo = NormalizeResidentText(buildingNo);
            if (string.IsNullOrWhiteSpace(normalizedBuildingNo)
                || string.Equals(normalizedBuildingNo, "No_house", StringComparison.OrdinalIgnoreCase)
                || string.Equals(normalizedBuildingNo, "بدون سكن", StringComparison.Ordinal)
                || (rawBuildingNo.Contains("Ø¨Ø¯", StringComparison.Ordinal)
                    && rawBuildingNo.Contains("Ø³ÙƒÙ†", StringComparison.Ordinal)))
                return "بدون سكن";

            return normalizedBuildingNo;
        }

        private static string NormalizeResidentText(string? value)
        {
            if (string.IsNullOrWhiteSpace(value))
                return string.Empty;

            var trimmedValue = value.Trim();
            if (ContainsArabicCharacters(trimmedValue) || !LooksLikeUtf8Mojibake(trimmedValue))
                return trimmedValue;

            try
            {
                var decodedValue = DecodeUtf8Mojibake(trimmedValue).Trim();
                return ContainsArabicCharacters(decodedValue) ? decodedValue : trimmedValue;
            }
            catch
            {
                return trimmedValue;
            }
        }

        private static string DecodeUtf8Mojibake(string value)
        {
            var bytes = new byte[value.Length];

            for (var index = 0; index < value.Length; index++)
            {
                var mappedByte = TryGetWindows1252Byte(value[index]);
                if (!mappedByte.HasValue)
                    return value;

                bytes[index] = mappedByte.Value;
            }

            return Encoding.UTF8.GetString(bytes);
        }

        private static byte? TryGetWindows1252Byte(char character)
        {
            if (character <= 0x00FF)
                return (byte)character;

            return character switch
            {
                '\u20AC' => 0x80,
                '\u201A' => 0x82,
                '\u0192' => 0x83,
                '\u201E' => 0x84,
                '\u2026' => 0x85,
                '\u2020' => 0x86,
                '\u2021' => 0x87,
                '\u02C6' => 0x88,
                '\u2030' => 0x89,
                '\u0160' => 0x8A,
                '\u2039' => 0x8B,
                '\u0152' => 0x8C,
                '\u017D' => 0x8E,
                '\u2018' => 0x91,
                '\u2019' => 0x92,
                '\u201C' => 0x93,
                '\u201D' => 0x94,
                '\u2022' => 0x95,
                '\u2013' => 0x96,
                '\u2014' => 0x97,
                '\u02DC' => 0x98,
                '\u2122' => 0x99,
                '\u0161' => 0x9A,
                '\u203A' => 0x9B,
                '\u0153' => 0x9C,
                '\u017E' => 0x9E,
                '\u0178' => 0x9F,
                _ => null
            };
        }

        private static bool LooksLikeUtf8Mojibake(string value)
        {
            return value.IndexOf('Ø') >= 0 || value.IndexOf('Ù') >= 0 || value.IndexOf('Ã') >= 0;
        }

        private static bool ContainsArabicCharacters(string value)
        {
            return value.Any(character => character >= '\u0600' && character <= '\u06FF');
        }

        private static string FormatResidentOptionText(string residentName, string identity, string housing)
        {
            return $"{residentName} | هوية: {FormatResidentInlineValue(identity)} | السكن: {FormatResidentInlineValue(housing)}";
        }

        private static string FormatResidentInlineValue(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
                return "-";

            var trimmedValue = value.Trim();
            if (trimmedValue.All(character => char.IsDigit(character) || character is '-' or '/' or ' '))
                return $"\u200E{trimmedValue}\u200E";

            return trimmedValue;
        }

        private static bool HasUsableOptions(IEnumerable<OptionItem>? options)
        {
            return options?.Any(option =>
                !string.IsNullOrWhiteSpace(option.Value) &&
                !string.Equals(option.Value, "-1", StringComparison.Ordinal)) == true;
        }

        /// <summary>
        /// Get residents with active housing assignments for ticket creation
        /// </summary>
        protected async Task<DataTable> GetResidentsWithHousing()
        {
            var dt = new DataTable();

            var connectionString = GetDefaultConnectionString();

            using (var connection = new SqlConnection(connectionString))
            {
                await connection.OpenAsync();

                using (var command = new SqlCommand("[Tickets].[ResidentDDL]", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@pageName_", "ResidentDDL");
                    command.Parameters.AddWithValue("@idaraID", IdaraId ?? (object)DBNull.Value);
                    command.Parameters.AddWithValue("@entrydata", usersId ?? (object)DBNull.Value);
                    command.Parameters.AddWithValue("@hostname", HostName ?? (object)DBNull.Value);

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        dt.Load(reader);
                    }
                }
            }

            return dt;
        }
    }
}
