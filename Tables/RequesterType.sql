-- ============================================================================
-- Table: RequesterType
-- Schema: [Tickets]
-- Purpose: Lookup table defining types of requesters who can create tickets
-- Notes: Distinguishes between different source types for ticket creation.
--          Required for validation: requester can be resident OR internal user, not both.
-- ============================================================================

IF OBJECT_ID('[Tickets].[RequesterType]', 'U') IS NOT NULL
    DROP TABLE [Tickets].[RequesterType];
GO

CREATE TABLE [Tickets].[RequesterType] (
    -- Primary Key
    [RequesterTypeID] INT IDENTITY(1,1) NOT NULL,

    -- Type Code and Name
    [RequesterTypeCode] VARCHAR(20) NOT NULL, -- e.g., 'RESIDENT', 'INTERNAL'
    [RequesterTypeName] VARCHAR(50) NOT NULL,
    [TypeDescription] VARCHAR(255) NULL,

    -- Type Category
    [IsInternal] BIT NOT NULL, -- TRUE for internal users, FALSE for residents/beneficiaries

    -- Audit Columns
    [IsActive] BIT NOT NULL CONSTRAINT DF_RequesterType_IsActive DEFAULT 1,
    [CreatedAt] DATETIME2 NOT NULL CONSTRAINT DF_RequesterType_CreatedAt DEFAULT SYSDATETIME(),
    [UpdatedAt] DATETIME2 NOT NULL CONSTRAINT DF_RequesterType_UpdatedAt DEFAULT SYSDATETIME(),
    [CreatedBy] VARCHAR(100) NULL,
    [UpdatedBy] VARCHAR(100) NULL,

    -- Primary Key Constraint
    CONSTRAINT PK_RequesterType PRIMARY KEY CLUSTERED ([RequesterTypeID])
);
GO

-- Unique Constraint: Type Code must be unique
ALTER TABLE [Tickets].[RequesterType]
ADD CONSTRAINT UQ_RequesterType_RequesterTypeCode UNIQUE ([RequesterTypeCode]);
GO

-- Index for lookups by code
CREATE NONCLUSTERED INDEX IX_RequesterType_RequesterTypeCode
ON [Tickets].[RequesterType] ([RequesterTypeCode]);
GO

-- Default Records
-- RESIDENT (IsInternal = 0), INTERNAL (IsInternal = 1)
