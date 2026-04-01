-- ============================================================================
-- Table: ArbitrationReason
-- Schema: [Tickets]
-- Purpose: Lookup table defining reasons for arbitration cases
-- Notes: Used to categorize scope disputes that require resolution.
--          Helps track common routing issues for service catalogue improvement.
-- ============================================================================

IF OBJECT_ID('[Tickets].[ArbitrationReason]', 'U') IS NOT NULL
    DROP TABLE [Tickets].[ArbitrationReason];
GO

CREATE TABLE [Tickets].[ArbitrationReason] (
    -- Primary Key
    [ArbitrationReasonID] INT IDENTITY(1,1) NOT NULL,

    -- Reason Code and Name
    [ArbitrationReasonCode] VARCHAR(30) NOT NULL,
    [ArbitrationReasonName] VARCHAR(100) NOT NULL,
    [ReasonDescription] VARCHAR(500) NULL,

    -- Reason Category
    [ArbitrationCategory] VARCHAR(30) NULL, -- e.g., 'WrongScope', 'UnknownService', 'OwnershipDispute'

    -- Ordering for UI display
    [DisplayOrder] INT NULL,

    -- Audit Columns
    [IsActive] BIT NOT NULL CONSTRAINT DF_ArbitrationReason_IsActive DEFAULT 1,
    [CreatedAt] DATETIME2 NOT NULL CONSTRAINT DF_ArbitrationReason_CreatedAt DEFAULT SYSDATETIME(),
    [UpdatedAt] DATETIME2 NOT NULL CONSTRAINT DF_ArbitrationReason_UpdatedAt DEFAULT SYSDATETIME(),
    [CreatedBy] VARCHAR(100) NULL,
    [UpdatedBy] VARCHAR(100) NULL,

    -- Primary Key Constraint
    CONSTRAINT PK_ArbitrationReason PRIMARY KEY CLUSTERED ([ArbitrationReasonID])
);
GO

-- Unique Constraint: Reason Code must be unique
ALTER TABLE [Tickets].[ArbitrationReason]
ADD CONSTRAINT UQ_ArbitrationReason_ArbitrationReasonCode UNIQUE ([ArbitrationReasonCode]);
GO

-- Index for lookups by code
CREATE NONCLUSTERED INDEX IX_ArbitrationReason_ArbitrationReasonCode
ON [Tickets].[ArbitrationReason] ([ArbitrationReasonCode]);
GO

-- Default Records
-- WRONG_SCOPE (Ticket belongs to wrong organizational unit),
-- UNKNOWN_SERVICE (Service not in catalogue),
-- OWNERSHIP_DISPUTE (Multiple units claiming responsibility),
-- CAPACITY_ISSUE (Current unit cannot handle workload)
