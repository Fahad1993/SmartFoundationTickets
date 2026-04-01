-- ============================================================================
-- Table: Service
-- Schema: [Tickets]
-- Purpose: Master table defining catalogue services visible to requesters
-- Notes: Stores service-level defaults and behavioral flags.
--          Soft delete only - records should not be physically deleted.
--          Referenced by ServiceRoutingRule, ServiceSLAPolicy, and Ticket tables.
-- ============================================================================

IF OBJECT_ID('[Tickets].[Service]', 'U') IS NOT NULL
    DROP TABLE [Tickets].[Service];
GO

CREATE TABLE [Tickets].[Service] (
    -- Primary Key
    [ServiceID] BIGINT IDENTITY(1,1) NOT NULL,

    -- IdaraID_FK is mandatory for filtering, reporting, and standard procedure patterns
    [IdaraID_FK] INT NOT NULL,

    -- Service Identification
    [ServiceCode] VARCHAR(30) NOT NULL,
    [ServiceName] VARCHAR(100) NOT NULL,
    [ServiceNameAR] NVARCHAR(100) NULL, -- Arabic name for bilingual support
    [ServiceDescription] VARCHAR(500) NULL,
    [ServiceDescriptionAR] NVARCHAR(500) NULL,

    -- Service Classification
    [TicketClassID_FK] INT NOT NULL, -- Reference to [Tickets].[TicketClass]

    -- Default Values
    [DefaultPriorityID_FK] INT NOT NULL, -- Reference to [Tickets].[Priority]

    -- Location and Workflow Flags
    [RequiresLocation] BIT NOT NULL CONSTRAINT DF_Service_RequiresLocation DEFAULT 1,
    [RequiresAttachment] BIT NOT NULL CONSTRAINT DF_Service_RequiresAttachment DEFAULT 0,
    [RequiresAppointment] BIT NOT NULL CONSTRAINT DF_Service_RequiresAppointment DEFAULT 0,

    -- Service Availability
    [IsActive] BIT NOT NULL CONSTRAINT DF_Service_IsActive DEFAULT 1,
    [IsPublic] BIT NOT NULL CONSTRAINT DF_Service_IsPublic DEFAULT 1, -- Visible to external requesters
    [EffectiveFrom] DATE NOT NULL CONSTRAINT DF_Service_EffectiveFrom DEFAULT CONVERT(DATE, SYSDATETIME()),
    [EffectiveTo] DATE NULL,

    -- Quality Management
    [EstimatedDurationMinutes] INT NULL, -- Estimated resolution time for planning
    [StandardResponseTemplate] VARCHAR(MAX) NULL, -- Template for standard responses

    -- Audit Columns
    [IsDeleted] BIT NOT NULL CONSTRAINT DF_Service_IsDeleted DEFAULT 0,
    [DeletedAt] DATETIME2 NULL,
    [CreatedAt] DATETIME2 NOT NULL CONSTRAINT DF_Service_CreatedAt DEFAULT SYSDATETIME(),
    [UpdatedAt] DATETIME2 NOT NULL CONSTRAINT DF_Service_UpdatedAt DEFAULT SYSDATETIME(),
    [CreatedBy] VARCHAR(100) NULL,
    [UpdatedBy] VARCHAR(100) NULL,

    -- Primary Key Constraint
    CONSTRAINT PK_Service PRIMARY KEY CLUSTERED ([ServiceID])
);
GO

-- Foreign Key Constraints
ALTER TABLE [Tickets].[Service]
ADD CONSTRAINT FK_Service_TicketClass
    FOREIGN KEY ([TicketClassID_FK]) REFERENCES [Tickets].[TicketClass]([TicketClassID]);

ALTER TABLE [Tickets].[Service]
ADD CONSTRAINT FK_Service_Priority
    FOREIGN KEY ([DefaultPriorityID_FK]) REFERENCES [Tickets].[Priority]([PriorityID]);
GO

-- Unique Constraint: Service Code must be unique within Idara
ALTER TABLE [Tickets].[Service]
ADD CONSTRAINT UQ_Service_ServiceCode_Idara UNIQUE ([ServiceCode], [IdaraID_FK]);
GO

-- Indexes
CREATE NONCLUSTERED INDEX IX_Service_ServiceCode
ON [Tickets].[Service] ([ServiceCode]);

CREATE NONCLUSTERED INDEX IX_Service_ServiceName
ON [Tickets].[Service] ([ServiceName]);

CREATE NONCLUSTERED INDEX IX_Service_IsActive
ON [Tickets].[Service] ([IsActive]) INCLUDE ([ServiceName], [ServiceDescription]);

CREATE NONCLUSTERED INDEX IX_Service_TicketClass
ON [Tickets].[Service] ([TicketClassID_FK]);
GO

-- Comment: This table is the core of the Service Catalogue.
-- Services are grouped by Idara for multi-department management.
-- Each service has a default priority and class for ticket initialization.
-- Soft delete is enforced via IsDeleted flag; records must not be physically deleted.
