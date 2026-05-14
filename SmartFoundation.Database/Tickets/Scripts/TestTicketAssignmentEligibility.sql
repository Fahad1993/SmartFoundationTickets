-- ============================================================================
-- Test: Ticket assignment eligibility via UserDistributor
-- Covers: ASSIGN_TICKET, REASSIGN_TICKET eligibility guards
-- ============================================================================

SET NOCOUNT ON;

DECLARE @errors INT = 0;
DECLARE @result TABLE (IsSuccessful INT, Message_ NVARCHAR(MAX));
DECLARE @eligibleUserID INT = NULL;
DECLARE @eligibleDistributorID BIGINT = NULL;
DECLARE @eligibleDSDID BIGINT = NULL;
DECLARE @idaraID INT = NULL;
DECLARE @ticketClassID INT = NULL;
DECLARE @requesterTypeID INT = NULL;
DECLARE @newStatusID INT = NULL;
DECLARE @assignedStatusID INT = NULL;
DECLARE @testTicketID1 BIGINT = NULL;
DECLARE @testTicketID2 BIGINT = NULL;
DECLARE @ineligibleUserID INT = 9999999;
DECLARE @testTicketNo1 NVARCHAR(50) = N'TST-ASGN-' + RIGHT(REPLACE(CONVERT(NVARCHAR(36), NEWID()), N'-', N''), 8);
DECLARE @testTicketNo2 NVARCHAR(50) = N'TST-RASG-' + RIGHT(REPLACE(CONVERT(NVARCHAR(36), NEWID()), N'-', N''), 8);

PRINT N'=== TestTicketAssignmentEligibility: assign / reassign guards ===';
PRINT N'';

SELECT TOP 1
      @eligibleUserID = CAST(ud.[userID_FK] AS INT)
    , @eligibleDistributorID = d.[distributorID]
    , @eligibleDSDID = d.[DSDID_FK]
    , @idaraID = f.[IdaraID]
FROM dbo.[UserDistributor] ud
INNER JOIN dbo.[Distributor] d
    ON d.[distributorID] = ud.[distributorID_FK]
INNER JOIN dbo.[Users] u
    ON u.[usersID] = ud.[userID_FK]
LEFT JOIN dbo.[V_GetFullStructureForDSD] f
    ON f.[DSDID] = d.[DSDID_FK]
WHERE ISNULL(ud.[UDActive], 1) = 1
  AND (ud.[UDStartDate] IS NULL OR CAST(ud.[UDStartDate] AS date) <= CAST(GETDATE() AS date))
  AND (ud.[UDEndDate] IS NULL OR CAST(ud.[UDEndDate] AS date) >= CAST(GETDATE() AS date))
  AND ISNULL(d.[distributorActive], 1) = 1
  AND ISNULL(u.[usersActive], 1) = 1
  AND f.[IdaraID] IS NOT NULL
ORDER BY ud.[userID_FK];

SELECT TOP 1 @ticketClassID = [ticketClassID]
FROM [Tickets].[TicketClass]
WHERE [ticketClassActive] = 1
ORDER BY [ticketClassID];

SELECT TOP 1 @requesterTypeID = [requesterTypeID]
FROM [Tickets].[RequesterType]
WHERE [requesterTypeCode] = N'INTERNAL'
  AND [requesterTypeActive] = 1
ORDER BY [requesterTypeID];

SELECT @newStatusID = [ticketStatusID]
FROM [Tickets].[TicketStatus]
WHERE [ticketStatusCode] = N'NEW'
  AND [ticketStatusActive] = 1;

SELECT @assignedStatusID = [ticketStatusID]
FROM [Tickets].[TicketStatus]
WHERE [ticketStatusCode] = N'ASSIGNED'
  AND [ticketStatusActive] = 1;

IF @eligibleUserID IS NULL OR @eligibleDistributorID IS NULL OR @eligibleDSDID IS NULL
   OR @ticketClassID IS NULL OR @requesterTypeID IS NULL OR @newStatusID IS NULL OR @assignedStatusID IS NULL
BEGIN
    PRINT N'  FAIL: Missing required seed/setup data for assignment test';
    SET @errors = @errors + 1;
    GOTO Cleanup;
END

INSERT INTO [Tickets].[Ticket]
(
      [ticketNo], [idaraID_FK], [parentTicketID_FK], [rootTicketID_FK]
    , [serviceID_FK], [ticketClassID_FK], [requesterTypeID_FK]
    , [requesterUserID_FK], [requesterResidentID_FK]
    , [title], [title_A], [description_], [description_A]
    , [suggestedPriorityID_FK], [effectivePriorityID_FK], [ticketStatusID_FK]
    , [currentDSDID_FK], [currentQueueDistributorID_FK], [assignedUserID_FK]
    , [locationBuildingNo], [locationUnitNo], [locationArea], [locationArea_A]
    , [operationalResolutionDate], [finalClosureDate]
    , [requiresQualityReview], [isOtherService], [isParentBlocked], [ticketActive]
    , [entryData], [hostName]
)
VALUES
(
      @testTicketNo1, @idaraID, NULL, NULL
    , NULL, @ticketClassID, @requesterTypeID
    , @eligibleUserID, NULL
    , N'تذكرة اختبار الإسناد', N'تذكرة اختبار الإسناد', N'اختبار أهلية الإسناد', N'اختبار أهلية الإسناد'
    , NULL, NULL, @newStatusID
    , @eligibleDSDID, @eligibleDistributorID, NULL
    , NULL, NULL, NULL, NULL
    , NULL, NULL
    , 0, 1, 0, 1
    , N'TEST', N'TEST-HOST'
);

SET @testTicketID1 = SCOPE_IDENTITY();

INSERT INTO [Tickets].[Ticket]
(
      [ticketNo], [idaraID_FK], [parentTicketID_FK], [rootTicketID_FK]
    , [serviceID_FK], [ticketClassID_FK], [requesterTypeID_FK]
    , [requesterUserID_FK], [requesterResidentID_FK]
    , [title], [title_A], [description_], [description_A]
    , [suggestedPriorityID_FK], [effectivePriorityID_FK], [ticketStatusID_FK]
    , [currentDSDID_FK], [currentQueueDistributorID_FK], [assignedUserID_FK]
    , [locationBuildingNo], [locationUnitNo], [locationArea], [locationArea_A]
    , [operationalResolutionDate], [finalClosureDate]
    , [requiresQualityReview], [isOtherService], [isParentBlocked], [ticketActive]
    , [entryData], [hostName]
)
VALUES
(
      @testTicketNo2, @idaraID, NULL, NULL
    , NULL, @ticketClassID, @requesterTypeID
    , @eligibleUserID, NULL
    , N'تذكرة اختبار إعادة الإسناد', N'تذكرة اختبار إعادة الإسناد', N'اختبار أهلية إعادة الإسناد', N'اختبار أهلية إعادة الإسناد'
    , NULL, NULL, @newStatusID
    , @eligibleDSDID, @eligibleDistributorID, NULL
    , NULL, NULL, NULL, NULL
    , NULL, NULL
    , 0, 1, 0, 1
    , N'TEST', N'TEST-HOST'
);

SET @testTicketID2 = SCOPE_IDENTITY();

PRINT N'--- TEST 1: ASSIGN_TICKET accepts mapped user ---';

INSERT INTO @result
EXEC [Tickets].[TicketSP]
      @Action = N'ASSIGN_TICKET'
    , @ticketID = @testTicketID1
    , @assignedUserID_FK = @eligibleUserID
    , @idaraID_FK = @idaraID
    , @entryData = N'TEST'
    , @hostName = N'TEST-HOST'
    , @performerUserID = @eligibleUserID;

IF EXISTS (SELECT 1 FROM @result WHERE IsSuccessful = 1)
   AND EXISTS (
        SELECT 1
        FROM [Tickets].[Ticket]
        WHERE [ticketID] = @testTicketID1
          AND [assignedUserID_FK] = @eligibleUserID
          AND [ticketStatusID_FK] = @assignedStatusID
   )
    PRINT N'  PASS: ASSIGN_TICKET accepted eligible mapped user';
ELSE
BEGIN
    PRINT N'  FAIL: ASSIGN_TICKET did not accept eligible mapped user';
    SET @errors = @errors + 1;
END

DELETE FROM @result;

PRINT N'--- TEST 2: ASSIGN_TICKET rejects unmapped user ---';

BEGIN TRY
    INSERT INTO @result
    EXEC [Tickets].[TicketSP]
          @Action = N'ASSIGN_TICKET'
        , @ticketID = @testTicketID2
        , @assignedUserID_FK = @ineligibleUserID
        , @idaraID_FK = @idaraID
        , @entryData = N'TEST'
        , @hostName = N'TEST-HOST'
        , @performerUserID = @eligibleUserID;

    PRINT N'  FAIL: ASSIGN_TICKET should have rejected unmapped user';
    SET @errors = @errors + 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 50001
        PRINT N'  PASS: ASSIGN_TICKET rejected unmapped user with business error';
    ELSE
    BEGIN
        PRINT N'  FAIL: Unexpected ASSIGN_TICKET error ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        SET @errors = @errors + 1;
    END
END CATCH

DELETE FROM @result;

PRINT N'--- TEST 3: REASSIGN_TICKET rejects unmapped user ---';

BEGIN TRY
    INSERT INTO @result
    EXEC [Tickets].[TicketSP]
          @Action = N'REASSIGN_TICKET'
        , @ticketID = @testTicketID1
        , @assignedUserID_FK = @ineligibleUserID
        , @currentDSDID_FK = @eligibleDSDID
        , @idaraID_FK = @idaraID
        , @entryData = N'TEST'
        , @hostName = N'TEST-HOST'
        , @performerUserID = @eligibleUserID;

    PRINT N'  FAIL: REASSIGN_TICKET should have rejected unmapped user';
    SET @errors = @errors + 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 50001
        PRINT N'  PASS: REASSIGN_TICKET rejected unmapped user with business error';
    ELSE
    BEGIN
        PRINT N'  FAIL: Unexpected REASSIGN_TICKET error ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        SET @errors = @errors + 1;
    END
END CATCH

DELETE FROM @result;

Cleanup:
DELETE FROM dbo.[AuditLog]
WHERE [TableName] = N'[Tickets].[Ticket]'
  AND [RecordID] IN (@testTicketID1, @testTicketID2);

DELETE FROM [Tickets].[TicketHistory]
WHERE [ticketID_FK] IN (@testTicketID1, @testTicketID2);

DELETE FROM [Tickets].[Ticket]
WHERE [ticketID] IN (@testTicketID1, @testTicketID2);

PRINT N'';
IF @errors = 0
    PRINT N'=== TestTicketAssignmentEligibility: ALL TESTS PASSED ===';
ELSE
    PRINT N'=== TestTicketAssignmentEligibility: ' + CAST(@errors AS NVARCHAR(10)) + N' TEST(S) FAILED ===';