SET NOCOUNT ON;

/*
Arabic-first migration for Tickets schema.
- Adds missing _A columns for user-facing text fields.
- Backfills _A from existing legacy columns when _A is NULL.
- Idempotent and safe to re-run.
*/

-- 1) Add missing _A columns
IF COL_LENGTH('Tickets.ArbitrationCase', 'decisionNotes_A') IS NULL
    EXEC(N'ALTER TABLE [Tickets].[ArbitrationCase] ADD [decisionNotes_A] NVARCHAR(2000) NULL;');

IF COL_LENGTH('Tickets.CatalogRoutingChangeLog', 'changeReason_A') IS NULL
    EXEC(N'ALTER TABLE [Tickets].[CatalogRoutingChangeLog] ADD [changeReason_A] NVARCHAR(2000) NULL;');

IF COL_LENGTH('Tickets.ClarificationRequest', 'requestNotes_A') IS NULL
    EXEC(N'ALTER TABLE [Tickets].[ClarificationRequest] ADD [requestNotes_A] NVARCHAR(2000) NULL;');

IF COL_LENGTH('Tickets.ClarificationRequest', 'responseNotes_A') IS NULL
    EXEC(N'ALTER TABLE [Tickets].[ClarificationRequest] ADD [responseNotes_A] NVARCHAR(2000) NULL;');

IF COL_LENGTH('Tickets.QualityReview', 'reviewNotes_A') IS NULL
    EXEC(N'ALTER TABLE [Tickets].[QualityReview] ADD [reviewNotes_A] NVARCHAR(2000) NULL;');

IF COL_LENGTH('Tickets.ServiceRoutingRule', 'changeReason_A') IS NULL
    EXEC(N'ALTER TABLE [Tickets].[ServiceRoutingRule] ADD [changeReason_A] NVARCHAR(1000) NULL;');

IF COL_LENGTH('Tickets.Ticket', 'title_A') IS NULL
    EXEC(N'ALTER TABLE [Tickets].[Ticket] ADD [title_A] NVARCHAR(500) NULL;');

IF COL_LENGTH('Tickets.Ticket', 'description_A') IS NULL
    EXEC(N'ALTER TABLE [Tickets].[Ticket] ADD [description_A] NVARCHAR(4000) NULL;');

IF COL_LENGTH('Tickets.Ticket', 'locationArea_A') IS NULL
    EXEC(N'ALTER TABLE [Tickets].[Ticket] ADD [locationArea_A] NVARCHAR(200) NULL;');

IF COL_LENGTH('Tickets.TicketHistory', 'notes_A') IS NULL
    EXEC(N'ALTER TABLE [Tickets].[TicketHistory] ADD [notes_A] NVARCHAR(2000) NULL;');

IF COL_LENGTH('Tickets.TicketPauseSession', 'pauseNotes_A') IS NULL
    EXEC(N'ALTER TABLE [Tickets].[TicketPauseSession] ADD [pauseNotes_A] NVARCHAR(2000) NULL;');

IF COL_LENGTH('Tickets.TicketSLAHistory', 'notes_A') IS NULL
    EXEC(N'ALTER TABLE [Tickets].[TicketSLAHistory] ADD [notes_A] NVARCHAR(2000) NULL;');

IF COL_LENGTH('Tickets.Service', 'serviceDesc_A') IS NULL
    EXEC(N'ALTER TABLE [Tickets].[Service] ADD [serviceDesc_A] NVARCHAR(2000) NULL;');

IF COL_LENGTH('Tickets.Priority', 'priorityDesc_A') IS NULL
    EXEC(N'ALTER TABLE [Tickets].[Priority] ADD [priorityDesc_A] NVARCHAR(1000) NULL;');

IF COL_LENGTH('Tickets.TicketClass', 'ticketClassDesc_A') IS NULL
    EXEC(N'ALTER TABLE [Tickets].[TicketClass] ADD [ticketClassDesc_A] NVARCHAR(1000) NULL;');

IF COL_LENGTH('Tickets.TicketStatus', 'ticketStatusDesc_A') IS NULL
    EXEC(N'ALTER TABLE [Tickets].[TicketStatus] ADD [ticketStatusDesc_A] NVARCHAR(1000) NULL;');

IF COL_LENGTH('Tickets.PauseReason', 'pauseReasonDesc_A') IS NULL
    EXEC(N'ALTER TABLE [Tickets].[PauseReason] ADD [pauseReasonDesc_A] NVARCHAR(1000) NULL;');

IF COL_LENGTH('Tickets.ArbitrationReason', 'arbitrationReasonDesc_A') IS NULL
    EXEC(N'ALTER TABLE [Tickets].[ArbitrationReason] ADD [arbitrationReasonDesc_A] NVARCHAR(1000) NULL;');

IF COL_LENGTH('Tickets.ClarificationReason', 'clarificationReasonDesc_A') IS NULL
    EXEC(N'ALTER TABLE [Tickets].[ClarificationReason] ADD [clarificationReasonDesc_A] NVARCHAR(1000) NULL;');

IF COL_LENGTH('Tickets.QualityReviewResult', 'qualityReviewResultDesc_A') IS NULL
    EXEC(N'ALTER TABLE [Tickets].[QualityReviewResult] ADD [qualityReviewResultDesc_A] NVARCHAR(1000) NULL;');

IF COL_LENGTH('Tickets.RequesterType', 'requesterTypeDesc_A') IS NULL
    EXEC(N'ALTER TABLE [Tickets].[RequesterType] ADD [requesterTypeDesc_A] NVARCHAR(1000) NULL;');

-- ServiceCatalogSuggestion _A columns are handled by dedicated script, but keep idempotent safety.
IF COL_LENGTH('Tickets.ServiceCatalogSuggestion', 'proposedServiceDesc_A') IS NULL
    EXEC(N'ALTER TABLE [Tickets].[ServiceCatalogSuggestion] ADD [proposedServiceDesc_A] NVARCHAR(2000) NULL;');

IF COL_LENGTH('Tickets.ServiceCatalogSuggestion', 'approvalNotes_A') IS NULL
    EXEC(N'ALTER TABLE [Tickets].[ServiceCatalogSuggestion] ADD [approvalNotes_A] NVARCHAR(2000) NULL;');

-- 2) Backfill _A from current legacy columns where needed
EXEC(N'UPDATE [Tickets].[ArbitrationCase] SET [decisionNotes_A] = [decisionNotes] WHERE [decisionNotes_A] IS NULL AND [decisionNotes] IS NOT NULL;');
EXEC(N'UPDATE [Tickets].[CatalogRoutingChangeLog] SET [changeReason_A] = [changeReason] WHERE [changeReason_A] IS NULL AND [changeReason] IS NOT NULL;');
EXEC(N'UPDATE [Tickets].[ClarificationRequest] SET [requestNotes_A] = [requestNotes] WHERE [requestNotes_A] IS NULL AND [requestNotes] IS NOT NULL;');
EXEC(N'UPDATE [Tickets].[ClarificationRequest] SET [responseNotes_A] = [responseNotes] WHERE [responseNotes_A] IS NULL AND [responseNotes] IS NOT NULL;');
EXEC(N'UPDATE [Tickets].[QualityReview] SET [reviewNotes_A] = [reviewNotes] WHERE [reviewNotes_A] IS NULL AND [reviewNotes] IS NOT NULL;');
EXEC(N'UPDATE [Tickets].[ServiceRoutingRule] SET [changeReason_A] = [changeReason] WHERE [changeReason_A] IS NULL AND [changeReason] IS NOT NULL;');
EXEC(N'UPDATE [Tickets].[Ticket] SET [title_A] = [title] WHERE [title_A] IS NULL AND [title] IS NOT NULL;');
EXEC(N'UPDATE [Tickets].[Ticket] SET [description_A] = [description_] WHERE [description_A] IS NULL AND [description_] IS NOT NULL;');
EXEC(N'UPDATE [Tickets].[Ticket] SET [locationArea_A] = [locationArea] WHERE [locationArea_A] IS NULL AND [locationArea] IS NOT NULL;');
EXEC(N'UPDATE [Tickets].[TicketHistory] SET [notes_A] = [notes] WHERE [notes_A] IS NULL AND [notes] IS NOT NULL;');
EXEC(N'UPDATE [Tickets].[TicketPauseSession] SET [pauseNotes_A] = [pauseNotes] WHERE [pauseNotes_A] IS NULL AND [pauseNotes] IS NOT NULL;');
EXEC(N'UPDATE [Tickets].[TicketSLAHistory] SET [notes_A] = [notes] WHERE [notes_A] IS NULL AND [notes] IS NOT NULL;');
EXEC(N'UPDATE [Tickets].[Service] SET [serviceDesc_A] = [serviceDesc] WHERE [serviceDesc_A] IS NULL AND [serviceDesc] IS NOT NULL;');
EXEC(N'UPDATE [Tickets].[Priority] SET [priorityDesc_A] = [priorityDesc] WHERE [priorityDesc_A] IS NULL AND [priorityDesc] IS NOT NULL;');
EXEC(N'UPDATE [Tickets].[TicketClass] SET [ticketClassDesc_A] = [ticketClassDesc] WHERE [ticketClassDesc_A] IS NULL AND [ticketClassDesc] IS NOT NULL;');
EXEC(N'UPDATE [Tickets].[TicketStatus] SET [ticketStatusDesc_A] = [ticketStatusDesc] WHERE [ticketStatusDesc_A] IS NULL AND [ticketStatusDesc] IS NOT NULL;');
EXEC(N'UPDATE [Tickets].[PauseReason] SET [pauseReasonDesc_A] = [pauseReasonDesc] WHERE [pauseReasonDesc_A] IS NULL AND [pauseReasonDesc] IS NOT NULL;');
EXEC(N'UPDATE [Tickets].[ArbitrationReason] SET [arbitrationReasonDesc_A] = [arbitrationReasonDesc] WHERE [arbitrationReasonDesc_A] IS NULL AND [arbitrationReasonDesc] IS NOT NULL;');
EXEC(N'UPDATE [Tickets].[ClarificationReason] SET [clarificationReasonDesc_A] = [clarificationReasonDesc] WHERE [clarificationReasonDesc_A] IS NULL AND [clarificationReasonDesc] IS NOT NULL;');
EXEC(N'UPDATE [Tickets].[QualityReviewResult] SET [qualityReviewResultDesc_A] = [qualityReviewResultDesc] WHERE [qualityReviewResultDesc_A] IS NULL AND [qualityReviewResultDesc] IS NOT NULL;');
EXEC(N'UPDATE [Tickets].[RequesterType] SET [requesterTypeDesc_A] = [requesterTypeDesc] WHERE [requesterTypeDesc_A] IS NULL AND [requesterTypeDesc] IS NOT NULL;');
EXEC(N'UPDATE [Tickets].[ServiceCatalogSuggestion] SET [proposedServiceDesc_A] = [proposedServiceDesc] WHERE [proposedServiceDesc_A] IS NULL AND [proposedServiceDesc] IS NOT NULL;');
EXEC(N'UPDATE [Tickets].[ServiceCatalogSuggestion] SET [approvalNotes_A] = [approvalNotes] WHERE [approvalNotes_A] IS NULL AND [approvalNotes] IS NOT NULL;');

-- 3) Quick verification output
SELECT TABLE_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Tickets'
  AND COLUMN_NAME IN (
      'decisionNotes_A', 'changeReason_A', 'requestNotes_A', 'responseNotes_A', 'reviewNotes_A',
      'title_A', 'description_A', 'locationArea_A', 'notes_A', 'pauseNotes_A',
      'serviceDesc_A', 'priorityDesc_A', 'ticketClassDesc_A', 'ticketStatusDesc_A',
      'pauseReasonDesc_A', 'arbitrationReasonDesc_A', 'clarificationReasonDesc_A',
      'qualityReviewResultDesc_A', 'requesterTypeDesc_A', 'proposedServiceDesc_A', 'approvalNotes_A'
  )
ORDER BY TABLE_NAME, COLUMN_NAME;
