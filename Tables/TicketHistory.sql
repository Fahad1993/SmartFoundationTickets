-- ============================================================================
-- Table: TicketHistory
-- Schema: [Tickets]
-- Purpose: Immutable operational audit history for ticket actions
-- Notes: Every meaningful change must be written to this table.
--          No soft delete behavior for history records.
-- ============================================================================

IF OBJECT_ID('[Tickets].[TicketHistory]', 'U') IS NOT NULL
    DROP TABLE [Tickets].[TicketHistory];
GO

CREATE TABLE [Tickets].[TicketHistory] (
    -- Primary Key
    [TicketHistoryID] BIGINT IDENTITY(1,1) NOT NULL,

    -- Ticket Reference
    [TicketID FK] BIGINT NOT NULL,

    -- IdaraID FK is mandatory for filtering and reporting
    [IdaraID FK] INT NOT NULL,

    -- Action Type (what happened)
    [ActionTypeCode] VARCHAR(30) NOT NULL,
    -- Values: CREATED, ROUTED, ASSIGNED, REASSIGNED, MOVED_TO_IN_PROGRESS,
    --         REJECTED_TO_SUPERVISOR, PAUSED, RESUMED, RESOLVED_OPERATIONALLY,
    --         REOPENED, QUALITY_REVIEW_STARTED, QUALITY_REVIEW_COMPLETED,
    --         QUALITY_REVIEW_RETURNED, FINALLY_CLOSED, REOPENED_AFTER_CLOSURE

    -- Old/New State Tracking
    [OldTicketStatusID FK] INT NULL, -- Reference to [Tickets].[TicketStatus]
    [NewTicketStatusID FK] INT NULL, -- Reference to [Tickets].[TicketStatus]

    -- Old/New DSD Tracking
    [OldDSDID FK] BIGINT NULL,
    [NewDSDID FK] BIGINT NULL,

    -- Old/New User Tracking
    [OldAssignedUserID FK] BIGINT NULL,
    [NewAssignedUserID FK] BIGINT NULL,

    -- Action Metadata
    [ActionNotes] VARCHAR(MAX) NULL,
    [ActionNotesAR] NVARCHAR(MAX) NULL, -- Arabic notes
    [ActionData] NVARCHAR(MAX) NULL, -- JSON for additional action context

    -- Action Context
    [ActionSource] VARCHAR(30) NULL, -- e.g., 'WEB', 'API', 'SYSTEM', 'EMAIL', 'MOBILE'
    [IPAddress] VARCHAR(50) NULL, -- For security audit

    -- Who Performed Action
    [PerformedBy] VARCHAR(100) NULL,
    [PerformedByUserID FK] BIGINT NULL, -- Reference to User table
    [PerformedAt] DATETIME2 NOT NULL CONSTRAINT DF_TicketHistory_PerformedAt DEFAULT SYSDATETIME(),

    -- Related Entities (for cross-referencing)
    [RelatedArbitrationCaseID FK] BIGINT NULL,
    [RelatedClarificationRequestID FK] BIGINT NULL,
    [RelatedPauseSessionID FK] BIGINT NULL,
    [RelatedQualityReviewID FK] BIGINT NULL,
    [RelatedChildTicketID FK] BIGINT NULL,

    -- Audit Columns
    [CreatedAt] DATETIME2 NOT NULL CONSTRAINT DF_TicketHistory_CreatedAt DEFAULT SYSDATETIME(),
    [CreatedBy] VARCHAR(100) NULL,
    [UpdatedBy] VARCHAR(100) NULL,

    -- Primary Key Constraint
    CONSTRAINT PK_TicketHistory PRIMARY KEY CLUSTERED ([TicketHistoryID]])
);
GO

-- Foreign Key Constraints (non-enforcing for performance)
ALTER TABLE [Tickets].[TicketHistory]
ADD CONSTRAINT FK_TicketHistory_Ticket
    FOREIGN KEY ([TicketID FK]) REFERENCES [Tickets].[Ticket]([TicketID]);

ALTER TABLE [Tickets].[TicketHistory]
ADD CONSTRAINT FK_TicketHistory_OldTicketStatus
    FOREIGN KEY ([OldTicketStatusID FK]) REFERENCES [Tickets].[TicketStatus]([TicketStatusID]));

ALTER TABLE [Tickets].[TicketHistory]
ADD CONSTRAINT FK_TicketHistory_NewTicketStatus
    FOREIGN KEY ([NewTicketStatusID FK]) REFERENCES [Tickets].[TicketStatus]([TicketStatusID]));
GO

-- Indexes
CREATE NONCLUSTERED INDEX IX_TicketHistory_TicketID
ON [Tickets].[TicketHistory] ([TicketID FK]);

CREATE NONCLUSTERED INDEX IX_TicketHistory_ActionTypeCode
ON [Tickets].[TicketHistory] ([ActionTypeCode]);

CREATE NONCLUSTERED INDEX IX_TicketHistory_PerformedAt
ON [Tickets].[TicketHistory] ([PerformedAt] DESC);

CREATE NONCLUSTERED INDEX IX_TicketHistory_PerformedByUserID
ON [Tickets].[TicketHistory] ([PerformedByUserID FK]);

-- Composite index for timeline queries
CREATE NONCLUSTERED INDEX IX_TicketHistory_Timeline
ON [Tickets].[TicketHistory] ([TicketID FK], [PerformedAt] DESC)
INCLUDE ([ActionTypeCode], [OldTicketStatusID FK], [NewTicketStatusID FK], [PerformedBy]));
GO

-- Comment: TicketHistory is the immutable audit log for all ticket actions.
-- Every SP action must write at least one history record.
-- History is append-only - records should never be updated or deleted.
-- Old/New fields track state transitions for state machine validation.
-- Related entity links enable cross-referencing between history and detail tables.
-- Non-enforcing foreign keys (NOCHECK) may be used for performance.
-- Full ticket audit trail can be reconstructed by joining this table with Ticket.
