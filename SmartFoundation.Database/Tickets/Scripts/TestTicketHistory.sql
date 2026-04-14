-- ============================================================================
-- Test: TicketHistory Creation-Event Logging
-- Covers T046: verify TicketHistory receives correct creation events
-- Prerequisites: SeedLookups.sql executed, at least one active Service exists
-- ============================================================================

SET NOCOUNT ON;

DECLARE @errors INT = 0;
DECLARE @result TABLE (IsSuccessful INT, Message_ NVARCHAR(MAX), NewTicketID BIGINT, NewTicketNo NVARCHAR(50));
DECLARE @testTicketID BIGINT = NULL;
DECLARE @testServiceID BIGINT = NULL;

PRINT N'=== TestTicketHistory: Creation-Event Logging ===';
PRINT N'';

-- ============================================================================
-- Cleanup any prior test residue
-- ============================================================================
DELETE FROM [Tickets].[TicketHistory] WHERE [entryData] = N'TEST';
DELETE FROM [Tickets].[Ticket] WHERE [entryData] = N'TEST';
DELETE FROM [Tickets].[Service] WHERE [serviceCode] = N'TEST_HIST_SVC';

-- ============================================================================
-- Setup: create a test service
-- ============================================================================
DECLARE @svcResult TABLE (IsSuccessful INT, Message_ NVARCHAR(MAX));
INSERT INTO @svcResult
EXEC [Tickets].[ServiceSP]
      @Action = N'INSERT_SERVICE'
    , @serviceCode = N'TEST_HIST_SVC'
    , @serviceName_A = N'خدمة اختبار التاريخ'
    , @serviceName_E = N'Test History Service'
    , @serviceDesc = N'Service for history tests'
    , @idaraID_FK = 1
    , @ticketClassID_FK = 1
    , @defaultPriorityID_FK = 3
    , @entryData = N'TEST'
    , @hostName = N'TEST-HOST';

SELECT @testServiceID = [serviceID] FROM [Tickets].[Service] WHERE [serviceCode] = N'TEST_HIST_SVC' AND [serviceActive] = 1;
DELETE FROM @svcResult;

-- ============================================================================
-- Setup: create a test ticket
-- ============================================================================
INSERT INTO @result
EXEC [Tickets].[TicketSP]
      @Action = N'INSERT_TICKET'
    , @ticketClassID_FK = 1
    , @requesterTypeID_FK = 2
    , @requesterUserID_FK = 42
    , @serviceID_FK = @testServiceID
    , @title = N'اختبار سجل التاريخ'
    , @description_ = N'Test ticket for history verification'
    , @suggestedPriorityID_FK = 3
    , @idaraID_FK = 1
    , @isOtherService = 0
    , @entryData = N'TEST'
    , @hostName = N'TEST-HOST';

SELECT @testTicketID = NewTicketID FROM @result WHERE IsSuccessful = 1;
DELETE FROM @result;

-- ============================================================================
-- TEST 1: TicketHistory row exists with action CREATED
-- ============================================================================
PRINT N'--- TEST 1: TicketHistory row with actionTypeCode = CREATED ---';

IF EXISTS (
    SELECT 1 FROM [Tickets].[TicketHistory]
    WHERE [ticketID_FK] = @testTicketID
      AND [actionTypeCode] = N'CREATED'
)
    PRINT N'  PASS: CREATED history entry found';
ELSE
BEGIN PRINT N'  FAIL: No CREATED history entry found'; SET @errors = @errors + 1; END

-- ============================================================================
-- TEST 2: oldStatusID_FK is NULL (no previous status)
-- ============================================================================
PRINT N'--- TEST 2: oldStatusID_FK is NULL for creation event ---';

IF EXISTS (
    SELECT 1 FROM [Tickets].[TicketHistory]
    WHERE [ticketID_FK] = @testTicketID
      AND [actionTypeCode] = N'CREATED'
      AND [oldStatusID_FK] IS NULL
)
    PRINT N'  PASS: oldStatusID_FK is NULL';
ELSE
BEGIN PRINT N'  FAIL: oldStatusID_FK should be NULL for creation'; SET @errors = @errors + 1; END

-- ============================================================================
-- TEST 3: newStatusID_FK = NEW status
-- ============================================================================
PRINT N'--- TEST 3: newStatusID_FK points to NEW status ---';

DECLARE @newStatusID INT;
SELECT @newStatusID = [newStatusID_FK]
FROM [Tickets].[TicketHistory]
WHERE [ticketID_FK] = @testTicketID
  AND [actionTypeCode] = N'CREATED';

IF @newStatusID IS NOT NULL AND EXISTS (
    SELECT 1 FROM [Tickets].[TicketStatus]
    WHERE [ticketStatusID] = @newStatusID
      AND [ticketStatusCode] = N'NEW'
)
    PRINT N'  PASS: newStatusID_FK = NEW status';
ELSE
BEGIN PRINT N'  FAIL: newStatusID_FK does not point to NEW status'; SET @errors = @errors + 1; END

-- ============================================================================
-- TEST 4: idaraID_FK matches ticket
-- ============================================================================
PRINT N'--- TEST 4: idaraID_FK matches ticket ---';

IF EXISTS (
    SELECT 1 FROM [Tickets].[TicketHistory] th
    INNER JOIN [Tickets].[Ticket] t ON th.[ticketID_FK] = t.[ticketID]
    WHERE th.[ticketID_FK] = @testTicketID
      AND th.[actionTypeCode] = N'CREATED'
      AND th.[idaraID_FK] = t.[idaraID_FK]
)
    PRINT N'  PASS: idaraID_FK matches ticket';
ELSE
BEGIN PRINT N'  FAIL: idaraID_FK mismatch'; SET @errors = @errors + 1; END

-- ============================================================================
-- TEST 5: performerUserID matches requesterUserID_FK
-- ============================================================================
PRINT N'--- TEST 5: performerUserID matches requesterUserID_FK ---';

IF EXISTS (
    SELECT 1 FROM [Tickets].[TicketHistory] th
    INNER JOIN [Tickets].[Ticket] t ON th.[ticketID_FK] = t.[ticketID]
    WHERE th.[ticketID_FK] = @testTicketID
      AND th.[actionTypeCode] = N'CREATED'
      AND th.[performerUserID] = t.[requesterUserID_FK]
)
    PRINT N'  PASS: performerUserID = requesterUserID_FK';
ELSE
BEGIN PRINT N'  FAIL: performerUserID mismatch'; SET @errors = @errors + 1; END

-- ============================================================================
-- TEST 6: actionDate is recent (within last 60 seconds)
-- ============================================================================
PRINT N'--- TEST 6: actionDate is recent ---';

IF EXISTS (
    SELECT 1 FROM [Tickets].[TicketHistory]
    WHERE [ticketID_FK] = @testTicketID
      AND [actionTypeCode] = N'CREATED'
      AND DATEDIFF(SECOND, [actionDate], GETDATE()) < 60
)
    PRINT N'  PASS: actionDate is recent';
ELSE
BEGIN PRINT N'  FAIL: actionDate is not recent'; SET @errors = @errors + 1; END

-- ============================================================================
-- TEST 7: Only one creation event per ticket
-- ============================================================================
PRINT N'--- TEST 7: Single creation event per ticket ---';

DECLARE @createCount INT;
SELECT @createCount = COUNT(*)
FROM [Tickets].[TicketHistory]
WHERE [ticketID_FK] = @testTicketID
  AND [actionTypeCode] = N'CREATED';

IF @createCount = 1
    PRINT N'  PASS: Exactly one CREATED entry';
ELSE
BEGIN PRINT N'  FAIL: Expected 1 CREATED entry, found ' + CAST(@createCount AS NVARCHAR(10)); SET @errors = @errors + 1; END

-- ============================================================================
-- TEST 8: V_TicketLastAction returns the creation event
-- ============================================================================
PRINT N'--- TEST 8: V_TicketLastAction shows creation event ---';

IF EXISTS (
    SELECT 1 FROM [Tickets].[V_TicketLastAction]
    WHERE [ticketID] = @testTicketID
      AND [actionTypeCode] = N'CREATED'
)
    PRINT N'  PASS: V_TicketLastAction returns creation event';
ELSE
BEGIN PRINT N'  FAIL: V_TicketLastAction missing creation event'; SET @errors = @errors + 1; END

-- ============================================================================
-- Cleanup
-- ============================================================================
DELETE FROM [Tickets].[TicketHistory] WHERE [ticketID_FK] = @testTicketID;
DELETE FROM dbo.AuditLog WHERE TableName = N'[Tickets].[Ticket]' AND RecordID = @testTicketID;
DELETE FROM [Tickets].[Ticket] WHERE [ticketID] = @testTicketID;
DELETE FROM dbo.AuditLog WHERE TableName = N'[Tickets].[Service]' AND RecordID = @testServiceID;
DELETE FROM [Tickets].[Service] WHERE [serviceID] = @testServiceID;

-- ============================================================================
PRINT N'';
IF @errors = 0
    PRINT N'=== TestTicketHistory: ALL TESTS PASSED ===';
ELSE
    PRINT N'=== TestTicketHistory: ' + CAST(@errors AS NVARCHAR(10)) + N' TEST(S) FAILED ===';
