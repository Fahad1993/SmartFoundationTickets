/**
 * Fix Mojibake Arabic Text in Tickets Schema
 * 
 * Root cause: UTF-8 bytes were stored as Latin1/CP1252 characters in NVARCHAR columns.
 * Each UTF-8 byte became a separate Unicode char in the U+00xx range.
 * 
 * Fix: read the U+00xx code points → assemble as byte array → decode as UTF-8.
 * 
 * Usage:
 *   node fix-mojibake.js preview   — show corrupted vs fixed (no changes)
 *   node fix-mojibake.js update    — apply fixes to the database
 */

const sql = require('mssql');

const config = {
    server: 'appstest',
    database: 'DATACORETi',
    options: { encrypt: false, trustServerCertificate: true },
    authentication: { type: 'default', options: { userName: '', password: '' } },
    // Windows auth via integrated security
    driver: 'msnodesqlv8',
};

// Use tedious with Windows auth
const configTedious = {
    server: 'appstest',
    database: 'DATACORETi',
    options: {
        encrypt: false,
        trustServerCertificate: true,
        trustedConnection: true,
    },
};

/**
 * Detect if a string contains Mojibake (UTF-8 bytes stored as Latin1 chars).
 * Mojibake Arabic has runs of chars in 0xC0-0xDF (first byte of 2-byte UTF-8)
 * followed by chars in 0x80-0xBF (continuation bytes).
 */
function isMojibake(str) {
    if (!str) return false;
    // Check for typical Arabic UTF-8 lead bytes stored as Latin1: Ø (U+00D8) or Ù (U+00D9)
    return /[\u00D8\u00D9][\u0080-\u00BF]/.test(str);
}

/**
 * Fix Mojibake: take a string of U+00xx chars (which are really UTF-8 bytes),
 * extract byte values, and decode as UTF-8.
 */
function fixMojibake(str) {
    if (!str) return str;
    // Extract byte values from code points
    const bytes = [];
    for (let i = 0; i < str.length; i++) {
        const cp = str.charCodeAt(i);
        if (cp > 255) {
            // This char isn't a raw byte — could be CP1252 remap
            // CP1252 maps 0x80-0x9F to specific Unicode chars
            const cp1252Byte = unicodeToCp1252(cp);
            if (cp1252Byte !== null) {
                bytes.push(cp1252Byte);
            } else {
                // Not a CP1252 remap — keep original bytes (already Unicode)
                // This shouldn't happen in pure Mojibake, but be safe
                const buf = Buffer.from(String.fromCodePoint(cp), 'utf8');
                for (const b of buf) bytes.push(b);
            }
        } else {
            bytes.push(cp);
        }
    }
    // Decode byte array as UTF-8
    return Buffer.from(bytes).toString('utf8');
}

/**
 * Map Unicode code points that came from CP1252 0x80-0x9F range back to their byte values.
 * These are the characters that CP1252 maps differently from ISO-8859-1.
 */
function unicodeToCp1252(cp) {
    const map = {
        0x20AC: 0x80, // €
        0x201A: 0x82, // ‚
        0x0192: 0x83, // ƒ
        0x201E: 0x84, // „
        0x2026: 0x85, // …
        0x2020: 0x86, // †
        0x2021: 0x87, // ‡
        0x02C6: 0x88, // ˆ
        0x2030: 0x89, // ‰
        0x0160: 0x8A, // Š
        0x2039: 0x8B, // ‹
        0x0152: 0x8C, // Œ
        0x017D: 0x8E, // Ž
        0x2018: 0x91, // '
        0x2019: 0x92, // '
        0x201C: 0x93, // "
        0x201D: 0x94, // "
        0x2022: 0x95, // •
        0x2013: 0x96, // –
        0x2014: 0x97, // —
        0x02DC: 0x98, // ˜
        0x2122: 0x99, // ™
        0x0161: 0x9A, // š
        0x203A: 0x9B, // ›
        0x0153: 0x9C, // œ
        0x017E: 0x9E, // ž
        0x0178: 0x9F, // Ÿ
    };
    return map[cp] ?? null;
}

// Tables and their text columns to fix
const TARGETS = [
    { table: 'Tickets.ServiceCatalogSuggestion', pk: 'serviceCatalogSuggestionID', cols: ['proposedServiceName_A', 'proposedServiceName_E', 'proposedServiceDesc', 'approvalNotes'] },
    { table: 'Tickets.Ticket', pk: 'ticketID', cols: ['title', 'description_', 'locationArea'] },
    { table: 'Tickets.TicketHistory', pk: 'ticketHistoryID', cols: ['notes'] },
    { table: 'Tickets.TicketPauseSession', pk: 'ticketPauseSessionID', cols: ['pauseNotes'] },
    { table: 'Tickets.ClarificationRequest', pk: 'clarificationRequestID', cols: ['requestNotes', 'responseNotes'] },
    { table: 'Tickets.TicketStatus', pk: 'ticketStatusID', cols: ['ticketStatusName_A'] },
    { table: 'Tickets.Priority', pk: 'priorityID', cols: ['priorityName_A'] },
    { table: 'Tickets.TicketClass', pk: 'ticketClassID', cols: ['ticketClassName_A'] },
    { table: 'Tickets.Service', pk: 'serviceID', cols: ['serviceName_A'] },
    { table: 'Tickets.PauseReason', pk: 'pauseReasonID', cols: ['pauseReasonName_A'] },
    { table: 'Tickets.ArbitrationReason', pk: 'arbitrationReasonID', cols: ['arbitrationReasonName_A'] },
    { table: 'Tickets.QualityReviewResult', pk: 'qualityReviewResultID', cols: ['qualityReviewResultName_A'] },
    { table: 'Tickets.ClarificationReason', pk: 'clarificationReasonID', cols: ['clarificationReasonName_A'] },
];

async function main() {
    const mode = process.argv[2] || 'preview';
    if (!['preview', 'update'].includes(mode)) {
        console.error('Usage: node fix-mojibake.js [preview|update]');
        process.exit(1);
    }

    console.log(`\n=== Fix Mojibake Arabic — Mode: ${mode.toUpperCase()} ===\n`);

    let pool;
    try {
        pool = await sql.connect(configTedious);
        console.log('Connected to', configTedious.server, '/', configTedious.database, '\n');
    } catch (err) {
        console.error('Connection failed:', err.message);
        process.exit(1);
    }

    let totalFixed = 0;

    for (const target of TARGETS) {
        const colList = [target.pk, ...target.cols].join(', ');
        let rows;
        try {
            const result = await pool.request().query(`SELECT ${colList} FROM ${target.table}`);
            rows = result.recordset;
        } catch (err) {
            console.log(`  ⚠ Skipping ${target.table}: ${err.message}`);
            continue;
        }

        let tableFixCount = 0;

        for (const row of rows) {
            const fixes = {};

            for (const col of target.cols) {
                const val = row[col];
                if (val && isMojibake(val)) {
                    const fixed = fixMojibake(val);
                    if (fixed !== val) {
                        fixes[col] = fixed;
                    }
                }
            }

            if (Object.keys(fixes).length === 0) continue;

            const pkVal = row[target.pk];
            tableFixCount++;
            totalFixed++;

            if (mode === 'preview') {
                console.log(`  ${target.table} [${target.pk}=${pkVal}]:`);
                for (const [col, fixed] of Object.entries(fixes)) {
                    const orig = row[col];
                    console.log(`    ${col}:`);
                    console.log(`      corrupted: ${orig.substring(0, 80)}${orig.length > 80 ? '...' : ''}`);
                    console.log(`      fixed:     ${fixed.substring(0, 80)}${fixed.length > 80 ? '...' : ''}`);
                }
            } else {
                // Build UPDATE
                const setClauses = [];
                const request = pool.request();
                request.input('pk', pkVal);

                let paramIdx = 0;
                for (const [col, fixed] of Object.entries(fixes)) {
                    const paramName = `p${paramIdx++}`;
                    setClauses.push(`${col} = @${paramName}`);
                    request.input(paramName, sql.NVarChar, fixed);
                }

                const updateSql = `UPDATE ${target.table} SET ${setClauses.join(', ')} WHERE ${target.pk} = @pk`;
                await request.query(updateSql);
                console.log(`  ✓ Fixed ${target.table} [${target.pk}=${pkVal}]: ${Object.keys(fixes).join(', ')}`);
            }
        }

        if (tableFixCount > 0) {
            console.log(`  → ${target.table}: ${tableFixCount} row(s) ${mode === 'preview' ? 'need fixing' : 'fixed'}\n`);
        }
    }

    console.log(`\n=== Total: ${totalFixed} row(s) ${mode === 'preview' ? 'need fixing' : 'fixed'} ===\n`);

    await pool.close();
}

main().catch(err => { console.error('Fatal:', err); process.exit(1); });
