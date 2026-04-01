-- ============================================================================
-- Table: ClarificationReason
-- Schema: [Tickets]
-- Purpose: Lookup table defining reasons for clarification requests
-- Notes: Used to categorize missing information requests.
--          Separated from arbitration as these are NOT scope disputes.
-- ============================================================================

IF OBJECT_ID('[Tickets].[ClarificationReason]', 'U') IS NOT NULL
    DROP TABLE [Tickets].[ClarificationReason];
GO

CREATE TABLE [Tickets].[ClarificationReason] (
    -- Primary Key
    [ClarificationReasonID] INT IDENTITY(1,1) NOT NULL,

    -- Reason Code and Name
    [ClarificationReasonCode] VARCHAR(30) NOT NULL,
    [ClarificationReasonName] VARCHAR(100) NOT NULL,
    [ReasonDescription] VARCHAR(500) NULL,

    -- Reason Category
    [ClarificationCategory] VARCHAR(30) NULL, -- e.g., 'MissingDetails', 'ConfirmScope', 'ApprovalRequired'

    -- Ordering for UI display
    [DisplayOrder] INT NULL,

    -- Audit Columns
    [IsActive] BIT NOT NULL CONSTRAINT DF_ClarificationReason_IsActive DEFAULT 1,
    [CreatedAt] DATETIME2 NOT NULL CONSTRAINT DF_ClarificationReason_CreatedAt DEFAULT SYSDATETIME(),
    [UpdatedAt] DATETIME2 NOT NULL CONSTRAINT DF_ClarificationReason_UpdatedAt DEFAULT SYSDATETIME(),
    [CreatedBy] VARCHAR(100) NULL,
    [UpdatedBy] VARCHAR(100) NULL,

    -- Primary Key Constraint
    CONSTRAINT PK_ClarificationReason PRIMARY KEY CLUSTERED ([ClarificationReasonID])
);
GO

-- Unique Constraint: Reason Code must be unique
ALTER TABLE [Tickets].[ClarificationReason]
ADD CONSTRAINT UQ_ClarificationReason_ClarificationReasonCode UNIQUE ([ClarificationReasonCode]);
GO

-- Index for lookups by code
CREATE NONCLUSTERED INDEX IX_ClarificationReason_ClarificationReasonCode
ON [Tickets].[ClarificationReason] ([ClarificationReasonCode]);
GO

-- Default Records
-- MISSING_TECHNICAL_DETAILS (Requires specifications residents can't provide),
-- CONFIRM_LOCATION (Need to verify service location),
-- CONFIRM_SCOPE (Need to confirm what work is included),
-- ADDITIONAL_INFO (Need more details about the issue),
-- ATTACHMENT_REQUIRED (Supporting documents needed)
