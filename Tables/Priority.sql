-- ============================================================================
-- Table: Priority
-- Schema: [Tickets]
-- Purpose: Lookup table defining priority levels for tickets
-- Notes: Differentiates tickets by urgency level for SLA calculation and triage.
-- ============================================================================

IF OBJECT_ID('[Tickets].[Priority]', 'U') IS NOT NULL
    DROP TABLE [Tickets].[Priority];
GO

CREATE TABLE [Tickets].[Priority] (
    -- Primary Key
    [PriorityID] INT IDENTITY(1,1) NOT NULL,

    -- Priority Code and Name
    [PriorityCode] VARCHAR(10) NOT NULL, -- e.g., 'P1', 'P2', 'P3', 'P4'
    [PriorityName] VARCHAR(50) NOT NULL,
    [PriorityDescription] VARCHAR(255) NULL,

    -- Priority Level (for sorting and SLA calculation)
    [PriorityLevel] INT NOT NULL, -- Lower number = Higher priority (1 = Critical, 4 = Low)
    [IsCritical] BIT NOT NULL CONSTRAINT DF_Priority_IsCritical DEFAULT 0,

    -- Color for UI display (optional)
    [DisplayColor] VARCHAR(20) NULL, -- e.g., '#FF0000' for critical

    -- Ordering for UI display
    [DisplayOrder] INT NULL,

    -- Audit Columns
    [IsActive] BIT NOT NULL CONSTRAINT DF_Priority_IsActive DEFAULT 1,
    [CreatedAt] DATETIME2 NOT NULL CONSTRAINT DF_Priority_CreatedAt DEFAULT SYSDATETIME(),
    [UpdatedAt] DATETIME2 NOT NULL CONSTRAINT DF_Priority_UpdatedAt DEFAULT SYSDATETIME(),
    [CreatedBy] VARCHAR(100) NULL,
    [UpdatedBy] VARCHAR(100) NULL,

    -- Primary Key Constraint
    CONSTRAINT PK_Priority PRIMARY KEY CLUSTERED ([PriorityID])
);
GO

-- Unique Constraint: Priority Code must be unique
ALTER TABLE [Tickets].[Priority]
ADD CONSTRAINT UQ_Priority_PriorityCode UNIQUE ([PriorityCode]);
GO

-- Index for lookups by code and level
CREATE NONCLUSTERED INDEX IX_Priority_PriorityCode
ON [Tickets].[Priority] ([PriorityCode]);

CREATE NONCLUSTERED INDEX IX_Priority_PriorityLevel
ON [Tickets].[Priority] ([PriorityLevel]);
GO

-- Default Records
-- P1 (Critical, Level 1), P2 (High, Level 2), P3 (Medium, Level 3), P4 (Low, Level 4)
