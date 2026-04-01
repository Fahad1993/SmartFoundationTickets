-- ============================================================================
-- Table: QualityReviewResult
-- Schema: [Tickets]
-- Purpose: Lookup table defining possible outcomes of quality review
-- Notes: Used to track final decisions in two-stage closure process.
-- ============================================================================

IF OBJECT_ID('[Tickets].[QualityReviewResult]', 'U') IS NOT NULL
    DROP TABLE [Tickets].[QualityReviewResult];
GO

CREATE TABLE [Tickets].[QualityReviewResult] (
    -- Primary Key
    [QualityReviewResultID] INT IDENTITY(1,1) NOT NULL,

    -- Result Code and Name
    [ResultCode] VARCHAR(20) NOT NULL, -- e.g., 'APPROVED', 'RETURNED', 'REJECTED'
    [ResultName] VARCHAR(50) NOT NULL,
    [ResultDescription] VARCHAR(255) NULL,

    -- Result Category and Impact
    [ResultCategory] VARCHAR(30) NULL, -- e.g., 'Approved', 'Returned', 'Rejected'
    [RequiresReassignment] BIT NOT NULL CONSTRAINT DF_QualityReviewResult_RequiresReassignment DEFAULT 0,
    -- TRUE if ticket needs to be reassigned after this result

    -- Ordering for UI display
    [DisplayOrder] INT NULL,

    -- Audit Columns
    [IsActive] BIT NOT NULL CONSTRAINT DF_QualityReviewResult_IsActive DEFAULT 1,
    [CreatedAt] DATETIME2 NOT NULL CONSTRAINT DF_QualityReviewResult_CreatedAt DEFAULT SYSDATETIME(),
    [UpdatedAt] DATETIME2 NOT NULL CONSTRAINT DF_QualityReviewResult_UpdatedAt DEFAULT SYSDATETIME(),
    [CreatedBy] VARCHAR(100) NULL,
    [UpdatedBy] VARCHAR(100) NULL,

    -- Primary Key Constraint
    CONSTRAINT PK_QualityReviewResult PRIMARY KEY CLUSTERED ([QualityReviewResultID])
);
GO

-- Unique Constraint: Result Code must be unique
ALTER TABLE [Tickets].[QualityReviewResult]
ADD CONSTRAINT UQ_QualityReviewResult_ResultCode UNIQUE ([ResultCode]);
GO

-- Index for lookups by code
CREATE NONCLUSTERED INDEX IX_QualityReviewResult_ResultCode
ON [Tickets].[QualityReviewResult] ([ResultCode]);
GO

-- Default Records
-- APPROVED (Quality verified, can finally close),
-- RETURNED_FOR_CORRECTION (Needs more work by current assignee),
-- REJECTED (Not acceptable, may need reassignment)
