-- ============================================================================
-- Table: ServiceSLAPolicy
-- Schema: [Tickets]
-- Purpose: Defines SLA targets for a service under a given priority
-- Notes: Each combination of Service + Priority has its own SLA targets.
--          Supports date ranges for policy changes over time.
-- ============================================================================

IF OBJECT_ID('[Tickets].[ServiceSLAPolicy]', 'U') IS NOT NULL
    DROP TABLE [Tickets].[ServiceSLAPolicy];
GO

CREATE TABLE [Tickets].[ServiceSLAPolicy] (
    -- Primary Key
    [ServiceSLAPolicyID] BIGINT IDENTITY(1,1) NOT NULL,

    -- IdaraID_FK is mandatory for filtering and reporting
    [IdaraID_FK] INT NOT NULL,

    -- Service and Priority References
    [ServiceID_FK] BIGINT NOT NULL,
    [PriorityID_FK] INT NOT NULL,

    -- Four SLA Targets (in minutes)
    [FirstResponseTargetMinutes] INT NOT NULL, -- Time to first acknowledge/respond
    [AssignmentTargetMinutes] INT NOT NULL, -- Time to assign to a user
    [OperationalCompletionTargetMinutes] INT NOT NULL, -- Time to complete the work
    [FinalClosureTargetMinutes] INT NOT NULL, -- Time for final quality closure

    -- Effective Date Range
    [EffectiveFrom] DATETIME2 NOT NULL CONSTRAINT DF_ServiceSLAPolicy_EffectiveFrom DEFAULT SYSDATETIME(),
    [EffectiveTo] DATETIME2 NULL, -- NULL means currently active policy

    -- Policy Metadata
    [PolicyDescription] VARCHAR(500) NULL,
    [IsWeekdayOnly] BIT NOT NULL CONSTRAINT DF_ServiceSLAPolicy_IsWeekdayOnly DEFAULT 0,
    -- If TRUE, only counts business days (requires calculation in SP)

    -- Audit Columns
    [CreatedAt] DATETIME2 NOT NULL CONSTRAINT DF_ServiceSLAPolicy_CreatedAt DEFAULT SYSDATETIME(),
    [UpdatedAt] DATETIME2 NOT NULL CONSTRAINT DF_ServiceSLAPolicy_UpdatedAt DEFAULT SYSDATETIME(),
    [CreatedBy] VARCHAR(100) NULL,
    [UpdatedBy] VARCHAR(100) NULL,

    -- Primary Key Constraint
    CONSTRAINT PK_ServiceSLAPolicy PRIMARY KEY CLUSTERED ([ServiceSLAPolicyID])
);
GO

-- Foreign Key Constraints
ALTER TABLE [Tickets].[ServiceSLAPolicy]
ADD CONSTRAINT FK_ServiceSLAPolicy_Service
    FOREIGN KEY ([ServiceID_FK]) REFERENCES [Tickets].[Service]([ServiceID]);

ALTER TABLE [Tickets].[ServiceSLAPolicy]
ADD CONSTRAINT FK_ServiceSLAPolicy_Priority
    FOREIGN KEY ([PriorityID_FK]) REFERENCES [Tickets].[Priority]([PriorityID]);
GO

-- Unique Constraint: Only one active policy per service+priority at any time
ALTER TABLE [Tickets].[ServiceSLAPolicy]
ADD CONSTRAINT UQ_ServiceSLAPolicy_Service_Priority_Active
    UNIQUE ([ServiceID_FK], [PriorityID_FK], [IdaraID_FK], [EffectiveFrom]);
GO

-- Indexes
CREATE NONCLUSTERED INDEX IX_ServiceSLAPolicy_ServiceID
ON [Tickets].[ServiceSLAPolicy] ([ServiceID_FK]);

CREATE NONCLUSTERED INDEX IX_ServiceSLAPolicy_PriorityID
ON [Tickets].[ServiceSLAPolicy] ([PriorityID_FK]);

CREATE NONCLUSTERED INDEX IX_ServiceSLAPolicy_EffectiveDates
ON [Tickets].[ServiceSLAPolicy] ([EffectiveFrom], [EffectiveTo]);

CREATE NONCLUSTERED INDEX IX_ServiceSLAPolicy_IsActive
ON [Tickets].[ServiceSLAPolicy] ([EffectiveTo]) INCLUDE ([FirstResponseTargetMinutes], [AssignmentTargetMinutes], [OperationalCompletionTargetMinutes], [FinalClosureTargetMinutes]);
GO

-- Comment: SLA targets are defined per service and priority combination.
-- All targets are stored in minutes for consistency.
-- Policies support date-based changes for different service levels over time.
-- IsWeekdayOnly flag indicates if business-day calculation is required.
