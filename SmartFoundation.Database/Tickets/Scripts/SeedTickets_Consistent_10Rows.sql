SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRAN;

BEGIN TRY
    -- Cleanup previous SEED10 data (child to parent order)
    DELETE FROM [Tickets].[CatalogRoutingChangeLog] WHERE [entryData] = N'SEED10';
    DELETE FROM [Tickets].[QualityReview] WHERE [entryData] = N'SEED10';
    DELETE FROM [Tickets].[TicketPauseSession] WHERE [entryData] = N'SEED10';
    DELETE FROM [Tickets].[ClarificationRequest] WHERE [entryData] = N'SEED10';
    DELETE FROM [Tickets].[ArbitrationCase] WHERE [entryData] = N'SEED10';
    DELETE FROM [Tickets].[TicketSLAHistory] WHERE [entryData] = N'SEED10';
    DELETE FROM [Tickets].[TicketSLA] WHERE [entryData] = N'SEED10';
    DELETE FROM [Tickets].[TicketHistory] WHERE [entryData] = N'SEED10';
    DELETE FROM [Tickets].[Ticket] WHERE [entryData] = N'SEED10';
    DELETE FROM [Tickets].[ServiceSLAPolicy] WHERE [entryData] = N'SEED10';
    DELETE FROM [Tickets].[ServiceRoutingRule] WHERE [entryData] = N'SEED10';
    DELETE FROM [Tickets].[Service] WHERE [entryData] = N'SEED10';

    DELETE FROM [Tickets].[QualityReviewResult] WHERE [entryData] = N'SEED10';
    DELETE FROM [Tickets].[ClarificationReason] WHERE [entryData] = N'SEED10';
    DELETE FROM [Tickets].[ArbitrationReason] WHERE [entryData] = N'SEED10';
    DELETE FROM [Tickets].[PauseReason] WHERE [entryData] = N'SEED10';
    DELETE FROM [Tickets].[Priority] WHERE [entryData] = N'SEED10';
    DELETE FROM [Tickets].[RequesterType] WHERE [entryData] = N'SEED10';
    DELETE FROM [Tickets].[TicketClass] WHERE [entryData] = N'SEED10';

    -- Ensure standard workflow statuses exist (used by Ticket/TicketHistory seeds)
    IF NOT EXISTS (SELECT 1 FROM [Tickets].[TicketStatus] WHERE [ticketStatusCode] = N'NEW')
        INSERT INTO [Tickets].[TicketStatus] ([ticketStatusCode],[ticketStatusName_A],[ticketStatusName_E],[ticketStatusDesc],[ticketStatusActive],[entryData],[hostName])
        VALUES (N'NEW',N'جديد',N'New',N'Created',1,N'SEED10',N'SEED10-HOST');

    IF NOT EXISTS (SELECT 1 FROM [Tickets].[TicketStatus] WHERE [ticketStatusCode] = N'ROUTED')
        INSERT INTO [Tickets].[TicketStatus] ([ticketStatusCode],[ticketStatusName_A],[ticketStatusName_E],[ticketStatusDesc],[ticketStatusActive],[entryData],[hostName])
        VALUES (N'ROUTED',N'موجّه',N'Routed',N'Routed to queue',1,N'SEED10',N'SEED10-HOST');

    IF NOT EXISTS (SELECT 1 FROM [Tickets].[TicketStatus] WHERE [ticketStatusCode] = N'ASSIGNED')
        INSERT INTO [Tickets].[TicketStatus] ([ticketStatusCode],[ticketStatusName_A],[ticketStatusName_E],[ticketStatusDesc],[ticketStatusActive],[entryData],[hostName])
        VALUES (N'ASSIGNED',N'مسند',N'Assigned',N'Assigned to user',1,N'SEED10',N'SEED10-HOST');

    IF NOT EXISTS (SELECT 1 FROM [Tickets].[TicketStatus] WHERE [ticketStatusCode] = N'IN_PROGRESS')
        INSERT INTO [Tickets].[TicketStatus] ([ticketStatusCode],[ticketStatusName_A],[ticketStatusName_E],[ticketStatusDesc],[ticketStatusActive],[entryData],[hostName])
        VALUES (N'IN_PROGRESS',N'قيد التنفيذ',N'In Progress',N'Work started',1,N'SEED10',N'SEED10-HOST');

    IF NOT EXISTS (SELECT 1 FROM [Tickets].[TicketStatus] WHERE [ticketStatusCode] = N'CLARIFICATION')
        INSERT INTO [Tickets].[TicketStatus] ([ticketStatusCode],[ticketStatusName_A],[ticketStatusName_E],[ticketStatusDesc],[ticketStatusActive],[entryData],[hostName])
        VALUES (N'CLARIFICATION',N'طلب توضيح',N'Clarification',N'Waiting for details',1,N'SEED10',N'SEED10-HOST');

    IF NOT EXISTS (SELECT 1 FROM [Tickets].[TicketStatus] WHERE [ticketStatusCode] = N'ARBITRATION')
        INSERT INTO [Tickets].[TicketStatus] ([ticketStatusCode],[ticketStatusName_A],[ticketStatusName_E],[ticketStatusDesc],[ticketStatusActive],[entryData],[hostName])
        VALUES (N'ARBITRATION',N'تحكيم',N'Arbitration',N'Under arbitration',1,N'SEED10',N'SEED10-HOST');

    IF NOT EXISTS (SELECT 1 FROM [Tickets].[TicketStatus] WHERE [ticketStatusCode] = N'PAUSED')
        INSERT INTO [Tickets].[TicketStatus] ([ticketStatusCode],[ticketStatusName_A],[ticketStatusName_E],[ticketStatusDesc],[ticketStatusActive],[entryData],[hostName])
        VALUES (N'PAUSED',N'متوقف مؤقتاً',N'Paused',N'Paused state',1,N'SEED10',N'SEED10-HOST');

    IF NOT EXISTS (SELECT 1 FROM [Tickets].[TicketStatus] WHERE [ticketStatusCode] = N'RESOLVED')
        INSERT INTO [Tickets].[TicketStatus] ([ticketStatusCode],[ticketStatusName_A],[ticketStatusName_E],[ticketStatusDesc],[ticketStatusActive],[entryData],[hostName])
        VALUES (N'RESOLVED',N'محلول',N'Resolved',N'Operationally resolved',1,N'SEED10',N'SEED10-HOST');

    IF NOT EXISTS (SELECT 1 FROM [Tickets].[TicketStatus] WHERE [ticketStatusCode] = N'CLOSED')
        INSERT INTO [Tickets].[TicketStatus] ([ticketStatusCode],[ticketStatusName_A],[ticketStatusName_E],[ticketStatusDesc],[ticketStatusActive],[entryData],[hostName])
        VALUES (N'CLOSED',N'مغلق',N'Closed',N'Closed ticket',1,N'SEED10',N'SEED10-HOST');

    IF NOT EXISTS (SELECT 1 FROM [Tickets].[TicketStatus] WHERE [ticketStatusCode] = N'REOPENED')
        INSERT INTO [Tickets].[TicketStatus] ([ticketStatusCode],[ticketStatusName_A],[ticketStatusName_E],[ticketStatusDesc],[ticketStatusActive],[entryData],[hostName])
        VALUES (N'REOPENED',N'معاد فتحه',N'Reopened',N'Reopened ticket',1,N'SEED10',N'SEED10-HOST');

    -- 10 rows each for lookup tables used by transactional tables
    ;WITH n AS (
        SELECT 1 AS i UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
        UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    )
    INSERT INTO [Tickets].[TicketClass]
    ([ticketClassCode],[ticketClassName_A],[ticketClassName_E],[ticketClassDesc],[ticketClassActive],[entryData],[hostName])
    SELECT
        CONCAT(N'SEED10_CLASS_', RIGHT(CONCAT(N'00', i), 2)),
        CONCAT(N'فئة ', i),
        CONCAT(N'Seed Class ', i),
        CONCAT(N'SEED10 ticket class ', i),
        1,
        N'SEED10',
        N'SEED10-HOST'
    FROM n;

    ;WITH n AS (
        SELECT 1 AS i UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
        UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    )
    INSERT INTO [Tickets].[RequesterType]
    ([requesterTypeCode],[requesterTypeName_A],[requesterTypeName_E],[requesterTypeDesc],[requesterTypeActive],[entryData],[hostName])
    SELECT
        CONCAT(N'SEED10_REQ_', RIGHT(CONCAT(N'00', i), 2)),
        CONCAT(N'نوع مقدم ', i),
        CONCAT(N'Seed Requester ', i),
        CONCAT(N'SEED10 requester type ', i),
        1,
        N'SEED10',
        N'SEED10-HOST'
    FROM n;

    ;WITH n AS (
        SELECT 1 AS i UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
        UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    )
    INSERT INTO [Tickets].[Priority]
    ([priorityCode],[priorityName_A],[priorityName_E],[priorityDesc],[priorityLevel],[priorityActive],[entryData],[hostName])
    SELECT
        CONCAT(N'SEED10_PRI_', RIGHT(CONCAT(N'00', i), 2)),
        CONCAT(N'أولوية ', i),
        CONCAT(N'Seed Priority ', i),
        CONCAT(N'SEED10 priority ', i),
        i,
        1,
        N'SEED10',
        N'SEED10-HOST'
    FROM n;

    ;WITH n AS (
        SELECT 1 AS i UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
        UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    )
    INSERT INTO [Tickets].[PauseReason]
    ([pauseReasonCode],[pauseReasonName_A],[pauseReasonName_E],[pauseReasonDesc],[pauseReasonActive],[entryData],[hostName])
    SELECT
        CONCAT(N'SEED10_PAUSE_', RIGHT(CONCAT(N'00', i), 2)),
        CONCAT(N'سبب إيقاف ', i),
        CONCAT(N'Seed Pause Reason ', i),
        CONCAT(N'SEED10 pause reason ', i),
        1,
        N'SEED10',
        N'SEED10-HOST'
    FROM n;

    ;WITH n AS (
        SELECT 1 AS i UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
        UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    )
    INSERT INTO [Tickets].[ArbitrationReason]
    ([arbitrationReasonCode],[arbitrationReasonName_A],[arbitrationReasonName_E],[arbitrationReasonDesc],[arbitrationReasonActive],[entryData],[hostName])
    SELECT
        CONCAT(N'SEED10_ARB_', RIGHT(CONCAT(N'00', i), 2)),
        CONCAT(N'سبب تحكيم ', i),
        CONCAT(N'Seed Arbitration Reason ', i),
        CONCAT(N'SEED10 arbitration reason ', i),
        1,
        N'SEED10',
        N'SEED10-HOST'
    FROM n;

    ;WITH n AS (
        SELECT 1 AS i UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
        UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    )
    INSERT INTO [Tickets].[ClarificationReason]
    ([clarificationReasonCode],[clarificationReasonName_A],[clarificationReasonName_E],[clarificationReasonDesc],[clarificationReasonActive],[entryData],[hostName])
    SELECT
        CONCAT(N'SEED10_CLR_', RIGHT(CONCAT(N'00', i), 2)),
        CONCAT(N'سبب توضيح ', i),
        CONCAT(N'Seed Clarification Reason ', i),
        CONCAT(N'SEED10 clarification reason ', i),
        1,
        N'SEED10',
        N'SEED10-HOST'
    FROM n;

    ;WITH n AS (
        SELECT 1 AS i UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
        UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    )
    INSERT INTO [Tickets].[QualityReviewResult]
    ([qualityReviewResultCode],[qualityReviewResultName_A],[qualityReviewResultName_E],[qualityReviewResultDesc],[qualityReviewResultActive],[entryData],[hostName])
    SELECT
        CONCAT(N'SEED10_QR_', RIGHT(CONCAT(N'00', i), 2)),
        CONCAT(N'نتيجة جودة ', i),
        CONCAT(N'Seed QR Result ', i),
        CONCAT(N'SEED10 quality result ', i),
        1,
        N'SEED10',
        N'SEED10-HOST'
    FROM n;

    DECLARE @class TABLE (rn INT PRIMARY KEY, id INT);
    DECLARE @req TABLE (rn INT PRIMARY KEY, id INT);
    DECLARE @pri TABLE (rn INT PRIMARY KEY, id INT);
    DECLARE @pause TABLE (rn INT PRIMARY KEY, id INT);
    DECLARE @arb TABLE (rn INT PRIMARY KEY, id INT);
    DECLARE @clar TABLE (rn INT PRIMARY KEY, id INT);
    DECLARE @qr TABLE (rn INT PRIMARY KEY, id INT);

    INSERT INTO @class (rn, id)
    SELECT ROW_NUMBER() OVER (ORDER BY [ticketClassID]), [ticketClassID]
    FROM [Tickets].[TicketClass]
    WHERE [entryData] = N'SEED10';

    INSERT INTO @req (rn, id)
    SELECT ROW_NUMBER() OVER (ORDER BY [requesterTypeID]), [requesterTypeID]
    FROM [Tickets].[RequesterType]
    WHERE [entryData] = N'SEED10';

    INSERT INTO @pri (rn, id)
    SELECT ROW_NUMBER() OVER (ORDER BY [priorityID]), [priorityID]
    FROM [Tickets].[Priority]
    WHERE [entryData] = N'SEED10';

    INSERT INTO @pause (rn, id)
    SELECT ROW_NUMBER() OVER (ORDER BY [pauseReasonID]), [pauseReasonID]
    FROM [Tickets].[PauseReason]
    WHERE [entryData] = N'SEED10';

    INSERT INTO @arb (rn, id)
    SELECT ROW_NUMBER() OVER (ORDER BY [arbitrationReasonID]), [arbitrationReasonID]
    FROM [Tickets].[ArbitrationReason]
    WHERE [entryData] = N'SEED10';

    INSERT INTO @clar (rn, id)
    SELECT ROW_NUMBER() OVER (ORDER BY [clarificationReasonID]), [clarificationReasonID]
    FROM [Tickets].[ClarificationReason]
    WHERE [entryData] = N'SEED10';

    INSERT INTO @qr (rn, id)
    SELECT ROW_NUMBER() OVER (ORDER BY [qualityReviewResultID]), [qualityReviewResultID]
    FROM [Tickets].[QualityReviewResult]
    WHERE [entryData] = N'SEED10';

    DECLARE @statusNew INT = (SELECT TOP 1 [ticketStatusID] FROM [Tickets].[TicketStatus] WHERE [ticketStatusCode] = N'NEW' ORDER BY [ticketStatusID]);
    DECLARE @statusRouted INT = (SELECT TOP 1 [ticketStatusID] FROM [Tickets].[TicketStatus] WHERE [ticketStatusCode] = N'ROUTED' ORDER BY [ticketStatusID]);
    DECLARE @statusAssigned INT = (SELECT TOP 1 [ticketStatusID] FROM [Tickets].[TicketStatus] WHERE [ticketStatusCode] = N'ASSIGNED' ORDER BY [ticketStatusID]);
    DECLARE @statusProgress INT = (SELECT TOP 1 [ticketStatusID] FROM [Tickets].[TicketStatus] WHERE [ticketStatusCode] = N'IN_PROGRESS' ORDER BY [ticketStatusID]);
    DECLARE @statusClarification INT = (SELECT TOP 1 [ticketStatusID] FROM [Tickets].[TicketStatus] WHERE [ticketStatusCode] = N'CLARIFICATION' ORDER BY [ticketStatusID]);
    DECLARE @statusArbitration INT = (SELECT TOP 1 [ticketStatusID] FROM [Tickets].[TicketStatus] WHERE [ticketStatusCode] = N'ARBITRATION' ORDER BY [ticketStatusID]);
    DECLARE @statusPaused INT = (SELECT TOP 1 [ticketStatusID] FROM [Tickets].[TicketStatus] WHERE [ticketStatusCode] = N'PAUSED' ORDER BY [ticketStatusID]);
    DECLARE @statusResolved INT = (SELECT TOP 1 [ticketStatusID] FROM [Tickets].[TicketStatus] WHERE [ticketStatusCode] = N'RESOLVED' ORDER BY [ticketStatusID]);
    DECLARE @statusClosed INT = (SELECT TOP 1 [ticketStatusID] FROM [Tickets].[TicketStatus] WHERE [ticketStatusCode] = N'CLOSED' ORDER BY [ticketStatusID]);
    DECLARE @statusReopened INT = (SELECT TOP 1 [ticketStatusID] FROM [Tickets].[TicketStatus] WHERE [ticketStatusCode] = N'REOPENED' ORDER BY [ticketStatusID]);

    DECLARE @serviceSeed TABLE
    (
        seq INT PRIMARY KEY,
        serviceID BIGINT,
        classID INT,
        priorityID INT,
        requiresQR BIT,
        allowsChild BIT
    );

    ;WITH n AS (
        SELECT 1 AS i UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
        UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    )
    INSERT INTO [Tickets].[Service]
    ([serviceCode],[serviceName_A],[serviceName_E],[serviceDesc],[idaraID_FK],[ticketClassID_FK],[defaultPriorityID_FK],[requiresLocation],[allowsChildTickets],[requiresQualityReview],[serviceActive],[entryData],[hostName])
    SELECT
        CONCAT(N'SEED10_SVC_', RIGHT(CONCAT(N'00', n.i), 2)),
        CONCAT(N'خدمة مترابطة ', n.i),
        CONCAT(N'Related Service ', n.i),
        CONCAT(N'SEED10 related service ', n.i),
        1,
        c.id,
        p.id,
        1,
        CASE WHEN n.i IN (1,4,7,10) THEN 1 ELSE 0 END,
        CASE WHEN n.i % 2 = 0 THEN 1 ELSE 0 END,
        1,
        N'SEED10',
        N'SEED10-HOST'
    FROM n
    INNER JOIN @class c ON c.rn = n.i
    INNER JOIN @pri p ON p.rn = n.i;

    INSERT INTO @serviceSeed (seq, serviceID, classID, priorityID, requiresQR, allowsChild)
    SELECT
        CONVERT(INT, RIGHT(s.[serviceCode], 2)) AS seq,
        s.[serviceID],
        s.[ticketClassID_FK],
        s.[defaultPriorityID_FK],
        s.[requiresQualityReview],
        s.[allowsChildTickets]
    FROM [Tickets].[Service] s
    WHERE s.[entryData] = N'SEED10'
      AND s.[serviceCode] LIKE N'SEED10_SVC_%';

    DECLARE @routingSeed TABLE
    (
        seq INT PRIMARY KEY,
        ruleID BIGINT,
        serviceID BIGINT
    );

    INSERT INTO [Tickets].[ServiceRoutingRule]
    ([serviceID_FK],[idaraID_FK],[targetDSDID_FK],[queueDistributorID_FK],[effectiveFrom],[effectiveTo],[approvedByUserID],[changeReason],[serviceRoutingRuleActive],[entryData],[hostName])
    SELECT
        s.serviceID,
        1,
        100 + s.seq,
        NULL,
        DATEADD(DAY, -30 + s.seq, GETDATE()),
        NULL,
        1000 + s.seq,
        CONCAT(N'قاعدة توجيه مترابطة للخدمة ', s.seq),
        1,
        N'SEED10',
        N'SEED10-HOST'
    FROM @serviceSeed s;

    INSERT INTO @routingSeed (seq, ruleID, serviceID)
    SELECT
        s.seq,
        r.[serviceRoutingRuleID],
        r.[serviceID_FK]
    FROM [Tickets].[ServiceRoutingRule] r
    INNER JOIN @serviceSeed s ON s.serviceID = r.[serviceID_FK]
    WHERE r.[entryData] = N'SEED10';

    INSERT INTO [Tickets].[ServiceSLAPolicy]
    ([idaraID_FK],[serviceID_FK],[priorityID_FK],[firstResponseTargetMinutes],[assignmentTargetMinutes],[operationalCompletionTargetMinutes],[finalClosureTargetMinutes],[effectiveFrom],[effectiveTo],[slaPolicyActive],[entryData],[hostName])
    SELECT
        1,
        s.serviceID,
        s.priorityID,
        15 + (s.seq * 5),
        30 + (s.seq * 10),
        240 + (s.seq * 60),
        360 + (s.seq * 90),
        DATEADD(DAY, -30 + s.seq, GETDATE()),
        NULL,
        1,
        N'SEED10',
        N'SEED10-HOST'
    FROM @serviceSeed s;

    DECLARE @ticketSeed TABLE
    (
        seq INT PRIMARY KEY,
        ticketID BIGINT,
        serviceID BIGINT,
        statusID INT,
        assignedUserID INT
    );

    INSERT INTO [Tickets].[Ticket]
    ([ticketNo],[idaraID_FK],[parentTicketID_FK],[rootTicketID_FK],[serviceID_FK],[ticketClassID_FK],[requesterTypeID_FK],[requesterUserID_FK],[requesterResidentID_FK],[title_A],[title],[description_A],[description_],[suggestedPriorityID_FK],[effectivePriorityID_FK],[ticketStatusID_FK],[currentDSDID_FK],[currentQueueDistributorID_FK],[assignedUserID_FK],[locationBuildingNo],[locationUnitNo],[locationArea_A],[locationArea],[operationalResolutionDate],[finalClosureDate],[requiresQualityReview],[isOtherService],[isParentBlocked],[ticketActive],[entryData],[hostName])
    SELECT
        CONCAT(N'SEED10-TKT-2026-', RIGHT(CONCAT(N'0000', s.seq), 4)),
        1,
        NULL,
        NULL,
        s.serviceID,
        s.classID,
        r.id,
        CASE WHEN s.seq % 2 = 0 THEN 3000 + s.seq ELSE NULL END,
        CASE WHEN s.seq % 2 = 1 THEN 900000 + s.seq ELSE NULL END,
        CONCAT(N'تذكرة مترابطة ', s.seq),
        CONCAT(N'Related Ticket ', s.seq),
        CONCAT(N'وصف عربي للتذكرة ', s.seq),
        CONCAT(N'Linked ticket description ', s.seq, N' uses service ', s.serviceID),
        s.priorityID,
        s.priorityID,
        CASE s.seq
            WHEN 1 THEN @statusNew
            WHEN 2 THEN @statusRouted
            WHEN 3 THEN @statusAssigned
            WHEN 4 THEN @statusProgress
            WHEN 5 THEN @statusClarification
            WHEN 6 THEN @statusArbitration
            WHEN 7 THEN @statusPaused
            WHEN 8 THEN @statusResolved
            WHEN 9 THEN @statusClosed
            ELSE @statusReopened
        END,
        100 + s.seq,
        NULL,
        CASE WHEN s.seq IN (3,4,8,9,10) THEN 4000 + s.seq ELSE NULL END,
        CONCAT(N'B-', RIGHT(CONCAT(N'00', s.seq), 2)),
        CONCAT(N'U-', RIGHT(CONCAT(N'00', s.seq), 2)),
        CONCAT(N'منطقة ', s.seq),
        CONCAT(N'Area ', s.seq),
        CASE WHEN s.seq IN (8,9) THEN DATEADD(HOUR, -s.seq, GETDATE()) ELSE NULL END,
        CASE WHEN s.seq = 9 THEN DATEADD(HOUR, -1, GETDATE()) ELSE NULL END,
        s.requiresQR,
        0,
        CASE WHEN s.seq = 1 THEN 1 ELSE 0 END,
        1,
        N'SEED10',
        N'SEED10-HOST'
    FROM @serviceSeed s
    INNER JOIN @req r ON r.rn = s.seq;

    INSERT INTO @ticketSeed (seq, ticketID, serviceID, statusID, assignedUserID)
    SELECT
        CONVERT(INT, RIGHT(t.[ticketNo], 4)) AS seq,
        t.[ticketID],
        t.[serviceID_FK],
        t.[ticketStatusID_FK],
        t.[assignedUserID_FK]
    FROM [Tickets].[Ticket] t
    WHERE t.[entryData] = N'SEED10'
      AND t.[ticketNo] LIKE N'SEED10-TKT-2026-%';

    -- Root/parent consistency
    UPDATE t
    SET t.[rootTicketID_FK] = t.[ticketID]
    FROM [Tickets].[Ticket] t
    INNER JOIN @ticketSeed x ON x.ticketID = t.[ticketID];

    DECLARE @parentTicketID BIGINT = (SELECT [ticketID] FROM @ticketSeed WHERE seq = 1);
    DECLARE @childTicketID BIGINT = (SELECT [ticketID] FROM @ticketSeed WHERE seq = 10);

    UPDATE [Tickets].[Ticket]
    SET
        [parentTicketID_FK] = @parentTicketID,
        [rootTicketID_FK] = @parentTicketID,
        [isParentBlocked] = 0
    WHERE [ticketID] = @childTicketID;

    INSERT INTO [Tickets].[TicketHistory]
    ([ticketID_FK],[idaraID_FK],[actionTypeCode],[oldStatusID_FK],[newStatusID_FK],[oldDSDID_FK],[newDSDID_FK],[oldAssignedUserID],[newAssignedUserID],[performerUserID],[notes_A],[notes],[actionDate],[entryData],[hostName])
    SELECT
        t.ticketID,
        1,
        N'CREATED',
        NULL,
        @statusNew,
        NULL,
        100 + t.seq,
        NULL,
        t.assignedUserID,
        COALESCE(t.assignedUserID, 3000 + t.seq),
        CONCAT(N'تم إنشاء التذكرة ', t.seq),
        CONCAT(N'Ticket ', t.seq, N' created'),
        DATEADD(MINUTE, -120 + (t.seq * 4), GETDATE()),
        N'SEED10',
        N'SEED10-HOST'
    FROM @ticketSeed t;

    INSERT INTO [Tickets].[TicketHistory]
    ([ticketID_FK],[idaraID_FK],[actionTypeCode],[oldStatusID_FK],[newStatusID_FK],[oldDSDID_FK],[newDSDID_FK],[oldAssignedUserID],[newAssignedUserID],[performerUserID],[notes_A],[notes],[actionDate],[entryData],[hostName])
    SELECT
        t.ticketID,
        1,
        N'STATUS_CHANGED',
        @statusNew,
        t.statusID,
        100 + t.seq,
        100 + t.seq,
        NULL,
        t.assignedUserID,
        COALESCE(t.assignedUserID, 3000 + t.seq),
        CONCAT(N'تحديث الحالة للتذكرة ', t.seq),
        CONCAT(N'Ticket ', t.seq, N' status updated'),
        DATEADD(MINUTE, -90 + (t.seq * 4), GETDATE()),
        N'SEED10',
        N'SEED10-HOST'
    FROM @ticketSeed t;

    DECLARE @slaSeed TABLE
    (
        seq INT PRIMARY KEY,
        slaID BIGINT,
        ticketID BIGINT
    );

    INSERT INTO [Tickets].[TicketSLA]
    ([ticketID_FK],[idaraID_FK],[slaTypeCode],[targetMinutes],[elapsedMinutes],[remainingMinutes],[isBreached],[slaStartDate],[slaStopDate],[slaCompletionDate],[lastCalculatedDate],[ticketSLAActive],[entryData],[hostName])
    SELECT
        t.ticketID,
        1,
        N'OPERATIONAL_COMPLETION',
        240 + (t.seq * 30),
        60 + (t.seq * 20),
        (240 + (t.seq * 30)) - (60 + (t.seq * 20)),
        CASE WHEN t.seq IN (9,10) THEN 1 ELSE 0 END,
        DATEADD(HOUR, -6, GETDATE()),
        CASE WHEN t.seq IN (8,9,10) THEN DATEADD(HOUR, -1, GETDATE()) ELSE NULL END,
        CASE WHEN t.seq IN (8,9) THEN DATEADD(HOUR, -1, GETDATE()) ELSE NULL END,
        GETDATE(),
        1,
        N'SEED10',
        N'SEED10-HOST'
    FROM @ticketSeed t;

    INSERT INTO @slaSeed (seq, slaID, ticketID)
    SELECT
        t.seq,
        s.[ticketSLAID],
        s.[ticketID_FK]
    FROM [Tickets].[TicketSLA] s
    INNER JOIN @ticketSeed t ON t.ticketID = s.[ticketID_FK]
    WHERE s.[entryData] = N'SEED10';

    INSERT INTO [Tickets].[TicketSLAHistory]
    ([ticketSLAID_FK],[idaraID_FK],[slaEventType],[eventDate],[notes],[performerUserID],[entryData],[hostName])
    SELECT
        s.slaID,
        1,
        CASE WHEN s.seq IN (9,10) THEN N'SLA_BREACHED' ELSE N'SLA_UPDATED' END,
        DATEADD(MINUTE, -(20 - s.seq), GETDATE()),
        CONCAT(N'SEED10 SLA event for ticket seq ', s.seq),
        5000 + s.seq,
        N'SEED10',
        N'SEED10-HOST'
    FROM @slaSeed s;

    DECLARE @arbCaseSeed TABLE
    (
        seq INT PRIMARY KEY,
        caseID BIGINT,
        ticketID BIGINT
    );

    INSERT INTO [Tickets].[ArbitrationCase]
    ([ticketID_FK],[idaraID_FK],[raisedByUserID],[raisedFromDSDID_FK],[arbitrationReasonID_FK],[arbitratorDistributorID],[arbitrationStatus],[decisionType],[decisionTargetDSDID_FK],[decisionNotes],[decisionDate],[arbitrationCaseActive],[entryData],[hostName])
    SELECT
        t.ticketID,
        1,
        6000 + t.seq,
        100 + t.seq,
        a.id,
        7000 + t.seq,
        CASE WHEN t.seq % 2 = 0 THEN N'DECIDED' ELSE N'OPEN' END,
        CASE WHEN t.seq % 2 = 0 THEN N'REDIRECT' ELSE NULL END,
        CASE WHEN t.seq % 2 = 0 THEN 200 + t.seq ELSE NULL END,
        CONCAT(N'SEED10 arbitration case for ticket ', t.seq),
        CASE WHEN t.seq % 2 = 0 THEN DATEADD(HOUR, -2, GETDATE()) ELSE NULL END,
        1,
        N'SEED10',
        N'SEED10-HOST'
    FROM @ticketSeed t
    INNER JOIN @arb a ON a.rn = t.seq;

    INSERT INTO @arbCaseSeed (seq, caseID, ticketID)
    SELECT
        t.seq,
        a.[arbitrationCaseID],
        a.[ticketID_FK]
    FROM [Tickets].[ArbitrationCase] a
    INNER JOIN @ticketSeed t ON t.ticketID = a.[ticketID_FK]
    WHERE a.[entryData] = N'SEED10';

    DECLARE @clarSeed TABLE
    (
        seq INT PRIMARY KEY,
        clarificationID BIGINT,
        ticketID BIGINT
    );

    INSERT INTO [Tickets].[ClarificationRequest]
    ([ticketID_FK],[idaraID_FK],[requestedByUserID],[requestedFromUserID],[requestedFromDSDID_FK],[clarificationReasonID_FK],[requestNotes],[responseNotes],[requestDate],[responseDate],[clarificationStatus],[clarificationActive],[entryData],[hostName])
    SELECT
        t.ticketID,
        1,
        8000 + t.seq,
        8100 + t.seq,
        100 + t.seq,
        c.id,
        CONCAT(N'SEED10 clarification request for ticket ', t.seq),
        CASE WHEN t.seq % 3 = 0 THEN CONCAT(N'SEED10 response for ticket ', t.seq) ELSE NULL END,
        DATEADD(HOUR, -5, GETDATE()),
        CASE WHEN t.seq % 3 = 0 THEN DATEADD(HOUR, -1, GETDATE()) ELSE NULL END,
        CASE WHEN t.seq % 3 = 0 THEN N'CLOSED' WHEN t.seq % 2 = 0 THEN N'RESPONDED' ELSE N'OPEN' END,
        1,
        N'SEED10',
        N'SEED10-HOST'
    FROM @ticketSeed t
    INNER JOIN @clar c ON c.rn = t.seq;

    INSERT INTO @clarSeed (seq, clarificationID, ticketID)
    SELECT
        t.seq,
        c.[clarificationRequestID],
        c.[ticketID_FK]
    FROM [Tickets].[ClarificationRequest] c
    INNER JOIN @ticketSeed t ON t.ticketID = c.[ticketID_FK]
    WHERE c.[entryData] = N'SEED10';

    INSERT INTO [Tickets].[TicketPauseSession]
    ([ticketID_FK],[idaraID_FK],[pauseReasonID_FK],[relatedChildTicketID_FK],[relatedArbitrationCaseID_FK],[relatedClarificationRequestID_FK],[pauseStart],[pauseEnd],[slaPauseFlag],[pauseNotes_A],[pauseNotes],[ticketPauseSessionActive],[entryData],[hostName])
    SELECT
        t.ticketID,
        1,
        p.id,
        CASE WHEN t.seq = 1 THEN @childTicketID ELSE NULL END,
        ac.caseID,
        cr.clarificationID,
        DATEADD(HOUR, -4, GETDATE()),
        CASE WHEN t.seq IN (3,6,9) THEN DATEADD(HOUR, -2, GETDATE()) ELSE NULL END,
        1,
        CONCAT(N'إيقاف مترابط للتذكرة ', t.seq),
        CONCAT(N'SEED10 pause session for ticket ', t.seq),
        1,
        N'SEED10',
        N'SEED10-HOST'
    FROM @ticketSeed t
    INNER JOIN @pause p ON p.rn = t.seq
    LEFT JOIN @arbCaseSeed ac ON ac.seq = t.seq
    LEFT JOIN @clarSeed cr ON cr.seq = t.seq;

    INSERT INTO [Tickets].[QualityReview]
    ([ticketID_FK],[idaraID_FK],[reviewerUserID],[reviewScope],[qualityReviewResultID_FK],[reviewNotes],[reviewDate],[returnToUserID],[finalized],[qualityReviewActive],[entryData],[hostName])
    SELECT
        t.ticketID,
        1,
        9000 + t.seq,
        CONCAT(N'SEED_SCOPE_', RIGHT(CONCAT(N'00', t.seq), 2)),
        q.id,
        CONCAT(N'SEED10 quality review for ticket ', t.seq),
        DATEADD(HOUR, -1, GETDATE()),
        CASE WHEN t.seq % 2 = 0 THEN NULL ELSE 9200 + t.seq END,
        CASE WHEN t.seq IN (8,9,10) THEN 1 ELSE 0 END,
        1,
        N'SEED10',
        N'SEED10-HOST'
    FROM @ticketSeed t
    INNER JOIN @qr q ON q.rn = t.seq;

    INSERT INTO [Tickets].[CatalogRoutingChangeLog]
    ([serviceID_FK],[idaraID_FK],[oldRoutingRuleID_FK],[newRoutingRuleID_FK],[changeReason],[sourceArbitrationCaseID_FK],[approvedByUserID],[effectiveFrom],[entryData],[hostName])
    SELECT
        r.serviceID,
        1,
        r.ruleID,
        r.ruleID,
        CONCAT(N'SEED10 routing log for service seq ', r.seq),
        ac.caseID,
        9500 + r.seq,
        DATEADD(DAY, -r.seq, GETDATE()),
        N'SEED10',
        N'SEED10-HOST'
    FROM @routingSeed r
    LEFT JOIN @arbCaseSeed ac ON ac.seq = r.seq;

    COMMIT TRAN;

    SELECT N'[Tickets].[TicketClass]' AS [TableName], COUNT(1) AS [RowsInserted] FROM [Tickets].[TicketClass] WHERE [entryData] = N'SEED10'
    UNION ALL
    SELECT N'[Tickets].[RequesterType]', COUNT(1) FROM [Tickets].[RequesterType] WHERE [entryData] = N'SEED10'
    UNION ALL
    SELECT N'[Tickets].[Priority]', COUNT(1) FROM [Tickets].[Priority] WHERE [entryData] = N'SEED10'
    UNION ALL
    SELECT N'[Tickets].[PauseReason]', COUNT(1) FROM [Tickets].[PauseReason] WHERE [entryData] = N'SEED10'
    UNION ALL
    SELECT N'[Tickets].[ArbitrationReason]', COUNT(1) FROM [Tickets].[ArbitrationReason] WHERE [entryData] = N'SEED10'
    UNION ALL
    SELECT N'[Tickets].[ClarificationReason]', COUNT(1) FROM [Tickets].[ClarificationReason] WHERE [entryData] = N'SEED10'
    UNION ALL
    SELECT N'[Tickets].[QualityReviewResult]', COUNT(1) FROM [Tickets].[QualityReviewResult] WHERE [entryData] = N'SEED10'
    UNION ALL
    SELECT N'[Tickets].[Service]', COUNT(1) FROM [Tickets].[Service] WHERE [entryData] = N'SEED10'
    UNION ALL
    SELECT N'[Tickets].[ServiceRoutingRule]', COUNT(1) FROM [Tickets].[ServiceRoutingRule] WHERE [entryData] = N'SEED10'
    UNION ALL
    SELECT N'[Tickets].[ServiceSLAPolicy]', COUNT(1) FROM [Tickets].[ServiceSLAPolicy] WHERE [entryData] = N'SEED10'
    UNION ALL
    SELECT N'[Tickets].[Ticket]', COUNT(1) FROM [Tickets].[Ticket] WHERE [entryData] = N'SEED10'
    UNION ALL
    SELECT N'[Tickets].[TicketHistory]', COUNT(1) FROM [Tickets].[TicketHistory] WHERE [entryData] = N'SEED10'
    UNION ALL
    SELECT N'[Tickets].[TicketSLA]', COUNT(1) FROM [Tickets].[TicketSLA] WHERE [entryData] = N'SEED10'
    UNION ALL
    SELECT N'[Tickets].[TicketSLAHistory]', COUNT(1) FROM [Tickets].[TicketSLAHistory] WHERE [entryData] = N'SEED10'
    UNION ALL
    SELECT N'[Tickets].[ArbitrationCase]', COUNT(1) FROM [Tickets].[ArbitrationCase] WHERE [entryData] = N'SEED10'
    UNION ALL
    SELECT N'[Tickets].[ClarificationRequest]', COUNT(1) FROM [Tickets].[ClarificationRequest] WHERE [entryData] = N'SEED10'
    UNION ALL
    SELECT N'[Tickets].[TicketPauseSession]', COUNT(1) FROM [Tickets].[TicketPauseSession] WHERE [entryData] = N'SEED10'
    UNION ALL
    SELECT N'[Tickets].[QualityReview]', COUNT(1) FROM [Tickets].[QualityReview] WHERE [entryData] = N'SEED10'
    UNION ALL
    SELECT N'[Tickets].[CatalogRoutingChangeLog]', COUNT(1) FROM [Tickets].[CatalogRoutingChangeLog] WHERE [entryData] = N'SEED10';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    THROW;
END CATCH;
