-- ============================================================================
-- Test: Routing Rule Insert / Close and Historical Replacement
-- Covers: INSERT_ROUTING_RULE, CLOSE_ROUTING_RULE in [Tickets].[ServiceSP]
-- Prerequisites: SeedLookups.sql executed, at least one active Service exists
-- ============================================================================

SET NOCOUNT ON;

DECLARE @errors INT = 0;
DECLARE @result TABLE (IsSuccessful INT, Message_ NVARCHAR(MAX));
DECLARE @testServiceID BIGINT = NULL;
DECLARE @ruleID1 BIGINT = NULL;
DECLARE @ruleID2 BIGINT = NULL;

PRINT N'=== TestServiceRoutingRule: INSERT / CLOSE / Historical Replacement ===';
PRINT N'';

-- ============================================================================
-- Setup: create a dedicated test service
-- ============================================================================
INSERT INTO @result
EXEC [Tickets].[ServiceSP]
      @Action = N'INSERT_SERVICE'
    , @serviceCode = N'TEST_ROUTING_SVC'
    , @serviceName_A = N'خدمة اختبار التوجيه'
    , @serviceName_E = N'Test Routing Service'
    , @serviceDesc = N'Test service for routing rule tests'
    , @idaraID_FK = 1
    , @ticketClassID_FK = 1
    , @defaultPriorityID_FK = 3
    , @entryData = N'TEST'
    , @hostName = N'TEST-HOST';

SET @testServiceID = SCOPE_IDENTITY();
DELETE FROM @result;

-- ============================================================================
-- TEST 1: INSERT_ROUTING_RULE — valid insert
-- ============================================================================
PRINT N'--- TEST 1: INSERT_ROUTING_RULE (valid) ---';

INSERT INTO @result
EXEC [Tickets].[ServiceSP]
      @Action          = N'INSERT_ROUTING_RULE'
    , @serviceID       = @testServiceID
    , @idaraID_FK      = 1
    , @targetDSDID_FK  = 100
    , @changeReason    = N'Test initial routing'
    , @approvedByUserID = 1
    , @entryData       = N'TEST'
    , @hostName        = N'TEST-HOST';

IF EXISTS (SELECT 1 FROM @result WHERE IsSuccessful = 1)
BEGIN
    SET @ruleID1 = SCOPE_IDENTITY();
    IF @ruleID1 IS NOT NULL
        PRINT N'  PASS: Routing rule inserted with ID = ' + CAST(@ruleID1 AS NVARCHAR(20));
    ELSE
    BEGIN PRINT N'  FAIL: Rule ID not captured'; SET @errors = @errors + 1; END
END
ELSE
BEGIN PRINT N'  FAIL: INSERT_ROUTING_RULE returned failure'; SET @errors = @errors + 1; END

DELETE FROM @result;

-- ============================================================================
-- TEST 2: INSERT_ROUTING_RULE — missing targetDSDID_FK
-- ============================================================================
PRINT N'--- TEST 2: INSERT_ROUTING_RULE (missing targetDSDID_FK) ---';

BEGIN TRY
    INSERT INTO @result
    EXEC [Tickets].[ServiceSP]
          @Action     = N'INSERT_ROUTING_RULE'
        , @serviceID  = @testServiceID
        , @idaraID_FK = 1
        , @entryData  = N'TEST'
        , @hostName   = N'TEST-HOST';

    PRINT N'  FAIL: Should have thrown error for missing targetDSDID_FK';
    SET @errors = @errors + 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 50001
        PRINT N'  PASS: Missing targetDSDID_FK rejected with error 50001';
    ELSE
    BEGIN PRINT N'  FAIL: Unexpected error: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10)); SET @errors = @errors + 1; END
END CATCH

DELETE FROM @result;

-- ============================================================================
-- TEST 3: INSERT_ROUTING_RULE — non-existent service
-- ============================================================================
PRINT N'--- TEST 3: INSERT_ROUTING_RULE (non-existent service) ---';

BEGIN TRY
    INSERT INTO @result
    EXEC [Tickets].[ServiceSP]
          @Action         = N'INSERT_ROUTING_RULE'
        , @serviceID      = 9999999
        , @idaraID_FK     = 1
        , @targetDSDID_FK = 100
        , @entryData      = N'TEST'
        , @hostName       = N'TEST-HOST';

    PRINT N'  FAIL: Should have thrown error for non-existent service';
    SET @errors = @errors + 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 50001
        PRINT N'  PASS: Non-existent service rejected with error 50001';
    ELSE
    BEGIN PRINT N'  FAIL: Unexpected error: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10)); SET @errors = @errors + 1; END
END CATCH

DELETE FROM @result;

-- ============================================================================
-- TEST 4: CLOSE_ROUTING_RULE — valid close
-- ============================================================================
PRINT N'--- TEST 4: CLOSE_ROUTING_RULE (valid) ---';

INSERT INTO @result
EXEC [Tickets].[ServiceSP]
      @Action    = N'CLOSE_ROUTING_RULE'
    , @serviceID = @ruleID1
    , @entryData = N'TEST'
    , @hostName  = N'TEST-HOST';

IF EXISTS (SELECT 1 FROM @result WHERE IsSuccessful = 1)
BEGIN
    IF EXISTS (
        SELECT 1 FROM [Tickets].[ServiceRoutingRule]
        WHERE [serviceRoutingRuleID] = @ruleID1
          AND [routingRuleActive] = 0
          AND [effectiveTo] IS NOT NULL
    )
        PRINT N'  PASS: Routing rule closed (active=0, effectiveTo set)';
    ELSE
    BEGIN PRINT N'  FAIL: Rule not properly closed'; SET @errors = @errors + 1; END
END
ELSE
BEGIN PRINT N'  FAIL: CLOSE_ROUTING_RULE returned failure'; SET @errors = @errors + 1; END

DELETE FROM @result;

-- ============================================================================
-- TEST 5: CLOSE_ROUTING_RULE — already closed
-- ============================================================================
PRINT N'--- TEST 5: CLOSE_ROUTING_RULE (already closed) ---';

BEGIN TRY
    INSERT INTO @result
    EXEC [Tickets].[ServiceSP]
          @Action    = N'CLOSE_ROUTING_RULE'
        , @serviceID = @ruleID1
        , @entryData = N'TEST'
        , @hostName  = N'TEST-HOST';

    PRINT N'  FAIL: Should have thrown error for already-closed rule';
    SET @errors = @errors + 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 50001
        PRINT N'  PASS: Already-closed rule rejected with error 50001';
    ELSE
    BEGIN PRINT N'  FAIL: Unexpected error: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10)); SET @errors = @errors + 1; END
END CATCH

DELETE FROM @result;

-- ============================================================================
-- TEST 6: Historical replacement — close old, insert new
-- ============================================================================
PRINT N'--- TEST 6: Historical replacement (close old + insert new) ---';

INSERT INTO @result
EXEC [Tickets].[ServiceSP]
      @Action          = N'INSERT_ROUTING_RULE'
    , @serviceID       = @testServiceID
    , @idaraID_FK      = 1
    , @targetDSDID_FK  = 200
    , @changeReason    = N'Replacement routing — section restructured'
    , @approvedByUserID = 2
    , @entryData       = N'TEST'
    , @hostName        = N'TEST-HOST';

SET @ruleID2 = SCOPE_IDENTITY();
DELETE FROM @result;

IF @ruleID2 IS NOT NULL AND EXISTS (
    SELECT 1 FROM [Tickets].[ServiceRoutingRule]
    WHERE [serviceRoutingRuleID] = @ruleID2
      AND [routingRuleActive] = 1
      AND [targetDSDID_FK] = 200
)
    PRINT N'  PASS: New routing rule created after historical replacement (targetDSDID=200)';
ELSE
BEGIN PRINT N'  FAIL: Replacement rule not found'; SET @errors = @errors + 1; END

IF EXISTS (
    SELECT 1 FROM [Tickets].[ServiceRoutingRule]
    WHERE [serviceRoutingRuleID] = @ruleID1
      AND [routingRuleActive] = 0
)
    PRINT N'  PASS: Old routing rule still preserved as inactive (historical accountability)';
ELSE
BEGIN PRINT N'  FAIL: Old rule not preserved'; SET @errors = @errors + 1; END

-- ============================================================================
-- TEST 7: Audit log verification
-- ============================================================================
PRINT N'--- TEST 7: Audit log entries for routing actions ---';

IF EXISTS (SELECT 1 FROM dbo.AuditLog WHERE TableName = N'[Tickets].[ServiceRoutingRule]' AND RecordID = @ruleID1)
    PRINT N'  PASS: AuditLog entries found for routing rule actions';
ELSE
BEGIN PRINT N'  FAIL: No AuditLog entries for routing rules'; SET @errors = @errors + 1; END

-- ============================================================================
-- Cleanup
-- ============================================================================
DELETE FROM dbo.AuditLog WHERE TableName = N'[Tickets].[ServiceRoutingRule]' AND RecordID IN (@ruleID1, @ruleID2);
DELETE FROM [Tickets].[ServiceRoutingRule] WHERE [serviceRoutingRuleID] IN (@ruleID1, @ruleID2);
DELETE FROM dbo.AuditLog WHERE TableName = N'[Tickets].[Service]' AND RecordID = @testServiceID;
DELETE FROM [Tickets].[Service] WHERE [serviceID] = @testServiceID;

-- ============================================================================
PRINT N'';
IF @errors = 0
    PRINT N'=== TestServiceRoutingRule: ALL TESTS PASSED ===';
ELSE
    PRINT N'=== TestServiceRoutingRule: ' + CAST(@errors AS NVARCHAR(10)) + N' TEST(S) FAILED ===';
