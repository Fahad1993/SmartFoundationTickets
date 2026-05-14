-- ============================================================================
-- Multi-Department Ticketing System — MSSQL Table Creation Script
-- ============================================================================
-- Description: Creates all 7 tables with constraints, foreign keys, indexes,
--              and default values for the ticketing system.
-- Target:      Microsoft SQL Server 2019+
-- Date:        April 16, 2026
-- ============================================================================

USE [TicketingSystem];
GO

-- ============================================================================
-- 1. Services (Service Catalogue)
-- ============================================================================
IF OBJECT_ID('dbo.Services', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Services (
        Id                  INT             IDENTITY(1,1)   NOT NULL,
        Code                NVARCHAR(20)    NOT NULL,
        NameEn              NVARCHAR(200)   NOT NULL,
        Department          NVARCHAR(100)   NOT NULL,
        Division            NVARCHAR(100)   NOT NULL,
        Section             NVARCHAR(100)   NOT NULL,
        DefaultPriority     NVARCHAR(20)    NOT NULL,       -- Critical | High | Medium | Low
        IsActive            BIT             NOT NULL        DEFAULT 1,
        SlaResponseMin      INT             NOT NULL,       -- minutes
        SlaAssignMin        INT             NOT NULL,       -- minutes
        SlaCompletionMin    INT             NOT NULL,       -- minutes
        SlaClosureMin       INT             NOT NULL,       -- minutes

        CONSTRAINT PK_Services PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT UQ_Services_Code UNIQUE (Code),
        CONSTRAINT CK_Services_DefaultPriority CHECK (DefaultPriority IN ('Critical', 'High', 'Medium', 'Low')),
        CONSTRAINT CK_Services_SlaResponseMin CHECK (SlaResponseMin >= 0),
        CONSTRAINT CK_Services_SlaAssignMin CHECK (SlaAssignMin >= 0),
        CONSTRAINT CK_Services_SlaCompletionMin CHECK (SlaCompletionMin >= 0),
        CONSTRAINT CK_Services_SlaClosureMin CHECK (SlaClosureMin >= 0)
    );
END;
GO

CREATE NONCLUSTERED INDEX IX_Services_Code ON dbo.Services (Code);
GO
CREATE NONCLUSTERED INDEX IX_Services_Department ON dbo.Services (Department);
GO
CREATE NONCLUSTERED INDEX IX_Services_IsActive ON dbo.Services (IsActive);
GO

-- ============================================================================
-- 2. Tickets
-- ============================================================================
IF OBJECT_ID('dbo.Tickets', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tickets (
        Id                      INT             IDENTITY(1,1)   NOT NULL,
        TicketNo                NVARCHAR(30)    NOT NULL,
        Title                   NVARCHAR(300)   NOT NULL,
        Description             NVARCHAR(MAX)   NOT NULL,
        Status                  NVARCHAR(30)    NOT NULL,       -- Open | Assigned | InProgress | Paused | Resolved | Closed | PendingArbitration | PendingClarification
        Priority                NVARCHAR(20)    NOT NULL,       -- Critical | High | Medium | Low
        RequesterType           NVARCHAR(20)    NOT NULL,       -- Resident | Internal
        RequesterName           NVARCHAR(200)   NOT NULL,
        ServiceId               INT             NULL,
        ServiceName             NVARCHAR(200)   NOT NULL,
        IsOtherService          BIT             NOT NULL        DEFAULT 0,
        Department              NVARCHAR(100)   NOT NULL,
        Division                NVARCHAR(100)   NOT NULL,
        Section                 NVARCHAR(100)   NOT NULL,
        CurrentQueue            NVARCHAR(200)   NOT NULL,
        AssignedUser            NVARCHAR(200)   NULL,
        ParentTicketId          INT             NULL,
        IsParentBlocked         BIT             NOT NULL        DEFAULT 0,
        RequiresQualityReview   BIT             NOT NULL        DEFAULT 0,
        CreatedAt               DATETIME2(7)    NOT NULL        DEFAULT GETUTCDATE(),
        UpdatedAt               DATETIME2(7)    NOT NULL        DEFAULT GETUTCDATE(),
        ResolvedAt              DATETIME2(7)    NULL,
        ClosedAt                DATETIME2(7)    NULL,
        SlaBreached             BIT             NOT NULL        DEFAULT 0,
        SlaResponseRemainMin    INT             NOT NULL        DEFAULT 0,
        SlaCompletionRemainMin  INT             NOT NULL        DEFAULT 0,
        Location                NVARCHAR(300)   NOT NULL,

        CONSTRAINT PK_Tickets PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT UQ_Tickets_TicketNo UNIQUE (TicketNo),
        CONSTRAINT FK_Tickets_ServiceId FOREIGN KEY (ServiceId) REFERENCES dbo.Services(Id),
        CONSTRAINT FK_Tickets_ParentTicketId FOREIGN KEY (ParentTicketId) REFERENCES dbo.Tickets(Id),
        CONSTRAINT CK_Tickets_Status CHECK (Status IN ('Open', 'Assigned', 'InProgress', 'Paused', 'Resolved', 'Closed', 'PendingArbitration', 'PendingClarification')),
        CONSTRAINT CK_Tickets_Priority CHECK (Priority IN ('Critical', 'High', 'Medium', 'Low')),
        CONSTRAINT CK_Tickets_RequesterType CHECK (RequesterType IN ('Resident', 'Internal'))
    );
END;
GO

CREATE NONCLUSTERED INDEX IX_Tickets_TicketNo ON dbo.Tickets (TicketNo);
GO
CREATE NONCLUSTERED INDEX IX_Tickets_Status ON dbo.Tickets (Status);
GO
CREATE NONCLUSTERED INDEX IX_Tickets_Priority ON dbo.Tickets (Priority);
GO
CREATE NONCLUSTERED INDEX IX_Tickets_Department ON dbo.Tickets (Department);
GO
CREATE NONCLUSTERED INDEX IX_Tickets_ServiceId ON dbo.Tickets (ServiceId);
GO
CREATE NONCLUSTERED INDEX IX_Tickets_ParentTicketId ON dbo.Tickets (ParentTicketId);
GO
CREATE NONCLUSTERED INDEX IX_Tickets_AssignedUser ON dbo.Tickets (AssignedUser);
GO
CREATE NONCLUSTERED INDEX IX_Tickets_SlaBreached ON dbo.Tickets (SlaBreached);
GO
CREATE NONCLUSTERED INDEX IX_Tickets_CreatedAt ON dbo.Tickets (CreatedAt DESC);
GO
CREATE NONCLUSTERED INDEX IX_Tickets_Status_SlaRemain ON dbo.Tickets (Status, SlaCompletionRemainMin)
    WHERE Status NOT IN ('Resolved', 'Closed');
GO

-- ============================================================================
-- 3. TicketHistories (Audit Trail)
-- ============================================================================
IF OBJECT_ID('dbo.TicketHistories', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.TicketHistories (
        Id          INT             IDENTITY(1,1)   NOT NULL,
        TicketId    INT             NOT NULL,
        Action      NVARCHAR(200)   NOT NULL,
        OldStatus   NVARCHAR(30)    NULL,
        NewStatus   NVARCHAR(30)    NULL,
        Performer   NVARCHAR(200)   NOT NULL,
        Notes       NVARCHAR(MAX)   NOT NULL,
        Date        DATETIME2(7)    NOT NULL        DEFAULT GETUTCDATE(),

        CONSTRAINT PK_TicketHistories PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_TicketHistories_TicketId FOREIGN KEY (TicketId) REFERENCES dbo.Tickets(Id)
    );
END;
GO

CREATE NONCLUSTERED INDEX IX_TicketHistories_TicketId ON dbo.TicketHistories (TicketId);
GO
CREATE NONCLUSTERED INDEX IX_TicketHistories_Date ON dbo.TicketHistories (Date DESC);
GO
CREATE NONCLUSTERED INDEX IX_TicketHistories_TicketId_Date ON dbo.TicketHistories (TicketId, Date DESC);
GO

-- ============================================================================
-- 4. ArbitrationCases
-- ============================================================================
IF OBJECT_ID('dbo.ArbitrationCases', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ArbitrationCases (
        Id              INT             IDENTITY(1,1)   NOT NULL,
        TicketId        INT             NOT NULL,
        RaisedBy        NVARCHAR(200)   NOT NULL,
        FromDSD         NVARCHAR(200)   NOT NULL,       -- originating dept/section/division
        Reason          NVARCHAR(MAX)   NOT NULL,
        Status          NVARCHAR(30)    NOT NULL,       -- Open | Redirected | Overruled | Cancelled
        Arbitrator      NVARCHAR(200)   NOT NULL,
        Decision        NVARCHAR(200)   NULL,
        DecisionTarget  NVARCHAR(200)   NULL,
        CreatedAt       DATETIME2(7)    NOT NULL        DEFAULT GETUTCDATE(),
        ResolvedAt      DATETIME2(7)    NULL,

        CONSTRAINT PK_ArbitrationCases PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_ArbitrationCases_TicketId FOREIGN KEY (TicketId) REFERENCES dbo.Tickets(Id),
        CONSTRAINT CK_ArbitrationCases_Status CHECK (Status IN ('Open', 'Redirected', 'Overruled', 'Cancelled'))
    );
END;
GO

CREATE NONCLUSTERED INDEX IX_ArbitrationCases_TicketId ON dbo.ArbitrationCases (TicketId);
GO
CREATE NONCLUSTERED INDEX IX_ArbitrationCases_Status ON dbo.ArbitrationCases (Status);
GO

-- ============================================================================
-- 5. ClarificationRequests
-- ============================================================================
IF OBJECT_ID('dbo.ClarificationRequests', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ClarificationRequests (
        Id              INT             IDENTITY(1,1)   NOT NULL,
        TicketId        INT             NOT NULL,
        RequestedBy     NVARCHAR(200)   NOT NULL,
        TargetUser      NVARCHAR(200)   NOT NULL,
        Reason          NVARCHAR(200)   NOT NULL,
        Status          NVARCHAR(30)    NOT NULL,       -- Open | Responded | Closed
        RequestNotes    NVARCHAR(MAX)   NOT NULL,
        ResponseNotes   NVARCHAR(MAX)   NULL,
        CreatedAt       DATETIME2(7)    NOT NULL        DEFAULT GETUTCDATE(),
        RespondedAt     DATETIME2(7)    NULL,

        CONSTRAINT PK_ClarificationRequests PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_ClarificationRequests_TicketId FOREIGN KEY (TicketId) REFERENCES dbo.Tickets(Id),
        CONSTRAINT CK_ClarificationRequests_Status CHECK (Status IN ('Open', 'Responded', 'Closed'))
    );
END;
GO

CREATE NONCLUSTERED INDEX IX_ClarificationRequests_TicketId ON dbo.ClarificationRequests (TicketId);
GO
CREATE NONCLUSTERED INDEX IX_ClarificationRequests_Status ON dbo.ClarificationRequests (Status);
GO

-- ============================================================================
-- 6. QualityReviews
-- ============================================================================
IF OBJECT_ID('dbo.QualityReviews', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.QualityReviews (
        Id          INT             IDENTITY(1,1)   NOT NULL,
        TicketId    INT             NOT NULL,
        Reviewer    NVARCHAR(200)   NOT NULL,
        Result      NVARCHAR(30)    NULL,               -- Approved | ReturnedForCorrection | Rejected | NULL = Pending
        Notes       NVARCHAR(MAX)   NOT NULL,
        CreatedAt   DATETIME2(7)    NOT NULL            DEFAULT GETUTCDATE(),
        ReviewedAt  DATETIME2(7)    NULL,

        CONSTRAINT PK_QualityReviews PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_QualityReviews_TicketId FOREIGN KEY (TicketId) REFERENCES dbo.Tickets(Id),
        CONSTRAINT CK_QualityReviews_Result CHECK (Result IS NULL OR Result IN ('Approved', 'ReturnedForCorrection', 'Rejected'))
    );
END;
GO

CREATE NONCLUSTERED INDEX IX_QualityReviews_TicketId ON dbo.QualityReviews (TicketId);
GO
CREATE NONCLUSTERED INDEX IX_QualityReviews_Result ON dbo.QualityReviews (Result);
GO

-- ============================================================================
-- 7. PauseSessions
-- ============================================================================
IF OBJECT_ID('dbo.PauseSessions', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PauseSessions (
        Id                      INT             IDENTITY(1,1)   NOT NULL,
        TicketId                INT             NOT NULL,
        Reason                  NVARCHAR(50)    NOT NULL,       -- ChildDependency | Arbitration | Clarification | WarehouseDelay | ApprovalDelay | ExternalDependency
        RelatedChildTicketId    INT             NULL,
        RelatedArbitrationId    INT             NULL,
        RelatedClarificationId  INT             NULL,
        StartedAt               DATETIME2(7)    NOT NULL        DEFAULT GETUTCDATE(),
        EndedAt                 DATETIME2(7)    NULL,
        Notes                   NVARCHAR(MAX)   NOT NULL,

        CONSTRAINT PK_PauseSessions PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_PauseSessions_TicketId FOREIGN KEY (TicketId) REFERENCES dbo.Tickets(Id),
        CONSTRAINT FK_PauseSessions_RelatedChildTicketId FOREIGN KEY (RelatedChildTicketId) REFERENCES dbo.Tickets(Id),
        CONSTRAINT FK_PauseSessions_RelatedArbitrationId FOREIGN KEY (RelatedArbitrationId) REFERENCES dbo.ArbitrationCases(Id),
        CONSTRAINT FK_PauseSessions_RelatedClarificationId FOREIGN KEY (RelatedClarificationId) REFERENCES dbo.ClarificationRequests(Id),
        CONSTRAINT CK_PauseSessions_Reason CHECK (Reason IN ('ChildDependency', 'Arbitration', 'Clarification', 'WarehouseDelay', 'ApprovalDelay', 'ExternalDependency'))
    );
END;
GO

CREATE NONCLUSTERED INDEX IX_PauseSessions_TicketId ON dbo.PauseSessions (TicketId);
GO
CREATE NONCLUSTERED INDEX IX_PauseSessions_EndedAt ON dbo.PauseSessions (EndedAt)
    WHERE EndedAt IS NULL;
GO

-- ============================================================================
-- End of Table Creation Script
-- ============================================================================
PRINT 'All 7 tables created successfully.';
GO