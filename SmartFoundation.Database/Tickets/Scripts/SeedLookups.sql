-- ============================================================================
-- Tickets Schema — Comprehensive Seed Script
-- 5 rows of realistic mock data per table
-- All FK relationships maintained across tables
--
-- Assumes existing enterprise tables:
--   dbo.Idara (idaraID), dbo.DeptSecDiv (DSDID), dbo.Distributor (distributorID),
--   dbo.Users (usersId), dbo.UserDistributor
-- ============================================================================

SET NOCOUNT ON;

-- ============================================================================
-- SECTION 1: LOOKUP TABLES
-- ============================================================================

PRINT N'--- Seeding [Tickets].[TicketStatus] ---';
INSERT INTO [Tickets].[TicketStatus] ([ticketStatusCode], [ticketStatusName_A], [ticketStatusName_E], [ticketStatusDesc], [ticketStatusActive], [entryData], [hostName])
VALUES
    (N'NEW',              N'جديد',                        N'New',                         N'Ticket just created, not yet routed',                       1, N'SEED', N'SEED-HOST'),
    (N'ROUTED',           N'موجّه',                       N'Routed',                      N'Ticket routed to an organizational queue',                  1, N'SEED', N'SEED-HOST'),
    (N'ASSIGNED',         N'مُسنَد',                       N'Assigned',                    N'Ticket assigned to an execution user',                      1, N'SEED', N'SEED-HOST'),
    (N'IN_PROGRESS',      N'قيد التنفيذ',                  N'In Progress',                 N'Work has started on the ticket',                            1, N'SEED', N'SEED-HOST'),
    (N'CLARIFICATION',    N'طلب توضيح',                    N'Clarification',               N'Ticket is waiting for clarification from another party',    1, N'SEED', N'SEED-HOST'),
    (N'ARBITRATION',      N'تحكيم',                        N'Arbitration',                 N'Ticket is under arbitration for scope dispute',             1, N'SEED', N'SEED-HOST'),
    (N'PAUSED',           N'متوقف',                        N'Paused',                      N'Ticket is paused due to blocking dependency',               1, N'SEED', N'SEED-HOST'),
    (N'RESOLVED',         N'تم التنفيذ',                    N'Operationally Resolved',      N'Work completed, awaiting quality review',                   1, N'SEED', N'SEED-HOST'),
    (N'CLOSED',           N'مغلق نهائي',                    N'Closed',                      N'Ticket passed quality review and is finally closed',        1, N'SEED', N'SEED-HOST'),
    (N'REJECTED',         N'مرفوض',                        N'Rejected',                    N'Ticket rejected back to supervisor',                        1, N'SEED', N'SEED-HOST'),
    (N'REOPENED',         N'إعادة فتح',                     N'Reopened',                    N'Closed ticket reopened for additional work',                1, N'SEED', N'SEED-HOST');

PRINT N'--- Seeding [Tickets].[TicketClass] ---';
INSERT INTO [Tickets].[TicketClass] ([ticketClassCode], [ticketClassName_A], [ticketClassName_E], [ticketClassDesc], [ticketClassActive], [entryData], [hostName])
VALUES
    (N'MAINTENANCE',  N'صيانة',            N'Maintenance',      N'Repair or maintenance request',       1, N'SEED', N'SEED-HOST'),
    (N'REQUEST',      N'طلب خدمة',          N'Service Request',  N'General service request',             1, N'SEED', N'SEED-HOST'),
    (N'COMPLAINT',    N'شكوى',              N'Complaint',        N'Resident or user complaint',          1, N'SEED', N'SEED-HOST'),
    (N'INQUIRY',      N'استفسار',            N'Inquiry',          N'General inquiry or information',      1, N'SEED', N'SEED-HOST'),
    (N'OTHER',        N'أخرى',              N'Other',            N'Miscellaneous or uncategorized',      1, N'SEED', N'SEED-HOST');

PRINT N'--- Seeding [Tickets].[Priority] ---';
INSERT INTO [Tickets].[Priority] ([priorityCode], [priorityName_A], [priorityName_E], [priorityDesc], [priorityLevel], [priorityActive], [entryData], [hostName])
VALUES
    (N'CRITICAL', N'حرج',       N'Critical', N'Immediate attention required — safety or security',   1, 1, N'SEED', N'SEED-HOST'),
    (N'HIGH',     N'مرتفع',     N'High',     N'Urgent — significant impact on operations',           2, 1, N'SEED', N'SEED-HOST'),
    (N'MEDIUM',   N'متوسط',     N'Medium',   N'Standard priority — normal operational timeline',     3, 1, N'SEED', N'SEED-HOST'),
    (N'LOW',      N'منخفض',     N'Low',      N'Minor impact — can be scheduled flexibly',            4, 1, N'SEED', N'SEED-HOST'),
    (N'PLANNED',  N'مخطط',      N'Planned',  N'Scheduled future work — not time-critical',           5, 1, N'SEED', N'SEED-HOST');

PRINT N'--- Seeding [Tickets].[RequesterType] ---';
INSERT INTO [Tickets].[RequesterType] ([requesterTypeCode], [requesterTypeName_A], [requesterTypeName_E], [requesterTypeDesc], [requesterTypeActive], [entryData], [hostName])
VALUES
    (N'RESIDENT',     N'مقيم / مستفيد',   N'Resident / Beneficiary', N'External beneficiary or resident of housing',   1, N'SEED', N'SEED-HOST'),
    (N'INTERNAL',     N'موظف داخلي',       N'Internal User',          N'Internal staff member from any department',     1, N'SEED', N'SEED-HOST'),
    (N'SUPERVISOR',   N'مشرف',             N'Supervisor',             N'Supervisor requesting on behalf of a section',  1, N'SEED', N'SEED-HOST'),
    (N'MANAGER',      N'مدير',             N'Manager',                N'Department or division manager',                1, N'SEED', N'SEED-HOST'),
    (N'SYSTEM',       N'نظام',             N'System',                 N'Auto-generated by system process',              1, N'SEED', N'SEED-HOST');

PRINT N'--- Seeding [Tickets].[PauseReason] ---';
INSERT INTO [Tickets].[PauseReason] ([pauseReasonCode], [pauseReasonName_A], [pauseReasonName_E], [pauseReasonDesc], [pauseReasonActive], [entryData], [hostName])
VALUES
    (N'CHILD_DEPENDENCY',   N'انتظار تذكرة فرعية',  N'Waiting for Child Ticket',    N'Parent blocked by an open child ticket',              1, N'SEED', N'SEED-HOST'),
    (N'ARBITRATION',        N'تحكيم جارٍ',           N'Arbitration in Progress',     N'Ticket under arbitration review',                     1, N'SEED', N'SEED-HOST'),
    (N'CLARIFICATION',      N'طلب توضيح جارٍ',       N'Clarification Pending',       N'Waiting for missing information',                     1, N'SEED', N'SEED-HOST'),
    (N'WAREHOUSE_DELAY',    N'تأخير مستودع',         N'Warehouse Delay',             N'Waiting for materials or supplies from stores',       1, N'SEED', N'SEED-HOST'),
    (N'APPROVAL_DELAY',     N'انتظار موافقة',        N'Approval Delay',              N'Waiting for managerial or financial approval',        1, N'SEED', N'SEED-HOST');

PRINT N'--- Seeding [Tickets].[ArbitrationReason] ---';
INSERT INTO [Tickets].[ArbitrationReason] ([arbitrationReasonCode], [arbitrationReasonName_A], [arbitrationReasonName_E], [arbitrationReasonDesc], [arbitrationReasonActive], [entryData], [hostName])
VALUES
    (N'WRONG_SECTION',    N'قسم خطأ',               N'Wrong Section',        N'Ticket routed to wrong section within the correct department',    1, N'SEED', N'SEED-HOST'),
    (N'WRONG_DEPARTMENT', N'إدارة خطأ',              N'Wrong Department',     N'Ticket does not belong to this department at all',                1, N'SEED', N'SEED-HOST'),
    (N'OVERLAP',          N'تداخل اختصاصات',         N'Overlapping Scope',    N'More than one unit claims or denies responsibility',              1, N'SEED', N'SEED-HOST'),
    (N'UNCLEAR_SERVICE',  N'خدمة غير محددة',         N'Unclear Service',      N'The Other service cannot be easily classified',                   1, N'SEED', N'SEED-HOST'),
    (N'REASSIGN_REQUEST', N'طلب إعادة تعيين',        N'Reassignment Request', N'Receiving unit requests formal reassignment to another unit',     1, N'SEED', N'SEED-HOST');

PRINT N'--- Seeding [Tickets].[ClarificationReason] ---';
INSERT INTO [Tickets].[ClarificationReason] ([clarificationReasonCode], [clarificationReasonName_A], [clarificationReasonName_E], [clarificationReasonDesc], [clarificationReasonActive], [entryData], [hostName])
VALUES
    (N'MISSING_LOCATION',   N'موقع ناقص',           N'Missing Location Details',  N'Building, unit, or area information is missing',         1, N'SEED', N'SEED-HOST'),
    (N'MISSING_TECHNICAL',  N'مواصفات تقنية ناقصة',  N'Missing Technical Specs',   N'Technical details or specifications needed for work',    1, N'SEED', N'SEED-HOST'),
    (N'MISSING_APPROVAL',   N'موافقة ناقصة',         N'Missing Approval',          N'Required approval document or sign-off not provided',    1, N'SEED', N'SEED-HOST'),
    (N'UNCLEAR_DESCRIPTION', N'وصف غير واضح',         N'Unclear Description',       N'Ticket description is vague or ambiguous',               1, N'SEED', N'SEED-HOST'),
    (N'MISSING_CONTACT',    N'بيانات تواصل ناقصة',    N'Missing Contact Info',      N'Requester contact information is incomplete',            1, N'SEED', N'SEED-HOST');

PRINT N'--- Seeding [Tickets].[QualityReviewResult] ---';
INSERT INTO [Tickets].[QualityReviewResult] ([qualityReviewResultCode], [qualityReviewResultName_A], [qualityReviewResultName_E], [qualityReviewResultDesc], [qualityReviewResultActive], [entryData], [hostName])
VALUES
    (N'APPROVED',          N'مقبول',                    N'Approved',              N'Work verified — final closure approved',              1, N'SEED', N'SEED-HOST'),
    (N'RETURN_CORRECTION', N'إعادة للتصحيح',             N'Return for Correction', N'Work incomplete or needs correction before closure',  1, N'SEED', N'SEED-HOST'),
    (N'REJECTED',          N'مرفوض',                     N'Rejected',              N'Work does not meet standards — must be redone',       1, N'SEED', N'SEED-HOST'),
    (N'ESCALATED',         N'مُصعَّد',                   N'Escalated',             N'Quality issue escalated to higher authority',         1, N'SEED', N'SEED-HOST'),
    (N'PARTIAL',           N'قبول جزئي',                 N'Partial Approval',      N'Some work items approved, others require rework',     1, N'SEED', N'SEED-HOST');

-- ============================================================================
-- SECTION 2: MASTER TABLES (Service Catalogue)
-- Uses idaraID = 1 as a representative Idara
-- ============================================================================

PRINT N'--- Seeding [Tickets].[Service] ---';
INSERT INTO [Tickets].[Service] ([serviceCode], [serviceName_A], [serviceName_E], [serviceDesc], [idaraID_FK], [ticketClassID_FK], [defaultPriorityID_FK], [requiresLocation], [allowsChildTickets], [requiresQualityReview], [serviceActive], [entryData], [hostName])
VALUES
    (N'WATER_FAUCET_REPAIR',  N'إصلاح صنبور مياه',           N'Water Faucet Repair',       N'Repair or replacement of leaking or broken water faucets',                1, 1, 2, 1, 0, 1, 1, N'SEED', N'SEED-HOST'),
    (N'AC_MAINTENANCE',       N'صيانة تكييف',                 N'Air Conditioner Maintenance',N'Routine or corrective maintenance for air conditioning units',           1, 1, 3, 1, 1, 1, 1, N'SEED', N'SEED-HOST'),
    (N'ELECTRICAL_REPAIR',    N'إصلاح كهرباء',                N'Electrical Repair',          N'Electrical wiring, outlet, or switch repair and safety checks',          1, 1, 2, 1, 0, 1, 1, N'SEED', N'SEED-HOST'),
    (N'PAINTING',             N'دهانات',                      N'Painting',                   N'Interior or exterior painting and wall finishing services',               1, 2, 4, 1, 0, 0, 1, N'SEED', N'SEED-HOST'),
    (N'PLUMBING',             N'سباكة',                       N'Plumbing',                   N'General plumbing repairs including pipes, drains, and fixtures',          1, 1, 3, 1, 1, 1, 1, N'SEED', N'SEED-HOST');

-- Capture generated Service IDs
DECLARE @svcID1 BIGINT = SCOPE_IDENTITY() - 4;
DECLARE @svcID2 BIGINT = @svcID1 + 1;
DECLARE @svcID3 BIGINT = @svcID1 + 2;
DECLARE @svcID4 BIGINT = @svcID1 + 3;
DECLARE @svcID5 BIGINT = @svcID1 + 4;

PRINT N'--- Seeding [Tickets].[ServiceRoutingRule] ---';
-- Uses DSDID values 100-104 as representative DeptSecDiv nodes
INSERT INTO [Tickets].[ServiceRoutingRule] ([serviceID_FK], [idaraID_FK], [targetDSDID_FK], [queueDistributorID_FK], [effectiveFrom], [effectiveTo], [changeReason_A], [changeReason_E], [approvedByUserID], [serviceRoutingRuleActive], [entryData], [hostName])
VALUES
    (@svcID1, 1, 100, NULL, N'2026-01-01', NULL, N'قاعدة أولية',              N'Initial routing rule',              1, 1, N'SEED', N'SEED-HOST'),
    (@svcID2, 1, 101, NULL, N'2026-01-01', NULL, N'قاعدة أولية',              N'Initial routing rule',              1, 1, N'SEED', N'SEED-HOST'),
    (@svcID3, 1, 102, NULL, N'2026-01-01', NULL, N'قاعدة أولية',              N'Initial routing rule',              1, 1, N'SEED', N'SEED-HOST'),
    (@svcID4, 1, 103, NULL, N'2026-01-01', NULL, N'قاعدة أولية',              N'Initial routing rule',              1, 1, N'SEED', N'SEED-HOST'),
    (@svcID5, 1, 104, NULL, N'2026-01-01', NULL, N'قاعدة أولية',              N'Initial routing rule',              1, 1, N'SEED', N'SEED-HOST');

DECLARE @ruleID1 BIGINT = SCOPE_IDENTITY() - 4;
DECLARE @ruleID2 BIGINT = @ruleID1 + 1;
DECLARE @ruleID3 BIGINT = @ruleID1 + 2;
DECLARE @ruleID4 BIGINT = @ruleID1 + 3;
DECLARE @ruleID5 BIGINT = @ruleID1 + 4;

PRINT N'--- Seeding [Tickets].[ServiceSLAPolicy] ---';
INSERT INTO [Tickets].[ServiceSLAPolicy] ([idaraID_FK], [serviceID_FK], [priorityID_FK], [firstResponseTargetMinutes], [assignmentTargetMinutes], [operationalCompletionTargetMinutes], [finalClosureTargetMinutes], [effectiveFrom], [effectiveTo], [slaPolicyActive], [entryData], [hostName])
VALUES
    (1, @svcID1, 2,   60,  240,  2880,  4320, N'2026-01-01', NULL, 1, N'SEED', N'SEED-HOST'),
    (1, @svcID2, 3,  120,  480,  5760,  7200, N'2026-01-01', NULL, 1, N'SEED', N'SEED-HOST'),
    (1, @svcID3, 2,   60,  240,  2880,  4320, N'2026-01-01', NULL, 1, N'SEED', N'SEED-HOST'),
    (1, @svcID4, 4,  480,  960, 10080, 14400, N'2026-01-01', NULL, 1, N'SEED', N'SEED-HOST'),
    (1, @svcID5, 3,  120,  480,  5760,  7200, N'2026-01-01', NULL, 1, N'SEED', N'SEED-HOST');

PRINT N'--- Seeding [Tickets].[ServiceCatalogSuggestion] ---';
INSERT INTO [Tickets].[ServiceCatalogSuggestion] ([sourceTicketID_FK], [idaraID_FK], [proposedServiceName_A], [proposedServiceName_E], [proposedServiceDesc], [proposedTargetDSDID_FK], [proposedPriorityID_FK], [approvalStatus], [approvedByUserID], [approvalDate], [approvalNotes], [createdServiceID_FK], [suggestionActive], [entryData], [hostName])
VALUES
    (NULL, 1, N'إصلاح سخان مياه',           N'Water Heater Repair',        N'Recurring Other requests for water heater repairs',   100, 2, N'PENDING',  NULL, NULL,             NULL,                                    NULL, 1, N'SEED', N'SEED-HOST'),
    (NULL, 1, N'تنظيف خزانات',               N'Tank Cleaning',              N'Periodic tank cleaning requests from residents',      101, 4, N'APPROVED', 1,   N'2026-02-15',     N'Sufficient recurring demand',          @svcID1, 1, N'SEED', N'SEED-HOST'),
    (NULL, 1, N'إصلاح باب',                  N'Door Repair',                N'Door and lock repair requests',                       102, 3, N'PENDING',  NULL, NULL,             NULL,                                    NULL, 1, N'SEED', N'SEED-HOST'),
    (NULL, 1, N'صيانة مصعد',                 N'Elevator Maintenance',       N'Elevator breakdown and scheduled maintenance',        103, 1, N'REJECTED', 2,   N'2026-03-01',     N'Duplicate of existing AC_MAINTENANCE', NULL, 0, N'SEED', N'SEED-HOST'),
    (NULL, 1, N'تنسيق حدائق',                N'Landscaping',                N'Garden and outdoor area maintenance',                 104, 4, N'PENDING',  NULL, NULL,             NULL,                                    NULL, 1, N'SEED', N'SEED-HOST');

-- ============================================================================
-- SECTION 3: TRANSACTION TABLES
-- Uses userID values 10-14 as representative internal users
-- ============================================================================

PRINT N'--- Seeding [Tickets].[Ticket] ---';
INSERT INTO [Tickets].[Ticket] ([ticketNo], [idaraID_FK], [parentTicketID_FK], [rootTicketID_FK], [serviceID_FK], [ticketClassID_FK], [requesterTypeID_FK], [requesterUserID_FK], [requesterResidentID_FK], [title], [description_], [suggestedPriorityID_FK], [effectivePriorityID_FK], [ticketStatusID_FK], [currentDSDID_FK], [currentQueueDistributorID_FK], [assignedUserID_FK], [locationBuildingNo], [locationUnitNo], [locationArea], [operationalResolutionDate], [finalClosureDate], [requiresQualityReview], [isOtherService], [isParentBlocked], [ticketActive], [entryData], [hostName])
VALUES
    (N'TKT-2026-00001', 1, NULL, NULL, @svcID1, 1, 1, NULL, 5001, N'صنبور مياه مكسور في المطبخ',       N'Kitchen faucet is leaking badly — water damage risk',        2, 2, 4, 100, NULL, 10, N'B-12',  N'3A', N'حي النزهة',  NULL,            NULL, 1, 0, 0, 1, N'SEED', N'SEED-HOST'),
    (N'TKT-2026-00002', 1, NULL, NULL, @svcID2, 1, 2, 10,   NULL, N'صيانة تكييف غرفة المعيشة',          N'AC unit making noise, needs inspection',                     3, 3, 5, 101, NULL, NULL, N'B-7',   N'1B', N'حي السلام',  NULL,            NULL, 1, 0, 0, 1, N'SEED', N'SEED-HOST'),
    (N'TKT-2026-00003', 1, NULL, NULL, @svcID3, 1, 1, NULL, 5002, N'مشكلة كهرباء - مخرج لا يعمل',        N'Electrical outlet in bedroom not working, possible wiring',   2, 2, 3, 102, NULL, 11, N'B-3',   N'2C', N'حي الأمل',   NULL,            NULL, 1, 0, 0, 1, N'SEED', N'SEED-HOST'),
    (N'TKT-2026-00004', 1, NULL, NULL, @svcID4, 2, 2, 11,   NULL, N'طلب دهان شقة',                      N'Full apartment repainting needed after renovation',           4, 4, 1, 103, NULL, NULL, N'B-20',  N'5A', N'حي الرياض',  NULL,            NULL, 0, 0, 0, 1, N'SEED', N'SEED-HOST'),
    (N'TKT-2026-00005', 1, NULL, NULL, @svcID5, 1, 1, NULL, 5003, N'مشكلة سباكة - انسداد تصريف',         N'Bathroom drain clogged, water backing up',                   3, 3, 2, 104, NULL, NULL, N'B-15',  N'1D', N'حي الورود',  NULL,            NULL, 1, 0, 0, 1, N'SEED', N'SEED-HOST');

-- Capture generated Ticket IDs
DECLARE @tktID1 BIGINT = SCOPE_IDENTITY() - 4;
DECLARE @tktID2 BIGINT = @tktID1 + 1;
DECLARE @tktID3 BIGINT = @tktID1 + 2;
DECLARE @tktID4 BIGINT = @tktID1 + 3;
DECLARE @tktID5 BIGINT = @tktID1 + 4;

PRINT N'--- Seeding [Tickets].[TicketHistory] ---';
INSERT INTO [Tickets].[TicketHistory] ([ticketID_FK], [idaraID_FK], [actionTypeCode], [oldStatusID_FK], [newStatusID_FK], [oldDSDID_FK], [newDSDID_FK], [oldAssignedUserID], [newAssignedUserID], [performerUserID], [notes], [entryData], [hostName])
VALUES
    (@tktID1, 1, N'CREATED',           NULL, 1, NULL, 100, NULL, NULL,  NULL,  N'Ticket created by resident',            N'SEED', N'SEED-HOST'),
    (@tktID1, 1, N'ROUTED',             1,   2, NULL, 100, NULL, NULL,  1,     N'Auto-routed by service catalogue',      N'SEED', N'SEED-HOST'),
    (@tktID1, 1, N'ASSIGNED',           2,   3, 100,  100, NULL, 10,   12,    N'Assigned to technician by supervisor',  N'SEED', N'SEED-HOST'),
    (@tktID1, 1, N'STARTED',            3,   4, 100,  100, 10,   10,   10,    N'Technician started work',               N'SEED', N'SEED-HOST'),
    (@tktID2, 1, N'CREATED',           NULL, 1, NULL, 101, NULL, NULL,  10,    N'Ticket created by internal user',       N'SEED', N'SEED-HOST');

PRINT N'--- Seeding [Tickets].[TicketSLA] ---';
INSERT INTO [Tickets].[TicketSLA] ([ticketID_FK], [idaraID_FK], [slaTypeCode], [targetMinutes], [elapsedMinutes], [remainingMinutes], [isBreached], [slaStartDate], [slaStopDate], [slaCompletionDate], [lastCalculatedDate], [ticketSLAActive], [entryData], [hostName])
VALUES
    (@tktID1, 1, N'FIRST_RESPONSE',              60,   15, 45,  0, N'2026-03-20 08:00', NULL,  NULL,              N'2026-03-20 08:15', 1, N'SEED', N'SEED-HOST'),
    (@tktID1, 1, N'ASSIGNMENT',                 240,  120, 120, 0, N'2026-03-20 09:00', NULL,  NULL,              N'2026-03-20 11:00', 1, N'SEED', N'SEED-HOST'),
    (@tktID1, 1, N'OPERATIONAL_COMPLETION',     2880, 600,2280, 0, N'2026-03-20 10:00', NULL,  NULL,              N'2026-03-20 20:00', 1, N'SEED', N'SEED-HOST'),
    (@tktID2, 1, N'FIRST_RESPONSE',             120,   30, 90,  0, N'2026-03-21 09:00', NULL,  NULL,              N'2026-03-21 09:30', 1, N'SEED', N'SEED-HOST'),
    (@tktID3, 1, N'FIRST_RESPONSE',              60,   60,  0,  1, N'2026-03-22 07:00', NULL,  NULL,              N'2026-03-22 08:00', 1, N'SEED', N'SEED-HOST');

-- Capture generated SLA IDs
DECLARE @slaID1 BIGINT = SCOPE_IDENTITY() - 4;
DECLARE @slaID2 BIGINT = @slaID1 + 1;
DECLARE @slaID3 BIGINT = @slaID1 + 2;
DECLARE @slaID4 BIGINT = @slaID1 + 3;
DECLARE @slaID5 BIGINT = @slaID1 + 4;

PRINT N'--- Seeding [Tickets].[TicketSLAHistory] ---';
INSERT INTO [Tickets].[TicketSLAHistory] ([ticketSLAID_FK], [idaraID_FK], [slaEventType], [eventDate], [notes], [performerUserID], [entryData], [hostName])
VALUES
    (@slaID1, 1, N'SLA_STARTED',  N'2026-03-20 08:00', N'First response SLA clock started on ticket creation',  NULL,  N'SEED', N'SEED-HOST'),
    (@slaID1, 1, N'SLA_TICK',     N'2026-03-20 08:15', N'15 minutes elapsed',                                   NULL,  N'SEED', N'SEED-HOST'),
    (@slaID2, 1, N'SLA_STARTED',  N'2026-03-20 09:00', N'Assignment SLA clock started after routing',            NULL,  N'SEED', N'SEED-HOST'),
    (@slaID3, 1, N'SLA_STARTED',  N'2026-03-20 10:00', N'Operational completion SLA clock started',              NULL,  N'SEED', N'SEED-HOST'),
    (@slaID5, 1, N'SLA_BREACHED', N'2026-03-22 08:00', N'First response SLA breached — target was 60 minutes',  10,   N'SEED', N'SEED-HOST');

PRINT N'--- Seeding [Tickets].[ArbitrationCase] ---';
INSERT INTO [Tickets].[ArbitrationCase] ([ticketID_FK], [idaraID_FK], [raisedByUserID], [raisedFromDSDID_FK], [arbitrationReasonID_FK], [arbitratorDistributorID], [arbitrationStatus], [decisionType], [decisionTargetDSDID_FK], [decisionNotes], [arbitrationCaseActive], [entryData], [hostName])
VALUES
    (@tktID5, 1, 11, 104, 1, 200, N'OPEN',       NULL,  NULL, NULL,                                N'Technician claims ticket belongs to another section',       1, N'SEED', N'SEED-HOST'),
    (@tktID2, 1, 10, 101, 3, 201, N'DECIDED',     N'REDIRECT', 105, N'Redirected to correct maintenance section',  1, N'SEED', N'SEED-HOST'),
    (@tktID4, 1, 12, 103, 2, 200, N'CANCELLED',   NULL,  NULL, N'Requester withdrew the dispute',           1, N'SEED', N'SEED-HOST'),
    (@tktID3, 1, 11, 102, 4, 202, N'OPEN',        NULL,  NULL, NULL,                                N'Service type unclear — needs classification',               1, N'SEED', N'SEED-HOST'),
    (@tktID1, 1, 10, 100, 5, 201, N'DECIDED',     N'OVERRULE', NULL, N'Original routing confirmed as correct', 1, N'SEED', N'SEED-HOST');

PRINT N'--- Seeding [Tickets].[ClarificationRequest] ---';
INSERT INTO [Tickets].[ClarificationRequest] ([ticketID_FK], [idaraID_FK], [requestedByUserID], [requestedFromUserID], [requestedFromDSDID_FK], [clarificationReasonID_FK], [requestNotes], [responseNotes], [clarificationStatus], [entryData], [hostName])
VALUES
    (@tktID1, 1, 10,  NULL, 100, 1, N'Need exact apartment location details',        N'Building B-12, Unit 3A, Al-Nuzha district',          N'CLOSED',   N'SEED', N'SEED-HOST'),
    (@tktID2, 1, 11,  10,   NULL, 2, N'AC model number and installation date needed', NULL,                                                   N'OPEN',     N'SEED', N'SEED-HOST'),
    (@tktID3, 1, 11,  NULL, 102, 4, N'Please describe the exact nature of the issue', N'Multiple outlets not working since yesterday morning', N'RESPONDED',N'SEED', N'SEED-HOST'),
    (@tktID5, 1, 10,  NULL, 104, 3, N'Need plumbing access approval from management',  NULL,                                                  N'OPEN',     N'SEED', N'SEED-HOST'),
    (@tktID4, 1, 12,  11,   NULL, 5, N'Requester phone number missing for scheduling',  N'Phone: 055-123-4567',                                N'CLOSED',   N'SEED', N'SEED-HOST');

-- Capture generated ClarificationRequest IDs
DECLARE @clarID1 BIGINT = SCOPE_IDENTITY() - 4;
DECLARE @clarID2 BIGINT = @clarID1 + 1;
DECLARE @clarID3 BIGINT = @clarID1 + 2;
DECLARE @clarID4 BIGINT = @clarID1 + 3;
DECLARE @clarID5 BIGINT = @clarID1 + 4;

PRINT N'--- Seeding [Tickets].[TicketPauseSession] ---';
INSERT INTO [Tickets].[TicketPauseSession] ([ticketID_FK], [idaraID_FK], [pauseReasonID_FK], [relatedChildTicketID_FK], [relatedArbitrationCaseID_FK], [relatedClarificationRequestID_FK], [pauseStart], [pauseEnd], [slapausesFlag], [pauseNotes], [ticketPauseSessionActive], [entryData], [hostName])
VALUES
    (@tktID1, 1, 3, NULL, NULL,  @clarID1, N'2026-03-20 08:30', N'2026-03-20 09:00', 1, N'Paused for location clarification',            1, N'SEED', N'SEED-HOST'),
    (@tktID5, 1, 2, NULL, 1,     NULL,    N'2026-03-22 10:00', NULL,                1, N'Paused pending arbitration outcome',           1, N'SEED', N'SEED-HOST'),
    (@tktID2, 1, 3, NULL, NULL,  @clarID2, N'2026-03-21 14:00', NULL,               1, N'Paused awaiting AC model details',             1, N'SEED', N'SEED-HOST'),
    (@tktID1, 1, 4, NULL, NULL,  NULL,    N'2026-03-20 11:00', N'2026-03-21 08:00', 1, N'Paused waiting for plumbing parts from store', 1, N'SEED', N'SEED-HOST'),
    (@tktID3, 1, 5, NULL, NULL,  NULL,    N'2026-03-22 09:00', NULL,                1, N'Paused waiting for manager approval',          1, N'SEED', N'SEED-HOST');

PRINT N'--- Seeding [Tickets].[QualityReview] ---';
INSERT INTO [Tickets].[QualityReview] ([ticketID_FK], [idaraID_FK], [reviewerUserID], [reviewScope], [qualityReviewResultID_FK], [reviewNotes], [returnToUserID], [finalized], [qualityReviewActive], [entryData], [hostName])
VALUES
    (@tktID1, 1, 20, N'FULL_INSPECTION',  1, N'Work completed satisfactorily — faucet replaced and tested',   NULL, 1, 1, N'SEED', N'SEED-HOST'),
    (@tktID2, 1, 20, N'DOCUMENT_REVIEW',  2, N'AC repair incomplete — still making noise',                   10,   0, 1, N'SEED', N'SEED-HOST'),
    (@tktID3, 1, 21, N'FULL_INSPECTION',  1, N'Electrical repair verified — all outlets functional',         NULL, 1, 1, N'SEED', N'SEED-HOST'),
    (@tktID4, 1, 21, N'DOCUMENT_REVIEW',  3, N'Painting quality below standard — needs second coat',         11,   0, 1, N'SEED', N'SEED-HOST'),
    (@tktID5, 1, 20, N'FULL_INSPECTION',  5, N'Plumbing work partially done — some drains still slow',       10,   0, 1, N'SEED', N'SEED-HOST');

PRINT N'--- Seeding [Tickets].[CatalogRoutingChangeLog] ---';
INSERT INTO [Tickets].[CatalogRoutingChangeLog] ([serviceID_FK], [idaraID_FK], [oldRoutingRuleID_FK], [newRoutingRuleID_FK], [changeReason], [sourceArbitrationCaseID_FK], [approvedByUserID], [effectiveFrom], [entryData], [hostName])
VALUES
    (@svcID1, 1, NULL,    @ruleID1, N'Initial routing established for Water Faucet Repair',       NULL, 1, N'2026-01-01', N'SEED', N'SEED-HOST'),
    (@svcID2, 1, NULL,    @ruleID2, N'Initial routing established for AC Maintenance',            NULL, 1, N'2026-01-01', N'SEED', N'SEED-HOST'),
    (@svcID3, 1, NULL,    @ruleID3, N'Initial routing established for Electrical Repair',         NULL, 1, N'2026-01-01', N'SEED', N'SEED-HOST'),
    (@svcID5, 1, @ruleID5, @ruleID5+1, N'Rerouted plumbing to specialized section per arbitration', 2, 3, N'2026-02-10', N'SEED', N'SEED-HOST'),
    (@svcID1, 1, @ruleID1, @ruleID1+1, N'Maintenance section restructured — routing updated',    NULL, 1, N'2026-03-15', N'SEED', N'SEED-HOST');

-- ============================================================================
-- SUMMARY
-- ============================================================================
PRINT N'';
PRINT N'========================================';
PRINT N'Tickets Schema Seed Complete';
PRINT N'========================================';
PRINT N'Lookup tables seeded with 5-11 reference rows each';
PRINT N'Master tables: 5 Services, 5 Routing Rules, 5 SLA Policies, 5 Suggestions';
PRINT N'Transaction tables: 5 Tickets, 5 History events, 5 SLA records';
PRINT N'Flow tables: 5 Arbitration Cases, 5 Clarification Requests, 5 Pause Sessions';
PRINT N'Quality: 5 Reviews, 5 Routing Change Log entries';
PRINT N'All FK relationships maintained across tables.';
PRINT N'========================================';
