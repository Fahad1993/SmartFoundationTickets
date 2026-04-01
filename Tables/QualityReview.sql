-- ============================================================================
-- Table: QualityReview
-- Schema: [Tickets]
-- Purpose: Tracks final quality/monitoring verification after operational resolution
-- Notes: Supports two-stage closure model: operational → final quality verification.
--          Only authorized reviewers can approve final closure.
-- ============================================================================

IF OBJECT_ID('[Tickets].[QualityReview]', 'U') IS NOT NULL
    DROP TABLE [Tickets].[QualityReview];
GO

CREATE TABLE [Tickets].[QualityReview] (
    -- Primary Key
    [QualityReviewID] BIGINT IDENTITY(1,1) NOT NULL,

    -- Ticket Reference
    [TicketID_FK] BIGINT NOT NULL,

    -- IdaraID_FK is mandatory for filtering and reporting
    [IdaraID_FK] INT NOT NULL,

    -- Reviewer Information
    [ReviewerID_FK] BIGINT NULL, -- Reference to User table (who performed review)
    [ReviewerName] VARCHAR(100) NULL,

    -- Review Scope and Type
    [ReviewScope] VARCHAR(50) NULL, -- e.g., 'FULL_REVIEW', 'SPOT_CHECK', 'DOCUMENTATION_ONLY'
    [ReviewType] VARCHAR(30) NOT NULL, -- e.g., 'STANDARD', 'ESCALATED', 'COMPLAINT_REVIEW'

    -- Review Process
    [ReviewStartedAt] DATETIME2 NOT NULL CONSTRAINT DF_QualityReview_ReviewStartedAt DEFAULT SYSDATETIME(),
    [ReviewedAt] DATETIME2 NULL,
    [ReviewDurationMinutes] INT NULL,

    -- Review Findings
    [ReviewResultID_FK] INT NOT NULL, -- Reference to [Tickets].[QualityReviewResult]
    [QualityScore] DECIMAL(3,1) NULL, -- Optional numeric quality score
    [DefectsFound] INT NULL,
    [ComplianceNotes] VARCHAR(MAX) NULL,

    -- Review Notes
    [ReviewNotes] VARCHAR(MAX) NULL,
    [ReviewNotesAR] NVARCHAR(MAX) NULL, -- Arabic notes

    -- Return Action (if not approved)
    [ReturnToUserID_FK] BIGINT NULL, -- User to return ticket to for correction
    [ReturnToDSDID_FK] BIGINT NULL, -- Organizational unit to return to
    [ReturnInstructions] VARCHAR(1000) NULL,
    [ReturnInstructionsAR] NVARCHAR(1000) NULL,

    -- Finalization
    [IsFinalized] BIT NOT NULL CONSTRAINT DF_QualityReview_IsFinalized DEFAULT 0,
    -- When TRUE, the review is complete and ticket state is updated
    [FinalizedAt] DATETIME2 NULL,
    [EscalationLevel] INT NULL, -- If escalated, how many levels up

    -- Audit Columns
    [CreatedAt] DATETIME2 NOT NULL CONSTRAINT DF_QualityReview_CreatedAt DEFAULT SYSDATETIME(),
    [UpdatedAt] DATETIME2 NOT NULL CONSTRAINT DF_QualityReview_UpdatedAt DEFAULT SYSDATETIME(),
    [CreatedBy] VARCHAR(100) NULL,
    [UpdatedBy] VARCHAR(100) NULL,

    -- Primary Key Constraint
    CONSTRAINT PK_QualityReview PRIMARY KEY CLUSTERED ([QualityReviewID])
);
GO

-- Foreign Key Constraints
ALTER TABLE [Tickets].[QualityReview]
ADD CONSTRAINT FK_QualityReview_Ticket
    FOREIGN KEY ([TicketID_FK]) REFERENCES [Tickets].[Ticket]([TicketID]);

ALTER TABLE [Tickets].[QualityReview]
ADD CONSTRAINT FK_QualityReview_QualityReviewResult
    FOREIGN KEY ([ReviewResultID_FK]) REFERENCES [Tickets].[QualityReviewResult]([QualityReviewResultID]);
GO

-- Indexes
CREATE NONCLUSTERED INDEX IX_QualityReview_TicketID
ON [Tickets].[QualityReview] ([TicketID_FK]);

CREATE NONCLUSTERED INDEX IX_QualityReview_ReviewerID
ON [Tickets].[QualityReview] ([ReviewerID_FK]);

CREATE NONCLUSTERED INDEX IX_QualityReview_ReviewStartedAt
ON [Tickets].[QualityReview] ([ReviewStartedAt] DESC);

CREATE NONCLUSTERED INDEX IX_QualityReview_InboxQuery
ON [Tickets].[QualityReview] ([TicketID_FK], [ReviewedAt])
INCLUDE ([ReviewResultID_FK], [ReviewerID_FK]);

CREATE NONCLUSTERED INDEX IX_QualityReview_PendingReviews
ON [Tickets].[QualityReview] ([ReviewerID_FK], [ReviewedAt]) -- NULL ReviewedAt means pending
INCLUDE ([TicketID_FK], [ReviewStartedAt]);
GO

-- Comment: Quality reviews enforce two-stage closure.
-- ReviewResultID_FK determines the outcome:
--   APPROVED → Ticket can be finally closed
--   RETURNED_FOR_CORRECTION → Ticket returned to same assignee
--   REJECTED → Ticket may need reassignment
-- QualityReviewResult is looked up for display text and RequiresReassignment flag.
-- Only one quality review per ticket should exist in final state.
