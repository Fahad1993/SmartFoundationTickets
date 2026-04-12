-- ============================================================================
-- Test: SLA Policy Upsert and Retrieval per Service + Priority
-- Covers: UPSERT_SLA_POLICY in [Tickets].[ServiceSP]
-- Prerequisites: SeedLookups.sql executed, at least one active Service exists
-- ============================================================================

SET NOCOUNT ON;

DECLARE @errors INT = 0;
DECLARE @result TABLE (IsSuccessful INT, Message_ NVARCHAR(MAX));
DECLARE @testServiceID BIGINT = NULL;

PRINT N'=== TestServiceSLAPolicy: UPSERT (INSERT then UPDATE) + Retrieval ===';
PRINT N'';

-- ============================================================================
-- Setup: create a dedicated test service
-- ============================================================================
INSERT INTO @result
EXEC [Tickets].[ServiceSP]
      @Action = N'INSERT_SERVICE'
    , @serviceCode = N'TEST_SLA_SVC'
    , @serviceName_A = N'خدمة اختبار SLA'
    , @serviceName_E = N'Test SLA Service'
    , @serviceDesc = N'Test service for SLA policy tests'
    , @idaraID_FK = 1
    , @ticketClassID_FK = 1
    , @defaultPriorityID_FK = 3
    , @entryData = N'TEST'
    , @hostName = N'TEST-HOST';

SET @testServiceID = SCOPE_IDENTITY();
DELETE FROM @result;

-- ============================================================================
-- TEST 1: UPSERT_SLA_POLICY — initial insert (no existing policy)
-- ============================================================================
PRINT N'--- TEST 1: UPSERT_SLA_POLICY (initial insert) ---';

INSERT INTO @result
EXEC [Tickets].[ServiceSP]
      @Action                            = N'UPSERT_SLA_POLICY'
    , @serviceID                         = @testServiceID
    , @idaraID_FK                        = 1
    , @priorityID_FK                     = 3
    , @firstResponseTargetMinutes        = 60
    , @assignmentTargetMinutes           = 240
    , @operationalCompletionTargetMinutes = 2880
    , @finalClosureTargetMinutes         = 4320
    , @entryData                         = N'TEST'
    , @hostName                          = N'TEST-HOST';

IF EXISTS (SELECT 1 FROM @result WHERE IsSuccessful = 1)
BEGIN
    DECLARE @slaID1 BIGINT;
    SELECT @slaID1 = [serviceSLAPolicyID]
    FROM [Tickets].[ServiceSLAPolicy]
    WHERE [serviceID_FK] = @testServiceID
      AND [priorityID_FK] = 3
      AND [idaraID_FK] = 1
      AND [slaPolicyActive] = 1;

    IF @slaID1 IS NOT NULL
        PRINT N'  PASS: SLA policy inserted with ID = ' + CAST(@slaID1 AS NVARCHAR(20));
    ELSE
    BEGIN PRINT N'  FAIL: SLA policy row not found after insert'; SET @errors = @errors + 1; END
END
ELSE
BEGIN PRINT N'  FAIL: UPSERT_SLA_POLICY (insert) returned failure'; SET @errors = @errors + 1; END

DELETE FROM @result;

-- ============================================================================
-- TEST 2: UPSERT_SLA_POLICY — update existing (upsert path)
-- ============================================================================
PRINT N'--- TEST 2: UPSERT_SLA_POLICY (update existing) ---';

INSERT INTO @result
EXEC [Tickets].[ServiceSP]
      @Action                            = N'UPSERT_SLA_POLICY'
    , @serviceID                         = @testServiceID
    , @idaraID_FK                        = 1
    , @priorityID_FK                     = 3
    , @firstResponseTargetMinutes        = 30
    , @assignmentTargetMinutes           = 120
    , @operationalCompletionTargetMinutes = 1440
    , @finalClosureTargetMinutes         = 2160
    , @entryData                         = N'TEST'
    , @hostName                          = N'TEST-HOST';

IF EXISTS (SELECT 1 FROM @result WHERE IsSuccessful = 1)
BEGIN
    IF EXISTS (
        SELECT 1 FROM [Tickets].[ServiceSLAPolicy]
        WHERE [serviceID_FK] = @testServiceID
          AND [priorityID_FK] = 3
          AND [idaraID_FK] = 1
          AND [slaPolicyActive] = 1
          AND [firstResponseTargetMinutes] = 30
          AND [assignmentTargetMinutes] = 120
          AND [operationalCompletionTargetMinutes] = 1440
          AND [finalClosureTargetMinutes] = 2160
    )
        PRINT N'  PASS: SLA policy updated with new target minutes';
    ELSE
    BEGIN PRINT N'  FAIL: SLA policy values not updated'; SET @errors = @errors + 1; END
END
ELSE
BEGIN PRINT N'  FAIL: UPSERT_SLA_POLICY (update) returned failure'; SET @errors = @errors + 1; END

DELETE FROM @result;

-- ============================================================================
-- TEST 3: UPSERT_SLA_POLICY — only one active row per service+priority+idara
-- ============================================================================
PRINT N'--- TEST 3: Verify single active row per service+priority+idara ---';

DECLARE @activeCount INT;
SELECT @activeCount = COUNT(*)
FROM [Tickets].[ServiceSLAPolicy]
WHERE [serviceID_FK] = @testServiceID
  AND [priorityID_FK] = 3
  AND [idaraID_FK] = 1
  AND [slaPolicyActive] = 1;

IF @activeCount = 1
    PRINT N'  PASS: Exactly one active SLA policy row (count = 1)';
ELSE
BEGIN PRINT N'  FAIL: Expected 1 active row, found ' + CAST(@activeCount AS NVARCHAR(10)); SET @errors = @errors + 1; END

-- ============================================================================
-- TEST 4: UPSERT_SLA_POLICY — missing required fields
-- ============================================================================
PRINT N'--- TEST 4: UPSERT_SLA_POLICY (missing priorityID_FK) ---';

BEGIN TRY
    INSERT INTO @result
    EXEC [Tickets].[ServiceSP]
          @Action     = N'UPSERT_SLA_POLICY'
        , @serviceID  = @testServiceID
        , @idaraID_FK = 1
        , @entryData  = N'TEST'
        , @hostName   = N'TEST-HOST';

    PRINT N'  FAIL: Should have thrown error for missing priorityID_FK';
    SET @errors = @errors + 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 50001
        PRINT N'  PASS: Missing priorityID_FK rejected with error 50001';
    ELSE
    BEGIN PRINT N'  FAIL: Unexpected error: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10)); SET @errors = @errors + 1; END
END CATCH

DELETE FROM @result;

-- ============================================================================
-- TEST 5: UPSERT_SLA_POLICY — insert for different priority (creates second row)
-- ============================================================================
PRINT N'--- TEST 5: UPSERT_SLA_POLICY (different priority = new row) ---';

INSERT INTO @result
EXEC [Tickets].[ServiceSP]
      @Action                            = N'UPSERT_SLA_POLICY'
    , @serviceID                         = @testServiceID
    , @idaraID_FK                        = 1
    , @priorityID_FK                     = 2
    , @firstResponseTargetMinutes        = 15
    , @assignmentTargetMinutes           = 60
    , @operationalCompletionTargetMinutes = 720
    , @finalClosureTargetMinutes         = 1080
    , @entryData                         = N'TEST'
    , @hostName                          = N'TEST-HOST';

IF EXISTS (SELECT 1 FROM @result WHERE IsSuccessful = 1)
BEGIN
    DECLARE @totalActive INT;
    SELECT @totalActive = COUNT(*)
    FROM [Tickets].[ServiceSLAPolicy]
    WHERE [serviceID_FK] = @testServiceID
      AND [idaraID_FK] = 1
      AND [slaPolicyActive] = 1;

    IF @totalActive = 2
        PRINT N'  PASS: Second SLA policy created for different priority (total active = 2)';
    ELSE
    BEGIN PRINT N'  FAIL: Expected 2 active rows, found ' + CAST(@totalActive AS NVARCHAR(10)); SET @errors = @errors + 1; END
END
ELSE
BEGIN PRINT N'  FAIL: UPSERT_SLA_POLICY (new priority) returned failure'; SET @errors = @errors + 1; END

DELETE FROM @result;

-- ============================================================================
-- TEST 6: Retrieval via V_ServiceFullDefinition (read model)
-- ============================================================================
PRINT N'--- TEST 6: Retrieval via V_ServiceFullDefinition ---';

IF EXISTS (
    SELECT 1 FROM [Tickets].[V_ServiceFullDefinition]
    WHERE [serviceID] = @testServiceID
      AND [slaPolicyID] IS NOT NULL
)
    PRINT N'  PASS: Test service visible in V_ServiceFullDefinition with SLA data';
ELSE
BEGIN PRINT N'  FAIL: Test service not found in view or SLA data missing'; SET @errors = @errors + 1; END

-- ============================================================================
-- TEST 7: Audit log verification
-- ============================================================================
PRINT N'--- TEST 7: Audit log entries for SLA operations ---';

IF EXISTS (SELECT 1 FROM dbo.AuditLog WHERE TableName = N'[Tickets].[ServiceSLAPolicy]' AND RecordID = @testServiceID)
    PRINT N'  PASS: AuditLog entries found for SLA policy actions';
ELSE
BEGIN PRINT N'  FAIL: No AuditLog entries for SLA policies'; SET @errors = @errors + 1; END

-- ============================================================================
-- Cleanup
-- ============================================================================
DELETE FROM dbo.AuditLog WHERE TableName = N'[Tickets].[ServiceSLAPolicy]' AND RecordID = @testServiceID;
DELETE FROM [Tickets].[ServiceSLAPolicy] WHERE [serviceID_FK] = @testServiceID;
DELETE FROM dbo.AuditLog WHERE TableName = N'[Tickets].[Service]' AND RecordID = @testServiceID;
DELETE FROM [Tickets].[Service] WHERE [serviceID] = @testServiceID;

-- ============================================================================
PRINT N'';
IF @errors = 0
    PRINT N'=== TestServiceSLAPolicy: ALL TESTS PASSED ===';
ELSE
    PRINT N'=== TestServiceSLAPolicy: ' + CAST(@errors AS NVARCHAR(10)) + N' TEST(S) FAILED ===';
