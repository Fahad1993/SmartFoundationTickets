-- ============================================================================
-- Table: CatalogRoutingChangeLog
-- Schema: [Tickets]
-- Purpose: Stores approved routing-rule changes for historical accountability
-- Notes: Routing-rule changes must be historically preserved, not overwritten silently.
--          Can be triggered by arbitration decisions or service updates.
-- ============================================================================

IF OBJECT_ID('[Tickets].[CatalogRoutingChangeLog]', 'U') IS NOT NULL
    DROP TABLE [Tickets].[CatalogRoutingChangeLog];
GO

CREATE TABLE [Tickets].[CatalogRoutingChangeLog] (
    -- Primary Key
    [CatalogRoutingChangeLogID] BIGINT IDENTITY(1,1) NOT NULL,

    -- Service Reference
    [ServiceID FK] BIGINT NOT NULL,

    -- IdaraID FK is mandatory for filtering and reporting
    [IdaraID FK] INT NOT NULL,

    -- Routing Rule References (old and new)
    [OldServiceRoutingRuleID FK] BIGINT NULL, -- Previous rule being replaced
    [NewServiceRoutingRuleID FK] BIGINT NOT NULL, -- New rule taking effect

    -- Change Details
    [ChangeType] VARCHAR(30) NOT NULL,
    -- Values: NEW_RULE, ROUTING_CORRECTION, PRIORITY_CHANGE, TARGET_CHANGE, DEACTIVATION

    [ChangeReason] VARCHAR(500) NULL,
    [ChangeDescription] VARCHAR(MAX) NULL,
    [ChangeDescriptionAR] NVARCHAR(MAX) NULL,

    -- Source of Change (why routing changed)
    [SourceArbitrationCaseID FK] BIGINT NULL, -- If change resulted from arbitration
    [SourceServiceSuggestionID FK] BIGINT NULL, -- If change resulted from suggestion approval
    [Source] VARCHAR(50) NULL, -- e.g., 'ARBITRATION', 'SUGGESTION', 'MANUAL', 'SYSTEM'

    -- Comparison of Old vs New Target
    [OldTargetDSDID FK] BIGINT NULL,
    [NewTargetDSDID FK] BIGINT NULL,
    [OldQueueDistributorID FK] BIGINT NULL,
    [NewQueueDistributorID FK] BIGINT NULL,

    -- Approval Information
    [ApprovedBy] VARCHAR(100) NULL,
    [ApprovedByUserID FK] BIGINT NULL, -- Reference to User table
    [ApprovedAt] DATETIME2 NULL,
    [ApprovalLevel] INT NULL, -- How many levels of approval

    -- Effective Dates
    [EffectiveFrom] DATETIME2 NOT NULL,
    [EffectiveTo] DATETIME2 NULL,

    -- Audit Columns
    [CreatedAt] DATETIME2 NOT NULL CONSTRAINT DF_CatalogRoutingChangeLog_CreatedAt DEFAULT SYSDATETIME(),
    [CreatedBy] VARCHAR(100) NULL,
    [UpdatedBy] VARCHAR(100) NULL,

    -- Primary Key Constraint
    CONSTRAINT PK_CatalogRoutingChangeLog PRIMARY KEY CLUSTERED ([CatalogRoutingChangeLogID]))
);
GO

-- Foreign Key Constraints
ALTER TABLE [Tickets].[CatalogRoutingChangeLog]
ADD CONSTRAINT FK_CatalogRoutingChangeLog_Service
    FOREIGN KEY ([ServiceID FK]) REFERENCES [Tickets].[Service]([ServiceID]));

ALTER TABLE [Tickets].[CatalogRoutingChangeLog]
ADD CONSTRAINT FK_CatalogRoutingChangeLog_OldServiceRoutingRule
    FOREIGN KEY ([OldServiceRoutingRuleID FK]) REFERENCES [Tickets].[ServiceRoutingRule]([ServiceRoutingRuleID]));

ALTER TABLE [Tickets].[CatalogRoutingChangeLog]
ADD CONSTRAINT FK_CatalogRoutingChangeLog_NewServiceRoutingRule
    FOREIGN KEY ([NewServiceRoutingRuleID FK]) REFERENCES [Tickets].[ServiceRoutingRule]([ServiceRoutingRuleID]));

ALTER TABLE [Tickets].[CatalogRoutingChangeLog]
ADD CONSTRAINT FK_CatalogRoutingChangeLog_SourceArbitrationCase
    FOREIGN KEY ([SourceArbitrationCaseID FK]) REFERENCES [Tickets].[ArbitrationCase]([ArbitrationCaseID]));

ALTER TABLE [Tickets].[CatalogRoutingChangeLog]
ADD CONSTRAINT FK_CatalogRoutingChangeLog_SourceServiceSuggestion
    FOREIGN KEY ([SourceServiceSuggestionID FK]) REFERENCES [Tickets].[ServiceCatalogSuggestion]([ServiceCatalogSuggestionID])));
GO

-- Indexes
CREATE NONCLUSTERED INDEX IX_CatalogRoutingChangeLog_ServiceID
ON [Tickets].[CatalogRoutingChangeLog] ([ServiceID FK]));

CREATE NONCLUSTERED INDEX IX_CatalogRoutingChangeLog_NewServiceRoutingRuleID
ON [Tickets].[CatalogRoutingChangeLog] ([NewServiceRoutingRuleID FK]));

CREATE NONCLUSTERED INDEX IX_CatalogRoutingChangeLog_ApprovedAt
ON [Tickets].[CatalogRoutingChangeLog] ([ApprovedAt] DESC));

CREATE NONCLUSTERED INDEX IX_CatalogRoutingChangeLog_EffectiveFrom
ON [Tickets].[CatalogRoutingChangeLog] ([EffectiveFrom] DESC));

CREATE NONCLUSTERED INDEX IX_CatalogRoutingChangeLog_ChangeType
ON [Tickets].[CatalogRoutingChangeLog] ([ChangeType]));

-- Composite index for service routing history query
CREATE NONCLUSTERED INDEX IX_CatalogRoutingChangeLog_ServiceHistory
ON [Tickets].[CatalogRoutingChangeLog] ([ServiceID FK], [EffectiveFrom] DESC)
INCLUDE ([ChangeType], [OldTargetDSDID FK], [NewTargetDSDID FK], [ApprovedBy]));
GO

-- Comment: CatalogRoutingChangeLog preserves all routing changes for accountability.
-- Changes can be triggered by:
--   NEW_RULE: Initial routing rule creation
--   ROUTING_CORRECTION: From arbitration decision
--   PRIORITY_CHANGE: Service priority affecting SLA
--   TARGET_CHANGE: Organizational restructure
--   DEACTIVATION: Rule deactivation
-- Old and New rule IDs are stored for rollback capability if needed.
-- Links to arbitration cases or service suggestions for traceability.
-- This log enables analysis of routing accuracy and service catalogue evolution.
-- Essential for SLA breach investigations (was routing correct at time of breach?).
