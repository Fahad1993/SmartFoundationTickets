-- ============================================================================
-- Smoke Test: Lookup Uniqueness and Seed Integrity
-- Validates all Tickets lookup tables have unique codes,
-- expected row counts, required fields, active flags, and entry metadata
-- ============================================================================

SET NOCOUNT ON;

DECLARE @errors INT = 0;

-- ============================================================================
-- Helper: report PASS / FAIL
-- ============================================================================
DECLARE @label NVARCHAR(200);

-- ============================================================================
-- [Tickets].[TicketStatus] — Expected 11 rows
-- ============================================================================
SET @label = N'[Tickets].[TicketStatus]';
PRINT N'--- ' + @label + N' ---';

IF NOT EXISTS (SELECT 1 FROM [Tickets].[TicketStatus] WHERE [ticketStatusCode] = N'NEW')
BEGIN PRINT N'  FAIL: Missing sentinel code NEW'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: sentinel code NEW found';

IF EXISTS (SELECT [ticketStatusCode], COUNT(*) FROM [Tickets].[TicketStatus] GROUP BY [ticketStatusCode] HAVING COUNT(*) > 1)
BEGIN PRINT N'  FAIL: Duplicate ticketStatusCode values'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: ticketStatusCode unique';

IF (SELECT COUNT(*) FROM [Tickets].[TicketStatus]) <> 11
BEGIN PRINT N'  FAIL: Expected 11 rows, found ' + CAST((SELECT COUNT(*) FROM [Tickets].[TicketStatus]) AS NVARCHAR(10)); SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: row count = 11';

IF EXISTS (SELECT 1 FROM [Tickets].[TicketStatus] WHERE [ticketStatusCode] IS NULL OR [ticketStatusName_E] IS NULL)
BEGIN PRINT N'  FAIL: NULL found in required columns (ticketStatusCode, ticketStatusName_E)'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: required columns populated';

IF NOT EXISTS (SELECT 1 FROM [Tickets].[TicketStatus] WHERE [ticketStatusActive] = 1)
BEGIN PRINT N'  FAIL: No active rows'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: at least one active row';

IF EXISTS (SELECT 1 FROM [Tickets].[TicketStatus] WHERE [entryData] IS NULL OR [hostName] IS NULL)
BEGIN PRINT N'  FAIL: NULL entryData or hostName'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: entry metadata populated';

-- ============================================================================
-- [Tickets].[TicketClass] — Expected 5 rows
-- ============================================================================
SET @label = N'[Tickets].[TicketClass]';
PRINT N'--- ' + @label + N' ---';

IF NOT EXISTS (SELECT 1 FROM [Tickets].[TicketClass] WHERE [ticketClassCode] = N'MAINTENANCE')
BEGIN PRINT N'  FAIL: Missing sentinel code MAINTENANCE'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: sentinel code MAINTENANCE found';

IF EXISTS (SELECT [ticketClassCode], COUNT(*) FROM [Tickets].[TicketClass] GROUP BY [ticketClassCode] HAVING COUNT(*) > 1)
BEGIN PRINT N'  FAIL: Duplicate ticketClassCode values'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: ticketClassCode unique';

IF (SELECT COUNT(*) FROM [Tickets].[TicketClass]) <> 5
BEGIN PRINT N'  FAIL: Expected 5 rows, found ' + CAST((SELECT COUNT(*) FROM [Tickets].[TicketClass]) AS NVARCHAR(10)); SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: row count = 5';

IF EXISTS (SELECT 1 FROM [Tickets].[TicketClass] WHERE [ticketClassCode] IS NULL OR [ticketClassName_E] IS NULL)
BEGIN PRINT N'  FAIL: NULL found in required columns (ticketClassCode, ticketClassName_E)'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: required columns populated';

IF NOT EXISTS (SELECT 1 FROM [Tickets].[TicketClass] WHERE [ticketClassActive] = 1)
BEGIN PRINT N'  FAIL: No active rows'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: at least one active row';

IF EXISTS (SELECT 1 FROM [Tickets].[TicketClass] WHERE [entryData] IS NULL OR [hostName] IS NULL)
BEGIN PRINT N'  FAIL: NULL entryData or hostName'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: entry metadata populated';

-- ============================================================================
-- [Tickets].[Priority] — Expected 5 rows, priorityLevel unique
-- ============================================================================
SET @label = N'[Tickets].[Priority]';
PRINT N'--- ' + @label + N' ---';

IF NOT EXISTS (SELECT 1 FROM [Tickets].[Priority] WHERE [priorityCode] = N'CRITICAL')
BEGIN PRINT N'  FAIL: Missing sentinel code CRITICAL'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: sentinel code CRITICAL found';

IF EXISTS (SELECT [priorityCode], COUNT(*) FROM [Tickets].[Priority] GROUP BY [priorityCode] HAVING COUNT(*) > 1)
BEGIN PRINT N'  FAIL: Duplicate priorityCode values'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: priorityCode unique';

IF EXISTS (SELECT [priorityLevel], COUNT(*) FROM [Tickets].[Priority] WHERE [priorityLevel] IS NOT NULL GROUP BY [priorityLevel] HAVING COUNT(*) > 1)
BEGIN PRINT N'  FAIL: Duplicate priorityLevel values'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: priorityLevel unique';

IF (SELECT COUNT(*) FROM [Tickets].[Priority]) <> 5
BEGIN PRINT N'  FAIL: Expected 5 rows, found ' + CAST((SELECT COUNT(*) FROM [Tickets].[Priority]) AS NVARCHAR(10)); SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: row count = 5';

IF EXISTS (SELECT 1 FROM [Tickets].[Priority] WHERE [priorityCode] IS NULL OR [priorityName_E] IS NULL)
BEGIN PRINT N'  FAIL: NULL found in required columns (priorityCode, priorityName_E)'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: required columns populated';

IF EXISTS (SELECT 1 FROM [Tickets].[Priority] WHERE [priorityLevel] IS NULL)
BEGIN PRINT N'  FAIL: NULL priorityLevel found'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: priorityLevel populated for all rows';

IF NOT EXISTS (SELECT 1 FROM [Tickets].[Priority] WHERE [priorityActive] = 1)
BEGIN PRINT N'  FAIL: No active rows'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: at least one active row';

IF EXISTS (SELECT 1 FROM [Tickets].[Priority] WHERE [entryData] IS NULL OR [hostName] IS NULL)
BEGIN PRINT N'  FAIL: NULL entryData or hostName'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: entry metadata populated';

-- ============================================================================
-- [Tickets].[RequesterType] — Expected 5 rows
-- ============================================================================
SET @label = N'[Tickets].[RequesterType]';
PRINT N'--- ' + @label + N' ---';

IF NOT EXISTS (SELECT 1 FROM [Tickets].[RequesterType] WHERE [requesterTypeCode] = N'RESIDENT')
BEGIN PRINT N'  FAIL: Missing sentinel code RESIDENT'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: sentinel code RESIDENT found';

IF EXISTS (SELECT [requesterTypeCode], COUNT(*) FROM [Tickets].[RequesterType] GROUP BY [requesterTypeCode] HAVING COUNT(*) > 1)
BEGIN PRINT N'  FAIL: Duplicate requesterTypeCode values'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: requesterTypeCode unique';

IF (SELECT COUNT(*) FROM [Tickets].[RequesterType]) <> 5
BEGIN PRINT N'  FAIL: Expected 5 rows, found ' + CAST((SELECT COUNT(*) FROM [Tickets].[RequesterType]) AS NVARCHAR(10)); SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: row count = 5';

IF EXISTS (SELECT 1 FROM [Tickets].[RequesterType] WHERE [requesterTypeCode] IS NULL OR [requesterTypeName_E] IS NULL)
BEGIN PRINT N'  FAIL: NULL found in required columns (requesterTypeCode, requesterTypeName_E)'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: required columns populated';

IF NOT EXISTS (SELECT 1 FROM [Tickets].[RequesterType] WHERE [requesterTypeActive] = 1)
BEGIN PRINT N'  FAIL: No active rows'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: at least one active row';

IF EXISTS (SELECT 1 FROM [Tickets].[RequesterType] WHERE [entryData] IS NULL OR [hostName] IS NULL)
BEGIN PRINT N'  FAIL: NULL entryData or hostName'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: entry metadata populated';

-- ============================================================================
-- [Tickets].[PauseReason] — Expected 5 rows
-- ============================================================================
SET @label = N'[Tickets].[PauseReason]';
PRINT N'--- ' + @label + N' ---';

IF NOT EXISTS (SELECT 1 FROM [Tickets].[PauseReason] WHERE [pauseReasonCode] = N'CHILD_DEPENDENCY')
BEGIN PRINT N'  FAIL: Missing sentinel code CHILD_DEPENDENCY'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: sentinel code CHILD_DEPENDENCY found';

IF EXISTS (SELECT [pauseReasonCode], COUNT(*) FROM [Tickets].[PauseReason] GROUP BY [pauseReasonCode] HAVING COUNT(*) > 1)
BEGIN PRINT N'  FAIL: Duplicate pauseReasonCode values'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: pauseReasonCode unique';

IF (SELECT COUNT(*) FROM [Tickets].[PauseReason]) <> 5
BEGIN PRINT N'  FAIL: Expected 5 rows, found ' + CAST((SELECT COUNT(*) FROM [Tickets].[PauseReason]) AS NVARCHAR(10)); SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: row count = 5';

IF EXISTS (SELECT 1 FROM [Tickets].[PauseReason] WHERE [pauseReasonCode] IS NULL OR [pauseReasonName_E] IS NULL)
BEGIN PRINT N'  FAIL: NULL found in required columns (pauseReasonCode, pauseReasonName_E)'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: required columns populated';

IF NOT EXISTS (SELECT 1 FROM [Tickets].[PauseReason] WHERE [pauseReasonActive] = 1)
BEGIN PRINT N'  FAIL: No active rows'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: at least one active row';

IF EXISTS (SELECT 1 FROM [Tickets].[PauseReason] WHERE [entryData] IS NULL OR [hostName] IS NULL)
BEGIN PRINT N'  FAIL: NULL entryData or hostName'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: entry metadata populated';

-- ============================================================================
-- [Tickets].[ArbitrationReason] — Expected 5 rows
-- ============================================================================
SET @label = N'[Tickets].[ArbitrationReason]';
PRINT N'--- ' + @label + N' ---';

IF NOT EXISTS (SELECT 1 FROM [Tickets].[ArbitrationReason] WHERE [arbitrationReasonCode] = N'WRONG_SECTION')
BEGIN PRINT N'  FAIL: Missing sentinel code WRONG_SECTION'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: sentinel code WRONG_SECTION found';

IF EXISTS (SELECT [arbitrationReasonCode], COUNT(*) FROM [Tickets].[ArbitrationReason] GROUP BY [arbitrationReasonCode] HAVING COUNT(*) > 1)
BEGIN PRINT N'  FAIL: Duplicate arbitrationReasonCode values'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: arbitrationReasonCode unique';

IF (SELECT COUNT(*) FROM [Tickets].[ArbitrationReason]) <> 5
BEGIN PRINT N'  FAIL: Expected 5 rows, found ' + CAST((SELECT COUNT(*) FROM [Tickets].[ArbitrationReason]) AS NVARCHAR(10)); SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: row count = 5';

IF EXISTS (SELECT 1 FROM [Tickets].[ArbitrationReason] WHERE [arbitrationReasonCode] IS NULL OR [arbitrationReasonName_E] IS NULL)
BEGIN PRINT N'  FAIL: NULL found in required columns (arbitrationReasonCode, arbitrationReasonName_E)'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: required columns populated';

IF NOT EXISTS (SELECT 1 FROM [Tickets].[ArbitrationReason] WHERE [arbitrationReasonActive] = 1)
BEGIN PRINT N'  FAIL: No active rows'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: at least one active row';

IF EXISTS (SELECT 1 FROM [Tickets].[ArbitrationReason] WHERE [entryData] IS NULL OR [hostName] IS NULL)
BEGIN PRINT N'  FAIL: NULL entryData or hostName'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: entry metadata populated';

-- ============================================================================
-- [Tickets].[ClarificationReason] — Expected 5 rows
-- ============================================================================
SET @label = N'[Tickets].[ClarificationReason]';
PRINT N'--- ' + @label + N' ---';

IF NOT EXISTS (SELECT 1 FROM [Tickets].[ClarificationReason] WHERE [clarificationReasonCode] = N'MISSING_LOCATION')
BEGIN PRINT N'  FAIL: Missing sentinel code MISSING_LOCATION'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: sentinel code MISSING_LOCATION found';

IF EXISTS (SELECT [clarificationReasonCode], COUNT(*) FROM [Tickets].[ClarificationReason] GROUP BY [clarificationReasonCode] HAVING COUNT(*) > 1)
BEGIN PRINT N'  FAIL: Duplicate clarificationReasonCode values'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: clarificationReasonCode unique';

IF (SELECT COUNT(*) FROM [Tickets].[ClarificationReason]) <> 5
BEGIN PRINT N'  FAIL: Expected 5 rows, found ' + CAST((SELECT COUNT(*) FROM [Tickets].[ClarificationReason]) AS NVARCHAR(10)); SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: row count = 5';

IF EXISTS (SELECT 1 FROM [Tickets].[ClarificationReason] WHERE [clarificationReasonCode] IS NULL OR [clarificationReasonName_E] IS NULL)
BEGIN PRINT N'  FAIL: NULL found in required columns (clarificationReasonCode, clarificationReasonName_E)'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: required columns populated';

IF NOT EXISTS (SELECT 1 FROM [Tickets].[ClarificationReason] WHERE [clarificationReasonActive] = 1)
BEGIN PRINT N'  FAIL: No active rows'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: at least one active row';

IF EXISTS (SELECT 1 FROM [Tickets].[ClarificationReason] WHERE [entryData] IS NULL OR [hostName] IS NULL)
BEGIN PRINT N'  FAIL: NULL entryData or hostName'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: entry metadata populated';

-- ============================================================================
-- [Tickets].[QualityReviewResult] — Expected 5 rows
-- ============================================================================
SET @label = N'[Tickets].[QualityReviewResult]';
PRINT N'--- ' + @label + N' ---';

IF NOT EXISTS (SELECT 1 FROM [Tickets].[QualityReviewResult] WHERE [qualityReviewResultCode] = N'APPROVED')
BEGIN PRINT N'  FAIL: Missing sentinel code APPROVED'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: sentinel code APPROVED found';

IF EXISTS (SELECT [qualityReviewResultCode], COUNT(*) FROM [Tickets].[QualityReviewResult] GROUP BY [qualityReviewResultCode] HAVING COUNT(*) > 1)
BEGIN PRINT N'  FAIL: Duplicate qualityReviewResultCode values'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: qualityReviewResultCode unique';

IF (SELECT COUNT(*) FROM [Tickets].[QualityReviewResult]) <> 5
BEGIN PRINT N'  FAIL: Expected 5 rows, found ' + CAST((SELECT COUNT(*) FROM [Tickets].[QualityReviewResult]) AS NVARCHAR(10)); SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: row count = 5';

IF EXISTS (SELECT 1 FROM [Tickets].[QualityReviewResult] WHERE [qualityReviewResultCode] IS NULL OR [qualityReviewResultName_E] IS NULL)
BEGIN PRINT N'  FAIL: NULL found in required columns (qualityReviewResultCode, qualityReviewResultName_E)'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: required columns populated';

IF NOT EXISTS (SELECT 1 FROM [Tickets].[QualityReviewResult] WHERE [qualityReviewResultActive] = 1)
BEGIN PRINT N'  FAIL: No active rows'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: at least one active row';

IF EXISTS (SELECT 1 FROM [Tickets].[QualityReviewResult] WHERE [entryData] IS NULL OR [hostName] IS NULL)
BEGIN PRINT N'  FAIL: NULL entryData or hostName'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: entry metadata populated';

-- ============================================================================
-- Cross-table integrity: all seed rows use entryData = 'SEED'
-- ============================================================================
PRINT N'';
PRINT N'--- Cross-table: entryData = SEED consistency ---';

IF EXISTS (SELECT 1 FROM [Tickets].[TicketStatus]         WHERE [entryData] <> N'SEED')
   OR EXISTS (SELECT 1 FROM [Tickets].[TicketClass]        WHERE [entryData] <> N'SEED')
   OR EXISTS (SELECT 1 FROM [Tickets].[Priority]           WHERE [entryData] <> N'SEED')
   OR EXISTS (SELECT 1 FROM [Tickets].[RequesterType]      WHERE [entryData] <> N'SEED')
   OR EXISTS (SELECT 1 FROM [Tickets].[PauseReason]        WHERE [entryData] <> N'SEED')
   OR EXISTS (SELECT 1 FROM [Tickets].[ArbitrationReason]  WHERE [entryData] <> N'SEED')
   OR EXISTS (SELECT 1 FROM [Tickets].[ClarificationReason] WHERE [entryData] <> N'SEED')
   OR EXISTS (SELECT 1 FROM [Tickets].[QualityReviewResult] WHERE [entryData] <> N'SEED')
BEGIN PRINT N'  FAIL: Non-SEED entryData found in lookup tables'; SET @errors = @errors + 1; END
ELSE PRINT N'  PASS: all lookup rows have entryData = SEED';

-- ============================================================================
-- Summary
-- ============================================================================
PRINT N'';
IF @errors = 0
    PRINT N'=== ALL LOOKUP SMOKE TESTS PASSED ===';
ELSE
    PRINT N'=== ' + CAST(@errors AS NVARCHAR(10)) + N' LOOKUP TEST(S) FAILED ===';
