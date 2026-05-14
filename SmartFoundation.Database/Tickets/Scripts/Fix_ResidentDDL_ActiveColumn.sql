-- Fix: Remove residentInfoActive check from ResidentDDL (column not exposed in view)
-- Execute this in SSMS

USE [DATACORETi]
GO

-- Drop and recreate only the ResidentDDL section by updating the whole SP
ALTER PROCEDURE [Tickets].[TicketDL]
(
      @pageName_          NVARCHAR(400)
    , @idaraID            INT
    , @entryData          INT
    , @hostName           NVARCHAR(400)
    , @filterTicketID     BIGINT = NULL
    , @filterTicketNo     NVARCHAR(50) = NULL
    , @filterStatusID     INT = NULL
    , @filterServiceID    BIGINT = NULL
    , @filterAssignedUserID INT = NULL
    , @filterDSDID        INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @pageName_ = N'TicketDetails' OR @pageName_ IS NULL
    BEGIN
        SELECT
              t.[ticketID]
            , t.[ticketNo]
            , t.[idaraID_FK]
            , t.[parentTicketID_FK]
            , t.[rootTicketID_FK]
            , t.[serviceID_FK]
            , CASE
                WHEN svc.[serviceName_A] IS NULL OR svc.[serviceName_A] NOT LIKE N'%[ء-ي]%'
                  THEN svc.[serviceName_E]
                ELSE svc.[serviceName_A]
              END AS [serviceName_A]
            , svc.[serviceName_E]
            , t.[ticketClassID_FK]
            , CASE
                WHEN tc.[ticketClassName_A] IS NULL OR tc.[ticketClassName_A] NOT LIKE N'%[ء-ي]%'
                  THEN tc.[ticketClassName_E]
                ELSE tc.[ticketClassName_A]
              END AS [ticketClassName_A]
            , tc.[ticketClassName_E]
            , t.[requesterTypeID_FK]
            , CASE
                WHEN rt.[requesterTypeName_A] IS NULL OR rt.[requesterTypeName_A] NOT LIKE N'%[ء-ي]%'
                  THEN rt.[requesterTypeName_E]
                ELSE rt.[requesterTypeName_A]
              END AS [requesterTypeName_A]
            , rt.[requesterTypeName_E]
            , t.[requesterUserID_FK]
            , t.[requesterResidentID_FK]
            , LTRIM(RTRIM(
                  ISNULL(rud.firstName_A, N'') + N' ' +
                  ISNULL(rud.secondName_A, N'') + N' ' +
                  ISNULL(rud.thirdName_A, N'') + N' ' +
                  ISNULL(rud.lastName_A, N'')
              )) AS [requesterName]
            , COALESCE(t.[title_A], t.[title]) AS [title]
            , COALESCE(t.[description_A], t.[description_]) AS [description_]
            , t.[suggestedPriorityID_FK]
            , t.[effectivePriorityID_FK]
            , CASE
                WHEN p.[priorityName_A] IS NULL OR p.[priorityName_A] NOT LIKE N'%[ء-ي]%'
                  THEN p.[priorityName_E]
                ELSE p.[priorityName_A]
              END AS [priorityName_A]
            , p.[priorityName_E]
            , t.[currentDSDID_FK]
            , dsd.[distributorName] AS [currentQueueDistributorName]
            , t.[assignedUserID_FK]
            , au.[firstName_A] + N' ' + au.[lastName_A] AS [assignedUserName]
            , t.[ticketStatusID_FK]
            , CASE
                WHEN s.[ticketStatusName_A] IS NULL OR s.[ticketStatusName_A] NOT LIKE N'%[ء-ي]%'
                  THEN s.[ticketStatusName_E]
                ELSE s.[ticketStatusName_A]
              END AS [ticketStatusName_A]
            , s.[ticketStatusName_E]
            , s.[ticketStatusCode]
            , t.[createdByUserID_FK]
            , cb.[firstName_A] + N' ' + cb.[lastName_A] AS [createdByUserName]
            , t.[entryDate]
            , t.[lastUpdated]
            , t.[requiresQualityReview]
            , t.[allowsChildTickets]
            , t.[locationBuildingNo]
            , t.[locationUnitNo]
            , t.[locationArea]
            , t.[isBlocked]
            , t.[blockingReason]
            , t.[ticketActive]
            , DATEDIFF(MINUTE, t.[entryDate], GETUTCDATE()) AS [elapsedMinutes]
            , sla.[slaTypeCode]
            , sla.[targetMinutes]
            , sla.[elapsedMinutes] AS [slaElapsedMinutes]
            , sla.[isBreached] AS [slaIsBreached]
            , sla.[slaStartDate] AS [slaStartDate]
        FROM [Tickets].[Ticket] t
        LEFT JOIN [Tickets].[Service] svc ON t.[serviceID_FK] = svc.[serviceID]
        LEFT JOIN [Tickets].[TicketClass] tc ON t.[ticketClassID_FK] = tc.[ticketClassID]
        LEFT JOIN [Tickets].[RequesterType] rt ON t.[requesterTypeID_FK] = rt.[requesterType]
        LEFT JOIN [dbo].[UsersDetails] rud ON t.[requesterUserID_FK] = rud.[UsersDetailsID]
        LEFT JOIN [Tickets].[Priority] p ON t.[suggestedPriorityID_FK] = p.[priorityID]
        LEFT JOIN [dbo].[DistributorServiceDetail] dsd ON t.[currentDSDID_FK] = dsd.[distributorServiceDetailID]
        LEFT JOIN [dbo].[UsersDetails] au ON t.[assignedUserID_FK] = au.[UsersDetailsID]
        LEFT JOIN [Tickets].[TicketStatus] s ON t.[ticketStatusID_FK] = s.[ticketStatusID]
        LEFT JOIN [dbo].[UsersDetails] cb ON t.[createdByUserID_FK] = cb.[UsersDetailsID]
        LEFT JOIN [Tickets].[TicketSLA] sla ON t.[ticketID] = sla.[ticketID_FK] AND sla.[ticketSLAActive] = 1
        WHERE t.[ticketActive] = 1
          AND (t.[idaraID_FK] = @idaraID OR @idaraID IS NULL)
          AND (@filterTicketID IS NULL OR t.[ticketID] = @filterTicketID)
          AND (@filterTicketNo IS NULL OR t.[ticketNo] LIKE N'%' + @filterTicketNo + N'%')
          AND (@filterStatusID IS NULL OR t.[ticketStatusID_FK] = @filterStatusID)
          AND (@filterServiceID IS NULL OR t.[serviceID_FK] = @filterServiceID)
          AND (@filterAssignedUserID IS NULL OR t.[assignedUserID_FK] = @filterAssignedUserID)
          AND (@filterDSDID IS NULL OR t.[currentDSDID_FK] = @filterDSDID)
        ORDER BY t.[entryDate] DESC;

        RETURN;
    END

    IF @pageName_ = N'TicketHistory'
    BEGIN
        SELECT
              th.[ticketHistoryID]
            , th.[ticketID_FK]
            , t.[ticketNo]
            , th.[actionTypeCode]
            , th.[oldStatusID_FK]
            , ts_old.[ticketStatusName_A] AS [oldStatusName_A]
            , ts_old.[ticketStatusName_E] AS [oldStatusName_E]
            , th.[newStatusID_FK]
            , ts_new.[ticketStatusName_A] AS [newStatusName_A]
            , ts_new.[ticketStatusName_E] AS [newStatusName_E]
            , th.[notes]
            , th.[performerUserID_FK]
            , perf.[firstName_A] + N' ' + perf.[lastName_A] AS [performerName]
            , th.[actionDate]
        FROM [Tickets].[TicketHistory] th
        INNER JOIN [Tickets].[Ticket] t ON th.[ticketID_FK] = t.[ticketID]
        LEFT JOIN [Tickets].[TicketStatus] ts_old ON th.[oldStatusID_FK] = ts_old.[ticketStatusID]
        LEFT JOIN [Tickets].[TicketStatus] ts_new ON th.[newStatusID_FK] = ts_new.[ticketStatusID]
        LEFT JOIN [dbo].[UsersDetails] perf ON th.[performerUserID_FK] = perf.[UsersDetailsID]
        WHERE th.[ticketHistoryActive] = 1
          AND th.[ticketID_FK] = @filterTicketID
        ORDER BY th.[actionDate] DESC;

        RETURN;
    END

    IF @pageName_ = N'ChildTickets'
    BEGIN
        SELECT
              t.[ticketID]
            , t.[ticketNo]
            , t.[parentTicketID_FK]
            , t.[rootTicketID_FK]
            , COALESCE(t.[title_A], t.[title]) AS [title]
            , t.[ticketStatusID_FK]
            , CASE
                WHEN s.[ticketStatusName_A] IS NULL OR s.[ticketStatusName_A] NOT LIKE N'%[ء-ي]%'
                  THEN s.[ticketStatusName_E]
                ELSE s.[ticketStatusName_A]
              END AS [ticketStatusName_A]
            , s.[ticketStatusCode]
            , t.[entryDate]
        FROM [Tickets].[Ticket] t
        LEFT JOIN [Tickets].[TicketStatus] s ON t.[ticketStatusID_FK] = s.[ticketStatusID]
        WHERE t.[ticketActive] = 1
          AND t.[parentTicketID_FK] = @filterTicketID
        ORDER BY t.[entryDate] ASC;

        RETURN;
    END

    IF @pageName_ = N'PauseSessions'
    BEGIN
        SELECT
              ps.[ticketPauseSessionID]
            , ps.[ticketID_FK]
            , t.[ticketNo]
            , pr.[pauseReasonCode]
            , pr.[pauseReasonName_A] AS [pauseReasonName]
            , ps.[pauseNotes]
            , ps.[pauseStart]
            , ps.[pauseEnd]
            , ps.[ticketPauseSessionActive]
        FROM [Tickets].[TicketPauseSession] ps
        INNER JOIN [Tickets].[Ticket] t ON ps.[ticketID_FK] = t.[ticketID]
        LEFT JOIN [Tickets].[PauseReason] pr ON ps.[pauseReasonID_FK] = pr.[pauseReasonID]
        WHERE ps.[ticketPauseSessionActive] = 1
          AND ps.[ticketID_FK] = @filterTicketID
        ORDER BY ps.[pauseStart] DESC;

        RETURN;
    END

    IF @pageName_ = N'TicketSLAs'
    BEGIN
        SELECT
              sla.[ticketSLAID]
            , sla.[ticketID_FK]
            , t.[ticketNo]
            , sla.[slaTypeCode]
            , sla.[targetMinutes]
            , sla.[elapsedMinutes]
            , sla.[isBreached]
            , sla.[slaStartDate]
            , sla.[slaEndDate]
            , sla.[ticketSLAActive]
        FROM [Tickets].[TicketSLA] sla
        INNER JOIN [Tickets].[Ticket] t ON sla.[ticketID_FK] = t.[ticketID]
        WHERE sla.[ticketSLAActive] = 1
          AND sla.[ticketID_FK] = @filterTicketID
        ORDER BY sla.[slaStartDate] DESC;

        RETURN;
    END

    IF @pageName_ = N'QualityReviews'
    BEGIN
        SELECT
              qr.[qualityReviewID]
            , qr.[ticketID_FK]
            , t.[ticketNo]
            , qr.[reviewScope]
            , qrr.[qualityReviewResultName_A] AS [resultName]
            , qr.[reviewerUserID_FK]
            , rev.[firstName_A] + N' ' + rev.[lastName_A] AS [reviewerName]
            , qr.[finalized]
            , qr.[qualityReviewActive]
            , qr.[entryDate]
        FROM [Tickets].[QualityReview] qr
        INNER JOIN [Tickets].[Ticket] t ON qr.[ticketID_FK] = t.[ticketID]
        LEFT JOIN [Tickets].[QualityReviewResult] qrr ON qr.[qualityReviewResultID_FK] = qrr.[qualityReviewResultID]
        LEFT JOIN [dbo].[UsersDetails] rev ON qr.[reviewerUserID_FK] = rev.[UsersDetailsID]
        WHERE qr.[qualityReviewActive] = 1
          AND qr.[ticketID_FK] = @filterTicketID
        ORDER BY qr.[entryDate] DESC;

        RETURN;
    END

    IF @pageName_ = N'ArbitrationCases'
    BEGIN
        SELECT
              ac.[arbitrationCaseID]
            , ac.[ticketID_FK]
            , t.[ticketNo]
            , ar.[arbitrationReasonName_A] AS [reasonName]
            , ac.[arbitrationStatus]
            , ac.[decidedByUserID_FK]
            , decider.[firstName_A] + N' ' + decider.[lastName_A] AS [deciderName]
            , ac.[decisionNotes]
            , ac.[arbitrationCaseActive]
            , ac.[entryDate]
        FROM [Tickets].[ArbitrationCase] ac
        INNER JOIN [Tickets].[Ticket] t ON ac.[ticketID_FK] = t.[ticketID]
        LEFT JOIN [Tickets].[ArbitrationReason] ar ON ac.[arbitrationReasonID_FK] = ar.[arbitrationReasonID]
        LEFT JOIN [dbo].[UsersDetails] decider ON ac.[decidedByUserID_FK] = decider.[UsersDetailsID]
        WHERE ac.[arbitrationCaseActive] = 1
          AND ac.[ticketID_FK] = @filterTicketID
        ORDER BY ac.[entryDate] DESC;

        RETURN;
    END

    IF @pageName_ = N'TicketAttachments'
    BEGIN
        SELECT
              ta.[ticketAttachmentID]
            , ta.[ticketID_FK]
            , t.[ticketNo]
            , ta.[fileName]
            , ta.[fileSize]
            , ta.[fileType]
            , ta.[uploadedByUserID_FK]
            , uploader.[firstName_A] + N' ' + uploader.[lastName_A] AS [uploaderName]
            , ta.[ticketAttachmentActive]
            , ta.[entryDate]
        FROM [Tickets].[TicketAttachment] ta
        INNER JOIN [Tickets].[Ticket] t ON ta.[ticketID_FK] = t.[ticketID]
        LEFT JOIN [dbo].[UsersDetails] uploader ON ta.[uploadedByUserID_FK] = uploader.[UsersDetailsID]
        WHERE ta.[ticketAttachmentActive] = 1
          AND ta.[ticketID_FK] = @filterTicketID
        ORDER BY ta.[entryDate] DESC;

        RETURN;
    END

    IF @pageName_ = N'PauseReasonDDL'
    BEGIN
        SELECT [pauseReasonID], [pauseReasonCode], [pauseReasonName_A], [pauseReasonName_E]
        FROM [Tickets].[PauseReason]
        WHERE [pauseReasonActive] = 1
        ORDER BY [pauseReasonID];

        RETURN;
    END

    IF @pageName_ = N'ArbitrationReasonDDL'
    BEGIN
        SELECT [arbitrationReasonID], [arbitrationReasonCode], [arbitrationReasonName_A], [arbitrationReasonName_E]
        FROM [Tickets].[ArbitrationReason]
        WHERE [arbitrationReasonActive] = 1
        ORDER BY [arbitrationReasonID];

        RETURN;
    END

    IF @pageName_ = N'QualityReviewResultDDL'
    BEGIN
        SELECT [qualityReviewResultID], [qualityReviewResultCode], [qualityReviewResultName_A], [qualityReviewResultName_E]
        FROM [Tickets].[QualityReviewResult]
        WHERE [qualityReviewResultActive] = 1
        ORDER BY [qualityReviewResultID];

        RETURN;
    END

    IF @pageName_ = N'RequesterTypeDDL'
    BEGIN
        SELECT [requesterTypeID], [requesterTypeCode], [requesterTypeName_A], [requesterTypeName_E]
        FROM [Tickets].[RequesterType]
        WHERE [requesterTypeActive] = 1
        ORDER BY [requesterTypeID];

        RETURN;
    END

    IF @pageName_ = N'TicketClassDDL'
    BEGIN
        SELECT [ticketClassID], [ticketClassCode], [ticketClassName_A], [ticketClassName_E]
        FROM [Tickets].[TicketClass]
        WHERE [ticketClassActive] = 1
        ORDER BY [ticketClassID];

        RETURN;
    END

    IF @pageName_ = N'PriorityDDL'
    BEGIN
        SELECT [priorityID], [priorityCode], [priorityName_A], [priorityName_E]
        FROM [Tickets].[Priority]
        WHERE [priorityActive] = 1
        ORDER BY [priorityID];

        RETURN;
    END

    IF @pageName_ = N'OpenArbitrations'
    BEGIN
        SELECT
              ac.[arbitrationCaseID]
            , ac.[ticketID_FK]
            , t.[ticketNo]
            , COALESCE(t.[title_A], t.[title]) AS [title]
            , COALESCE(ar.[arbitrationReasonName_A], ar.[arbitrationReasonName_E]) AS [arbitrationReasonName_E]
            , ac.[arbitrationStatus]
            , ac.[entryDate]
        FROM [Tickets].[ArbitrationCase] ac
        INNER JOIN [Tickets].[Ticket] t ON ac.[ticketID_FK] = t.[ticketID]
        LEFT JOIN [Tickets].[ArbitrationReason] ar ON ac.[arbitrationReasonID_FK] = ar.[arbitrationReasonID]
        WHERE ac.[arbitrationStatus] = N'OPEN'
          AND ac.[arbitrationCaseActive] = 1
          AND (ac.[idaraID_FK] = @idaraID OR @idaraID IS NULL)
        ORDER BY ac.[arbitrationCaseID] DESC;

        RETURN;
    END

    IF @pageName_ = N'PendingReviews'
    BEGIN
        SELECT
              qr.[qualityReviewID]
            , qr.[ticketID_FK]
            , t.[ticketNo]
            , COALESCE(t.[title_A], t.[title]) AS [title]
            , qr.[reviewScope]
            , qr.[entryDate]
        FROM [Tickets].[QualityReview] qr
        INNER JOIN [Tickets].[Ticket] t ON qr.[ticketID_FK] = t.[ticketID]
        WHERE qr.[finalized] = 0
          AND qr.[qualityReviewActive] = 1
          AND (qr.[idaraID_FK] = @idaraID OR @idaraID IS NULL)
        ORDER BY qr.[qualityReviewID] DESC;

        RETURN;
    END

    IF @pageName_ = N'BreachedSLAs'
    BEGIN
        SELECT
              sla.[ticketSLAID]
            , sla.[ticketID_FK]
            , t.[ticketNo]
            , COALESCE(t.[title_A], t.[title]) AS [title]
            , sla.[slaTypeCode]
            , sla.[targetMinutes]
            , sla.[elapsedMinutes]
            , sla.[isBreached]
            , sla.[slaStartDate]
        FROM [Tickets].[TicketSLA] sla
        INNER JOIN [Tickets].[Ticket] t ON sla.[ticketID_FK] = t.[ticketID]
        WHERE sla.[isBreached] = 1
          AND sla.[ticketSLAActive] = 1
          AND (sla.[idaraID_FK] = @idaraID OR @idaraID IS NULL)
        ORDER BY sla.[ticketSLAID] DESC;

        RETURN;
    END

    IF @pageName_ = N'TicketAdminLookup'
    BEGIN
        SELECT [ticketStatusID], [ticketStatusCode], [ticketStatusName_A], [ticketStatusName_E], [ticketStatusDesc], [ticketStatusActive], [entryDate]
        FROM [Tickets].[TicketStatus] ORDER BY [ticketStatusID];

        SELECT [pauseReasonID], [pauseReasonCode], [pauseReasonName_A], [pauseReasonName_E], [pauseReasonDesc], [pauseReasonActive], [entryDate]
        FROM [Tickets].[PauseReason] ORDER BY [pauseReasonID];

        SELECT [arbitrationReasonID], [arbitrationReasonCode], [arbitrationReasonName_A], [arbitrationReasonName_E], [arbitrationReasonDesc], [arbitrationReasonActive], [entryDate]
        FROM [Tickets].[ArbitrationReason] ORDER BY [arbitrationReasonID];

        SELECT [qualityReviewResultID], [qualityReviewResultCode], [qualityReviewResultName_A], [qualityReviewResultName_E], [qualityReviewResultDesc], [qualityReviewResultActive], [entryDate]
        FROM [Tickets].[QualityReviewResult] ORDER BY [qualityReviewResultID];

        SELECT [ticketClassID], [ticketClassCode], [ticketClassName_A], [ticketClassName_E], [ticketClassDesc], [ticketClassActive], [entryDate]
        FROM [Tickets].[TicketClass] ORDER BY [ticketClassID];

        SELECT [priorityID], [priorityCode], [priorityName_A], [priorityName_E], [priorityDesc], [priorityLevel], [priorityActive], [entryDate]
        FROM [Tickets].[Priority] ORDER BY [priorityLevel], [priorityID];

        RETURN;
    END

    IF @pageName_ = N'ResidentDDL'
    BEGIN
        SELECT DISTINCT
            r.[residentInfoID] AS [residentInfoID],
            r.[NationalID] AS [NationalID],
            r.[generalNo_FK] AS [generalNo_FK],
            r.[FullName_A] AS [FullName_A],
            r.[FullName_E] AS [FullName_E],
            r.[rankNameA] AS [rankNameA],
            r.[militaryUnitName_A] AS [militaryUnitName_A],
            ba.[BuildingNo] AS [BuildingNo]
        FROM [Housing].[V_GetFullResidentDetails] r
        INNER JOIN [DATACORE].[Housing].[BuildingAssign] ba
            ON r.[generalNo_FK] = ba.[GeneralNo]
        INNER JOIN [DATACORE].[Housing].[BuildingAssignStatus] bas
            ON ba.[BuildingAssignStatusID_FK] = bas.[BuildingAssignStatusID]
        WHERE r.[IdaraID] = @idaraID
          AND bas.[Active] = 1
        ORDER BY r.[FullName_A] ASC;

        RETURN;
    END

    IF @pageName_ = N'BuildingDDL'
    BEGIN
        SELECT
            bd.[buildingDetailsID] AS [buildingDetailsID],
            bd.[buildingDetailsNo] AS [buildingDetailsNo],
            bd.[buildingDetailsRooms] AS [buildingDetailsRooms],
            bt.[buildingTypeName_A] AS [buildingTypeName_A],
            m.[militaryLocationName_A] AS [militaryLocationName_A],
            bc.[buildingClassName_A] AS [buildingClassName_A]
        FROM [DATACORE].[Housing].[BuildingDetails] bd
        INNER JOIN [DATACORE].[Housing].[BuildingType] bt ON bd.[buildingTypeID_FK] = bt.[buildingTypeID]
        INNER JOIN [DATACORE].[Housing].[MilitaryLocation] m ON bd.[militaryLocationID_FK] = m.[militaryLocationID]
        INNER JOIN [DATACORE].[Housing].[BuildingClass] bc ON bd.[buildingClassID_FK] = bc.[buildingClassID]
        WHERE bd.[buildingDetailsActive] = 1
          AND bd.[IdaraId_FK] = @idaraID
          AND bt.[buildingTypeActive] = 1
          AND m.[militaryLocationActive] = 1
          AND bc.[buildingClassActive] = 1
        ORDER BY bd.[buildingDetailsNo] ASC;

        RETURN;
    END

    IF @pageName_ = N'TicketReasonDDL'
    BEGIN
        SELECT
            [ticketReasonID],
            [ticketReasonCode],
            [ticketReasonName_A],
            [ticketReasonName_E],
            [priorityID_FK]
        FROM [Tickets].[TicketReason]
        WHERE [ticketReasonActive] = 1
          AND ([idaraID_FK] = @idaraID OR [idaraID_FK] IS NULL)
        ORDER BY [displayOrder] ASC, [ticketReasonID] ASC;

        RETURN;
    END

    IF @pageName_ = N'TicketDescriptionTemplateDDL'
    BEGIN
        SELECT
            [templateID],
            [templateCode],
            [templateName_A],
            [templateName_E],
            [templateContent_A]
        FROM [Tickets].[TicketDescriptionTemplate]
        WHERE [templateActive] = 1
          AND ([idaraID_FK] = @idaraID OR [idaraID_FK] IS NULL)
        ORDER BY [displayOrder] ASC, [templateID] ASC;

        RETURN;
    END
END
GO

PRINT 'TicketDL updated successfully with fixed ResidentDDL!';
