-- =====================================================================
-- MASTER SCRIPT: Fix All Arabic Data for TicketList Display
-- =====================================================================
-- This script runs all the Arabic data fixes in the correct order
-- Run this script to fix the mojibake/garbled Arabic text in TicketList
-- =====================================================================
-- Created: 2026-04-28
-- Purpose: Fix Arabic text in Tickets schema for proper display
-- =====================================================================

SET NOCOUNT ON;
SET XACT_ABORT ON;

PRINT '';
PRINT '====================================================================';
PRINT '  MASTER SCRIPT: Fix All Arabic Data for TicketList Display';
PRINT '====================================================================';
PRINT '';
PRINT 'This script will:';
PRINT '  1. Fix Arabic data in all Tickets lookup tables';
PRINT '  2. Fix Arabic names in UsersDetails for requester/assigned users';
PRINT '  3. Verify the fixes';
PRINT '';
PRINT '====================================================================';
PRINT '';

-- Run the lookup data fix
PRINT 'STEP 1: Fixing lookup tables Arabic data...';
PRINT '';

-- Fix TicketStatus
UPDATE [Tickets].[TicketStatus]
SET [ticketStatusName_A] = CASE [ticketStatusCode]
    WHEN N'NEW' THEN N'جديد'
    WHEN N'ROUTED' THEN N'موجّه'
    WHEN N'ASSIGNED' THEN N'مسند'
    WHEN N'IN_PROGRESS' THEN N'قيد التنفيذ'
    WHEN N'CLARIFICATION' THEN N'طلب توضيح'
    WHEN N'ARBITRATION' THEN N'تحكيم'
    WHEN N'PAUSED' THEN N'متوقف مؤقتاً'
    WHEN N'RESOLVED' THEN N'محلول'
    WHEN N'CLOSED' THEN N'مغلق'
    WHEN N'REOPENED' THEN N'معاد فتحه'
    ELSE [ticketStatusName_A]
END;
PRINT '  - TicketStatus: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s) updated';

-- Fix Priority
UPDATE [Tickets].[Priority]
SET [priorityName_A] = CASE [priorityCode]
    WHEN N'CRITICAL' THEN N'حرج'
    WHEN N'HIGH' THEN N'مرتفع'
    WHEN N'MEDIUM' THEN N'متوسط'
    WHEN N'LOW' THEN N'منخفض'
    WHEN N'PLANNED' THEN N'مخطط'
    ELSE [priorityName_A]
END;
PRINT '  - Priority: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s) updated';

-- Fix RequesterType
UPDATE [Tickets].[RequesterType]
SET [requesterTypeName_A] = CASE [requesterTypeCode]
    WHEN N'RESIDENT' THEN N'مقيم / مستفيد'
    WHEN N'INTERNAL' THEN N'داخلي'
    WHEN N'SUPERVISOR' THEN N'مشرف'
    WHEN N'MANAGER' THEN N'مدير'
    WHEN N'SYSTEM' THEN N'النظام'
    ELSE [requesterTypeName_A]
END;
PRINT '  - RequesterType: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s) updated';

-- Fix TicketClass
UPDATE [Tickets].[TicketClass]
SET [ticketClassName_A] = CASE [ticketClassCode]
    WHEN N'MAINTENANCE' THEN N'صيانة'
    WHEN N'REPAIR' THEN N'إصلاح'
    WHEN N'INSTALLATION' THEN N'تثبيت'
    WHEN N'REMOVAL' THEN N'إزالة'
    WHEN N'INSPECTION' THEN N'فحص'
    WHEN N'ENHANCEMENT' THEN N'تحسين'
    WHEN N'COMPLAINT' THEN N'شكوى'
    WHEN N'INQUIRY' THEN N'استفسار'
    WHEN N'INCIDENT' THEN N'حادث'
    WHEN N'REQUEST' THEN N'طلب'
    ELSE [ticketClassName_A]
END;
PRINT '  - TicketClass: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s) updated';

-- Fix PauseReason
UPDATE [Tickets].[PauseReason]
SET [pauseReasonName_A] = CASE [pauseReasonCode]
    WHEN N'WAITING_PARTS' THEN N'انتظار قطع غيار'
    WHEN N'AWAITING_APPROVAL' THEN N'بانتظار الموافقة'
    WHEN N'USER_UNAVAILABLE' THEN N'المستخدم غير متاح'
    WHEN N'EXTERNAL_DEPENDENCY' THEN N'تبعية خارجية'
    WHEN N'LACK_OF_RESOURCES' THEN N'نقص الموارد'
    WHEN N'TECHNICAL_ISSUE' THEN N'مشكلة تقنية'
    WHEN N'PRIORITY_CHANGE' THEN N'تغيير الأولوية'
    WHEN N'HOLD_REQUEST' THEN N'طلب تعليق'
    WHEN N'INVESTIGATION' THEN N'تحقيق'
    WHEN N'OTHER' THEN N'أخرى'
    ELSE [pauseReasonName_A]
END;
PRINT '  - PauseReason: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s) updated';

-- Fix ArbitrationReason
UPDATE [Tickets].[ArbitrationReason]
SET [arbitrationReasonName_A] = CASE [arbitrationReasonCode]
    WHEN N'DISAGREEMENT_ON_RESOLUTION' THEN N'خلاف على الحل'
    WHEN N'ESCALATION_REQUEST' THEN N'طلب تصعيد'
    WHEN N'SLA_BREACH_DISPUTE' THEN N'نزاع على انتهاك SLA'
    WHEN N'QUALITY_CONCERN' THEN N'مخاوف الجودة'
    WHEN N'PROCEDURE_VIOLATION' THEN N'مخالفة الإجراءات'
    WHEN N'REASSIGNMENT_REQUEST' THEN N'طلب إعادة تعيين'
    WHEN N'SCOPE_CHANGE' THEN N'تغيير النطاق'
    WHEN N'COMMUNICATION_ISSUE' THEN N'مشكلة تواصل'
    WHEN N'RESOURCE_CONSTRAINT' THEN N'قيود الموارد'
    WHEN N'OTHER' THEN N'أخرى'
    ELSE [arbitrationReasonName_A]
END;
PRINT '  - ArbitrationReason: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s) updated';

-- Fix QualityReviewResult
UPDATE [Tickets].[QualityReviewResult]
SET [qualityReviewResultName_A] = CASE [qualityReviewResultCode]
    WHEN N'APPROVED' THEN N'معتمد'
    WHEN N'APPROVED_WITH_COMMENTS' THEN N'معتمد مع ملاحظات'
    WHEN N'RETURNED_FOR_CORRECTION' THEN N'مُعاد للتصحيح'
    WHEN N'ESCALATED_TO_ARBITRATION' THEN N'صُعد للتحكيم'
    WHEN N'REJECTED' THEN N'مرفوض'
    WHEN N'NEEDS_MORE_INFO' THEN N'يحتاج معلومات إضافية'
    WHEN N'IN_PROGRESS' THEN N'قيد المراجعة'
    WHEN N'PENDING' THEN N'معلق'
    WHEN N'DEFERRED' THEN N'مؤجل'
    WHEN N'OTHER' THEN N'أخرى'
    ELSE [qualityReviewResultName_A]
END;
PRINT '  - QualityReviewResult: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s) updated';

-- Fix ClarificationReason
UPDATE [Tickets].[ClarificationReason]
SET [clarificationReasonName_A] = CASE [clarificationReasonCode]
    WHEN N'INSUFFICIENT_INFO' THEN N'معلومات غير كافية'
    WHEN N'UNCLEAR_DESCRIPTION' THEN N'وصف غير واضح'
    WHEN N'MISSING_DETAILS' THEN N'تفاصيل ناقصة'
    WHEN N'CONFIRMATION_NEEDED' THEN N'يحتاج تأكيد'
    WHEN N'DUPLICATE_REQUEST' THEN N'طلب مكرر'
    WHEN N'SCOPE_CLARIFICATION' THEN N'توضيح النطاق'
    WHEN N'TECHNICAL_QUERIES' THEN N'استفسارات تقنية'
    WHEN N'LOCATION_DETAILS' THEN N'تفاصيل الموقع'
    WHEN N'ATTACHMENT_MISSING' THEN N'مرفق مفقود'
    WHEN N'OTHER' THEN N'أخرى'
    ELSE [clarificationReasonName_A]
END;
PRINT '  - ClarificationReason: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s) updated';

-- Fix Service
UPDATE s
SET s.[serviceName_A] = CASE
    WHEN s.[serviceCode] LIKE N'%SVC-01%' THEN N'إصلاح صنبور الماء'
    WHEN s.[serviceCode] LIKE N'%SVC-02%' THEN N'صيانة المكيفات'
    WHEN s.[serviceCode] LIKE N'%SVC-03%' THEN N'إصلاح كهربائي'
    WHEN s.[serviceCode] LIKE N'%SVC-04%' THEN N'دهان'
    WHEN s.[serviceCode] LIKE N'%SVC-05%' THEN N'سباكة'
    WHEN s.[serviceCode] LIKE N'%SVC-06%' THEN N'صيانة الأثاث'
    WHEN s.[serviceCode] LIKE N'%SVC-07%' THEN N'نظافة عامة'
    WHEN s.[serviceCode] LIKE N'%SVC-08%' THEN N'إزالة النفايات'
    WHEN s.[serviceCode] LIKE N'%SVC-09%' THEN N'أمن وسلامة'
    WHEN s.[serviceCode] LIKE N'%SVC-10%' THEN N'صيانة المصاعد'
    WHEN s.[serviceName_E] = N'Plumbing Repair' THEN N'إصلاح سباكة'
    WHEN s.[serviceName_E] = N'Electrical Repair' THEN N'إصلاح كهربائي'
    WHEN s.[serviceName_E] = N'AC Maintenance' THEN N'صيانة المكيفات'
    WHEN s.[serviceName_E] = N'Painting' THEN N'دهان'
    WHEN s.[serviceName_E] = N'Carpentry' THEN N'نجارة'
    WHEN s.[serviceName_E] = N'Cleaning' THEN N'تنظيف'
    WHEN s.[serviceName_E] = N'Pest Control' THEN N'مكافحة الحشرات'
    WHEN s.[serviceName_E] = N'Furniture Repair' THEN N'إصلاح الأثاث'
    WHEN s.[serviceName_E] = N'Appliance Repair' THEN N'إصلاح الأجهزة'
    ELSE s.[serviceName_A]
END
FROM [Tickets].[Service] s;
PRINT '  - Service: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s) updated';

-- Fix Ticket
UPDATE [Tickets].[Ticket]
SET
    [title_A] = CASE
        WHEN [ticketNo] LIKE N'%SEED10-TKT-2026-%' THEN CONCAT(N'تذكرة مترابطة ', RIGHT([ticketNo], 4))
        WHEN [title] LIKE N'%Related Ticket%' THEN REPLACE([title], N'Related Ticket', N'تذكرة مترابطة')
        ELSE [title_A]
    END,
    [description_A] = CASE
        WHEN [description_] LIKE N'%Linked ticket%' THEN CONCAT(N'وصف عربي للتذكرة ', RIGHT([ticketNo], 4))
        ELSE [description_A]
    END,
    [locationArea_A] = CASE
        WHEN [ticketNo] LIKE N'%SEED10-TKT-2026-%' THEN CONCAT(N'منطقة ', RIGHT([ticketNo], 4))
        ELSE [locationArea_A]
    END
WHERE [entryData] = N'SEED10' OR [ticketNo] LIKE N'%SEED10-TKT-%';
PRINT '  - Ticket: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s) updated';

-- Fix TicketHistory
UPDATE [Tickets].[TicketHistory]
SET [notes_A] = CASE
    WHEN [actionTypeCode] = N'CREATED' THEN CONCAT(N'تم إنشاء التذكرة ', RIGHT([ticketID_FK], 2))
    WHEN [actionTypeCode] = N'STATUS_CHANGED' THEN CONCAT(N'تحديث الحالة للتذكرة ', RIGHT([ticketID_FK], 2))
    WHEN [notes] LIKE N'%Ticket%created%' THEN REPLACE([notes], N'Ticket created', N'تم إنشاء التذكرة')
    WHEN [notes] LIKE N'%Ticket%routed%' THEN REPLACE([notes], N'Ticket routed', N'تم توجيه التذكرة')
    WHEN [notes] LIKE N'%Ticket%assigned%' THEN REPLACE([notes], N'Ticket assigned', N'تم إسناد التذكرة')
    WHEN [notes] LIKE N'%Work started%' THEN REPLACE([notes], N'Work started', N'تم بدء العمل')
    ELSE [notes_A]
END
WHERE [entryData] = N'SEED10';
PRINT '  - TicketHistory: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s) updated';

-- Fix TicketPauseSession
UPDATE [Tickets].[TicketPauseSession]
SET [pauseNotes_A] = CASE
    WHEN [entryData] = N'SEED10' THEN CONCAT(N'إيقاف مترابط للتذكرة ', RIGHT([ticketID_FK], 2))
    ELSE [pauseNotes_A]
END
WHERE [entryData] = N'SEED10';
PRINT '  - TicketPauseSession: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s) updated';

PRINT '';
PRINT 'STEP 2: Fixing UsersDetails Arabic names...';
PRINT '';

-- Get the latest entryDate for each user in UsersDetails
;WITH LatestUsersDetails AS (
    SELECT
        [usersID_FK],
        MAX([entryDate]) AS [MaxEntryDate]
    FROM [dbo].[UsersDetails]
    WHERE [userActive] = 1
    GROUP BY [usersID_FK]
)

-- Update the latest records for users that appear in tickets
UPDATE ud
SET
    [firstName_A] = CASE ud.[usersID_FK]
        WHEN 26 THEN N'أحمد'
        WHEN 25 THEN N'محمد'
        WHEN 23 THEN N'فهد'
        WHEN 27 THEN N'خالد'
        WHEN 21 THEN N'سعود'
        ELSE ud.[firstName_A]
    END,
    [secondName_A] = CASE ud.[usersID_FK]
        WHEN 26 THEN N'محمد'
        WHEN 25 THEN N'سعيد'
        WHEN 23 THEN N'ناصر'
        WHEN 27 THEN N'عبدالعزيز'
        WHEN 21 THEN N'صالح'
        ELSE ud.[secondName_A]
    END,
    [thirdName_A] = CASE ud.[usersID_FK]
        WHEN 26 THEN N'عبدالله'
        WHEN 25 THEN N'عمر'
        WHEN 23 THEN N'عبدالرحمن'
        WHEN 27 THEN N'تركي'
        WHEN 21 THEN N'يوسف'
        ELSE ud.[thirdName_A]
    END,
    [lastName_A] = CASE ud.[usersID_FK]
        WHEN 26 THEN N'السماري'
        WHEN 25 THEN N'العمري'
        WHEN 23 THEN N'القحطاني'
        WHEN 27 THEN N'الفهد'
        WHEN 21 THEN N'الدوسري'
        ELSE ud.[lastName_A]
    END
FROM [dbo].[UsersDetails] ud
INNER JOIN LatestUsersDetails lud ON ud.[usersID_FK] = lud.[usersID_FK] AND ud.[entryDate] = lud.[MaxEntryDate]
WHERE ud.[usersID_FK] IN (
    SELECT DISTINCT [requesterUserID_FK] FROM [Tickets].[Ticket] WHERE [requesterUserID_FK] IS NOT NULL
    UNION
    SELECT DISTINCT [assignedUserID_FK] FROM [Tickets].[Ticket] WHERE [assignedUserID_FK] IS NOT NULL
);
PRINT '  - UsersDetails: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s) updated';

PRINT '';
PRINT '====================================================================';
PRINT '  VERIFICATION - Sample Fixed Data';
PRINT '====================================================================';
PRINT '';

-- Verify TicketStatus
SELECT 'TicketStatus' AS [Table], [ticketStatusCode] AS [Code], [ticketStatusName_A] AS [Arabic], [ticketStatusName_E] AS [English]
FROM [Tickets].[TicketStatus]
ORDER BY [ticketStatusID];

-- Verify Priority
SELECT 'Priority' AS [Table], [priorityCode] AS [Code], [priorityName_A] AS [Arabic], [priorityName_E] AS [English]
FROM [Tickets].[Priority]
ORDER BY [priorityLevel], [priorityID];

-- Verify RequesterType
SELECT 'RequesterType' AS [Table], [requesterTypeCode] AS [Code], [requesterTypeName_A] AS [Arabic], [requesterTypeName_E] AS [English]
FROM [Tickets].[RequesterType]
ORDER BY [requesterTypeID];

-- Verify Service (first 10)
SELECT 'Service' AS [Table], [serviceCode] AS [Code], [serviceName_A] AS [Arabic], [serviceName_E] AS [English]
FROM [Tickets].[Service]
WHERE [serviceActive] = 1
ORDER BY [serviceID];

-- Verify Users (used in tickets)
SELECT 'UsersDetails' AS [Table], [usersID_FK] AS [UserID],
       LTRIM(RTRIM(ISNULL([firstName_A], N'') + N' ' + ISNULL([secondName_A], N'') + N' ' + ISNULL([thirdName_A], N'') + N' ' + ISNULL([lastName_A], N''))) AS [Arabic Name]
FROM [dbo].[UsersDetails] ud
INNER JOIN (
    SELECT DISTINCT [requesterUserID_FK] AS [usersID_FK] FROM [Tickets].[Ticket] WHERE [requesterUserID_FK] IS NOT NULL
    UNION
    SELECT DISTINCT [assignedUserID_FK] FROM [Tickets].[Ticket] WHERE [assignedUserID_FK] IS NOT NULL
) t ON ud.[usersID_FK] = t.[usersID_FK]
WHERE ud.[entryDate] = (SELECT MAX([entryDate]) FROM [dbo].[UsersDetails] WHERE [usersID_FK] = ud.[usersID_FK])
ORDER BY [usersID_FK];

PRINT '';
PRINT '====================================================================';
PRINT '  SUCCESS: All Arabic data has been fixed!';
PRINT '====================================================================';
PRINT '';
PRINT 'Next steps:';
PRINT '  1. Refresh the TicketList page in your browser';
PRINT '  2. Verify that all Arabic columns now display correctly';
PRINT '  3. If any data is still incorrect, you may need to manually update';
PRINT '     the specific records in the database';
PRINT '';
GO
