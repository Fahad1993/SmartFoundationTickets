-- =====================================================================
-- Fix All Arabic Lookup Data in Tickets Schema
-- =====================================================================
-- This script updates all lookup tables with correct Arabic values
-- instead of the mojibake/garbled characters
-- =====================================================================

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRAN;

BEGIN TRY
    PRINT '===== Fixing TicketStatus Arabic Data =====';

    -- Update TicketStatus with correct Arabic values
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

    PRINT 'Updated TicketStatus: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

    PRINT '';
    PRINT '===== Fixing Priority Arabic Data =====';

    -- Update Priority with correct Arabic values
    UPDATE [Tickets].[Priority]
    SET [priorityName_A] = CASE [priorityCode]
        WHEN N'CRITICAL' THEN N'حرج'
        WHEN N'HIGH' THEN N'مرتفع'
        WHEN N'MEDIUM' THEN N'متوسط'
        WHEN N'LOW' THEN N'منخفض'
        WHEN N'PLANNED' THEN N'مخطط'
        ELSE [priorityName_A]
    END;

    PRINT 'Updated Priority: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

    PRINT '';
    PRINT '===== Fixing RequesterType Arabic Data =====';

    -- Update RequesterType with correct Arabic values
    UPDATE [Tickets].[RequesterType]
    SET [requesterTypeName_A] = CASE [requesterTypeCode]
        WHEN N'RESIDENT' THEN N'مقيم / مستفيد'
        WHEN N'INTERNAL' THEN N'داخلي'
        WHEN N'SUPERVISOR' THEN N'مشرف'
        WHEN N'MANAGER' THEN N'مدير'
        WHEN N'SYSTEM' THEN N'النظام'
        ELSE [requesterTypeName_A]
    END;

    PRINT 'Updated RequesterType: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

    PRINT '';
    PRINT '===== Fixing TicketClass Arabic Data =====';

    -- Update TicketClass with correct Arabic values
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

    PRINT 'Updated TicketClass: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

    PRINT '';
    PRINT '===== Fixing PauseReason Arabic Data =====';

    -- Update PauseReason with correct Arabic values
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

    PRINT 'Updated PauseReason: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

    PRINT '';
    PRINT '===== Fixing ArbitrationReason Arabic Data =====';

    -- Update ArbitrationReason with correct Arabic values
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

    PRINT 'Updated ArbitrationReason: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

    PRINT '';
    PRINT '===== Fixing QualityReviewResult Arabic Data =====';

    -- Update QualityReviewResult with correct Arabic values
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

    PRINT 'Updated QualityReviewResult: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

    PRINT '';
    PRINT '===== Fixing ClarificationReason Arabic Data =====';

    -- Update ClarificationReason with correct Arabic values
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

    PRINT 'Updated ClarificationReason: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

    PRINT '';
    PRINT '===== Fixing Service Arabic Data =====';

    -- Update Service with correct Arabic values
    -- First, check existing service codes and update accordingly
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

    PRINT 'Updated Service: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

    PRINT '';
    PRINT '===== Fixing Ticket Arabic Data =====';

    -- Update Ticket title_A and description_A for seed data
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

    PRINT 'Updated Ticket: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

    PRINT '';
    PRINT '===== Fixing TicketHistory Arabic Data =====';

    -- Update TicketHistory notes_A for seed data
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

    PRINT 'Updated TicketHistory: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

    PRINT '';
    PRINT '===== Fixing TicketPauseSession Arabic Data =====';

    -- Update TicketPauseSession pauseNotes_A for seed data
    UPDATE [Tickets].[TicketPauseSession]
    SET [pauseNotes_A] = CASE
        WHEN [entryData] = N'SEED10' THEN CONCAT(N'إيقاف مترابط للتذكرة ', RIGHT([ticketID_FK], 2))
        ELSE [pauseNotes_A]
    END
    WHERE [entryData] = N'SEED10';

    PRINT 'Updated TicketPauseSession: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

    PRINT '';
    PRINT '===== VERIFICATION =====';
    PRINT 'Here is a sample of the fixed data:';
    PRINT '';

    SELECT 'TicketStatus' AS [Table], [ticketStatusCode], [ticketStatusName_A]
    FROM [Tickets].[TicketStatus]
    ORDER BY [ticketStatusID];

    SELECT 'Priority' AS [Table], [priorityCode], [priorityName_A]
    FROM [Tickets].[Priority]
    ORDER BY [priorityLevel], [priorityID];

    SELECT 'RequesterType' AS [Table], [requesterTypeCode], [requesterTypeName_A]
    FROM [Tickets].[RequesterType]
    ORDER BY [requesterTypeID];

    SELECT 'Service' AS [Table], [serviceCode], [serviceName_A]
    FROM [Tickets].[Service]
    WHERE [serviceActive] = 1
    ORDER BY [serviceID];

    PRINT '';
    PRINT '===== SUCCESS: All Arabic data has been fixed =====';

    COMMIT TRAN;

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    PRINT 'ERROR: Fix failed!';
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR(5));
    PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR(5));

    THROW;
END CATCH;
GO

PRINT '';
PRINT 'Script completed successfully.';
PRINT 'Please refresh the TicketList page to see the corrected Arabic data.';
GO
