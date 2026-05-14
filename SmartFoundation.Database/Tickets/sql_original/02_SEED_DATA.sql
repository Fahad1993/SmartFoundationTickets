-- ============================================================================
-- Multi-Department Ticketing System — MSSQL Seed Data Script
-- ============================================================================
-- Description: Inserts all mock/seed data into the 7 tables.
--              Uses SET IDENTITY_INSERT to preserve original IDs.
-- Target:      Microsoft SQL Server 2019+
-- Date:        April 16, 2026
-- ============================================================================

USE [TicketingSystem];
GO

-- ============================================================================
-- 1. Services (10 records)
-- ============================================================================
SET IDENTITY_INSERT dbo.Services ON;
GO

INSERT INTO dbo.Services (Id, Code, NameEn, Department, Division, Section, DefaultPriority, IsActive, SlaResponseMin, SlaAssignMin, SlaCompletionMin, SlaClosureMin)
VALUES
    (1,  N'SVC-001', N'Water Faucet Repair',           N'Maintenance',     N'Plumbing',        N'Residential',  N'Medium',   1, 60,  120, 1440,  2880),
    (2,  N'SVC-002', N'Electrical Wiring Inspection',   N'Maintenance',     N'Electrical',      N'Safety',       N'High',     1, 30,  60,  720,   1440),
    (3,  N'SVC-003', N'AC Unit Maintenance',            N'Maintenance',     N'HVAC',            N'Cooling',      N'Medium',   1, 60,  180, 2880,  4320),
    (4,  N'SVC-004', N'Office Furniture Request',       N'Admin Services',  N'Procurement',     N'Furniture',    N'Low',      1, 120, 480, 10080, 14400),
    (5,  N'SVC-005', N'Network Access Setup',           N'IT',              N'Infrastructure',  N'Network',      N'High',     1, 15,  30,  480,   720),
    (6,  N'SVC-006', N'Parking Permit Issuance',        N'Admin Services',  N'Facilities',      N'Parking',      N'Low',      1, 240, 480, 4320,  5760),
    (7,  N'SVC-007', N'Fire Alarm System Check',        N'Safety',          N'Fire Safety',     N'Inspection',   N'Critical', 1, 15,  30,  240,   480),
    (8,  N'SVC-008', N'Elevator Maintenance',           N'Maintenance',     N'Mechanical',      N'Elevators',    N'High',     1, 30,  60,  1440,  2880),
    (9,  N'SVC-009', N'Landscaping Request',            N'Facilities',      N'Grounds',         N'Landscaping',  N'Low',      0, 480, 960, 20160, 28800),
    (10, N'SVC-010', N'Security Badge Replacement',     N'Security',        N'Access Control',  N'Badges',       N'Medium',   1, 60,  120, 1440,  2160);
GO

SET IDENTITY_INSERT dbo.Services OFF;
GO

-- ============================================================================
-- 2. Tickets (10 records)
-- ============================================================================
SET IDENTITY_INSERT dbo.Tickets ON;
GO

INSERT INTO dbo.Tickets (Id, TicketNo, Title, Description, Status, Priority, RequesterType, RequesterName, ServiceId, ServiceName, IsOtherService, Department, Division, Section, CurrentQueue, AssignedUser, ParentTicketId, IsParentBlocked, RequiresQualityReview, CreatedAt, UpdatedAt, ResolvedAt, ClosedAt, SlaBreached, SlaResponseRemainMin, SlaCompletionRemainMin, Location)
VALUES
    -- Ticket 1: InProgress, parent of Ticket 5, blocked
    (1, N'TKT-2026-0001', N'Leaking faucet in Building A, Floor 3',
     N'Water is leaking from the kitchen faucet in room 305. The leak has been ongoing for 2 days and is getting worse.',
     N'InProgress', N'Medium', N'Resident', N'Ahmed Al-Rashid',
     1, N'Water Faucet Repair', 0,
     N'Maintenance', N'Plumbing', N'Residential', N'Plumbing - Residential',
     N'Omar Hassan', NULL, 1, 1,
     '2026-04-10T08:30:00Z', '2026-04-12T14:00:00Z', NULL, NULL,
     0, 0, 720, N'Building A, Floor 3, Room 305'),

    -- Ticket 2: Assigned, Critical
    (2, N'TKT-2026-0002', N'Electrical sparks in server room',
     N'Sparks observed near the main electrical panel in the server room. Immediate inspection required.',
     N'Assigned', N'Critical', N'Internal', N'Fatima Al-Sayed',
     2, N'Electrical Wiring Inspection', 0,
     N'Maintenance', N'Electrical', N'Safety', N'Electrical - Safety',
     N'Khalid Ibrahim', NULL, 0, 1,
     '2026-04-11T09:15:00Z', '2026-04-11T10:00:00Z', NULL, NULL,
     0, 0, 300, N'Data Center, Room B2'),

    -- Ticket 3: PendingClarification, SLA Breached
    (3, N'TKT-2026-0003', N'AC not cooling in executive office',
     N'The air conditioning unit in the CEO office is blowing warm air. Temperature is uncomfortable.',
     N'PendingClarification', N'High', N'Internal', N'Nora Al-Fahad',
     3, N'AC Unit Maintenance', 0,
     N'Maintenance', N'HVAC', N'Cooling', N'HVAC - Cooling',
     N'Yusuf Malik', NULL, 0, 0,
     '2026-04-09T11:00:00Z', '2026-04-13T09:30:00Z', NULL, NULL,
     1, 0, -120, N'Executive Tower, Floor 12'),

    -- Ticket 4: PendingArbitration, Other service
    (4, N'TKT-2026-0004', N'Unknown issue with building entrance gate',
     N'The main entrance gate is malfunctioning. It opens and closes randomly. Not sure which department handles this.',
     N'PendingArbitration', N'High', N'Resident', N'Layla Mahmoud',
     NULL, N'Other', 1,
     N'Unassigned', N'-', N'-', N'Arbitration Queue',
     NULL, NULL, 0, 0,
     '2026-04-12T07:45:00Z', '2026-04-12T08:00:00Z', NULL, NULL,
     0, 45, 1380, N'Main Entrance Gate, Building C'),

    -- Ticket 5: Open, child of Ticket 1
    (5, N'TKT-2026-0005', N'Order replacement faucet parts from warehouse',
     N'Child ticket: Need replacement faucet cartridge and O-rings for TKT-2026-0001.',
     N'Open', N'Medium', N'Internal', N'Omar Hassan',
     4, N'Office Furniture Request', 0,
     N'Admin Services', N'Procurement', N'Furniture', N'Procurement - Furniture',
     NULL, 1, 0, 0,
     '2026-04-12T14:00:00Z', '2026-04-12T14:00:00Z', NULL, NULL,
     0, 100, 9000, N'Warehouse'),

    -- Ticket 6: Resolved
    (6, N'TKT-2026-0006', N'Setup VPN access for new employee',
     N'New employee in Finance department needs VPN access configured. Start date is April 16.',
     N'Resolved', N'High', N'Internal', N'Sara Al-Dosari',
     5, N'Network Access Setup', 0,
     N'IT', N'Infrastructure', N'Network', N'IT - Network',
     N'Ali Reza', NULL, 0, 1,
     '2026-04-08T13:00:00Z', '2026-04-14T16:00:00Z', '2026-04-14T16:00:00Z', NULL,
     0, 0, 0, N'IT Department'),

    -- Ticket 7: Closed
    (7, N'TKT-2026-0007', N'Fire alarm false trigger in cafeteria',
     N'Fire alarm triggered in the main cafeteria without any visible cause. Needs immediate inspection.',
     N'Closed', N'Critical', N'Internal', N'Mohammed Al-Harbi',
     7, N'Fire Alarm System Check', 0,
     N'Safety', N'Fire Safety', N'Inspection', N'Fire Safety - Inspection',
     N'Hassan Noor', NULL, 0, 1,
     '2026-04-07T06:00:00Z', '2026-04-09T12:00:00Z', '2026-04-08T10:00:00Z', '2026-04-09T12:00:00Z',
     0, 0, 0, N'Main Cafeteria, Ground Floor'),

    -- Ticket 8: InProgress, Critical
    (8, N'TKT-2026-0008', N'Elevator stuck between floors',
     N'Elevator #3 in Tower B is stuck between floors 5 and 6. No passengers inside currently.',
     N'InProgress', N'Critical', N'Resident', N'Reem Al-Qahtani',
     8, N'Elevator Maintenance', 0,
     N'Maintenance', N'Mechanical', N'Elevators', N'Mechanical - Elevators',
     N'Tariq Aziz', NULL, 0, 1,
     '2026-04-14T15:30:00Z', '2026-04-14T16:00:00Z', NULL, NULL,
     0, 0, 1200, N'Tower B, Elevator #3'),

    -- Ticket 9: Open
    (9, N'TKT-2026-0009', N'Request new security badge - lost',
     N'Employee lost their security badge and needs a replacement issued.',
     N'Open', N'Medium', N'Internal', N'Huda Al-Mutairi',
     10, N'Security Badge Replacement', 0,
     N'Security', N'Access Control', N'Badges', N'Access Control - Badges',
     NULL, NULL, 0, 0,
     '2026-04-14T10:00:00Z', '2026-04-14T10:00:00Z', NULL, NULL,
     0, 50, 1380, N'Security Office'),

    -- Ticket 10: Paused
    (10, N'TKT-2026-0010', N'Parking permit for new contractor',
     N'A new contractor starting next week needs a temporary parking permit for 3 months.',
     N'Paused', N'Low', N'Internal', N'Majid Al-Otaibi',
     6, N'Parking Permit Issuance', 0,
     N'Admin Services', N'Facilities', N'Parking', N'Facilities - Parking',
     N'Salma Youssef', NULL, 0, 0,
     '2026-04-13T08:00:00Z', '2026-04-14T09:00:00Z', NULL, NULL,
     0, 0, 3800, N'Parking Lot B');
GO

SET IDENTITY_INSERT dbo.Tickets OFF;
GO

-- ============================================================================
-- 3. TicketHistories (12 records across 3 tickets)
-- ============================================================================
SET IDENTITY_INSERT dbo.TicketHistories ON;
GO

INSERT INTO dbo.TicketHistories (Id, TicketId, Action, OldStatus, NewStatus, Performer, Notes, Date)
VALUES
    -- Ticket 1 history (6 entries)
    (1,  1, N'Ticket Created',       NULL,          N'Open',       N'System',          N'Ticket created by resident Ahmed Al-Rashid',                              '2026-04-10T08:30:00Z'),
    (2,  1, N'Routed to Queue',      N'Open',       N'Open',       N'System',          N'Auto-routed to Plumbing - Residential based on service routing rule',      '2026-04-10T08:30:05Z'),
    (3,  1, N'Assigned',             N'Open',       N'Assigned',   N'Supervisor Ali',  N'Assigned to Omar Hassan',                                                  '2026-04-10T10:00:00Z'),
    (4,  1, N'Work Started',         N'Assigned',   N'InProgress', N'Omar Hassan',     N'Technician on site, inspecting the faucet',                                '2026-04-11T08:00:00Z'),
    (5,  1, N'Child Ticket Created', N'InProgress', N'InProgress', N'Omar Hassan',     N'Created child ticket TKT-2026-0005 for replacement parts',                 '2026-04-12T14:00:00Z'),
    (6,  1, N'Paused',              N'InProgress', N'Paused',     N'System',          N'Paused due to child dependency (TKT-2026-0005)',                            '2026-04-12T14:00:05Z'),

    -- Ticket 2 history (2 entries)
    (7,  2, N'Ticket Created',       NULL,          N'Open',       N'System',          N'Ticket created by internal user Fatima Al-Sayed',                          '2026-04-11T09:15:00Z'),
    (8,  2, N'Assigned',             N'Open',       N'Assigned',   N'Supervisor Nabil', N'Urgent: Assigned to Khalid Ibrahim for immediate inspection',             '2026-04-11T09:30:00Z'),

    -- Ticket 6 history (4 entries)
    (20, 6, N'Ticket Created',       NULL,          N'Open',       N'System',          N'Ticket created by internal user Sara Al-Dosari',                           '2026-04-08T13:00:00Z'),
    (21, 6, N'Assigned',             N'Open',       N'Assigned',   N'IT Manager',      N'Assigned to Ali Reza',                                                     '2026-04-08T14:00:00Z'),
    (22, 6, N'Work Started',         N'Assigned',   N'InProgress', N'Ali Reza',        N'Configuring VPN access',                                                   '2026-04-09T09:00:00Z'),
    (23, 6, N'Resolved',             N'InProgress', N'Resolved',   N'Ali Reza',        N'VPN configured and tested. Credentials sent to employee.',                  '2026-04-14T16:00:00Z');
GO

SET IDENTITY_INSERT dbo.TicketHistories OFF;
GO

-- ============================================================================
-- 4. ArbitrationCases (1 record)
-- ============================================================================
SET IDENTITY_INSERT dbo.ArbitrationCases ON;
GO

INSERT INTO dbo.ArbitrationCases (Id, TicketId, RaisedBy, FromDSD, Reason, Status, Arbitrator, Decision, DecisionTarget, CreatedAt, ResolvedAt)
VALUES
    (1, 4, N'System', N'N/A', N'Unknown service - requires arbitration to determine responsible department', N'Open', N'Central Operations Manager', NULL, NULL, '2026-04-12T08:00:00Z', NULL);
GO

SET IDENTITY_INSERT dbo.ArbitrationCases OFF;
GO

-- ============================================================================
-- 5. ClarificationRequests (1 record)
-- ============================================================================
SET IDENTITY_INSERT dbo.ClarificationRequests ON;
GO

INSERT INTO dbo.ClarificationRequests (Id, TicketId, RequestedBy, TargetUser, Reason, Status, RequestNotes, ResponseNotes, CreatedAt, RespondedAt)
VALUES
    (1, 3, N'Yusuf Malik', N'Nora Al-Fahad', N'Missing technical specifications', N'Open',
     N'Need the AC unit model number and the exact room number. Also, when was the last maintenance performed?',
     NULL, '2026-04-13T09:30:00Z', NULL);
GO

SET IDENTITY_INSERT dbo.ClarificationRequests OFF;
GO

-- ============================================================================
-- 6. QualityReviews (2 records)
-- ============================================================================
SET IDENTITY_INSERT dbo.QualityReviews ON;
GO

INSERT INTO dbo.QualityReviews (Id, TicketId, Reviewer, Result, Notes, CreatedAt, ReviewedAt)
VALUES
    (1, 6, N'Quality Team Lead', NULL,       N'Pending quality review for VPN setup completion',                  '2026-04-14T16:05:00Z', NULL),
    (2, 7, N'Safety Inspector',  N'Approved', N'Fire alarm system inspected and recalibrated. All clear.',        '2026-04-08T10:05:00Z', '2026-04-09T12:00:00Z');
GO

SET IDENTITY_INSERT dbo.QualityReviews OFF;
GO

-- ============================================================================
-- 7. PauseSessions (2 records)
-- ============================================================================
SET IDENTITY_INSERT dbo.PauseSessions ON;
GO

INSERT INTO dbo.PauseSessions (Id, TicketId, Reason, RelatedChildTicketId, RelatedArbitrationId, RelatedClarificationId, StartedAt, EndedAt, Notes)
VALUES
    (1, 1,  N'ChildDependency', 5,    NULL, NULL, '2026-04-12T14:00:05Z', NULL, N'Waiting for replacement parts from warehouse'),
    (2, 10, N'ApprovalDelay',   NULL, NULL, NULL, '2026-04-14T09:00:00Z', NULL, N'Waiting for contractor agreement approval from HR');
GO

SET IDENTITY_INSERT dbo.PauseSessions OFF;
GO

-- ============================================================================
-- End of Seed Data Script
-- ============================================================================
PRINT 'All seed data inserted successfully.';
GO