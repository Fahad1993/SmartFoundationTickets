-- ============================================================================
-- Table: PauseReason
-- Schema: [Tickets]
-- Purpose: Lookup table defining reasons for ticket pause/blocking
-- Notes: Used to track why a ticket SLA clock is paused or work is blocked.
--          Required for SLA calculation and reporting on delays.
-- ============================================================================

IF OBJECT_ID('[Tickets].[PauseReason]', 'U') IS NOT NULL
    DROP TABLE [Tickets].[PauseReason];
GO

CREATE TABLE [Tickets].[PauseReason] (
    -- Primary Key
    [PauseReasonID] INT IDENTITY(1,1) NOT NULL,

    -- Reason Code and Name
    [PauseReasonCode] VARCHAR(30) NOT NULL, -- e.g., 'DEPENDENCY', 'ARBITRATION', 'CLARIFICATION', etc.
    [PauseReasonName] VARCHAR(100) NOT NULL,
    [ReasonDescription] VARCHAR(500) NULL,

    -- Pause Category
    [PauseCategory] VARCHAR(30) NULL, -- e.g., 'External', 'Internal', 'Process'

    -- SLA Behavior
    [PausesSLA] BIT NOT NULL CONSTRAINT DF_PauseReason_PausesSLA DEFAULT 1,
    -- Whether this pause reason counts against SLA (usually FALSE for legitimate blockers)

    -- Ordering for UI display
    [DisplayOrder] INT NULL,

    -- Audit Columns
    [IsActive] BIT NOT NULL CONSTRAINT DF_PauseReason_IsActive DEFAULT 1,
    [CreatedAt] DATETIME2 NOT NULL CONSTRAINT DF_PauseReason_CreatedAt DEFAULT SYSDATETIME(),
    [UpdatedAt] DATETIME2 NOT NULL CONSTRAINT DF_PauseReason_UpdatedAt DEFAULT SYSDATETIME(),
    [CreatedBy] VARCHAR(100) NULL,
    [UpdatedBy] VARCHAR(100) NULL,

    -- Primary Key Constraint
    CONSTRAINT PK_PauseReason PRIMARY KEY CLUSTERED ([PauseReasonID])
);
GO

-- Unique Constraint: Reason Code must be unique
ALTER TABLE [Tickets].[PauseReason]
ADD CONSTRAINT UQ_PauseReason_PauseReasonCode UNIQUE ([PauseReasonCode]);
GO

-- Index for lookups by code
CREATE NONCLUSTERED INDEX IX_PauseReason_PauseReasonCode
ON [Tickets].[PauseReason] ([PauseReasonCode]);
GO

-- Default Records
-- DEPENDENCY (Child ticket blocking), ARBITRATION (Waiting for arbitration decision),
-- CLARIFICATION (Waiting for information), WAREHOUSE (Waiting for supplies),
-- APPROVAL (Waiting for approval), EXTERNAL (Third-party delay)
