-- ============================================================================
-- Multi-Department Ticketing System — MSSQL Views
-- ============================================================================
-- Description: Creates all views for dashboard, queue, detail, reports, etc.
-- Target:      Microsoft SQL Server 2019+
-- Date:        April 16, 2026
-- ============================================================================

USE [TicketingSystem];
GO

-- ============================================================================
-- 1. vw_TicketDashboard
--    Aggregated KPIs for the Dashboard page
-- ============================================================================
IF OBJECT_ID('dbo.vw_TicketDashboard', 'V') IS NOT NULL
    DROP VIEW dbo.vw_TicketDashboard;
GO

CREATE VIEW dbo.vw_TicketDashboard
AS
SELECT
    -- Active Tickets (not Resolved or Closed)
    (SELECT COUNT(*) FROM dbo.Tickets WHERE Status NOT IN ('Resolved', 'Closed'))
        AS ActiveTickets,

    -- SLA Breaches
    (SELECT COUNT(*) FROM dbo.Tickets WHERE SlaBreached = 1)
        AS SlaBreaches,

    -- Resolved Today (UTC date)
    (SELECT COUNT(*) FROM dbo.Tickets WHERE ResolvedAt IS NOT NULL AND CAST(ResolvedAt AS DATE) = CAST(GETUTCDATE() AS DATE))
        AS ResolvedToday,

    -- Average Resolution Time in minutes (for resolved/closed tickets that have ResolvedAt)
    (SELECT ISNULL(AVG(DATEDIFF(MINUTE, CreatedAt, ResolvedAt)), 0) FROM dbo.Tickets WHERE ResolvedAt IS NOT NULL)
        AS AvgResolutionMin,

    -- Total Tickets
    (SELECT COUNT(*) FROM dbo.Tickets)
        AS TotalTickets;
GO

-- ============================================================================
-- 2. vw_TicketQueue
--    Full ticket list with computed fields for the Ticket Queue page
-- ============================================================================
IF OBJECT_ID('dbo.vw_TicketQueue', 'V') IS NOT NULL
    DROP VIEW dbo.vw_TicketQueue;
GO

CREATE VIEW dbo.vw_TicketQueue
AS
SELECT
    t.Id,
    t.TicketNo,
    t.Title,
    t.Description,
    t.Status,
    t.Priority,
    t.RequesterType,
    t.RequesterName,
    t.ServiceId,
    t.ServiceName,
    t.IsOtherService,
    t.Department,
    t.Division,
    t.Section,
    t.CurrentQueue,
    t.AssignedUser,
    t.ParentTicketId,
    t.IsParentBlocked,
    t.RequiresQualityReview,
    t.CreatedAt,
    t.UpdatedAt,
    t.ResolvedAt,
    t.ClosedAt,
    t.SlaBreached,
    t.SlaResponseRemainMin,
    t.SlaCompletionRemainMin,
    t.Location,
    -- Computed: is this ticket active?
    CASE WHEN t.Status NOT IN ('Resolved', 'Closed') THEN 1 ELSE 0 END AS IsActive,
    -- Computed: child ticket count
    (SELECT COUNT(*) FROM dbo.Tickets c WHERE c.ParentTicketId = t.Id) AS ChildTicketCount
FROM dbo.Tickets t;
GO

-- ============================================================================
-- 3. vw_TicketDetail
--    Single ticket with all related data counts for the Detail page
-- ============================================================================
IF OBJECT_ID('dbo.vw_TicketDetail', 'V') IS NOT NULL
    DROP VIEW dbo.vw_TicketDetail;
GO

CREATE VIEW dbo.vw_TicketDetail
AS
SELECT
    t.Id,
    t.TicketNo,
    t.Title,
    t.Description,
    t.Status,
    t.Priority,
    t.RequesterType,
    t.RequesterName,
    t.ServiceId,
    t.ServiceName,
    t.IsOtherService,
    t.Department,
    t.Division,
    t.Section,
    t.CurrentQueue,
    t.AssignedUser,
    t.ParentTicketId,
    t.IsParentBlocked,
    t.RequiresQualityReview,
    t.CreatedAt,
    t.UpdatedAt,
    t.ResolvedAt,
    t.ClosedAt,
    t.SlaBreached,
    t.SlaResponseRemainMin,
    t.SlaCompletionRemainMin,
    t.Location,
    -- Parent ticket info
    pt.TicketNo AS ParentTicketNo,
    pt.Title AS ParentTicketTitle,
    pt.Status AS ParentTicketStatus,
    -- Counts
    (SELECT COUNT(*) FROM dbo.Tickets c WHERE c.ParentTicketId = t.Id) AS ChildTicketCount,
    (SELECT COUNT(*) FROM dbo.ArbitrationCases ac WHERE ac.TicketId = t.Id) AS ArbitrationCaseCount,
    (SELECT COUNT(*) FROM dbo.ClarificationRequests cr WHERE cr.TicketId = t.Id) AS ClarificationRequestCount,
    (SELECT COUNT(*) FROM dbo.QualityReviews qr WHERE qr.TicketId = t.Id) AS QualityReviewCount,
    (SELECT COUNT(*) FROM dbo.PauseSessions ps WHERE ps.TicketId = t.Id) AS PauseSessionCount,
    (SELECT COUNT(*) FROM dbo.TicketHistories th WHERE th.TicketId = t.Id) AS HistoryEntryCount
FROM dbo.Tickets t
LEFT JOIN dbo.Tickets pt ON t.ParentTicketId = pt.Id;
GO

-- ============================================================================
-- 4. vw_StatusCounts
--    Count of tickets per status (for Dashboard and Reports)
-- ============================================================================
IF OBJECT_ID('dbo.vw_StatusCounts', 'V') IS NOT NULL
    DROP VIEW dbo.vw_StatusCounts;
GO

CREATE VIEW dbo.vw_StatusCounts
AS
SELECT
    s.StatusName,
    ISNULL(tc.TicketCount, 0) AS TicketCount
FROM (
    VALUES
        (N'Open'),
        (N'Assigned'),
        (N'InProgress'),
        (N'Paused'),
        (N'Resolved'),
        (N'Closed'),
        (N'PendingArbitration'),
        (N'PendingClarification')
) AS s(StatusName)
LEFT JOIN (
    SELECT Status, COUNT(*) AS TicketCount
    FROM dbo.Tickets
    GROUP BY Status
) AS tc ON s.StatusName = tc.Status;
GO

-- ============================================================================
-- 5. vw_DepartmentWorkload
--    Ticket counts per department with active and breached breakdowns
-- ============================================================================
IF OBJECT_ID('dbo.vw_DepartmentWorkload', 'V') IS NOT NULL
    DROP VIEW dbo.vw_DepartmentWorkload;
GO

CREATE VIEW dbo.vw_DepartmentWorkload
AS
SELECT
    t.Department,
    COUNT(*) AS TotalTickets,
    SUM(CASE WHEN t.Status NOT IN ('Resolved', 'Closed') THEN 1 ELSE 0 END) AS ActiveTickets,
    SUM(CASE WHEN t.SlaBreached = 1 THEN 1 ELSE 0 END) AS SlaBreachedTickets,
    -- Health indicator
    CASE
        WHEN SUM(CASE WHEN t.SlaBreached = 1 THEN 1 ELSE 0 END) = 0 THEN N'Healthy'
        WHEN SUM(CASE WHEN t.SlaBreached = 1 THEN 1 ELSE 0 END) <= 1 THEN N'Warning'
        ELSE N'Critical'
    END AS HealthStatus
FROM dbo.Tickets t
GROUP BY t.Department;
GO

-- ============================================================================
-- 6. vw_ServiceFrequency
--    Count of tickets per service, sorted by frequency
-- ============================================================================
IF OBJECT_ID('dbo.vw_ServiceFrequency', 'V') IS NOT NULL
    DROP VIEW dbo.vw_ServiceFrequency;
GO

CREATE VIEW dbo.vw_ServiceFrequency
AS
SELECT
    t.ServiceName,
    COUNT(*) AS TicketCount,
    ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC, t.ServiceName ASC) AS Rank
FROM dbo.Tickets t
GROUP BY t.ServiceName;
GO

-- ============================================================================
-- 7. vw_OverdueTickets
--    Active tickets that are overdue or at risk (SLA remaining < 240 min)
-- ============================================================================
IF OBJECT_ID('dbo.vw_OverdueTickets', 'V') IS NOT NULL
    DROP VIEW dbo.vw_OverdueTickets;
GO

CREATE VIEW dbo.vw_OverdueTickets
AS
SELECT
    t.Id,
    t.TicketNo,
    t.Title,
    t.Status,
    t.Priority,
    t.Department,
    t.SlaBreached,
    t.SlaCompletionRemainMin,
    t.CreatedAt,
    t.AssignedUser,
    t.ServiceName,
    -- Risk level
    CASE
        WHEN t.SlaCompletionRemainMin <= 0 THEN N'Breached'
        WHEN t.SlaCompletionRemainMin < 120 THEN N'Critical'
        ELSE N'AtRisk'
    END AS RiskLevel
FROM dbo.Tickets t
WHERE t.Status NOT IN ('Resolved', 'Closed')
  AND t.SlaCompletionRemainMin < 240;
GO

-- ============================================================================
-- 8. vw_SLABreachedTickets
--    All tickets where SLA has been breached
-- ============================================================================
IF OBJECT_ID('dbo.vw_SLABreachedTickets', 'V') IS NOT NULL
    DROP VIEW dbo.vw_SLABreachedTickets;
GO

CREATE VIEW dbo.vw_SLABreachedTickets
AS
SELECT
    t.Id,
    t.TicketNo,
    t.Title,
    t.Status,
    t.Priority,
    t.Department,
    t.Division,
    t.Section,
    t.ServiceName,
    t.AssignedUser,
    t.SlaCompletionRemainMin,
    t.CreatedAt,
    t.UpdatedAt
FROM dbo.Tickets t
WHERE t.SlaBreached = 1;
GO

-- ============================================================================
-- 9. vw_RecentActivity
--    Last N history entries across all tickets (for Dashboard)
-- ============================================================================
IF OBJECT_ID('dbo.vw_RecentActivity', 'V') IS NOT NULL
    DROP VIEW dbo.vw_RecentActivity;
GO

CREATE VIEW dbo.vw_RecentActivity
AS
SELECT
    th.Id,
    th.TicketId,
    th.Action,
    th.OldStatus,
    th.NewStatus,
    th.Performer,
    th.Notes,
    th.Date,
    t.TicketNo,
    t.Title AS TicketTitle
FROM dbo.TicketHistories th
INNER JOIN dbo.Tickets t ON th.TicketId = t.Id;
GO

-- ============================================================================
-- 10. vw_ActiveTicketsByPriority
--     Count of active tickets grouped by priority
-- ============================================================================
IF OBJECT_ID('dbo.vw_ActiveTicketsByPriority', 'V') IS NOT NULL
    DROP VIEW dbo.vw_ActiveTicketsByPriority;
GO

CREATE VIEW dbo.vw_ActiveTicketsByPriority
AS
SELECT
    p.PriorityName,
    ISNULL(tc.TicketCount, 0) AS TicketCount
FROM (
    VALUES
        (N'Critical'),
        (N'High'),
        (N'Medium'),
        (N'Low')
) AS p(PriorityName)
LEFT JOIN (
    SELECT Priority, COUNT(*) AS TicketCount
    FROM dbo.Tickets
    WHERE Status NOT IN ('Resolved', 'Closed')
    GROUP BY Priority
) AS tc ON p.PriorityName = tc.Priority;
GO

-- ============================================================================
-- 11. vw_ChildTickets
--     Lists all child tickets with parent info
-- ============================================================================
IF OBJECT_ID('dbo.vw_ChildTickets', 'V') IS NOT NULL
    DROP VIEW dbo.vw_ChildTickets;
GO

CREATE VIEW dbo.vw_ChildTickets
AS
SELECT
    c.Id AS ChildTicketId,
    c.TicketNo AS ChildTicketNo,
    c.Title AS ChildTicketTitle,
    c.Status AS ChildTicketStatus,
    c.ParentTicketId,
    p.TicketNo AS ParentTicketNo,
    p.Title AS ParentTicketTitle,
    p.Status AS ParentTicketStatus
FROM dbo.Tickets c
INNER JOIN dbo.Tickets p ON c.ParentTicketId = p.Id;
GO

-- ============================================================================
-- End of Views Script
-- ============================================================================
PRINT 'All views created successfully.';
GO