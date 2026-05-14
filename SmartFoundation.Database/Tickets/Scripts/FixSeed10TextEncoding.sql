SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRAN;

BEGIN TRY
    -- Normalize TicketStatus Arabic labels for SEED10 fallback rows (if any were inserted)
    UPDATE [Tickets].[TicketStatus]
    SET [ticketStatusName_A] = [ticketStatusName_E]
    WHERE [entryData] = N'SEED10';

    -- Normalize lookup Arabic labels to ASCII-safe readable values
    UPDATE [Tickets].[TicketClass]
    SET [ticketClassName_A] = [ticketClassName_E]
    WHERE [entryData] = N'SEED10';

    UPDATE [Tickets].[RequesterType]
    SET [requesterTypeName_A] = [requesterTypeName_E]
    WHERE [entryData] = N'SEED10';

    UPDATE [Tickets].[Priority]
    SET [priorityName_A] = [priorityName_E]
    WHERE [entryData] = N'SEED10';

    UPDATE [Tickets].[PauseReason]
    SET [pauseReasonName_A] = [pauseReasonName_E]
    WHERE [entryData] = N'SEED10';

    UPDATE [Tickets].[ArbitrationReason]
    SET [arbitrationReasonName_A] = [arbitrationReasonName_E]
    WHERE [entryData] = N'SEED10';

    UPDATE [Tickets].[ClarificationReason]
    SET [clarificationReasonName_A] = [clarificationReasonName_E]
    WHERE [entryData] = N'SEED10';

    UPDATE [Tickets].[QualityReviewResult]
    SET [qualityReviewResultName_A] = [qualityReviewResultName_E]
    WHERE [entryData] = N'SEED10';

    UPDATE [Tickets].[Service]
    SET [serviceName_A] = [serviceName_E]
    WHERE [entryData] = N'SEED10';

    -- Normalize transactional Arabic fields to match readable source columns
    UPDATE [Tickets].[Ticket]
    SET
        [title_A] = [title],
        [description_A] = [description_],
        [locationArea_A] = [locationArea]
    WHERE [entryData] = N'SEED10';

    UPDATE [Tickets].[TicketHistory]
    SET [notes_A] = [notes]
    WHERE [entryData] = N'SEED10';

    UPDATE [Tickets].[TicketPauseSession]
    SET [pauseNotes_A] = [pauseNotes]
    WHERE [entryData] = N'SEED10';

    COMMIT TRAN;

    SELECT N'[Tickets].[TicketClass]' AS [TableName], COUNT(1) AS [RowsFixed] FROM [Tickets].[TicketClass] WHERE [entryData] = N'SEED10'
    UNION ALL
    SELECT N'[Tickets].[RequesterType]', COUNT(1) FROM [Tickets].[RequesterType] WHERE [entryData] = N'SEED10'
    UNION ALL
    SELECT N'[Tickets].[Priority]', COUNT(1) FROM [Tickets].[Priority] WHERE [entryData] = N'SEED10'
    UNION ALL
    SELECT N'[Tickets].[Service]', COUNT(1) FROM [Tickets].[Service] WHERE [entryData] = N'SEED10'
    UNION ALL
    SELECT N'[Tickets].[Ticket]', COUNT(1) FROM [Tickets].[Ticket] WHERE [entryData] = N'SEED10'
    UNION ALL
    SELECT N'[Tickets].[TicketHistory]', COUNT(1) FROM [Tickets].[TicketHistory] WHERE [entryData] = N'SEED10'
    UNION ALL
    SELECT N'[Tickets].[TicketPauseSession]', COUNT(1) FROM [Tickets].[TicketPauseSession] WHERE [entryData] = N'SEED10';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;
    THROW;
END CATCH;
