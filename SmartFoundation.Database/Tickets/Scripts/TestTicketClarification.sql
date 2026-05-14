-- ============================================================================
-- Test: Ticket clarification workflow
-- Covers: REQUEST_CLARIFICATION, RESPOND_CLARIFICATION,
--         clarification-specific RESUME_TICKET guard,
--         open-clarification RESOLVE_TICKET guard
-- ============================================================================

SET NOCOUNT ON;

DECLARE @errors INT = 0;
DECLARE @result TABLE (IsSuccessful INT, Message_ NVARCHAR(MAX));
DECLARE @testTicketID BIGINT = NULL;
DECLARE @clarificationRequestID BIGINT = NULL;
DECLARE @idaraID INT = NULL;
DECLARE @ticketClassID INT = NULL;
DECLARE @requesterTypeID INT = NULL;
DECLARE @requesterUserID INT = NULL;
DECLARE @targetUserID INT = NULL;
DECLARE @targetDSDID BIGINT = NULL;
DECLARE @queueDistributorID BIGINT = NULL;
DECLARE @clarificationReasonID INT = NULL;
DECLARE @inProgressStatusID INT = NULL;
DECLARE @clarificationStatusID INT = NULL;
DECLARE @testTicketNo NVARCHAR(50) = N'TST-CLAR-' + RIGHT(REPLACE(CONVERT(NVARCHAR(36), NEWID()), N'-', N''), 8);

PRINT N'=== TestTicketClarification: clarification request / response workflow ===';
PRINT N'';

SELECT TOP 1
      @requesterUserID = CAST(ud.[userID_FK] AS INT)
    , @queueDistributorID = d.[distributorID]
    , @targetDSDID = d.[DSDID_FK]
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

SELECT TOP 1
    @targetUserID = CAST(ud.[userID_FK] AS INT)
FROM dbo.[UserDistributor] ud
INNER JOIN dbo.[Distributor] d
    ON d.[distributorID] = ud.[distributorID_FK]
WHERE ISNULL(ud.[UDActive], 1) = 1
  AND (ud.[UDStartDate] IS NULL OR CAST(ud.[UDStartDate] AS date) <= CAST(GETDATE() AS date))
  AND (ud.[UDEndDate] IS NULL OR CAST(ud.[UDEndDate] AS date) >= CAST(GETDATE() AS date))
  AND ISNULL(d.[distributorActive], 1) = 1
  AND ud.[userID_FK] <> @requesterUserID
  AND ((@queueDistributorID IS NOT NULL AND ud.[distributorID_FK] = @queueDistributorID)
       OR (@targetDSDID IS NOT NULL AND d.[DSDID_FK] = @targetDSDID))
ORDER BY ud.[userID_FK];

IF @targetUserID IS NULL
    SET @targetUserID = @requesterUserID;

SELECT TOP 1 @ticketClassID = [ticketClassID]
FROM [Tickets].[TicketClass]
WHERE [ticketClassActive] = 1
ORDER BY [ticketClassID];

SELECT TOP 1 @requesterTypeID = [requesterTypeID]
FROM [Tickets].[RequesterType]
WHERE [requesterTypeCode] = N'INTERNAL'
  AND [requesterTypeActive] = 1
ORDER BY [requesterTypeID];

SELECT TOP 1 @clarificationReasonID = [clarificationReasonID]
FROM [Tickets].[ClarificationReason]
WHERE [clarificationReasonActive] = 1
ORDER BY [clarificationReasonID];

SELECT @inProgressStatusID = [ticketStatusID]
FROM [Tickets].[TicketStatus]
WHERE [ticketStatusCode] = N'IN_PROGRESS'
  AND [ticketStatusActive] = 1;

SELECT @clarificationStatusID = [ticketStatusID]
FROM [Tickets].[TicketStatus]
WHERE [ticketStatusCode] = N'CLARIFICATION'
  AND [ticketStatusActive] = 1;

IF @requesterUserID IS NULL OR @ticketClassID IS NULL OR @requesterTypeID IS NULL
   OR @clarificationReasonID IS NULL OR @inProgressStatusID IS NULL OR @clarificationStatusID IS NULL
BEGIN
    PRINT N'  FAIL: Missing required seed/setup data for clarification test';
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
      @testTicketNo, @idaraID, NULL, NULL
    , NULL, @ticketClassID, @requesterTypeID
    , @requesterUserID, NULL
    , N'تذكرة اختبار توضيح', N'تذكرة اختبار توضيح', N'اختبار دورة طلب التوضيح', N'اختبار دورة طلب التوضيح'
    , NULL, NULL, @inProgressStatusID
    , @targetDSDID, @queueDistributorID, @requesterUserID
    , NULL, NULL, NULL, NULL
    , NULL, NULL
    , 0, 1, 0, 1
    , N'TEST', N'TEST-HOST'
);

SET @testTicketID = SCOPE_IDENTITY();

PRINT N'--- TEST 1: REQUEST_CLARIFICATION (valid) ---';

INSERT INTO @result
EXEC [Tickets].[TicketSP]
      @Action = N'REQUEST_CLARIFICATION'
    , @ticketID = @testTicketID
    , @requestedFromUserID = @targetUserID
    , @requestedFromDSDID_FK = @targetDSDID
    , @clarificationReasonID_FK = @clarificationReasonID
    , @notes_A = N'نحتاج تفاصيل إضافية لاختبار التوضيح'
    , @idaraID_FK = @idaraID
    , @entryData = N'TEST'
    , @hostName = N'TEST-HOST'
    , @performerUserID = @requesterUserID;

IF EXISTS (SELECT 1 FROM @result WHERE IsSuccessful = 1)
BEGIN
    SELECT TOP 1 @clarificationRequestID = [clarificationRequestID]
    FROM [Tickets].[ClarificationRequest]
    WHERE [ticketID_FK] = @testTicketID
    ORDER BY [clarificationRequestID] DESC;

    IF @clarificationRequestID IS NOT NULL
       AND EXISTS (
            SELECT 1
            FROM [Tickets].[ClarificationRequest]
            WHERE [clarificationRequestID] = @clarificationRequestID
              AND [clarificationStatus] = N'OPEN'
       )
       AND EXISTS (
            SELECT 1
            FROM [Tickets].[Ticket]
            WHERE [ticketID] = @testTicketID
              AND [ticketStatusID_FK] = @clarificationStatusID
       )
       AND EXISTS (
            SELECT 1
            FROM [Tickets].[TicketPauseSession]
            WHERE [ticketID_FK] = @testTicketID
              AND [relatedClarificationRequestID_FK] = @clarificationRequestID
              AND [pauseEnd] IS NULL
              AND [ticketPauseSessionActive] = 1
       )
        PRINT N'  PASS: Clarification request created, ticket moved to CLARIFICATION, pause opened';
    ELSE
    BEGIN
        PRINT N'  FAIL: Clarification request state is incomplete after request';
        SET @errors = @errors + 1;
    END
END
ELSE
BEGIN
    PRINT N'  FAIL: REQUEST_CLARIFICATION returned failure';
    SET @errors = @errors + 1;
END

DELETE FROM @result;

PRINT N'--- TEST 2: RESUME_TICKET blocked while clarification is open ---';

BEGIN TRY
    INSERT INTO @result
    EXEC [Tickets].[TicketSP]
          @Action = N'RESUME_TICKET'
        , @ticketID = @testTicketID
        , @idaraID_FK = @idaraID
        , @entryData = N'TEST'
        , @hostName = N'TEST-HOST'
        , @performerUserID = @requesterUserID;

    PRINT N'  FAIL: RESUME_TICKET should have been blocked for clarification pause';
    SET @errors = @errors + 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 50001
        PRINT N'  PASS: RESUME_TICKET blocked for clarification-owned pause';
    ELSE
    BEGIN
        PRINT N'  FAIL: Unexpected RESUME_TICKET error ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        SET @errors = @errors + 1;
    END
END CATCH

DELETE FROM @result;

PRINT N'--- TEST 3: RESOLVE_TICKET blocked while clarification is open ---';

BEGIN TRY
    INSERT INTO @result
    EXEC [Tickets].[TicketSP]
          @Action = N'RESOLVE_TICKET'
        , @ticketID = @testTicketID
        , @notes_A = N'محاولة حل غير مسموحة أثناء طلب التوضيح'
        , @idaraID_FK = @idaraID
        , @entryData = N'TEST'
        , @hostName = N'TEST-HOST'
        , @performerUserID = @requesterUserID;

    PRINT N'  FAIL: RESOLVE_TICKET should have been blocked for open clarification';
    SET @errors = @errors + 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 50001
        PRINT N'  PASS: RESOLVE_TICKET blocked while clarification is open';
    ELSE
    BEGIN
        PRINT N'  FAIL: Unexpected RESOLVE_TICKET error ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        SET @errors = @errors + 1;
    END
END CATCH

DELETE FROM @result;

PRINT N'--- TEST 4: RESPOND_CLARIFICATION (valid) ---';

INSERT INTO @result
EXEC [Tickets].[TicketSP]
      @Action = N'RESPOND_CLARIFICATION'
    , @clarificationRequestID = @clarificationRequestID
    , @notes_A = N'تم تزويد التفاصيل المطلوبة لاختبار التوضيح'
    , @idaraID_FK = @idaraID
    , @entryData = N'TEST'
    , @hostName = N'TEST-HOST'
    , @performerUserID = @targetUserID;

IF EXISTS (SELECT 1 FROM @result WHERE IsSuccessful = 1)
BEGIN
    IF EXISTS (
            SELECT 1
            FROM [Tickets].[ClarificationRequest]
            WHERE [clarificationRequestID] = @clarificationRequestID
              AND [clarificationStatus] = N'RESPONDED'
              AND [responseDate] IS NOT NULL
       )
       AND EXISTS (
            SELECT 1
            FROM [Tickets].[TicketPauseSession]
            WHERE [relatedClarificationRequestID_FK] = @clarificationRequestID
              AND [pauseEnd] IS NOT NULL
              AND [ticketPauseSessionActive] = 0
       )
       AND EXISTS (
            SELECT 1
            FROM [Tickets].[Ticket]
            WHERE [ticketID] = @testTicketID
              AND [ticketStatusID_FK] = @inProgressStatusID
       )
        PRINT N'  PASS: Clarification response recorded, pause closed, ticket restored to prior status';
    ELSE
    BEGIN
        PRINT N'  FAIL: Clarification response did not restore the expected state';
        SET @errors = @errors + 1;
    END
END
ELSE
BEGIN
    PRINT N'  FAIL: RESPOND_CLARIFICATION returned failure';
    SET @errors = @errors + 1;
END

DELETE FROM @result;

Cleanup:
DELETE FROM dbo.[AuditLog]
WHERE ([TableName] = N'[Tickets].[ClarificationRequest]' AND [RecordID] = @clarificationRequestID)
   OR ([TableName] = N'[Tickets].[Ticket]' AND [RecordID] = @testTicketID);

DELETE FROM [Tickets].[TicketPauseSession]
WHERE [ticketID_FK] = @testTicketID;

DELETE FROM [Tickets].[ClarificationRequest]
WHERE [ticketID_FK] = @testTicketID;

DELETE FROM [Tickets].[TicketHistory]
WHERE [ticketID_FK] = @testTicketID;

DELETE FROM [Tickets].[Ticket]
WHERE [ticketID] = @testTicketID;

PRINT N'';
IF @errors = 0
    PRINT N'=== TestTicketClarification: ALL TESTS PASSED ===';
ELSE
    PRINT N'=== TestTicketClarification: ' + CAST(@errors AS NVARCHAR(10)) + N' TEST(S) FAILED ===';