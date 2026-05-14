SET NOCOUNT ON;

-- Add Arabic-first columns if missing.
IF COL_LENGTH('Tickets.ServiceCatalogSuggestion', 'proposedServiceDesc_A') IS NULL
BEGIN
    ALTER TABLE [Tickets].[ServiceCatalogSuggestion]
    ADD [proposedServiceDesc_A] NVARCHAR(2000) NULL;
END;

IF COL_LENGTH('Tickets.ServiceCatalogSuggestion', 'approvalNotes_A') IS NULL
BEGIN
    ALTER TABLE [Tickets].[ServiceCatalogSuggestion]
    ADD [approvalNotes_A] NVARCHAR(2000) NULL;
END;

GO

-- Backfill Arabic columns from legacy columns for existing rows.
UPDATE [Tickets].[ServiceCatalogSuggestion]
SET [proposedServiceDesc_A] = [proposedServiceDesc]
WHERE [proposedServiceDesc_A] IS NULL
  AND [proposedServiceDesc] IS NOT NULL;

UPDATE [Tickets].[ServiceCatalogSuggestion]
SET [approvalNotes_A] = [approvalNotes]
WHERE [approvalNotes_A] IS NULL
  AND [approvalNotes] IS NOT NULL;

-- Keep legacy columns aligned if only Arabic values are provided later.
UPDATE [Tickets].[ServiceCatalogSuggestion]
SET [proposedServiceDesc] = [proposedServiceDesc_A]
WHERE [proposedServiceDesc] IS NULL
  AND [proposedServiceDesc_A] IS NOT NULL;

UPDATE [Tickets].[ServiceCatalogSuggestion]
SET [approvalNotes] = [approvalNotes_A]
WHERE [approvalNotes] IS NULL
  AND [approvalNotes_A] IS NOT NULL;

SELECT
    COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Tickets'
  AND TABLE_NAME = 'ServiceCatalogSuggestion'
  AND COLUMN_NAME IN ('proposedServiceDesc_A', 'approvalNotes_A')
ORDER BY COLUMN_NAME;
