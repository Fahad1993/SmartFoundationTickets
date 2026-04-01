-- ============================================================================
-- Table: ServiceRoutingRule
-- Schema: [Tickets]
-- Purpose: Stores the default routing target for each service
-- Notes: Supports historical change over time using effective date ranges.
--          TargetDSDID_FK is mandatory - it's the true routing target.
--          RoutingLevelCode is NOT required as source-of-truth field in V1.
-- ============================================================================

IF OBJECT_ID('[Tickets].[ServiceRoutingRule]', 'U') IS NOT NULL
    DROP TABLE [Tickets].[ServiceRoutingRule];
GO

CREATE TABLE [Tickets].[ServiceRoutingRule] (
    -- Primary Key
    [ServiceRoutingRuleID] BIGINT IDENTITY(1,1) NOT NULL,

    -- Service Reference
    [ServiceID_FK] BIGINT NOT NULL,

    -- IdaraID_FK is mandatory for filtering and reporting
    [IdaraID_FK] INT NOT NULL,

    -- TargetDSDID_FK is routing truth - mandatory
    [TargetDSDID_FK] BIGINT NOT NULL, -- Reference to existing organizational DSDID
    -- This points to the actual Dept/Div/Section responsible for the service

    -- Optional Queue Distributor (if separate from DSD)
    [QueueDistributorID_FK] BIGINT NULL, -- Reference to existing Distributor table

    -- Effective Date Range (supports historical routing rules)
    [EffectiveFrom] DATETIME2 NOT NULL CONSTRAINT DF_ServiceRoutingRule_EffectiveFrom DEFAULT SYSDATETIME(),
    [EffectiveTo] DATETIME2 NULL, -- NULL means currently active rule

    -- Change Management
    [ChangeReason] VARCHAR(500) NULL,
    [PreviousRuleID_FK] BIGINT NULL, -- Self-reference for history tracking
    [ReplacedByRuleID_FK] BIGINT NULL, -- Self-reference for forward chaining

    -- Approval Information
    [ApprovedBy] VARCHAR(100) NULL,
    [ApprovedAt] DATETIME2 NULL,

    -- Audit Columns
    [CreatedAt] DATETIME2 NOT NULL CONSTRAINT DF_ServiceRoutingRule_CreatedAt DEFAULT SYSDATETIME(),
    [UpdatedAt] DATETIME2 NOT NULL CONSTRAINT DF_ServiceRoutingRule_UpdatedAt DEFAULT SYSDATETIME(),
    [CreatedBy] VARCHAR(100) NULL,
    [UpdatedBy] VARCHAR(100) NULL,

    -- Primary Key Constraint
    CONSTRAINT PK_ServiceRoutingRule PRIMARY KEY CLUSTERED ([ServiceRoutingRuleID])
);
GO

-- Foreign Key Constraints
ALTER TABLE [Tickets].[ServiceRoutingRule]
ADD CONSTRAINT FK_ServiceRoutingRule_Service
    FOREIGN KEY ([ServiceID_FK]) REFERENCES [Tickets].[Service]([ServiceID]);

-- Self-reference for history tracking
ALTER TABLE [Tickets].[ServiceRoutingRule]
ADD CONSTRAINT FK_ServiceRoutingRule_PreviousRule
    FOREIGN KEY ([PreviousRuleID_FK]) REFERENCES [Tickets].[ServiceRoutingRule]([ServiceRoutingRuleID]);

ALTER TABLE [Tickets].[ServiceRoutingRule]
ADD CONSTRAINT FK_ServiceRoutingRule_ReplacedByRule
    FOREIGN KEY ([ReplacedByRuleID_FK]) REFERENCES [Tickets].[ServiceRoutingRule]([ServiceRoutingRuleID]);
GO

-- Unique Constraint: Only one active rule per service at any time
ALTER TABLE [Tickets].[ServiceRoutingRule]
ADD CONSTRAINT UQ_ServiceRoutingRule_Service_Active UNIQUE ([ServiceID_FK], [IdaraID_FK], [EffectiveFrom]);
GO

-- Indexes
CREATE NONCLUSTERED INDEX IX_ServiceRoutingRule_ServiceID
ON [Tickets].[ServiceRoutingRule] ([ServiceID_FK]);

CREATE NONCLUSTERED INDEX IX_ServiceRoutingRule_TargetDSDID
ON [Tickets].[ServiceRoutingRule] ([TargetDSDID_FK]);

CREATE NONCLUSTERED INDEX IX_ServiceRoutingRule_EffectiveDates
ON [Tickets].[ServiceRoutingRule] ([EffectiveFrom], [EffectiveTo]);

CREATE NONCLUSTERED INDEX IX_ServiceRoutingRule_IsActive
ON [Tickets].[ServiceRoutingRule] ([EffectiveTo]) INCLUDE ([TargetDSDID_FK]);
GO

-- Comment: TargetDSDID_FK is the source of truth for routing.
-- Routing rules support historical changes using effective date ranges.
-- When a new rule is created, the old rule's EffectiveTo is set.
-- This preserves routing history for accountability.
