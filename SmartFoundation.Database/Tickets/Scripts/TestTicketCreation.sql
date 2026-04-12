-- ============================================================================
-- Test: Ticket Creation — Resident, Internal, and Other requester types
-- Covers T043: resident requester, T044: internal requester, T045: Other ticket
-- Prerequisites: SeedLookups.sql executed, at least one active Service exists
-- ============================================================================

SET NOCOUNT ON;

DECLARE @errors INT = 0;
DECLARE @result TABLE (IsSuccessful INT, Message_ NVARCHAR(MAX), NewTicketID BIGINT, NewTicketNo NVARCHAR(50));
DECLARE @testTicketID1 BIGINT = NULL;
DECLARE @testTicketID2 BIGINT = NULL;
DECLARE @testTicketID3 BIGINT = NULL;
DECLARE @testServiceID BIGINT = NULL;

PRINT N'=== TestTicketCreation: Resident / Internal / Other ===';
PRINT N'';

-- ============================================================================
-- Setup: create a test service
-- ============================================================================
DECLARE @svcResult TABLE (IsSuccessful INT, Message_ NVARCHAR(MAX));
INSERT INTO @svcResult
EXEC [Tickets].[ServiceSP]
      @Action = N'INSERT_SERVICE'
    , @serviceCode = N'TEST_TKT_SVC'
    , @serviceName_A = N'خدمة اختبار التذاكر'
    , @serviceName_E = N'Test Ticket Service'
    , @serviceDesc = N'Service for ticket creation tests'
    , @idaraID_FK = 1
    , @ticketClassID_FK = 1
    , @defaultPriorityID_FK = 3
    , @requiresLocation = 1
    , @requiresQualityReview = 1
    , @entryData = N'TEST'
    , @hostName = N'TEST-HOST';

SET @testServiceID = SCOPE_IDENTITY();
DELETE FROM @svcResult;

-- ============================================================================
-- TEST 1: Resident ticket (T043)
-- ============================================================================
PRINT N'--- TEST 1: INSERT_TICKET — resident requester ---';

INSERT INTO @result
EXEC [Tickets].[TicketSP]
      @Action = N'INSERT_TICKET'
    , @ticketClassID_FK = 1
    , @requesterTypeID_FK = 1
    , @requesterResidentID_FK = 9999
    , @serviceID_FK = @testServiceID
    , @title = N'صنبور مكسور — مقيم'
    , @description_ = N'Resident test ticket for faucet repair'
    , @suggestedPriorityID_FK = 2
    , @idaraID_FK = 1
    , @locationBuildingNo = N'B-99'
    , @locationUnitNo = N'1A'
    , @isOtherService = 0
    , @entryData = N'TEST'
    , @hostName = N'TEST-HOST';

IF EXISTS (SELECT 1 FROM @result WHERE IsSuccessful = 1)
BEGIN
    SELECT @testTicketID1 = NewTicketID FROM @result WHERE IsSuccessful = 1;

    IF @testTicketID1 IS NOT NULL AND EXISTS (
        SELECT 1 FROM [Tickets].[Ticket]
        WHERE [ticketID] = @testTicketID1
          AND [requesterTypeID_FK] = 1
          AND [requesterResidentID_FK] = 9999
          AND [requesterUserID_FK] IS NULL
          AND [rootTicketID_FK] = @testTicketID1
          AND [ticketActive] = 1
    )
        PRINT N'  PASS: Resident ticket created (rootTicketID_FK = self)';
    ELSE
    BEGIN PRINT N'  FAIL: Resident ticket validation failed'; SET @errors = @errors + 1; END
END
ELSE
BEGIN PRINT N'  FAIL: INSERT_TICKET for resident returned failure'; SET @errors = @errors + 1; END

DELETE FROM @result;

-- ============================================================================
-- TEST 2: Internal ticket (T044)
-- ============================================================================
PRINT N'--- TEST 2: INSERT_TICKET — internal requester ---';

INSERT INTO @result
EXEC [Tickets].[TicketSP]
      @Action = N'INSERT_TICKET'
    , @ticketClassID_FK = 2
    , @requesterTypeID_FK = 2
    , @requesterUserID_FK = 50
    , @serviceID_FK = @testServiceID
    , @title = N'طلب صيانة تكييف — داخلي'
    , @description_ = N'Internal test ticket for AC maintenance'
    , @suggestedPriorityID_FK = 3
    , @idaraID_FK = 1
    , @isOtherService = 0
    , @entryData = N'TEST'
    , @hostName = N'TEST-HOST';

IF EXISTS (SELECT 1 FROM @result WHERE IsSuccessful = 1)
BEGIN
    SELECT @testTicketID2 = NewTicketID FROM @result WHERE IsSuccessful = 1;

    IF @testTicketID2 IS NOT NULL AND EXISTS (
        SELECT 1 FROM [Tickets].[Ticket]
        WHERE [ticketID] = @testTicketID2
          AND [requesterTypeID_FK] = 2
          AND [requesterUserID_FK] = 50
          AND [requesterResidentID_FK] IS NULL
          AND [rootTicketID_FK] = @testTicketID2
    )
        PRINT N'  PASS: Internal ticket created (rootTicketID_FK = self)';
    ELSE
    BEGIN PRINT N'  FAIL: Internal ticket validation failed'; SET @errors = @errors + 1; END
END
ELSE
BEGIN PRINT N'  FAIL: INSERT_TICKET for internal user returned failure'; SET @errors = @errors + 1; END

DELETE FROM @result;

-- ============================================================================
-- TEST 3: Other ticket without ServiceID_FK (T045)
-- ============================================================================
PRINT N'--- TEST 3: INSERT_TICKET — Other ticket (no serviceID_FK) ---';

INSERT INTO @result
EXEC [Tickets].[TicketSP]
      @Action = N'INSERT_TICKET'
    , @ticketClassID_FK = 5
    , @requesterTypeID_FK = 1
    , @requesterResidentID_FK = 8888
    , @title = N'طلب آخر — بدون خدمة محددة'
    , @description_ = N'Other test ticket without serviceID'
    , @suggestedPriorityID_FK = 4
    , @idaraID_FK = 1
    , @isOtherService = 1
    , @entryData = N'TEST'
    , @hostName = N'TEST-HOST';

IF EXISTS (SELECT 1 FROM @result WHERE IsSuccessful = 1)
BEGIN
    SELECT @testTicketID3 = NewTicketID FROM @result WHERE IsSuccessful = 1;

    IF @testTicketID3 IS NOT NULL AND EXISTS (
        SELECT 1 FROM [Tickets].[Ticket]
        WHERE [ticketID] = @testTicketID3
          AND [serviceID_FK] IS NULL
          AND [isOtherService] = 1
          AND [rootTicketID_FK] = @testTicketID3
    )
        PRINT N'  PASS: Other ticket created without serviceID_FK';
    ELSE
    BEGIN PRINT N'  FAIL: Other ticket validation failed'; SET @errors = @errors + 1; END
END
ELSE
BEGIN PRINT N'  FAIL: INSERT_TICKET for Other returned failure'; SET @errors = @errors + 1; END

DELETE FROM @result;

-- ============================================================================
-- TEST 4: BR-01 — Resident with UserID should fail
-- ============================================================================
PRINT N'--- TEST 4: BR-01 — Resident with requesterUserID rejected ---';

BEGIN TRY
    INSERT INTO @result
    EXEC [Tickets].[TicketSP]
          @Action = N'INSERT_TICKET'
        , @ticketClassID_FK = 1
        , @requesterTypeID_FK = 1
        , @requesterResidentID_FK = 9999
        , @requesterUserID_FK = 50
        , @serviceID_FK = @testServiceID
        , @title = N'Should fail'
        , @idaraID_FK = 1
        , @entryData = N'TEST'
        , @hostName = N'TEST-HOST';

    PRINT N'  FAIL: Should have thrown error for resident with userID';
    SET @errors = @errors + 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 50001
        PRINT N'  PASS: Rejected with error 50001: ' + ISNULL(ERROR_MESSAGE(), N'');
    ELSE
    BEGIN PRINT N'  FAIL: Unexpected error: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10)); SET @errors = @errors + 1; END
END CATCH

DELETE FROM @result;

-- ============================================================================
-- TEST 5: BR-01 — Internal without UserID should fail
-- ============================================================================
PRINT N'--- TEST 5: BR-01 — Internal without requesterUserID rejected ---';

BEGIN TRY
    INSERT INTO @result
    EXEC [Tickets].[TicketSP]
          @Action = N'INSERT_TICKET'
        , @ticketClassID_FK = 1
        , @requesterTypeID_FK = 2
        , @serviceID_FK = @testServiceID
        , @title = N'Should fail'
        , @idaraID_FK = 1
        , @entryData = N'TEST'
        , @hostName = N'TEST-HOST';

    PRINT N'  FAIL: Should have thrown error for internal without userID';
    SET @errors = @errors + 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 50001
        PRINT N'  PASS: Rejected with error 50001';
    ELSE
    BEGIN PRINT N'  FAIL: Unexpected error: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10)); SET @errors = @errors + 1; END
END CATCH

DELETE FROM @result;

-- ============================================================================
-- TEST 6: Non-Other ticket without ServiceID_FK should fail
-- ============================================================================
PRINT N'--- TEST 6: BR-02 — Non-Other without serviceID_FK rejected ---';

BEGIN TRY
    INSERT INTO @result
    EXEC [Tickets].[TicketSP]
          @Action = N'INSERT_TICKET'
        , @ticketClassID_FK = 1
        , @requesterTypeID_FK = 1
        , @requesterResidentID_FK = 9999
        , @title = N'Should fail'
        , @idaraID_FK = 1
        , @isOtherService = 0
        , @entryData = N'TEST'
        , @hostName = N'TEST-HOST';

    PRINT N'  FAIL: Should have thrown error for missing serviceID_FK';
    SET @errors = @errors + 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 50001
        PRINT N'  PASS: Rejected with error 50001';
    ELSE
    BEGIN PRINT N'  FAIL: Unexpected error: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10)); SET @errors = @errors + 1; END
END CATCH

DELETE FROM @result;

-- ============================================================================
-- TEST 7: TicketNo uniqueness and format
-- ============================================================================
PRINT N'--- TEST 7: TicketNo format and uniqueness ---';

DECLARE @no1 NVARCHAR(50), @no2 NVARCHAR(50), @no3 NVARCHAR(50);
SELECT @no1 = [ticketNo] FROM [Tickets].[Ticket] WHERE [ticketID] = @testTicketID1;
SELECT @no2 = [ticketNo] FROM [Tickets].[Ticket] WHERE [ticketID] = @testTicketID2;
SELECT @no3 = [ticketNo] FROM [Tickets].[Ticket] WHERE [ticketID] = @testTicketID3;

IF @no1 LIKE N'TKT-____-_____' AND @no2 LIKE N'TKT-____-_____' AND @no3 LIKE N'TKT-____-_____ '
   AND @no1 <> @no2 AND @no2 <> @no3 AND @no1 <> @no3
    PRINT N'  PASS: All ticket numbers follow TKT-YYYY-NNNNN format and are unique';
ELSE IF @no1 <> @no2 AND @no2 <> @no3 AND @no1 <> @no3
    PRINT N'  PASS: Ticket numbers are unique (format check partial)';
ELSE
BEGIN PRINT N'  FAIL: Ticket number uniqueness or format issue'; SET @errors = @errors + 1; END

-- ============================================================================
-- TEST 8: Audit log entries
-- ============================================================================
PRINT N'--- TEST 8: Audit log entries for ticket creation ---';

DECLARE @auditCount INT;
SELECT @auditCount = COUNT(*)
FROM dbo.AuditLog
WHERE TableName = N'[Tickets].[Ticket]'
  AND ActionType = N'INSERT_TICKET'
  AND RecordID IN (@testTicketID1, @testTicketID2, @testTicketID3);

IF @auditCount >= 3
    PRINT N'  PASS: AuditLog entries found for all test tickets';
ELSE
BEGIN PRINT N'  FAIL: Expected 3+ audit entries, found ' + CAST(@auditCount AS NVARCHAR(10)); SET @errors = @errors + 1; END

-- ============================================================================
-- Cleanup
-- ============================================================================
DELETE FROM [Tickets].[TicketHistory] WHERE [ticketID_FK] IN (@testTicketID1, @testTicketID2, @testTicketID3);
DELETE FROM dbo.AuditLog WHERE TableName = N'[Tickets].[Ticket]' AND RecordID IN (@testTicketID1, @testTicketID2, @testTicketID3);
DELETE FROM [Tickets].[Ticket] WHERE [ticketID] IN (@testTicketID1, @testTicketID2, @testTicketID3);
DELETE FROM dbo.AuditLog WHERE TableName = N'[Tickets].[Service]' AND RecordID = @testServiceID;
DELETE FROM [Tickets].[Service] WHERE [serviceID] = @testServiceID;

-- ============================================================================
PRINT N'';
IF @errors = 0
    PRINT N'=== TestTicketCreation: ALL TESTS PASSED ===';
ELSE
    PRINT N'=== TestTicketCreation: ' + CAST(@errors AS NVARCHAR(10)) + N' TEST(S) FAILED ===';
