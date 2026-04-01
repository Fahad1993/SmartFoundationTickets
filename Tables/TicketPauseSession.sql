-- ============================================================================
-- Table: TicketPauseSession
-- Schema: [Tickets]
-- Purpose: Tracks pause windows and blocking causes for tickets
-- Notes: Supports valid SLA pause/resume behavior.
--          Parent tickets may be paused due to dependent child tickets.
-- ============================================================================

IF OBJECT_ID('[Tickets].[TicketPauseSession]', 'U') IS NOT NULL
    DROP TABLE [Tickets].[TicketPauseSession];
GO

CREATE TABLE [Tickets].[TicketPauseSession] (
    -- Primary Key
    [TicketPauseSessionID] BIGINT IDENTITY(1,1) NOT NULL,

    -- Ticket Reference
    [TicketID_FK] BIGINT NOT NULL,

    -- IdaraID_FK is mandatory for filtering and reporting
    [IdaraID_FK] INT NOT NULL,

    -- Pause Reason
    [PauseReasonID_FK] INT NOT NULL, -- Reference to [Tickets].[PauseReason]

    -- Optional Related Entities (for tracking what caused the pause)
    [RelatedChildTicketID_FK] BIGINT NULL, -- If paused due to child ticket dependency
    [RelatedArbitrationCaseID_FK] BIGINT NULL, -- If paused due to arbitration
    [RelatedClarificationRequestID_FK] BIGINT NULL, -- If paused due to clarification

    -- Pause Window Timestamps
    [PauseStartedAt] DATETIME2 NOT NULL CONSTRAINT DF_TicketPauseSession_PauseStartedAt DEFAULT SYSDATETIME(),
    [PauseEndedAt] DATETIME2 NULL,
    [TotalPausedMinutes] INT NULL, -- Calculated when session ends

    -- SLA Behavior
    [PausesSLA] BIT NOT NULL CONSTRAINT DF_TicketPauseSession_PausesSLA DEFAULT 1,
    -- Usually TRUE for legitimate blocking reasons
    [SLABackfillMinutes] INT NULL, -- If SLA was running when pause started

    -- Pause Details
    [PauseNotes] VARCHAR(MAX) NULL,
    [PauseNotesAR] NVARCHAR(MAX) NULL,
    [PausedBy] VARCHAR(100) NULL,
    [ResumedBy] VARCHAR(100) NULL,

    -- Impact Information
    [IsBlocking] BIT NOT NULL CONSTRAINT DF_TicketPauseSession_IsBlocking DEFAULT 1,
    -- TRUE if this pause blocks ticket progression
    [NotifiedStakeholders] BIT NOT NULL CONSTRAINT DF_TicketPauseSession_NotifiedStakeholders DEFAULT 0,

    -- Audit Columns
    [CreatedAt] DATETIME2 NOT NULL CONSTRAINT DF_TicketPauseSession_CreatedAt DEFAULT SYSDATETIME(),
    [UpdatedAt] DATETIME2 NOT NULL CONSTRAINT DF_TicketPauseSession_UpdatedAt DEFAULT SYSDATETIME(),
    [CreatedBy] VARCHAR(100) NULL,
    [UpdatedBy] VARCHAR(100) NULL,

    -- Primary Key Constraint
    CONSTRAINT PK_TicketPauseSession PRIMARY KEY CLUSTERED ([TicketPauseSessionID])
);
GO

-- Foreign Key Constraints
ALTER TABLE [Tickets].[TicketPauseSession]
ADD CONSTRAINT FK_TicketPauseSession_Ticket
    FOREIGN KEY ([TicketID_FK]) REFERENCES [Tickets].[Ticket]([TicketID]);

ALTER TABLE [Tickets].[TicketPauseSession]
ADD CONSTRAINT FK_TicketPauseSession_PauseReason
    FOREIGN KEY ([PauseReasonID_FK]) REFERENCES [Tickets].[PauseReason]([PauseReasonID]);

ALTER TABLE [Tickets].[TicketPauseSession]
ADD CONSTRAINT FK_TicketPauseSession_RelatedChildTicket
    FOREIGN KEY ([RelatedChildTicketID_FK]) REFERENCES [Tickets].[Ticket]([TicketID]);

ALTER TABLE [Tickets].[TicketPauseSession]
ADD CONSTRAINT FK_TicketPauseSession_RelatedArbitrationCase
    FOREIGN KEY ([RelatedArbitrationCaseID_FK]) REFERENCES [Tickets].[ArbitrationCase]([ArbitrationCaseID]);

ALTER TABLE [Tickets].[TicketPauseSession]
ADD CONSTRAINT FK_TicketPauseSession_RelatedClarificationRequest
    FOREIGN KEY ([RelatedClarificationRequestID_FK]) REFERENCES [Tickets].[ClarificationRequest]([ClarificationRequestID]);
GO

-- Indexes
CREATE NONCLUSTERED INDEX IX_TicketPauseSession_TicketID
ON [Tickets].[TicketPauseSession] ([TicketID_FK]);

CREATE NONCLUSTERED INDEX IX_TicketPauseSession_PauseStartedAt
ON [Tickets].[TicketPauseSession] ([PauseStartedAt] DESC);

CREATE NONCLUSTERED INDEX IX_TicketPauseSession_PauseEndedAt
ON [Tickets].[TicketPauseSession] ([PauseEndedAt]);

CREATE NONCLUSTERED INDEX IX_TicketPauseSession_ActivePauses
ON [Tickets].[TicketPauseSession] ([PauseEndedAt]) -- NULL means active
INCLUDE ([TicketID FK], [PauseReasonID FK], [PauseStartedAt]);

CREATE NONCLUSTERED INDEX IX_TicketPauseSession_RelatedChildTicket
ON [Tickets].[TicketPauseSession] ([RelatedChildTicketID_FK]);
GO

-- Check Constraint: Only one related entity type at a time
ALTER TABLE [Tickets].[TicketPauseSession]
ADD CONSTRAINT CK_TicketPauseSession_SingleRelatedEntity
    CHECK (
        (RelatedChildTicketID_FK IS NULL AND RelatedArbitrationCaseID_FK IS NULL AND RelatedClarificationRequestID_FK IS NULL) OR
        (RelatedChildTicketID_FK IS NOT NULL AND RelatedArbitrationCaseID_FK IS NULL AND RelatedClarificationRequestID_FK IS NULL) OR
        (RelatedChildTicketID_FK IS NULL AND RelatedArbitrationCaseID_FK IS NOT NULL AND RelatedClarificationRequestID_FK IS NULL) OR
        (RelatedChildTicketID FK IS NULL AND RelatedArbitrationCaseID_FK IS NOT NULL AND RelatedClarificationRequestID FK IS NOT NULL)
    );
GO

-- Comment: Pause sessions track all SLA pauses and work interruptions.
-- Pauses can be for various reasons: dependency (child ticket), arbitration, clarification,
-- warehouse delay, approval delay, external dependency.
-- The PausesSLA flag indicates if SLA should be paused during this session.
-- TotalPausedMinutes is calculated when the session ends for SLA tracking.
-- Multiple pause sessions can exist per ticket (sequential, not overlapping).
-- Check constraint ensures only one related entity type is linked per pause session.
