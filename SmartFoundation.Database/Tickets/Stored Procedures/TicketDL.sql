CREATE PROCEDURE [Tickets].[TicketDL]
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
            , s.[serviceName_A]
            , s.[serviceName_E]
            , t.[ticketClassID_FK]
            , tc.[ticketClassName_A]
            , tc.[ticketClassName_E]
            , t.[requesterTypeID_FK]
            , rt.[requesterTypeName_A]
            , rt.[requesterTypeName_E]
            , t.[requesterUserID_FK]
            , t.[requesterResidentID_FK]
            , t.[title]
            , t.[description_]
            , t.[suggestedPriorityID_FK]
            , t.[effectivePriorityID_FK]
            , p.[priorityName_A]
            , p.[priorityName_E]
            , t.[ticketStatusID_FK]
            , ts.[ticketStatusCode]
            , ts.[ticketStatusName_A]
            , ts.[ticketStatusName_E]
            , t.[currentDSDID_FK]
            , t.[currentQueueDistributorID_FK]
            , t.[assignedUserID_FK]
            , t.[locationBuildingNo]
            , t.[locationUnitNo]
            , t.[locationArea]
            , t.[operationalResolutionDate]
            , t.[finalClosureDate]
            , t.[requiresQualityReview]
            , t.[isOtherService]
            , t.[isParentBlocked]
            , t.[ticketActive]
        FROM [Tickets].[Ticket] t
        LEFT JOIN [Tickets].[Service] s ON t.[serviceID_FK] = s.[serviceID]
        LEFT JOIN [Tickets].[TicketClass] tc ON t.[ticketClassID_FK] = tc.[ticketClassID]
        LEFT JOIN [Tickets].[RequesterType] rt ON t.[requesterTypeID_FK] = rt.[requesterTypeID]
        LEFT JOIN [Tickets].[Priority] p ON t.[effectivePriorityID_FK] = p.[priorityID]
        LEFT JOIN [Tickets].[TicketStatus] ts ON t.[ticketStatusID_FK] = ts.[ticketStatusID]
        WHERE t.[ticketActive] = 1
          AND (t.[idaraID_FK] = @idaraID OR @idaraID IS NULL)
          AND (t.[ticketID] = @filterTicketID OR @filterTicketID IS NULL)
          AND (t.[ticketNo] = @filterTicketNo OR @filterTicketNo IS NULL)
          AND (t.[ticketStatusID_FK] = @filterStatusID OR @filterStatusID IS NULL)
          AND (t.[serviceID_FK] = @filterServiceID OR @filterServiceID IS NULL)
          AND (t.[assignedUserID_FK] = @filterAssignedUserID OR @filterAssignedUserID IS NULL)
          AND (t.[currentDSDID_FK] = @filterDSDID OR @filterDSDID IS NULL)
        ORDER BY t.[ticketID] DESC;

        RETURN;
    END

    IF @pageName_ = N'TicketList'
    BEGIN
        SELECT
              t.[ticketID]
            , t.[ticketNo]
            , t.[title]
            , s.[serviceName_A]
            , s.[serviceName_E]
            , p.[priorityName_A]
            , ts.[ticketStatusName_A]
            , ts.[ticketStatusName_E]
            , t.[currentDSDID_FK]
            , t.[assignedUserID_FK]
            , t.[entryDate]
        FROM [Tickets].[Ticket] t
        LEFT JOIN [Tickets].[Service] s ON t.[serviceID_FK] = s.[serviceID]
        LEFT JOIN [Tickets].[Priority] p ON t.[effectivePriorityID_FK] = p.[priorityID]
        LEFT JOIN [Tickets].[TicketStatus] ts ON t.[ticketStatusID_FK] = ts.[ticketStatusID]
        WHERE t.[ticketActive] = 1
          AND (t.[idaraID_FK] = @idaraID OR @idaraID IS NULL)
          AND (t.[ticketStatusID_FK] = @filterStatusID OR @filterStatusID IS NULL)
          AND (t.[serviceID_FK] = @filterServiceID OR @filterServiceID IS NULL)
          AND (t.[currentDSDID_FK] = @filterDSDID OR @filterDSDID IS NULL)
        ORDER BY t.[ticketID] DESC;

        RETURN;
    END

    IF @pageName_ = N'TicketHistory'
    BEGIN
        SELECT
              th.[ticketHistoryID]
            , th.[ticketID_FK]
            , th.[actionTypeCode]
            , th.[oldStatusID_FK]
            , os.[ticketStatusCode]   AS [oldStatusCode]
            , os.[ticketStatusName_E] AS [oldStatusName_E]
            , th.[newStatusID_FK]
            , ns.[ticketStatusCode]   AS [newStatusCode]
            , ns.[ticketStatusName_E] AS [newStatusName_E]
            , th.[oldDSDID_FK]
            , th.[newDSDID_FK]
            , th.[oldAssignedUserID]
            , th.[newAssignedUserID]
            , th.[performerUserID]
            , th.[notes]
            , th.[actionDate]
        FROM [Tickets].[TicketHistory] th
        LEFT JOIN [Tickets].[TicketStatus] os ON th.[oldStatusID_FK] = os.[ticketStatusID]
        INNER JOIN [Tickets].[TicketStatus] ns ON th.[newStatusID_FK] = ns.[ticketStatusID]
        WHERE th.[ticketID_FK] = @filterTicketID
        ORDER BY th.[ticketHistoryID];

        RETURN;
    END

    IF @pageName_ = N'StatusDDL'
    BEGIN
        SELECT [ticketStatusID], [ticketStatusCode], [ticketStatusName_A], [ticketStatusName_E]
        FROM [Tickets].[TicketStatus]
        WHERE [ticketStatusActive] = 1
        ORDER BY [ticketStatusID];

        RETURN;
    END
END
