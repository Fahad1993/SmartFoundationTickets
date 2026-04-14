-- ============================================================================
-- Test: Service CRUD through [Tickets].[ServiceSP]
-- Covers: INSERT_SERVICE, UPDATE_SERVICE, DELETE_SERVICE
-- Prerequisites: SeedLookups.sql executed, [Tickets] schema exists
-- ============================================================================

SET NOCOUNT ON;

DECLARE @errors INT = 0;
DECLARE @testServiceID BIGINT = NULL;
DECLARE @result TABLE (IsSuccessful INT, Message_ NVARCHAR(MAX));

PRINT N'=== TestServiceSP: INSERT / UPDATE / DELETE ===';
PRINT N'';

-- ============================================================================
-- Cleanup any prior test residue
-- ============================================================================
DELETE FROM [Tickets].[Service] WHERE [serviceCode] = N'TEST_FAUCET';

-- ============================================================================
-- TEST 1: INSERT_SERVICE — valid insert
-- ============================================================================
PRINT N'--- TEST 1: INSERT_SERVICE (valid) ---';

INSERT INTO @result
EXEC [Tickets].[ServiceSP]
      @Action                = N'INSERT_SERVICE'
    , @serviceCode           = N'TEST_FAUCET'
    , @serviceName_A         = N'إصلاح صنبور اختبار'
    , @serviceName_E         = N'Test Faucet Repair'
    , @serviceDesc           = N'Test service for smoke testing'
    , @idaraID_FK            = 1
    , @ticketClassID_FK      = 1
    , @defaultPriorityID_FK  = 3
    , @requiresLocation      = 1
    , @allowsChildTickets    = 0
    , @requiresQualityReview = 1
    , @entryData             = N'TEST'
    , @hostName              = N'TEST-HOST';

IF EXISTS (SELECT 1 FROM @result WHERE IsSuccessful = 1)
BEGIN
    SELECT @testServiceID = [serviceID]
    FROM [Tickets].[Service]
    WHERE [serviceCode] = N'TEST_FAUCET' AND [serviceActive] = 1;

    IF @testServiceID IS NOT NULL
        PRINT N'  PASS: Service inserted with ID = ' + CAST(@testServiceID AS NVARCHAR(20));
    ELSE
    BEGIN PRINT N'  FAIL: Row not found after insert'; SET @errors = @errors + 1; END
END
ELSE
BEGIN PRINT N'  FAIL: INSERT_SERVICE returned failure'; SET @errors = @errors + 1; END

DELETE FROM @result;

-- ============================================================================
-- TEST 2: INSERT_SERVICE — duplicate name rejection
-- ============================================================================
PRINT N'--- TEST 2: INSERT_SERVICE (duplicate name) ---';

BEGIN TRY
    INSERT INTO @result
    EXEC [Tickets].[ServiceSP]
          @Action        = N'INSERT_SERVICE'
        , @serviceName_A = N'إصلاح صنبور اختبار'
        , @idaraID_FK    = 1
        , @entryData     = N'TEST'
        , @hostName      = N'TEST-HOST';

    PRINT N'  FAIL: Duplicate insert should have thrown error 50001';
    SET @errors = @errors + 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 50001
        PRINT N'  PASS: Duplicate rejected with error 50001: ' + ISNULL(ERROR_MESSAGE(), N'');
    ELSE
    BEGIN PRINT N'  FAIL: Unexpected error: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10)) + N' ' + ERROR_MESSAGE(); SET @errors = @errors + 1; END
END CATCH

DELETE FROM @result;

-- ============================================================================
-- TEST 3: INSERT_SERVICE — missing required fields
-- ============================================================================
PRINT N'--- TEST 3: INSERT_SERVICE (missing serviceName_A) ---';

BEGIN TRY
    INSERT INTO @result
    EXEC [Tickets].[ServiceSP]
          @Action = N'INSERT_SERVICE'
        , @entryData = N'TEST'
        , @hostName = N'TEST-HOST';

    PRINT N'  FAIL: Missing fields should have thrown error 50001';
    SET @errors = @errors + 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 50001
        PRINT N'  PASS: Missing field rejected with error 50001';
    ELSE
    BEGIN PRINT N'  FAIL: Unexpected error: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10)); SET @errors = @errors + 1; END
END CATCH

DELETE FROM @result;

-- ============================================================================
-- TEST 4: UPDATE_SERVICE — valid update
-- ============================================================================
PRINT N'--- TEST 4: UPDATE_SERVICE (valid) ---';

INSERT INTO @result
EXEC [Tickets].[ServiceSP]
      @Action        = N'UPDATE_SERVICE'
    , @serviceID     = @testServiceID
    , @serviceName_E = N'Test Faucet Repair UPDATED'
    , @entryData     = N'TEST'
    , @hostName      = N'TEST-HOST';

IF EXISTS (SELECT 1 FROM @result WHERE IsSuccessful = 1)
BEGIN
    IF EXISTS (
        SELECT 1 FROM [Tickets].[Service]
        WHERE [serviceID] = @testServiceID
          AND [serviceName_E] = N'Test Faucet Repair UPDATED'
    )
        PRINT N'  PASS: Service updated successfully';
    ELSE
    BEGIN PRINT N'  FAIL: Update did not take effect'; SET @errors = @errors + 1; END
END
ELSE
BEGIN PRINT N'  FAIL: UPDATE_SERVICE returned failure'; SET @errors = @errors + 1; END

DELETE FROM @result;

-- ============================================================================
-- TEST 5: UPDATE_SERVICE — non-existent ID
-- ============================================================================
PRINT N'--- TEST 5: UPDATE_SERVICE (non-existent ID) ---';

BEGIN TRY
    INSERT INTO @result
    EXEC [Tickets].[ServiceSP]
          @Action    = N'UPDATE_SERVICE'
        , @serviceID = 9999999
        , @entryData = N'TEST'
        , @hostName  = N'TEST-HOST';

    PRINT N'  FAIL: Should have thrown error for non-existent service';
    SET @errors = @errors + 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 50001
        PRINT N'  PASS: Non-existent ID rejected with error 50001';
    ELSE
    BEGIN PRINT N'  FAIL: Unexpected error: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10)); SET @errors = @errors + 1; END
END CATCH

DELETE FROM @result;

-- ============================================================================
-- TEST 6: DELETE_SERVICE — valid soft delete
-- ============================================================================
PRINT N'--- TEST 6: DELETE_SERVICE (valid soft delete) ---';

INSERT INTO @result
EXEC [Tickets].[ServiceSP]
      @Action    = N'DELETE_SERVICE'
    , @serviceID = @testServiceID
    , @entryData = N'TEST'
    , @hostName  = N'TEST-HOST';

IF EXISTS (SELECT 1 FROM @result WHERE IsSuccessful = 1)
BEGIN
    IF EXISTS (
        SELECT 1 FROM [Tickets].[Service]
        WHERE [serviceID] = @testServiceID
          AND [serviceActive] = 0
    )
        PRINT N'  PASS: Service soft-deleted (serviceActive = 0)';
    ELSE
    BEGIN PRINT N'  FAIL: Service not marked inactive'; SET @errors = @errors + 1; END
END
ELSE
BEGIN PRINT N'  FAIL: DELETE_SERVICE returned failure'; SET @errors = @errors + 1; END

DELETE FROM @result;

-- ============================================================================
-- TEST 7: DELETE_SERVICE — already inactive
-- ============================================================================
PRINT N'--- TEST 7: DELETE_SERVICE (already inactive) ---';

BEGIN TRY
    INSERT INTO @result
    EXEC [Tickets].[ServiceSP]
          @Action    = N'DELETE_SERVICE'
        , @serviceID = @testServiceID
        , @entryData = N'TEST'
        , @hostName  = N'TEST-HOST';

    PRINT N'  FAIL: Should have thrown error for already-inactive service';
    SET @errors = @errors + 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 50001
        PRINT N'  PASS: Already-inactive rejected with error 50001';
    ELSE
    BEGIN PRINT N'  FAIL: Unexpected error: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10)); SET @errors = @errors + 1; END
END CATCH

DELETE FROM @result;

-- ============================================================================
-- TEST 8: Audit log verification
-- ============================================================================
PRINT N'--- TEST 8: Audit log entries created ---';

IF EXISTS (SELECT 1 FROM dbo.AuditLog WHERE TableName = N'[Tickets].[Service]' AND RecordID = @testServiceID)
    PRINT N'  PASS: AuditLog entries found for test service';
ELSE
BEGIN PRINT N'  FAIL: No AuditLog entries for test service'; SET @errors = @errors + 1; END

-- ============================================================================
-- Cleanup: remove test data
-- ============================================================================
DELETE FROM dbo.AuditLog WHERE TableName = N'[Tickets].[Service]' AND RecordID = @testServiceID;
DELETE FROM [Tickets].[Service] WHERE [serviceID] = @testServiceID;

-- ============================================================================
PRINT N'';
IF @errors = 0
    PRINT N'=== TestServiceSP: ALL TESTS PASSED ===';
ELSE
    PRINT N'=== TestServiceSP: ' + CAST(@errors AS NVARCHAR(10)) + N' TEST(S) FAILED ===';
