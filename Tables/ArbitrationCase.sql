-- ============================================================================
-- Table: ArbitrationCase
-- Schema: [Tickets]
-- Purpose: Tracks wrong-scope disputes that require resolution
-- Notes: Used when routing is challenged through supervisory chain.
--          Separates scope disputes from clarification requests.
-- ============================================================================

IF OBJECT_ID('[Tickets].[ArbitrationCase]', 'U') IS NOT NULL
    DROP TABLE [Tickets].[ArbitrationCase];
GO

CREATE TABLE [Tickets].[ArbitrationCase] (
    -- Primary Key
    [ArbitrationCaseID] BIGINT IDENTITY(1,1) NOT NULL,

    -- Ticket Reference
    [TicketID_FK] BIGINT NOT NULL,

    -- IdaraID_FK is mandatory for filtering and reporting
    [IdaraID_FK] INT NOT NULL,

    -- Who Raised the Case
    [RaisedBy] VARCHAR(100) NULL, -- User who initiated arbitration
    [RaisedByUserID_FK] BIGINT NULL, -- Reference to User table
    [RaisedAt] DATETIME2 NOT NULL CONSTRAINT DF_ArbitrationCase_RaisedAt DEFAULT SYSDATETIME(),

    -- From Which DSD (current location where dispute was raised)
    [FromDSDID_FK] BIGINT NULL, -- Current queue at time of arbitration
    [FromDistributorID_FK] BIGINT NULL, -- Current queue distributor

    -- Arbitration Reason
    [ArbitrationReasonID_FK] INT NOT NULL, -- Reference to [Tickets].[ArbitrationReason]

    -- Current Arbitrator (organizational receiver for the case)
    [CurrentArbitratorDistributorID_FK] BIGINT NULL, -- Reference to existing Distributor table
    [AssignedArbitratorAt] DATETIME2 NULL,

    -- Case Details
    [DisputeDescription] VARCHAR(MAX) NULL,
    [ProposedTargetDSDID_FK] BIGINT NULL, -- Suggested by the raising unit

    -- Status Management
    [ArbitrationStatus] VARCHAR(20) NOT NULL CONSTRAINT DF_ArbitrationCase_ArbitrationStatus DEFAULT 'OPEN',
    -- Values: OPEN, UNDER_REVIEW, DECIDED, CANCELLED

    -- Decision Information
    [DecisionType] VARCHAR(30) NULL, -- Values: REDIRECT, OVERRULE, NO_CHANGE
    [DecisionTargetDSDID_FK] BIGINT NULL, -- New target if REDIRECT decision
    [DecisionNotes] VARCHAR(MAX) NULL,
    [DecidedBy] VARCHAR(100) NULL,
    [DecidedAt] DATETIME2 NULL,

    -- Reference to Catalog Change Log (if routing was corrected)
    [CatalogRoutingChangeLogID_FK] BIGINT NULL, -- Link to [Tickets].[CatalogRoutingChangeLog]

    -- Audit Columns
    [CreatedAt] DATETIME2 NOT NULL CONSTRAINT DF_ArbitrationCase_CreatedAt DEFAULT SYSDATETIME(),
    [UpdatedAt] DATETIME2 NOT NULL CONSTRAINT DF_ArbitrationCase_UpdatedAt DEFAULT SYSDATETIME(),
    [CreatedBy] VARCHAR(100) NULL,
    [UpdatedBy] VARCHAR(100) NULL,

    -- Primary Key Constraint
    CONSTRAINT PK_ArbitrationCase PRIMARY KEY CLUSTERED ([ArbitrationCaseID])
);
GO

-- Foreign Key Constraints
ALTER TABLE [Tickets].[ArbitrationCase]
ADD CONSTRAINT FK_ArbitrationCase_Ticket
    FOREIGN KEY ([TicketID_FK]) REFERENCES [Tickets].[Ticket]([TicketID]);

ALTER TABLE [Tickets].[ArbitrationCase]
ADD CONSTRAINT FK_ArbitrationCase_ArbitrationReason
    FOREIGN KEY ([ArbitrationReasonID_FK]) REFERENCES [Tickets].[ArbitrationReason]([ArbitrationReasonID]);

ALTER TABLE [Tickets].[ArbitrationCase]
ADD CONSTRAINT FK_ArbitrationCase_CatalogRoutingChangeLog
    FOREIGN KEY ([CatalogRoutingChangeLogID_FK]) REFERENCES [Tickets].[CatalogRoutingChangeLog]([CatalogRoutingChangeLogID]);
GO

-- Indexes
CREATE NONCLUSTERED INDEX IX_ArbitrationCase_TicketID
ON [Tickets].[ArbitrationCase] ([TicketID_FK]);

CREATE NONCLUSTERED INDEX IX_ArbitrationCase_ArbitrationStatus
ON [Tickets].[ArbitrationCase] ([ArbitrationStatus]);

CREATE NONCLUSTERED INDEX IX_ArbitrationCase_CurrentArbitrator
ON [Tickets].[ArbitrationCase] ([CurrentArbitratorDistributorID_FK]);

CREATE NONCLUSTERED INDEX IX_ArbitrationCase_RaisedAt
ON [Tickets].[ArbitrationCase] ([RaisedAt] DESC);

CREATE NONCLUSTERED INDEX IX_ArbitrationCase_InboxQuery
ON [Tickets].[ArbitrationCase] ([ArbitrationStatus], [CurrentArbitratorDistributorID_FK], [RaisedAt] DESC);
GO

-- Comment: Arbitration cases track scope disputes raised through supervisory chain.
-- Decision types: REDIRECT (reassign to different DSD), OVERRULE (reject dispute), NO_CHANGE.
-- Links to CatalogRoutingChangeLog when routing is corrected based on arbitration.
-- Only users with appropriate authorization can assign cases to arbitrators.
