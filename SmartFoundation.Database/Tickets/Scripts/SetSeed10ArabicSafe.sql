SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRAN;

BEGIN TRY
    ;WITH s AS (
        SELECT [serviceID], ROW_NUMBER() OVER (ORDER BY [serviceID]) AS rn
        FROM [Tickets].[Service]
        WHERE [entryData] = N'SEED10'
    )
    UPDATE t
    SET [serviceName_A] =
        NCHAR(1582) + NCHAR(1583) + NCHAR(1605) + NCHAR(1577) + N' ' +
        NCHAR(1585) + NCHAR(1602) + NCHAR(1605) + N' ' +
        CAST(s.rn AS NVARCHAR(10))
    FROM [Tickets].[Service] t
    INNER JOIN s ON s.[serviceID] = t.[serviceID];

    ;WITH r AS (
        SELECT [requesterTypeID], ROW_NUMBER() OVER (ORDER BY [requesterTypeID]) AS rn
        FROM [Tickets].[RequesterType]
        WHERE [entryData] = N'SEED10'
    )
    UPDATE t
    SET [requesterTypeName_A] =
        NCHAR(1606) + NCHAR(1608) + NCHAR(1593) + N' ' +
        NCHAR(1605) + NCHAR(1602) + NCHAR(1583) + NCHAR(1605) + N' ' +
        NCHAR(1575) + NCHAR(1604) + NCHAR(1591) + NCHAR(1604) + N' ' +
        CAST(r.rn AS NVARCHAR(10))
    FROM [Tickets].[RequesterType] t
    INNER JOIN r ON r.[requesterTypeID] = t.[requesterTypeID];

    ;WITH p AS (
        SELECT [priorityID], ROW_NUMBER() OVER (ORDER BY [priorityID]) AS rn
        FROM [Tickets].[Priority]
        WHERE [entryData] = N'SEED10'
    )
    UPDATE t
    SET [priorityName_A] =
        NCHAR(1571) + NCHAR(1608) + NCHAR(1604) + NCHAR(1608) + NCHAR(1610) + NCHAR(1577) + N' ' +
        CAST(p.rn AS NVARCHAR(10))
    FROM [Tickets].[Priority] t
    INNER JOIN p ON p.[priorityID] = t.[priorityID];

    ;WITH c AS (
        SELECT [ticketClassID], ROW_NUMBER() OVER (ORDER BY [ticketClassID]) AS rn
        FROM [Tickets].[TicketClass]
        WHERE [entryData] = N'SEED10'
    )
    UPDATE t
    SET [ticketClassName_A] =
        NCHAR(1601) + NCHAR(1574) + NCHAR(1577) + N' ' +
        CAST(c.rn AS NVARCHAR(10))
    FROM [Tickets].[TicketClass] t
    INNER JOIN c ON c.[ticketClassID] = t.[ticketClassID];

    ;WITH x AS (
        SELECT [ticketID], ROW_NUMBER() OVER (ORDER BY [ticketID]) AS rn
        FROM [Tickets].[Ticket]
        WHERE [entryData] = N'SEED10'
    )
    UPDATE t
    SET
        [title_A] = NCHAR(1578) + NCHAR(1584) + NCHAR(1603) + NCHAR(1585) + NCHAR(1577) + N' ' + NCHAR(1585) + NCHAR(1602) + NCHAR(1605) + N' ' + CAST(x.rn AS NVARCHAR(10)),
        [title] = NCHAR(1578) + NCHAR(1584) + NCHAR(1603) + NCHAR(1585) + NCHAR(1577) + N' ' + NCHAR(1585) + NCHAR(1602) + NCHAR(1605) + N' ' + CAST(x.rn AS NVARCHAR(10)),
        [description_A] = NCHAR(1608) + NCHAR(1589) + NCHAR(1601) + N' ' + NCHAR(1593) + NCHAR(1585) + NCHAR(1576) + NCHAR(1610) + N' ' + CAST(x.rn AS NVARCHAR(10)),
        [description_] = NCHAR(1608) + NCHAR(1589) + NCHAR(1601) + N' ' + NCHAR(1593) + NCHAR(1585) + NCHAR(1576) + NCHAR(1610) + N' ' + CAST(x.rn AS NVARCHAR(10)),
        [locationArea_A] = NCHAR(1605) + NCHAR(1606) + NCHAR(1591) + NCHAR(1602) + NCHAR(1577) + N' ' + CAST(x.rn AS NVARCHAR(10)),
        [locationArea] = NCHAR(1605) + NCHAR(1606) + NCHAR(1591) + NCHAR(1602) + NCHAR(1577) + N' ' + CAST(x.rn AS NVARCHAR(10))
    FROM [Tickets].[Ticket] t
    INNER JOIN x ON x.[ticketID] = t.[ticketID];

    ;WITH h AS (
        SELECT [ticketHistoryID], ROW_NUMBER() OVER (ORDER BY [ticketHistoryID]) AS rn
        FROM [Tickets].[TicketHistory]
        WHERE [entryData] = N'SEED10'
    )
    UPDATE t
    SET
        [notes_A] = NCHAR(1605) + NCHAR(1604) + NCHAR(1575) + NCHAR(1581) + NCHAR(1592) + NCHAR(1577) + N' ' + CAST(h.rn AS NVARCHAR(10)),
        [notes] = NCHAR(1605) + NCHAR(1604) + NCHAR(1575) + NCHAR(1581) + NCHAR(1592) + NCHAR(1577) + N' ' + CAST(h.rn AS NVARCHAR(10))
    FROM [Tickets].[TicketHistory] t
    INNER JOIN h ON h.[ticketHistoryID] = t.[ticketHistoryID];

    ;WITH ps AS (
        SELECT [ticketPauseSessionID], ROW_NUMBER() OVER (ORDER BY [ticketPauseSessionID]) AS rn
        FROM [Tickets].[TicketPauseSession]
        WHERE [entryData] = N'SEED10'
    )
    UPDATE t
    SET
        [pauseNotes_A] = NCHAR(1573) + NCHAR(1610) + NCHAR(1602) + NCHAR(1575) + NCHAR(1601) + N' ' + NCHAR(1605) + NCHAR(1572) + NCHAR(1602) + NCHAR(1578) + N' ' + CAST(ps.rn AS NVARCHAR(10)),
        [pauseNotes] = NCHAR(1573) + NCHAR(1610) + NCHAR(1602) + NCHAR(1575) + NCHAR(1601) + N' ' + NCHAR(1605) + NCHAR(1572) + NCHAR(1602) + NCHAR(1578) + N' ' + CAST(ps.rn AS NVARCHAR(10))
    FROM [Tickets].[TicketPauseSession] t
    INNER JOIN ps ON ps.[ticketPauseSessionID] = t.[ticketPauseSessionID];

    COMMIT TRAN;

    SELECT TOP 10
        t.[ticketNo],
        s.[serviceName_A],
        rt.[requesterTypeName_A],
        p.[priorityName_A],
        t.[title],
        t.[locationArea]
    FROM [Tickets].[Ticket] t
    LEFT JOIN [Tickets].[Service] s ON s.[serviceID] = t.[serviceID_FK]
    LEFT JOIN [Tickets].[RequesterType] rt ON rt.[requesterTypeID] = t.[requesterTypeID_FK]
    LEFT JOIN [Tickets].[Priority] p ON p.[priorityID] = t.[effectivePriorityID_FK]
    WHERE t.[entryData] = N'SEED10'
    ORDER BY t.[ticketID] DESC;

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;
    THROW;
END CATCH;
