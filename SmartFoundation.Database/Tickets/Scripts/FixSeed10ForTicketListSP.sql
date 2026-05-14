SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRAN;

BEGIN TRY
    DECLARE @u1 INT = 25;
    DECLARE @u2 INT = 26;
    DECLARE @u3 INT = 27;
    DECLARE @u4 INT = 23;
    DECLARE @u5 INT = 22;
    DECLARE @u6 INT = 19;
    DECLARE @u7 INT = 20;
    DECLARE @u8 INT = 21;

    ;WITH t AS (
        SELECT [ticketID], ROW_NUMBER() OVER (ORDER BY [ticketID]) AS rn
        FROM [Tickets].[Ticket]
        WHERE [entryData] = N'SEED10'
    )
    UPDATE tk
    SET
        [requesterUserID_FK] = CASE t.rn
            WHEN 1 THEN @u1 WHEN 2 THEN @u2 WHEN 3 THEN @u3 WHEN 4 THEN @u4
            WHEN 5 THEN @u5 WHEN 6 THEN @u6 WHEN 7 THEN @u7 WHEN 8 THEN @u8
            WHEN 9 THEN @u1 ELSE @u2 END,
        [requesterResidentID_FK] = NULL,
        [assignedUserID_FK] = CASE t.rn
            WHEN 1 THEN @u3 WHEN 2 THEN @u4 WHEN 3 THEN @u5 WHEN 4 THEN @u6
            WHEN 5 THEN @u7 WHEN 6 THEN @u8 WHEN 7 THEN @u1 WHEN 8 THEN @u2
            WHEN 9 THEN @u3 ELSE @u4 END
    FROM [Tickets].[Ticket] tk
    INNER JOIN t ON t.[ticketID] = tk.[ticketID];

    UPDATE [Tickets].[TicketSLA]
    SET [slaTypeCode] = N'RESOLUTION'
    WHERE [entryData] = N'SEED10';

    COMMIT TRAN;

    SELECT TOP 10
          t.[ticketNo]
        , t.[requesterUserID_FK]
        , t.[assignedUserID_FK]
        , s.[slaTypeCode]
        , s.[elapsedMinutes]
    FROM [Tickets].[Ticket] t
    LEFT JOIN [Tickets].[TicketSLA] s ON s.[ticketID_FK] = t.[ticketID] AND s.[entryData] = N'SEED10'
    WHERE t.[entryData] = N'SEED10'
    ORDER BY t.[ticketID] DESC;

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;
    THROW;
END CATCH;
