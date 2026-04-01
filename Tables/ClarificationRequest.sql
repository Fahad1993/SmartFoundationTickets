-- ============================================================================
-- Table: ClarificationRequest
-- Schema: [Tickets]
-- Purpose: Tracks missing information requests separately from disputes
-- Notes: Clarification is NOT a scope dispute - ticket belongs to correct unit.
--          Missing details may need to be supplied by parent ticket owner or sending unit.
--          End beneficiaries are not expected to provide technical specifications.
-- ============================================================================

IF OBJECT_ID('[Tickets].[ClarificationRequest]', 'U') IS NOT NULL
    DROP TABLE [Tickets].[ClarificationRequest];
GO

CREATE TABLE [Tickets].[ClarificationRequest] (
    -- Primary Key
    [ClarificationRequestID] BIGINT IDENTITY(1,1) NOT NULL,

    -- Ticket Reference
    [TicketID_FK] BIGINT NOT NULL,

    -- IdaraID_FK is mandatory for filtering and reporting
    [IdaraID_FK] INT NOT NULL,

    -- Requester of Clarification
    [RequestedBy] VARCHAR(100) NULL,
    [RequestedByUserID_FK] BIGINT NULL, -- Reference to User table
    [RequestedAt] DATETIME2 NOT NULL CONSTRAINT DF_ClarificationRequest_RequestedAt DEFAULT SYSDATETIME(),

    -- Target of Clarification (who should respond)
    [RequestedToUserID_FK] BIGINT NULL, -- Specific user to respond
    [RequestedToDSDID_FK] BIGINT NULL, -- Organizational unit to respond

    -- Clarification Reason
    [ClarificationReasonID_FK] INT NOT NULL, -- Reference to [Tickets].[ClarificationReason]

    -- Request Details
    [ClarificationTitle] VARCHAR(200) NOT NULL,
    [ClarificationNotes] VARCHAR(MAX) NULL,
    [ClarificationNotesAR] NVARCHAR(MAX) NULL, -- Arabic notes

    -- Required Information List (can be multi-line)
    [RequiredInformation] VARCHAR(MAX) NULL,

    -- Status Management
    [ClarificationStatus] VARCHAR(20) NOT NULL CONSTRAINT DF_ClarificationRequest_ClarificationStatus DEFAULT 'OPEN',
    -- Values: OPEN, RESPONDED, CLOSED

    -- Response Information
    [RespondedBy] VARCHAR(100) NULL,
    [RespondedAt] DATETIME2 NULL,
    [ResponseNotes] VARCHAR(MAX) NULL,
    [ResponseNotesAR] NVARCHAR(MAX) NULL,
    [AttachmentsProvided] BIT NOT NULL CONSTRAINT DF_ClarificationRequest_AttachmentsProvided DEFAULT 0,

    -- Blocking Behavior
    [BlocksTicket] BIT NOT NULL CONSTRAINT DF_ClarificationRequest_BlocksTicket DEFAULT 0,
    -- TRUE if ticket cannot progress until clarification is resolved
    [LinkedPauseSessionID_FK] BIGINT NULL, -- Link to [Tickets].[TicketPauseSession] if blocking

    -- Audit Columns
    [CreatedAt] DATETIME2 NOT NULL CONSTRAINT DF_ClarificationRequest_CreatedAt DEFAULT SYSDATETIME(),
    [UpdatedAt] DATETIME2 NOT NULL CONSTRAINT DF_ClarificationRequest_UpdatedAt DEFAULT SYSDATETIME(),
    [CreatedBy] VARCHAR(100) NULL,
    [UpdatedBy] VARCHAR(100) NULL,

    -- Primary Key Constraint
    CONSTRAINT PK_ClarificationRequest PRIMARY KEY CLUSTERED ([ClarificationRequestID])
);
GO

-- Foreign Key Constraints
ALTER TABLE [Tickets].[ClarificationRequest]
ADD CONSTRAINT FK_ClarificationRequest_Ticket
    FOREIGN KEY ([TicketID_FK]) REFERENCES [Tickets].[Ticket]([TicketID]);

ALTER TABLE [Tickets].[ClarificationRequest]
ADD CONSTRAINT FK_ClarificationRequest_ClarificationReason
    FOREIGN KEY ([ClarificationReasonID_FK]) REFERENCES [Tickets].[ClarificationReason]([ClarificationReasonID]);

ALTER TABLE [Tickets].[ClarificationRequest]
ADD CONSTRAINT FK_ClarificationRequest_PauseSession
    FOREIGN KEY ([LinkedPauseSessionID_FK]) REFERENCES [Tickets].[TicketPauseSession]([TicketPauseSessionID]);
GO

-- Indexes
CREATE NONCLUSTERED INDEX IX_ClarificationRequest_TicketID
ON [Tickets].[ClarificationRequest] ([TicketID_FK]);

CREATE NONCLUSTERED INDEX IX_ClarificationRequest_ClarificationStatus
ON [Tickets].[ClarificationRequest] ([ClarificationStatus]);

CREATE NONCLUSTERED INDEX IX_ClarificationRequest_RequestedAt
ON [Tickets].[ClarificationRequest] ([RequestedAt] DESC);

CREATE NONCLUSTERED INDEX IX_ClarificationRequest_InboxQuery
ON [Tickets].[ClarificationRequest] ([ClarificationStatus], [RequestedToDSDID_FK], [RequestedAt] DESC);
GO

-- Comment: Clarification requests are for missing information, NOT scope disputes.
-- A clarification can target a specific user or an organizational unit.
-- When BlocksTicket = TRUE, the ticket is paused until clarification is resolved.
-- This links to TicketPauseSession for SLA tracking.
-- Clarifications are separate from arbitration - they do NOT change the ticket owner.
