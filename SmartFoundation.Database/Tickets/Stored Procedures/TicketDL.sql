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
            , p.[priorityCode]
            , t.[ticketStatusID_FK]
            , ts.[ticketStatusCode]
            , CASE
                WHEN ts.[ticketStatusName_A] IS NULL OR ts.[ticketStatusName_A] NOT LIKE N'%[ء-ي]%'
                  THEN ts.[ticketStatusName_E]
                ELSE ts.[ticketStatusName_A]
              END AS [ticketStatusName_A]
            , ts.[ticketStatusName_E]
            , t.[currentDSDID_FK]
            , t.[currentQueueDistributorID_FK]
            , t.[assignedUserID_FK]
            , LTRIM(RTRIM(
                  ISNULL(aud.firstName_A, N'') + N' ' +
                  ISNULL(aud.secondName_A, N'') + N' ' +
                  ISNULL(aud.thirdName_A, N'') + N' ' +
                  ISNULL(aud.lastName_A, N'')
              )) AS [assignedUserName]
            , t.[locationBuildingNo]
            , t.[locationUnitNo]
            , COALESCE(t.[locationArea_A], t.[locationArea]) AS [locationArea]
            , t.[operationalResolutionDate]
            , t.[finalClosureDate]
            , t.[requiresQualityReview]
            , t.[isOtherService]
            , t.[isParentBlocked]
            , t.[ticketActive]
            , svc.[allowsChildTickets]
            , sla.[elapsedMinutes]   AS [slaElapsedMinutes]
            , sla.[targetMinutes]    AS [slaTargetMinutes]
            , sla.[isBreached]       AS [slaIsBreached]
            , sla.[slaTypeCode]      AS [slaTypeCode]
            , t.[entryDate]
        FROM [Tickets].[Ticket] t
        LEFT JOIN [Tickets].[Service] svc ON t.[serviceID_FK] = svc.[serviceID]
        LEFT JOIN [Tickets].[TicketClass] tc ON t.[ticketClassID_FK] = tc.[ticketClassID]
        LEFT JOIN [Tickets].[RequesterType] rt ON t.[requesterTypeID_FK] = rt.[requesterTypeID]
        LEFT JOIN [Tickets].[Priority] p ON t.[effectivePriorityID_FK] = p.[priorityID]
        LEFT JOIN [Tickets].[TicketStatus] ts ON t.[ticketStatusID_FK] = ts.[ticketStatusID]
        -- Requester user name (latest details row)
        OUTER APPLY (
            SELECT TOP 1
                  CASE WHEN ud.firstName_A IS NULL OR ud.firstName_A NOT LIKE N'%[ء-ي]%' THEN ud.firstName_E ELSE ud.firstName_A END AS firstName_A
                , CASE WHEN ud.secondName_A IS NULL OR ud.secondName_A NOT LIKE N'%[ء-ي]%' THEN ud.secondName_E ELSE ud.secondName_A END AS secondName_A
                , CASE WHEN ud.thirdName_A IS NULL OR ud.thirdName_A NOT LIKE N'%[ء-ي]%' THEN ud.thirdName_E ELSE ud.thirdName_A END AS thirdName_A
                , CASE WHEN ud.lastName_A IS NULL OR ud.lastName_A NOT LIKE N'%[ء-ي]%' THEN ud.lastName_E ELSE ud.lastName_A END AS lastName_A
            FROM dbo.UsersDetails ud
            WHERE ud.usersID_FK = t.[requesterUserID_FK]
            ORDER BY ud.entryDate DESC, ud.usersDetailsID DESC
        ) rud
        -- Assigned user name (latest details row)
        OUTER APPLY (
            SELECT TOP 1
                  CASE WHEN ud.firstName_A IS NULL OR ud.firstName_A NOT LIKE N'%[ء-ي]%' THEN ud.firstName_E ELSE ud.firstName_A END AS firstName_A
                , CASE WHEN ud.secondName_A IS NULL OR ud.secondName_A NOT LIKE N'%[ء-ي]%' THEN ud.secondName_E ELSE ud.secondName_A END AS secondName_A
                , CASE WHEN ud.thirdName_A IS NULL OR ud.thirdName_A NOT LIKE N'%[ء-ي]%' THEN ud.thirdName_E ELSE ud.thirdName_A END AS thirdName_A
                , CASE WHEN ud.lastName_A IS NULL OR ud.lastName_A NOT LIKE N'%[ء-ي]%' THEN ud.lastName_E ELSE ud.lastName_A END AS lastName_A
            FROM dbo.UsersDetails ud
            WHERE ud.usersID_FK = t.[assignedUserID_FK]
            ORDER BY ud.entryDate DESC, ud.usersDetailsID DESC
        ) aud
        -- Resolution SLA
        OUTER APPLY (
            SELECT TOP 1 sl.[elapsedMinutes], sl.[targetMinutes], sl.[isBreached], sl.[slaTypeCode]
            FROM [Tickets].[TicketSLA] sl
            WHERE sl.[ticketID_FK] = t.[ticketID]
              AND sl.[slaTypeCode] = N'RESOLUTION'
              AND sl.[ticketSLAActive] = 1
        ) sla
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
            , COALESCE(t.[title_A], t.[title]) AS [title]
            , CASE
                WHEN s.[serviceName_A] IS NULL OR s.[serviceName_A] NOT LIKE N'%[ء-ي]%'
                  THEN s.[serviceName_E]
                ELSE s.[serviceName_A]
              END AS [serviceName_A]
            , s.[serviceName_E]
            , CASE
                WHEN rt.[requesterTypeName_A] IS NULL OR rt.[requesterTypeName_A] NOT LIKE N'%[ء-ي]%'
                  THEN rt.[requesterTypeName_E]
                ELSE rt.[requesterTypeName_A]
              END AS [requesterTypeName_A]
            , rt.[requesterTypeName_E]
            , LTRIM(RTRIM(
                  ISNULL(rud.firstName_A, N'') + N' ' +
                  ISNULL(rud.secondName_A, N'') + N' ' +
                  ISNULL(rud.thirdName_A, N'') + N' ' +
                  ISNULL(rud.lastName_A, N'')
              )) AS [requesterName]
            , CASE
                WHEN p.[priorityName_A] IS NULL OR p.[priorityName_A] NOT LIKE N'%[ء-ي]%'
                  THEN p.[priorityName_E]
                ELSE p.[priorityName_A]
              END AS [priorityName_A]
            , p.[priorityName_E]
            , CASE
                WHEN ts.[ticketStatusName_A] IS NULL OR ts.[ticketStatusName_A] NOT LIKE N'%[ء-ي]%'
                  THEN ts.[ticketStatusName_E]
                ELSE ts.[ticketStatusName_A]
              END AS [ticketStatusName_A]
            , ts.[ticketStatusName_E]
            , ts.[ticketStatusCode]
            , LTRIM(RTRIM(
                  ISNULL(aud.firstName_A, N'') + N' ' +
                  ISNULL(aud.secondName_A, N'') + N' ' +
                  ISNULL(aud.thirdName_A, N'') + N' ' +
                  ISNULL(aud.lastName_A, N'')
              )) AS [assignedUserName]
            , sla.[elapsedMinutes]
            , t.[currentDSDID_FK]
            , t.[assignedUserID_FK]
            , t.[entryDate]
        FROM [Tickets].[Ticket] t
        LEFT JOIN [Tickets].[Service] s ON t.[serviceID_FK] = s.[serviceID]
        LEFT JOIN [Tickets].[Priority] p ON t.[effectivePriorityID_FK] = p.[priorityID]
        LEFT JOIN [Tickets].[TicketStatus] ts ON t.[ticketStatusID_FK] = ts.[ticketStatusID]
        LEFT JOIN [Tickets].[RequesterType] rt ON t.[requesterTypeID_FK] = rt.[requesterTypeID]
        -- Requester user name (latest details row)
        OUTER APPLY (
            SELECT TOP 1
                  CASE WHEN ud.firstName_A IS NULL OR ud.firstName_A NOT LIKE N'%[ء-ي]%' THEN ud.firstName_E ELSE ud.firstName_A END AS firstName_A
                , CASE WHEN ud.secondName_A IS NULL OR ud.secondName_A NOT LIKE N'%[ء-ي]%' THEN ud.secondName_E ELSE ud.secondName_A END AS secondName_A
                , CASE WHEN ud.thirdName_A IS NULL OR ud.thirdName_A NOT LIKE N'%[ء-ي]%' THEN ud.thirdName_E ELSE ud.thirdName_A END AS thirdName_A
                , CASE WHEN ud.lastName_A IS NULL OR ud.lastName_A NOT LIKE N'%[ء-ي]%' THEN ud.lastName_E ELSE ud.lastName_A END AS lastName_A
            FROM dbo.UsersDetails ud
            WHERE ud.usersID_FK = t.[requesterUserID_FK]
            ORDER BY ud.entryDate DESC, ud.usersDetailsID DESC
        ) rud
        -- Assigned user name (latest details row)
        OUTER APPLY (
            SELECT TOP 1
                  CASE WHEN ud.firstName_A IS NULL OR ud.firstName_A NOT LIKE N'%[ء-ي]%' THEN ud.firstName_E ELSE ud.firstName_A END AS firstName_A
                , CASE WHEN ud.secondName_A IS NULL OR ud.secondName_A NOT LIKE N'%[ء-ي]%' THEN ud.secondName_E ELSE ud.secondName_A END AS secondName_A
                , CASE WHEN ud.thirdName_A IS NULL OR ud.thirdName_A NOT LIKE N'%[ء-ي]%' THEN ud.thirdName_E ELSE ud.thirdName_A END AS thirdName_A
                , CASE WHEN ud.lastName_A IS NULL OR ud.lastName_A NOT LIKE N'%[ء-ي]%' THEN ud.lastName_E ELSE ud.lastName_A END AS lastName_A
            FROM dbo.UsersDetails ud
            WHERE ud.usersID_FK = t.[assignedUserID_FK]
            ORDER BY ud.entryDate DESC, ud.usersDetailsID DESC
        ) aud
        -- Resolution SLA elapsed minutes
        OUTER APPLY (
            SELECT TOP 1 sl.[elapsedMinutes]
            FROM [Tickets].[TicketSLA] sl
            WHERE sl.[ticketID_FK] = t.[ticketID]
              AND sl.[slaTypeCode] = N'RESOLUTION'
              AND sl.[ticketSLAActive] = 1
        ) sla
        WHERE t.[ticketActive] = 1
          AND (t.[idaraID_FK] = @idaraID OR @idaraID IS NULL)
          AND (t.[ticketStatusID_FK] = @filterStatusID OR @filterStatusID IS NULL)
          AND (t.[serviceID_FK] = @filterServiceID OR @filterServiceID IS NULL)
          AND (t.[currentDSDID_FK] = @filterDSDID OR @filterDSDID IS NULL)
        ORDER BY t.[ticketID] DESC;

        SELECT [ticketStatusID], [ticketStatusName_A], [ticketStatusName_E]
        FROM [Tickets].[TicketStatus]
        WHERE [ticketStatusActive] = 1
        ORDER BY [ticketStatusID];

        SELECT [serviceID], [serviceName_A], [serviceName_E]
        FROM [Tickets].[Service]
        WHERE [serviceActive] = 1
          AND ([idaraID_FK] = @idaraID OR @idaraID IS NULL OR [idaraID_FK] IS NULL)
        ORDER BY [serviceID];

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
            , COALESCE(os.[ticketStatusName_A], os.[ticketStatusName_E]) AS [oldStatusName_E]
            , os.[ticketStatusName_A] AS [oldStatusName_A]
            , th.[newStatusID_FK]
            , ns.[ticketStatusCode]   AS [newStatusCode]
            , COALESCE(ns.[ticketStatusName_A], ns.[ticketStatusName_E]) AS [newStatusName_E]
            , ns.[ticketStatusName_A] AS [newStatusName_A]
            , th.[oldDSDID_FK]
            , th.[newDSDID_FK]
            , th.[oldAssignedUserID]
            , th.[newAssignedUserID]
            , th.[performerUserID]
            , LTRIM(RTRIM(
                  ISNULL(pud.firstName_A, N'') + N' ' +
                  ISNULL(pud.secondName_A, N'') + N' ' +
                  ISNULL(pud.thirdName_A, N'') + N' ' +
                  ISNULL(pud.lastName_A, N'')
              )) AS [performerName]
            , COALESCE(
                NULLIF(th.[notes_A], N''),
                CASE th.[notes]
                  WHEN N'Ticket created' THEN N'Ã˜ÂªÃ™â€¦ Ã˜Â¥Ã™â€ Ã˜Â´Ã˜Â§Ã˜Â¡ Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â°Ã™Æ’Ã˜Â±Ã˜Â©'
                  WHEN N'Ticket routed' THEN N'Ã˜ÂªÃ™â€¦ Ã˜ÂªÃ™Ë†Ã˜Â¬Ã™Å Ã™â€¡ Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â°Ã™Æ’Ã˜Â±Ã˜Â©'
                  WHEN N'Ticket assigned' THEN N'Ã˜ÂªÃ™â€¦ Ã˜Â¥Ã˜Â³Ã™â€ Ã˜Â§Ã˜Â¯ Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â°Ã™Æ’Ã˜Â±Ã˜Â©'
                  WHEN N'Ticket reassigned' THEN N'Ã˜ÂªÃ™â€¦Ã˜Âª Ã˜Â¥Ã˜Â¹Ã˜Â§Ã˜Â¯Ã˜Â© Ã˜Â¥Ã˜Â³Ã™â€ Ã˜Â§Ã˜Â¯ Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â°Ã™Æ’Ã˜Â±Ã˜Â©'
                  WHEN N'Work started' THEN N'Ã˜ÂªÃ™â€¦ Ã˜Â¨Ã˜Â¯Ã˜Â¡ Ã˜Â§Ã™â€žÃ˜Â¹Ã™â€¦Ã™â€ž'
                  WHEN N'Ticket resolved - awaiting quality review' THEN N'Ã˜ÂªÃ™â€¦ Ã˜Â­Ã™â€ž Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â°Ã™Æ’Ã˜Â±Ã˜Â© - Ã˜Â¨Ã˜Â§Ã™â€ Ã˜ÂªÃ˜Â¸Ã˜Â§Ã˜Â± Ã™â€¦Ã˜Â±Ã˜Â§Ã˜Â¬Ã˜Â¹Ã˜Â© Ã˜Â§Ã™â€žÃ˜Â¬Ã™Ë†Ã˜Â¯Ã˜Â©'
                  WHEN N'Ticket resolved and closed' THEN N'Ã˜ÂªÃ™â€¦ Ã˜Â­Ã™â€ž Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â°Ã™Æ’Ã˜Â±Ã˜Â© Ã™Ë†Ã˜Â¥Ã˜ÂºÃ™â€žÃ˜Â§Ã™â€šÃ™â€¡Ã˜Â§'
                  WHEN N'Ticket closed' THEN N'Ã˜ÂªÃ™â€¦ Ã˜Â¥Ã˜ÂºÃ™â€žÃ˜Â§Ã™â€š Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â°Ã™Æ’Ã˜Â±Ã˜Â©'
                  WHEN N'Ticket paused' THEN N'Ã˜ÂªÃ™â€¦ Ã˜Â¥Ã™Å Ã™â€šÃ˜Â§Ã™Â Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â°Ã™Æ’Ã˜Â±Ã˜Â©'
                  WHEN N'Ticket resumed' THEN N'Ã˜ÂªÃ™â€¦ Ã˜Â§Ã˜Â³Ã˜ÂªÃ˜Â¦Ã™â€ Ã˜Â§Ã™Â Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â°Ã™Æ’Ã˜Â±Ã˜Â©'
                  WHEN N'Child ticket created' THEN N'Ã˜ÂªÃ™â€¦ Ã˜Â¥Ã™â€ Ã˜Â´Ã˜Â§Ã˜Â¡ Ã˜ÂªÃ˜Â°Ã™Æ’Ã˜Â±Ã˜Â© Ã™ÂÃ˜Â±Ã˜Â¹Ã™Å Ã˜Â©'
                  WHEN N'Quality review approved - ticket closed' THEN N'Ã˜ÂªÃ™â€¦ Ã˜Â§Ã˜Â¹Ã˜ÂªÃ™â€¦Ã˜Â§Ã˜Â¯ Ã™â€¦Ã˜Â±Ã˜Â§Ã˜Â¬Ã˜Â¹Ã˜Â© Ã˜Â§Ã™â€žÃ˜Â¬Ã™Ë†Ã˜Â¯Ã˜Â© - Ã˜ÂªÃ™â€¦ Ã˜Â¥Ã˜ÂºÃ™â€žÃ˜Â§Ã™â€š Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â°Ã™Æ’Ã˜Â±Ã˜Â©'
                  WHEN N'Quality review returned for correction' THEN N'Ã˜ÂªÃ™â€¦ Ã˜Â¥Ã˜Â±Ã˜Â¬Ã˜Â§Ã˜Â¹ Ã™â€¦Ã˜Â±Ã˜Â§Ã˜Â¬Ã˜Â¹Ã˜Â© Ã˜Â§Ã™â€žÃ˜Â¬Ã™Ë†Ã˜Â¯Ã˜Â© Ã™â€žÃ™â€žÃ˜ÂªÃ˜ÂµÃ˜Â­Ã™Å Ã˜Â­'
                  WHEN N'Quality review escalated to arbitration' THEN N'Ã˜ÂªÃ™â€¦ Ã˜ÂªÃ˜ÂµÃ˜Â¹Ã™Å Ã˜Â¯ Ã™â€¦Ã˜Â±Ã˜Â§Ã˜Â¬Ã˜Â¹Ã˜Â© Ã˜Â§Ã™â€žÃ˜Â¬Ã™Ë†Ã˜Â¯Ã˜Â© Ã˜Â¥Ã™â€žÃ™â€° Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â­Ã™Æ’Ã™Å Ã™â€¦'
                  WHEN N'Arbitration raised' THEN N'Ã˜ÂªÃ™â€¦ Ã˜Â±Ã™ÂÃ˜Â¹ Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â­Ã™Æ’Ã™Å Ã™â€¦'
                  WHEN N'Arbitration decided' THEN N'Ã˜ÂªÃ™â€¦ Ã˜Â§Ã˜ÂªÃ˜Â®Ã˜Â§Ã˜Â° Ã™â€šÃ˜Â±Ã˜Â§Ã˜Â± Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â­Ã™Æ’Ã™Å Ã™â€¦'
                  ELSE th.[notes]
                END
              ) AS [notes]
            , th.[actionDate]
        FROM [Tickets].[TicketHistory] th
        LEFT JOIN [Tickets].[TicketStatus] os ON th.[oldStatusID_FK] = os.[ticketStatusID]
        LEFT JOIN [Tickets].[TicketStatus] ns ON th.[newStatusID_FK] = ns.[ticketStatusID]
        OUTER APPLY (
            SELECT TOP 1
                  CASE WHEN ud.firstName_A IS NULL OR ud.firstName_A NOT LIKE N'%[ء-ي]%' THEN ud.firstName_E ELSE ud.firstName_A END AS firstName_A
                , CASE WHEN ud.secondName_A IS NULL OR ud.secondName_A NOT LIKE N'%[ء-ي]%' THEN ud.secondName_E ELSE ud.secondName_A END AS secondName_A
                , CASE WHEN ud.thirdName_A IS NULL OR ud.thirdName_A NOT LIKE N'%[ء-ي]%' THEN ud.thirdName_E ELSE ud.thirdName_A END AS thirdName_A
                , CASE WHEN ud.lastName_A IS NULL OR ud.lastName_A NOT LIKE N'%[ء-ي]%' THEN ud.lastName_E ELSE ud.lastName_A END AS lastName_A
            FROM dbo.UsersDetails ud
            WHERE ud.usersID_FK = th.[performerUserID]
            ORDER BY ud.entryDate DESC, ud.usersDetailsID DESC
        ) pud
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

    IF @pageName_ = N'ChildTickets'
    BEGIN
        SELECT
              ct.[ticketID]
            , ct.[ticketNo]
            , COALESCE(ct.[title_A], ct.[title]) AS [title]
            , ts.[ticketStatusCode]
            , COALESCE(ts.[ticketStatusName_A], ts.[ticketStatusName_E]) AS [ticketStatusName_E]
            , ts.[ticketStatusName_A]
            , COALESCE(p.[priorityName_A], p.[priorityName_E]) AS [priorityName_E]
            , ct.[entryDate]
        FROM [Tickets].[Ticket] ct
        LEFT JOIN [Tickets].[TicketStatus] ts ON ct.[ticketStatusID_FK] = ts.[ticketStatusID]
        LEFT JOIN [Tickets].[Priority] p ON ct.[effectivePriorityID_FK] = p.[priorityID]
        WHERE ct.[parentTicketID_FK] = @filterTicketID
          AND ct.[ticketActive] = 1
        ORDER BY ct.[ticketID] DESC;

        RETURN;
    END

    IF @pageName_ = N'PauseSessions'
    BEGIN
        SELECT
              ps.[ticketPauseSessionID]
            , ps.[ticketID_FK]
            , pr.[pauseReasonName_A]
            , pr.[pauseReasonName_E]
            , ps.[relatedChildTicketID_FK]
            , ps.[relatedArbitrationCaseID_FK]
            , ps.[relatedClarificationRequestID_FK]
            , ps.[pauseStart]
            , ps.[pauseEnd]
            , ps.[slaPauseFlag]
            , COALESCE(ps.[pauseNotes_A], ps.[pauseNotes]) AS [pauseNotes]
            , ps.[ticketPauseSessionActive]
        FROM [Tickets].[TicketPauseSession] ps
        LEFT JOIN [Tickets].[PauseReason] pr ON ps.[pauseReasonID_FK] = pr.[pauseReasonID]
        WHERE ps.[ticketID_FK] = @filterTicketID
        ORDER BY ps.[ticketPauseSessionID] DESC;

        RETURN;
    END

    IF @pageName_ = N'TicketSLAs'
    BEGIN
        SELECT
              sla.[ticketSLAID]
            , sla.[ticketID_FK]
            , sla.[slaTypeCode]
            , sla.[targetMinutes]
            , sla.[elapsedMinutes]
            , sla.[remainingMinutes]
            , sla.[isBreached]
            , sla.[slaStartDate]
            , sla.[slaStopDate]
            , sla.[slaCompletionDate]
            , sla.[ticketSLAActive]
        FROM [Tickets].[TicketSLA] sla
        WHERE sla.[ticketID_FK] = @filterTicketID
          AND sla.[ticketSLAActive] = 1
        ORDER BY sla.[ticketSLAID];

        RETURN;
    END

    IF @pageName_ = N'QualityReviews'
    BEGIN
        SELECT
              qr.[qualityReviewID]
            , qr.[ticketID_FK]
            , qr.[reviewerUserID]
            , qr.[reviewScope]
            , qr.[qualityReviewResultID_FK]
            , qrr.[qualityReviewResultCode]
            , qrr.[qualityReviewResultName_A]
            , qrr.[qualityReviewResultName_E]
            , qr.[reviewNotes]
            , qr.[returnToUserID]
            , qr.[finalized]
            , qr.[entryDate]
        FROM [Tickets].[QualityReview] qr
        LEFT JOIN [Tickets].[QualityReviewResult] qrr ON qr.[qualityReviewResultID_FK] = qrr.[qualityReviewResultID]
        WHERE qr.[ticketID_FK] = @filterTicketID
          AND qr.[qualityReviewActive] = 1
        ORDER BY qr.[qualityReviewID] DESC;

        RETURN;
    END

    IF @pageName_ = N'ArbitrationCases'
    BEGIN
        SELECT
              ac.[arbitrationCaseID]
            , ac.[ticketID_FK]
            , ac.[raisedByUserID]
            , ac.[raisedFromDSDID_FK]
            , ar.[arbitrationReasonName_A]
            , ar.[arbitrationReasonName_E]
            , ac.[arbitratorDistributorID]
            , ac.[arbitrationStatus]
            , ac.[decisionType]
            , ac.[decisionTargetDSDID_FK]
            , ac.[decisionNotes]
            , ac.[decisionDate]
            , ac.[entryDate]
        FROM [Tickets].[ArbitrationCase] ac
        LEFT JOIN [Tickets].[ArbitrationReason] ar ON ac.[arbitrationReasonID_FK] = ar.[arbitrationReasonID]
        WHERE ac.[ticketID_FK] = @filterTicketID
          AND ac.[arbitrationCaseActive] = 1
        ORDER BY ac.[arbitrationCaseID] DESC;

        RETURN;
    END

    IF @pageName_ = N'TicketAttachments'
    BEGIN
        SELECT
              ta.[ticketAttachmentID]
            , ta.[ticketID_FK]
            , ta.[fileName]
            , ta.[storedFileName]
            , ta.[filePath]
            , ta.[fileSizeBytes]
            , ta.[contentType]
            , ta.[uploadedByUserID]
            , ta.[attachmentType]
            , ta.[entryDate]
        FROM [Tickets].[TicketAttachment] ta
        WHERE ta.[ticketID_FK] = @filterTicketID
          AND ta.[ticketAttachmentActive] = 1
        ORDER BY ta.[ticketAttachmentID] DESC;

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
      ;WITH ResidentHousing AS
      (
        SELECT
          r.[residentInfoID] AS [residentInfoID],
          r.[NationalID] AS [NationalID],
          r.[generalNo_FK] AS [generalNo_FK],
          r.[FullName_A] AS [ResidentName_A],
          r.[FullName_E] AS [FullName_E],
          r.[rankNameA] AS [rankNameA],
          r.[militaryUnitName_A] AS [militaryUnitName_A],
                CASE
                    WHEN ba.[BuildingNo] IS NULL
                      OR LTRIM(RTRIM(CONVERT(NVARCHAR(100), ba.[BuildingNo]))) = N''
                      OR CONVERT(NVARCHAR(100), ba.[BuildingNo]) = N'No_house'
                    THEN N'بدون سكن'
                    ELSE CONVERT(NVARCHAR(100), ba.[BuildingNo])
                END AS [BuildingNo],
          ROW_NUMBER() OVER
          (
            PARTITION BY r.[residentInfoID]
            ORDER BY
              CASE
                WHEN ba.[BuildingNo] IS NULL
                  OR LTRIM(RTRIM(CONVERT(NVARCHAR(100), ba.[BuildingNo]))) = N''
                  OR CONVERT(NVARCHAR(100), ba.[BuildingNo]) = N'No_house'
                THEN 1 ELSE 0
              END,
              ba.[BuildingAssignDate] DESC,
              ba.[BuildingAssignID] DESC
          ) AS [rn]
        FROM [Housing].[V_GetFullResidentDetails] r
        INNER JOIN [DATACORE].[Housing].[BuildingAssign] ba
          ON r.[generalNo_FK] = ba.[GeneralNo]
        INNER JOIN [DATACORE].[Housing].[BuildingAssignStatus] bas
          ON ba.[BuildingAssignStatusID_FK] = bas.[BuildingAssignStatusID]
        WHERE r.[IdaraID] = @idaraID
          AND bas.[Active] = 1
      )
      SELECT
        rh.[residentInfoID] AS [residentInfoID],
        rh.[NationalID] AS [NationalID],
        rh.[generalNo_FK] AS [generalNo_FK],
        rh.[ResidentName_A] AS [ResidentName_A],
        rh.[ResidentName_A]
          + N' | هوية: '
          + COALESCE(NULLIF(rh.[NationalID], N''), CONVERT(NVARCHAR(50), rh.[generalNo_FK]), N'-')
          + N' | السكن: '
          + COALESCE(NULLIF(rh.[BuildingNo], N''), N'بدون سكن') AS [FullName_A],
        rh.[ResidentName_A]
          + N' | هوية: '
          + COALESCE(NULLIF(rh.[NationalID], N''), CONVERT(NVARCHAR(50), rh.[generalNo_FK]), N'-')
          + N' | السكن: '
          + COALESCE(NULLIF(rh.[BuildingNo], N''), N'بدون سكن') AS [ResidentDisplay],
        rh.[FullName_E] AS [FullName_E],
        rh.[rankNameA] AS [rankNameA],
        rh.[militaryUnitName_A] AS [militaryUnitName_A],
        rh.[BuildingNo] AS [BuildingNo]
      FROM ResidentHousing rh
      WHERE rh.[rn] = 1
      ORDER BY rh.[ResidentName_A] ASC;

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





