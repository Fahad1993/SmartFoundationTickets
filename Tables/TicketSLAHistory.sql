-- ============================================================================
-- Table: TicketSLAHistory
-- Schema: [Tickets]
-- Purpose: Immutable SLA event history for SLA tracking audit
-- Notes: Tracks all SLA lifecycle events for each SLA type.
--          No soft delete behavior for history records.
-- ============================================================================

IF OBJECT_ID('[Tickets].[TicketSLAHistory]', 'U') IS NOT NULL
    DROP TABLE [Tickets].[TicketSLAHistory];
GO

CREATE TABLE [Tickets].[TicketSLAHistory] (
    -- Primary Key
    [TicketSLAHistoryID] BIGINT IDENTITY(1,1) NOT NULL,

    -- Ticket SLA Reference
    [TicketSLAID FK] BIGINT NOT NULL,

    -- Ticket Reference (for direct query without joining)
    [TicketID FK] BIGINT NOT NULL,

    -- IdaraID FK is mandatory for filtering and reporting
    [IdaraID FK] INT NOT NULL,

    -- SLA Event Type (what happened to SLA)
    [SLAEventTypeCode] VARCHAR(30) NOT NULL,
    -- Values: INITIALIZED, PAUSED, RESUMED, UPDATED_TARGET, BREACHED, COMPLETED, ADJUSTED

    -- Event Timestamp
    [EventDate] DATETIME2 NOT NULL CONSTRAINT DF_TicketSLAHistory_EventDate DEFAULT SYSDATETIME(),

    -- SLA Type Context
    [SLATypeCode] VARCHAR(30) NOT NULL, -- e.g., FIRST_RESPONSE, ASSIGNMENT, OPERATIONAL_COMPLETION, FINAL_CLOSURE

    -- Target Changes
    [OldTargetMinutes] INT NULL,
    [NewTargetMinutes] INT NULL,

    -- Calculated State at Event Time
    [ElapsedMinutes] INT NULL,
    [RemainingMinutes] INT NULL,
    [PausedMinutes] INT NULL,
    [IsBreached] BIT NULL,

    -- Additional Event Context
    [EventNotes] VARCHAR(MAX) NULL,
    [TriggeredBy] VARCHAR(50) NULL, -- What triggered the event
    [PauseSessionID FK] BIGINT NULL, -- Reference to [Tickets].[TicketPauseSession] for pause events

    -- Who Performed Action (for manual SLA adjustments)
    [Performer] VARCHAR(100) NULL,
    [PerformerUserID FK] BIGINT NULL,

    -- Audit Columns
    [CreatedAt] DATETIME2 NOT NULL CONSTRAINT DF_TicketSLAHistory_CreatedAt DEFAULT SYSDATETIME(),
    [CreatedBy] VARCHAR(100) NULL,

    -- Primary Key Constraint
    CONSTRAINT PK_TicketSLAHistory PRIMARY KEY CLUSTERED ([TicketSLAHistoryID]]))
);
GO

-- Foreign Key Constraints
ALTER TABLE [Tickets].[TicketSLAHistory]
ADD CONSTRAINT FK_TicketSLAHistory_TicketSLA
    FOREIGN KEY ([TicketSLAID FK]) REFERENCES [Tickets].[TicketSLA]([TicketSLAID]));

ALTER TABLE [Tickets].[TicketSLAHistory]
ADD CONSTRAINT FK_TicketSLAHistory_PauseSession
    FOREIGN KEY ([PauseSessionID FK]) REFERENCES [Tickets].[TicketPauseSession]([TicketPauseSessionID]));
GO

-- Indexes
CREATE NONCLUSTERED INDEX IX_TicketSLAHistory_TicketSLAID
ON [Tickets].[TicketSLAHistory] ([TicketSLAID FK]));

CREATE NONCLUSTERED INDEX IX_TicketSLAHistory_TicketID
ON [Tickets].[TicketSLAHistory] ([TicketID FK]));

CREATE NONCLUSTERED INDEX IX_TicketSLAHistory_SLATypeCode
ON [Tickets].[TicketSLAHistory] ([SLATypeCode]));

CREATE NONCLUSTERED INDEX IX_TicketSLAHistory_SLAEventTypeCode
ON [Tickets].[TicketSLAHistory] ([SLAEventTypeCode]));

CREATE NONCLUSTERED INDEX IX_TicketSLAHistory_EventDate
ON [Tickets].[TicketSLAHistory] ([EventDate] DESC);

-- Composite index for SLA timeline queries
CREATE NONCLUSTERED INDEX IX_TicketSLAHistory_SLATimeline
ON [Tickets].[TicketSLAHistory] ([TicketSLAID FK], [EventDate] DESC)
INCLUDE ([SLAEventTypeCode], [ElapsedMinutes], [RemainingMinutes], [IsBreached]]);
GO

-- Comment: TicketSLAHistory tracks all SLA events for audit purposes.
-- SLA events are:
--   INITIALIZED: SLA clock started with initial target
--   PAUSED: SLA clock paused (linked to TicketPauseSession)
--   RESUMED: SLA clock resumed after pause
--   UPDATED_TARGET: Target minutes changed (e.g., priority change)
--   BREACHED: SLA time exceeded
--   COMPLETED: SLA met (milestone achieved)
--   ADJUSTED: Manual adjustment by administrator
-- This history enables reconstruction of SLA state at any point in time.
-- Useful for SLA performance analysis and breach investigation.
