-- =====================================================================
-- Fix Mojibake Arabic Text in Tickets Schema
-- =====================================================================
-- Root cause : UTF-8 bytes were incorrectly interpreted as Latin1/CP1252
--              and stored into NVARCHAR columns.
-- Example    : 'Ã˜Â¥Ã˜ÂµÃ™â€žÃ˜Â§Ã˜Â­'  â†’  should be  'Ø¥ØµÙ„Ø§Ø­'
-- Technique  : Reverse the double-encoding:
--   1. NVARCHAR (mojibake) â†’ VARCHAR (CP1252) â€” recovers original UTF-8 bytes
--   2. VARCHAR â†’ VARBINARY          â€” raw bytes
--   3. VARBINARY â†’ VARCHAR (UTF-8 collation) â€” SQL Server decodes as UTF-8
--   4. VARCHAR (UTF-8) â†’ NVARCHAR   â€” proper Unicode
-- Requires   : SQL Server 2019+ (Latin1_General_100_CI_AI_SC_UTF8 collation)
-- Database   : DATACORETi (appstest)
-- =====================================================================

-- =====================================================================
-- PART 0 â€” Compatibility check (UTF-8 collation available?)
-- =====================================================================
IF NOT EXISTS (
    SELECT 1 FROM sys.fn_helpcollations()
    WHERE [name] = 'Latin1_General_100_CI_AI_SC_UTF8'
)
BEGIN
    RAISERROR('UTF-8 collation Latin1_General_100_CI_AI_SC_UTF8 is not available. Requires SQL Server 2019+.', 16, 1);
    RETURN;
END
GO

-- =====================================================================
-- PART 1 â€” DIAGNOSTIC: Find rows with Mojibake patterns
-- =====================================================================
-- Mojibake Arabic always contains Ã˜ (U+00D8) or Ã™ (U+00D9):
-- these are the first bytes of 2-byte UTF-8 sequences for Arabic chars.
-- =====================================================================

PRINT '===== DIAGNOSTIC: Rows containing Mojibake patterns =====';

-- Tickets.Ticket
SELECT 'Tickets.Ticket' AS [Table], ticketID AS [ID],
       'title' AS [Column], title AS [Value]
FROM   Tickets.Ticket
WHERE  title LIKE N'%Ã˜%' OR title LIKE N'%Ã™%'
UNION ALL
SELECT 'Tickets.Ticket', ticketID,
       'description_', LEFT(description_, 200)
FROM   Tickets.Ticket
WHERE  description_ LIKE N'%Ã˜%' OR description_ LIKE N'%Ã™%'
UNION ALL
SELECT 'Tickets.Ticket', ticketID,
       'locationArea', locationArea
FROM   Tickets.Ticket
WHERE  locationArea LIKE N'%Ã˜%' OR locationArea LIKE N'%Ã™%';

-- Tickets.TicketHistory
SELECT 'Tickets.TicketHistory' AS [Table], ticketHistoryID AS [ID],
       'notes' AS [Column], LEFT(notes, 200) AS [Value]
FROM   Tickets.TicketHistory
WHERE  notes LIKE N'%Ã˜%' OR notes LIKE N'%Ã™%';

-- Tickets.TicketPauseSession
SELECT 'Tickets.TicketPauseSession' AS [Table], ticketPauseSessionID AS [ID],
       'pauseNotes' AS [Column], LEFT(pauseNotes, 200) AS [Value]
FROM   Tickets.TicketPauseSession
WHERE  pauseNotes LIKE N'%Ã˜%' OR pauseNotes LIKE N'%Ã™%';

-- Tickets.ClarificationRequest
SELECT 'Tickets.ClarificationRequest' AS [Table], clarificationRequestID AS [ID],
       'requestNotes' AS [Column], LEFT(requestNotes, 200) AS [Value]
FROM   Tickets.ClarificationRequest
WHERE  requestNotes LIKE N'%Ã˜%' OR requestNotes LIKE N'%Ã™%'
UNION ALL
SELECT 'Tickets.ClarificationRequest', clarificationRequestID,
       'responseNotes', LEFT(responseNotes, 200)
FROM   Tickets.ClarificationRequest
WHERE  responseNotes LIKE N'%Ã˜%' OR responseNotes LIKE N'%Ã™%';

-- Lookup tables (if the existing fix_arabic.sql hasn't been run yet)
SELECT 'Tickets.TicketStatus' AS [Table], ticketStatusID AS [ID],
       'ticketStatusName_A' AS [Column], ticketStatusName_A AS [Value]
FROM   Tickets.TicketStatus
WHERE  ticketStatusName_A LIKE N'%Ã˜%' OR ticketStatusName_A LIKE N'%Ã™%'
UNION ALL
SELECT 'Tickets.Priority', priorityID,
       'priorityName_A', priorityName_A
FROM   Tickets.Priority
WHERE  priorityName_A LIKE N'%Ã˜%' OR priorityName_A LIKE N'%Ã™%'
UNION ALL
SELECT 'Tickets.TicketClass', ticketClassID,
       'ticketClassName_A', ticketClassName_A
FROM   Tickets.TicketClass
WHERE  ticketClassName_A LIKE N'%Ã˜%' OR ticketClassName_A LIKE N'%Ã™%'
UNION ALL
SELECT 'Tickets.Service', serviceID,
       'serviceName_A', serviceName_A
FROM   Tickets.Service
WHERE  serviceName_A LIKE N'%Ã˜%' OR serviceName_A LIKE N'%Ã™%';

GO

-- =====================================================================
-- PART 2 â€” PREVIEW: Show corrupted vs fixed side-by-side
-- =====================================================================
-- Run this FIRST to verify the conversion produces correct Arabic.
-- The fix expression:
--   CAST(
--     CAST(
--       CAST(
--         CAST(col COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX))
--       AS VARBINARY(MAX))
--     AS VARCHAR(MAX))
--     COLLATE Latin1_General_100_CI_AI_SC_UTF8
--   AS NVARCHAR(MAX))
-- =====================================================================

PRINT '';
PRINT '===== PREVIEW: Corrupted â†’ Fixed =====';

-- Tickets.Ticket â€” title
SELECT ticketID,
       title                AS corrupted_title,
       CAST(
         CAST(
           CAST(
             CAST(title COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX))
           AS VARBINARY(MAX))
         AS VARCHAR(MAX))
         COLLATE Latin1_General_100_CI_AI_SC_UTF8
       AS NVARCHAR(MAX))    AS fixed_title
FROM   Tickets.Ticket
WHERE  title LIKE N'%Ã˜%' OR title LIKE N'%Ã™%';

-- Tickets.Ticket â€” description_
SELECT ticketID,
       LEFT(description_, 200) AS corrupted_description,
       LEFT(
         CAST(
           CAST(
             CAST(
               CAST(description_ COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX))
             AS VARBINARY(MAX))
           AS VARCHAR(MAX))
           COLLATE Latin1_General_100_CI_AI_SC_UTF8
         AS NVARCHAR(MAX)), 200) AS fixed_description
FROM   Tickets.Ticket
WHERE  description_ LIKE N'%Ã˜%' OR description_ LIKE N'%Ã™%';

-- Tickets.Ticket â€” locationArea
SELECT ticketID,
       locationArea         AS corrupted_locationArea,
       CAST(
         CAST(
           CAST(
             CAST(locationArea COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX))
           AS VARBINARY(MAX))
         AS VARCHAR(MAX))
         COLLATE Latin1_General_100_CI_AI_SC_UTF8
       AS NVARCHAR(MAX))    AS fixed_locationArea
FROM   Tickets.Ticket
WHERE  locationArea LIKE N'%Ã˜%' OR locationArea LIKE N'%Ã™%';

-- Tickets.TicketHistory â€” notes
SELECT ticketHistoryID,
       LEFT(notes, 200)     AS corrupted_notes,
       LEFT(
         CAST(
           CAST(
             CAST(
               CAST(notes COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX))
             AS VARBINARY(MAX))
           AS VARCHAR(MAX))
           COLLATE Latin1_General_100_CI_AI_SC_UTF8
         AS NVARCHAR(MAX)), 200) AS fixed_notes
FROM   Tickets.TicketHistory
WHERE  notes LIKE N'%Ã˜%' OR notes LIKE N'%Ã™%';

-- Tickets.TicketPauseSession â€” pauseNotes
SELECT ticketPauseSessionID,
       LEFT(pauseNotes, 200)  AS corrupted_pauseNotes,
       LEFT(
         CAST(
           CAST(
             CAST(
               CAST(pauseNotes COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX))
             AS VARBINARY(MAX))
           AS VARCHAR(MAX))
           COLLATE Latin1_General_100_CI_AI_SC_UTF8
         AS NVARCHAR(MAX)), 200) AS fixed_pauseNotes
FROM   Tickets.TicketPauseSession
WHERE  pauseNotes LIKE N'%Ã˜%' OR pauseNotes LIKE N'%Ã™%';

-- Tickets.ClarificationRequest â€” requestNotes / responseNotes
SELECT clarificationRequestID,
       LEFT(requestNotes, 200)  AS corrupted_requestNotes,
       LEFT(
         CAST(
           CAST(
             CAST(
               CAST(requestNotes COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX))
             AS VARBINARY(MAX))
           AS VARCHAR(MAX))
           COLLATE Latin1_General_100_CI_AI_SC_UTF8
         AS NVARCHAR(MAX)), 200) AS fixed_requestNotes
FROM   Tickets.ClarificationRequest
WHERE  requestNotes LIKE N'%Ã˜%' OR requestNotes LIKE N'%Ã™%';

SELECT clarificationRequestID,
       LEFT(responseNotes, 200) AS corrupted_responseNotes,
       LEFT(
         CAST(
           CAST(
             CAST(
               CAST(responseNotes COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX))
             AS VARBINARY(MAX))
           AS VARCHAR(MAX))
           COLLATE Latin1_General_100_CI_AI_SC_UTF8
         AS NVARCHAR(MAX)), 200) AS fixed_responseNotes
FROM   Tickets.ClarificationRequest
WHERE  responseNotes LIKE N'%Ã˜%' OR responseNotes LIKE N'%Ã™%';

-- Lookup tables preview
SELECT 'TicketStatus' AS [Table], ticketStatusID AS [ID],
       ticketStatusName_A AS corrupted,
       CAST(CAST(CAST(CAST(ticketStatusName_A COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX)) AS VARBINARY(MAX)) AS VARCHAR(MAX)) COLLATE Latin1_General_100_CI_AI_SC_UTF8 AS NVARCHAR(MAX)) AS fixed
FROM   Tickets.TicketStatus
WHERE  ticketStatusName_A LIKE N'%Ã˜%' OR ticketStatusName_A LIKE N'%Ã™%'
UNION ALL
SELECT 'Priority', priorityID,
       priorityName_A,
       CAST(CAST(CAST(CAST(priorityName_A COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX)) AS VARBINARY(MAX)) AS VARCHAR(MAX)) COLLATE Latin1_General_100_CI_AI_SC_UTF8 AS NVARCHAR(MAX))
FROM   Tickets.Priority
WHERE  priorityName_A LIKE N'%Ã˜%' OR priorityName_A LIKE N'%Ã™%'
UNION ALL
SELECT 'TicketClass', ticketClassID,
       ticketClassName_A,
       CAST(CAST(CAST(CAST(ticketClassName_A COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX)) AS VARBINARY(MAX)) AS VARCHAR(MAX)) COLLATE Latin1_General_100_CI_AI_SC_UTF8 AS NVARCHAR(MAX))
FROM   Tickets.TicketClass
WHERE  ticketClassName_A LIKE N'%Ã˜%' OR ticketClassName_A LIKE N'%Ã™%'
UNION ALL
SELECT 'Service', serviceID,
       serviceName_A,
       CAST(CAST(CAST(CAST(serviceName_A COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX)) AS VARBINARY(MAX)) AS VARCHAR(MAX)) COLLATE Latin1_General_100_CI_AI_SC_UTF8 AS NVARCHAR(MAX))
FROM   Tickets.Service
WHERE  serviceName_A LIKE N'%Ã˜%' OR serviceName_A LIKE N'%Ã™%'
UNION ALL
SELECT 'PauseReason', pauseReasonID,
       pauseReasonName_A,
       CAST(CAST(CAST(CAST(pauseReasonName_A COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX)) AS VARBINARY(MAX)) AS VARCHAR(MAX)) COLLATE Latin1_General_100_CI_AI_SC_UTF8 AS NVARCHAR(MAX))
FROM   Tickets.PauseReason
WHERE  pauseReasonName_A LIKE N'%Ã˜%' OR pauseReasonName_A LIKE N'%Ã™%'
UNION ALL
SELECT 'ArbitrationReason', arbitrationReasonID,
       arbitrationReasonName_A,
       CAST(CAST(CAST(CAST(arbitrationReasonName_A COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX)) AS VARBINARY(MAX)) AS VARCHAR(MAX)) COLLATE Latin1_General_100_CI_AI_SC_UTF8 AS NVARCHAR(MAX))
FROM   Tickets.ArbitrationReason
WHERE  arbitrationReasonName_A LIKE N'%Ã˜%' OR arbitrationReasonName_A LIKE N'%Ã™%'
UNION ALL
SELECT 'QualityReviewResult', qualityReviewResultID,
       qualityReviewResultName_A,
       CAST(CAST(CAST(CAST(qualityReviewResultName_A COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX)) AS VARBINARY(MAX)) AS VARCHAR(MAX)) COLLATE Latin1_General_100_CI_AI_SC_UTF8 AS NVARCHAR(MAX))
FROM   Tickets.QualityReviewResult
WHERE  qualityReviewResultName_A LIKE N'%Ã˜%' OR qualityReviewResultName_A LIKE N'%Ã™%';

GO

-- =====================================================================
-- PART 3 â€” UPDATE: Fix the data permanently
-- =====================================================================
-- *** ONLY RUN THIS AFTER VERIFYING THE PREVIEW ABOVE ***
-- Uses a transaction so you can ROLLBACK if something looks wrong.
-- =====================================================================

PRINT '';
PRINT '===== UPDATE: Fixing Mojibake data =====';

BEGIN TRANSACTION;

-- â”€â”€ Tickets.Ticket â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- title
UPDATE Tickets.Ticket
SET    title = CAST(
         CAST(
           CAST(
             CAST(title COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX))
           AS VARBINARY(MAX))
         AS VARCHAR(MAX))
         COLLATE Latin1_General_100_CI_AI_SC_UTF8
       AS NVARCHAR(MAX))
WHERE  title LIKE N'%Ã˜%' OR title LIKE N'%Ã™%';

PRINT 'Updated Ticket.title: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

-- description_
UPDATE Tickets.Ticket
SET    description_ = CAST(
         CAST(
           CAST(
             CAST(description_ COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX))
           AS VARBINARY(MAX))
         AS VARCHAR(MAX))
         COLLATE Latin1_General_100_CI_AI_SC_UTF8
       AS NVARCHAR(MAX))
WHERE  description_ LIKE N'%Ã˜%' OR description_ LIKE N'%Ã™%';

PRINT 'Updated Ticket.description_: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

-- locationArea
UPDATE Tickets.Ticket
SET    locationArea = CAST(
         CAST(
           CAST(
             CAST(locationArea COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX))
           AS VARBINARY(MAX))
         AS VARCHAR(MAX))
         COLLATE Latin1_General_100_CI_AI_SC_UTF8
       AS NVARCHAR(MAX))
WHERE  locationArea LIKE N'%Ã˜%' OR locationArea LIKE N'%Ã™%';

PRINT 'Updated Ticket.locationArea: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

-- â”€â”€ Tickets.TicketHistory â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

UPDATE Tickets.TicketHistory
SET    notes = CAST(
         CAST(
           CAST(
             CAST(notes COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX))
           AS VARBINARY(MAX))
         AS VARCHAR(MAX))
         COLLATE Latin1_General_100_CI_AI_SC_UTF8
       AS NVARCHAR(MAX))
WHERE  notes LIKE N'%Ã˜%' OR notes LIKE N'%Ã™%';

PRINT 'Updated TicketHistory.notes: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

-- â”€â”€ Tickets.TicketPauseSession â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

UPDATE Tickets.TicketPauseSession
SET    pauseNotes = CAST(
         CAST(
           CAST(
             CAST(pauseNotes COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX))
           AS VARBINARY(MAX))
         AS VARCHAR(MAX))
         COLLATE Latin1_General_100_CI_AI_SC_UTF8
       AS NVARCHAR(MAX))
WHERE  pauseNotes LIKE N'%Ã˜%' OR pauseNotes LIKE N'%Ã™%';

PRINT 'Updated TicketPauseSession.pauseNotes: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

-- â”€â”€ Tickets.ClarificationRequest â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

UPDATE Tickets.ClarificationRequest
SET    requestNotes = CAST(
         CAST(
           CAST(
             CAST(requestNotes COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX))
           AS VARBINARY(MAX))
         AS VARCHAR(MAX))
         COLLATE Latin1_General_100_CI_AI_SC_UTF8
       AS NVARCHAR(MAX))
WHERE  requestNotes LIKE N'%Ã˜%' OR requestNotes LIKE N'%Ã™%';

PRINT 'Updated ClarificationRequest.requestNotes: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

UPDATE Tickets.ClarificationRequest
SET    responseNotes = CAST(
         CAST(
           CAST(
             CAST(responseNotes COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX))
           AS VARBINARY(MAX))
         AS VARCHAR(MAX))
         COLLATE Latin1_General_100_CI_AI_SC_UTF8
       AS NVARCHAR(MAX))
WHERE  responseNotes LIKE N'%Ã˜%' OR responseNotes LIKE N'%Ã™%';

PRINT 'Updated ClarificationRequest.responseNotes: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

-- â”€â”€ Lookup tables â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

UPDATE Tickets.TicketStatus
SET    ticketStatusName_A = CAST(CAST(CAST(CAST(ticketStatusName_A COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX)) AS VARBINARY(MAX)) AS VARCHAR(MAX)) COLLATE Latin1_General_100_CI_AI_SC_UTF8 AS NVARCHAR(MAX))
WHERE  ticketStatusName_A LIKE N'%Ã˜%' OR ticketStatusName_A LIKE N'%Ã™%';

PRINT 'Updated TicketStatus.ticketStatusName_A: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

UPDATE Tickets.Priority
SET    priorityName_A = CAST(CAST(CAST(CAST(priorityName_A COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX)) AS VARBINARY(MAX)) AS VARCHAR(MAX)) COLLATE Latin1_General_100_CI_AI_SC_UTF8 AS NVARCHAR(MAX))
WHERE  priorityName_A LIKE N'%Ã˜%' OR priorityName_A LIKE N'%Ã™%';

PRINT 'Updated Priority.priorityName_A: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

UPDATE Tickets.TicketClass
SET    ticketClassName_A = CAST(CAST(CAST(CAST(ticketClassName_A COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX)) AS VARBINARY(MAX)) AS VARCHAR(MAX)) COLLATE Latin1_General_100_CI_AI_SC_UTF8 AS NVARCHAR(MAX))
WHERE  ticketClassName_A LIKE N'%Ã˜%' OR ticketClassName_A LIKE N'%Ã™%';

PRINT 'Updated TicketClass.ticketClassName_A: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

UPDATE Tickets.Service
SET    serviceName_A = CAST(CAST(CAST(CAST(serviceName_A COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX)) AS VARBINARY(MAX)) AS VARCHAR(MAX)) COLLATE Latin1_General_100_CI_AI_SC_UTF8 AS NVARCHAR(MAX))
WHERE  serviceName_A LIKE N'%Ã˜%' OR serviceName_A LIKE N'%Ã™%';

PRINT 'Updated Service.serviceName_A: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

UPDATE Tickets.PauseReason
SET    pauseReasonName_A = CAST(CAST(CAST(CAST(pauseReasonName_A COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX)) AS VARBINARY(MAX)) AS VARCHAR(MAX)) COLLATE Latin1_General_100_CI_AI_SC_UTF8 AS NVARCHAR(MAX))
WHERE  pauseReasonName_A LIKE N'%Ã˜%' OR pauseReasonName_A LIKE N'%Ã™%';

PRINT 'Updated PauseReason.pauseReasonName_A: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

UPDATE Tickets.ArbitrationReason
SET    arbitrationReasonName_A = CAST(CAST(CAST(CAST(arbitrationReasonName_A COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX)) AS VARBINARY(MAX)) AS VARCHAR(MAX)) COLLATE Latin1_General_100_CI_AI_SC_UTF8 AS NVARCHAR(MAX))
WHERE  arbitrationReasonName_A LIKE N'%Ã˜%' OR arbitrationReasonName_A LIKE N'%Ã™%';

PRINT 'Updated ArbitrationReason.arbitrationReasonName_A: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

UPDATE Tickets.QualityReviewResult
SET    qualityReviewResultName_A = CAST(CAST(CAST(CAST(qualityReviewResultName_A COLLATE SQL_Latin1_General_CP1_CI_AS AS VARCHAR(MAX)) AS VARBINARY(MAX)) AS VARCHAR(MAX)) COLLATE Latin1_General_100_CI_AI_SC_UTF8 AS NVARCHAR(MAX))
WHERE  qualityReviewResultName_A LIKE N'%Ã˜%' OR qualityReviewResultName_A LIKE N'%Ã™%';

PRINT 'Updated QualityReviewResult.qualityReviewResultName_A: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

-- =====================================================================
-- PART 4 â€” VERIFY: Quick spot-check after update
-- =====================================================================

PRINT '';
PRINT '===== VERIFICATION =====';

SELECT ticketID, title, LEFT(description_, 100) AS description_, locationArea
FROM   Tickets.Ticket
WHERE  ticketID <= 10;

SELECT ticketStatusCode, ticketStatusName_A FROM Tickets.TicketStatus;
SELECT priorityCode, priorityName_A        FROM Tickets.Priority;
SELECT ticketClassID, ticketClassName_A     FROM Tickets.TicketClass;
SELECT serviceID, serviceName_A             FROM Tickets.Service;

-- =====================================================================
-- If the Arabic text looks correct above â†’ COMMIT
-- If something went wrong           â†’ ROLLBACK
-- =====================================================================

-- COMMIT;
-- ROLLBACK;

