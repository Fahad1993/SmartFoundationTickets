-- ============================================================================
-- Table: ServiceCatalogSuggestion
-- Schema: [Tickets]
-- Purpose: Captures proposals to convert "Other" requests into formal catalogue services
-- Notes: Enables service catalogue learning from repeated real-world cases.
--          Can be approved to create a new Service record.
-- ============================================================================

IF OBJECT_ID('[Tickets].[ServiceCatalogSuggestion]', 'U') IS NOT NULL
    DROP TABLE [Tickets].[ServiceCatalogSuggestion];
GO

CREATE TABLE [Tickets].[ServiceCatalogSuggestion] (
    -- Primary Key
    [ServiceCatalogSuggestionID] BIGINT IDENTITY(1,1) NOT NULL,

    -- Source Reference (where does suggestion came from)
    [SourceTicketID_FK] BIGINT NULL, -- Reference to [Tickets].[Tickets]
    [SourceArbitrationCaseID_FK] BIGINT NULL, -- Reference to [Tickets].[ArbitrationCase]

    -- IdaraID_FK is mandatory for filtering and reporting
    [IdaraID_FK] INT NOT NULL,

    -- Proposed Service Details
    [ProposedServiceName] VARCHAR(100) NOT NULL,
    [ProposedServiceNameAR] NVARCHAR(100) NULL, -- Arabic name
    [ProposedDescription] VARCHAR(1000) NOT NULL,
    [ProposedDescriptionAR] NVARCHAR(1000) NULL,
    [ProposedCategory] VARCHAR(50) NULL,

    -- Proposed Routing (optional)
    [ProposedTargetDSDID_FK] BIGINT NULL, -- Suggested organizational unit
    [ProposedPriorityID_FK] INT NULL, -- Suggested default priority

    -- Suggested by
    [SuggestedBy] VARCHAR(100) NULL, -- User or arbitrator name
    [SuggestedAt] DATETIME2 NOT NULL CONSTRAINT DF_ServiceCatalogSuggestion_SuggestedAt DEFAULT SYSDATETIME(),

    -- Approval Status and Process
    [ApprovalStatus] VARCHAR(20) NOT NULL CONSTRAINT DF_ServiceCatalogSuggestion_ApprovalStatus DEFAULT 'PENDING',
    -- Values: PENDING, APPROVED, REJECTED
    [ApprovedBy] VARCHAR(100) NULL,
    [ApprovedAt] DATETIME2 NULL,
    [RejectionReason] VARCHAR(500) NULL,

    -- Reference to Created Service (if approved)
    [CreatedServiceID_FK] BIGINT NULL, -- Reference to [Tickets].[Service] after approval

    -- Audit Columns
    [CreatedAt] DATETIME2 NOT NULL CONSTRAINT DF_ServiceCatalogSuggestion_CreatedAt DEFAULT SYSDATETIME(),
    [UpdatedAt] DATETIME2 NOT NULL CONSTRAINT DF_ServiceCatalogSuggestion_UpdatedAt DEFAULT SYSDATETIME(),
    [CreatedBy] VARCHAR(100) NULL,
    [UpdatedBy] VARCHAR(100) NULL,

    -- Primary Key Constraint
    CONSTRAINT PK_ServiceCatalogSuggestion PRIMARY KEY CLUSTERED ([ServiceCatalogSuggestionID])
);
GO

-- Foreign Key Constraints
ALTER TABLE [Tickets].[ServiceCatalogSuggestion]
ADD CONSTRAINT FK_ServiceCatalogSuggestion_Ticket
    FOREIGN KEY ([SourceTicketID_FK]) REFERENCES [Tickets].[Tickets]([TicketID]);

ALTER TABLE [Tickets].[ServiceCatalogSuggestion]
ADD CONSTRAINT FK_ServiceCatalogSuggestion_ArbitrationCase
    FOREIGN KEY ([SourceArbitrationCaseID_FK]) REFERENCES [Tickets].[ArbitrationCase]([ArbitrationCaseID]);

ALTER TABLE [Tickets].[ServiceCatalogSuggestion]
ADD CONSTRAINT FK_ServiceCatalogSuggestion_Priority
    FOREIGN KEY ([ProposedPriorityID_FK]) REFERENCES [Tickets].[Priority]([PriorityID]);

ALTER TABLE [Tickets].[ServiceCatalogSuggestion]
ADD CONSTRAINT FK_ServiceCatalogSuggestion_Service
    FOREIGN KEY ([CreatedServiceID_FK]) REFERENCES [Tickets].[Service]([ServiceID]);
GO

-- Indexes
CREATE NONCLUSTERED INDEX IX_ServiceCatalogSuggestion_SourceTicket
ON [Tickets].[ServiceCatalogSuggestion] ([SourceTicketID_FK]);

CREATE NONCLUSTERED INDEX IX_ServiceCatalogSuggestion_ApprovalStatus
ON [Tickets].[ServiceCatalogSuggestion] ([ApprovalStatus]);

CREATE NONCLUSTERED INDEX IX_ServiceCatalogSuggestion_SuggestedAt
ON [Tickets].[ServiceCatalogSuggestion] ([SuggestedAt] DESC);
GO

-- Comment: This table captures "Other" service suggestions for catalogue improvement.
-- Suggestions can originate from tickets or arbitration cases.
-- When approved, CreatedServiceID_FK links to the new Service record.
-- This enables continuous improvement of service catalogue based on real needs.
