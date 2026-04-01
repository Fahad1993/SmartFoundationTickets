-- ============================================================================
-- Table: TicketStatus
-- Schema: [Tickets]
-- Purpose: Lookup table defining all possible statuses for a ticket throughout its lifecycle
-- Notes: This table stores static reference data for ticket states.
--          Used to enforce valid status transitions and reporting.
-- ============================================================================

IF OBJECT_ID('[Tickets].[TicketStatus]', 'U') IS NOT NULL
    DROP TABLE [Tickets].[TicketStatus];
GO

CREATE TABLE [Tickets].[TicketStatus] (
    -- Primary Key
    [TicketStatusID] INT IDENTITY(1,1) NOT NULL,

    -- Status Code and Description
    [StatusCode] VARCHAR(20) NOT NULL,
    [StatusName] VARCHAR(50) NOT NULL,
    [StatusDescription] VARCHAR(255) NULL,

    -- Status Category (for grouping)
    [StatusCategory] VARCHAR(30) NULL, -- e.g., 'Open', 'InProgress', 'Closed', 'Cancelled'

    -- Ordering for UI display
    [DisplayOrder] INT NULL,

    -- Audit Columns
    [IsActive] BIT NOT NULL CONSTRAINT DF_TicketStatus_IsActive DEFAULT 1,
    [CreatedAt] DATETIME2 NOT NULL CONSTRAINT DF_TicketStatus_CreatedAt DEFAULT SYSDATETIME(),
    [UpdatedAt] DATETIME2 NOT NULL CONSTRAINT DF_TicketStatus_UpdatedAt DEFAULT SYSDATETIME(),
    [CreatedBy] VARCHAR(100) NULL,
    [UpdatedBy] VARCHAR(100) NULL,

    -- Primary Key Constraint
    CONSTRAINT PK_TicketStatus PRIMARY KEY CLUSTERED ([TicketStatusID])
);
GO

-- Unique Constraint: Status Code must be unique
ALTER TABLE [Tickets].[TicketStatus]
ADD CONSTRAINT UQ_TicketStatus_StatusCode UNIQUE ([StatusCode]);
GO

-- Index for lookups by code
CREATE NONCLUSTERED INDEX IX_TicketStatus_StatusCode
ON [Tickets].[TicketStatus] ([StatusCode]);
GO

-- Default Records (can be seeded via separate script)
-- Values would include: New, Queue, InProgress, Clarification, Arbitration, Paused,
-- OperationalResolved, QualityReview, FinallyClosed, Rejected, Cancelled
