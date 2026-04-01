-- ============================================================================
-- Table: TicketClass
-- Schema: [Tickets]
-- Purpose: Lookup table defining categories/types of tickets
-- Notes: Differentiates tickets by service category (e.g., IT, Facilities, HR).
--          Used for reporting and workflow routing.
-- ============================================================================

IF OBJECT_ID('[Tickets].[TicketClass]', 'U') IS NOT NULL
    DROP TABLE [Tickets].[TicketClass];
GO

CREATE TABLE [Tickets].[TicketClass] (
    -- Primary Key
    [TicketClassID] INT IDENTITY(1,1) NOT NULL,

    -- Class Code and Description
    [ClassCode] VARCHAR(20) NOT NULL,
    [ClassName] VARCHAR(50) NOT NULL,
    [ClassDescription] VARCHAR(255) NULL,

    -- Class Category
    [ClassCategory] VARCHAR(30) NULL, -- e.g., 'Facilities', 'IT', 'HR', 'Finance'

    -- Ordering for UI display
    [DisplayOrder] INT NULL,

    -- Audit Columns
    [IsActive] BIT NOT NULL CONSTRAINT DF_TicketClass_IsActive DEFAULT 1,
    [CreatedAt] DATETIME2 NOT NULL CONSTRAINT DF_TicketClass_CreatedAt DEFAULT SYSDATETIME(),
    [UpdatedAt] DATETIME2 NOT NULL CONSTRAINT DF_TicketClass_UpdatedAt DEFAULT SYSDATETIME(),
    [CreatedBy] VARCHAR(100) NULL,
    [UpdatedBy] VARCHAR(100) NULL,

    -- Primary Key Constraint
    CONSTRAINT PK_TicketClass PRIMARY KEY CLUSTERED ([TicketClassID])
);
GO

-- Unique Constraint: Class Code must be unique
ALTER TABLE [Tickets].[TicketClass]
ADD CONSTRAINT UQ_TicketClass_ClassCode UNIQUE ([ClassCode]);
GO

-- Index for lookups by code
CREATE NONCLUSTERED INDEX IX_TicketClass_ClassCode
ON [Tickets].[TicketClass] ([ClassCode]);
GO

-- Default Records
-- Examples: FACILITIES, IT, HR, FINANCE, SECURITY, ADMIN
