-- Fix Arabic Values in Tickets Lookup Tables
-- Uses N'' Unicode string literals for correct Arabic encoding

-- TicketStatus
UPDATE Tickets.TicketStatus SET ticketStatusName_A = N'جديد'              WHERE ticketStatusCode = 'NEW';
UPDATE Tickets.TicketStatus SET ticketStatusName_A = N'موجّه'             WHERE ticketStatusCode = 'ROUTED';
UPDATE Tickets.TicketStatus SET ticketStatusName_A = N'معيّن'             WHERE ticketStatusCode = 'ASSIGNED';
UPDATE Tickets.TicketStatus SET ticketStatusName_A = N'جاري التنفيذ'      WHERE ticketStatusCode = 'IN_PROGRESS';
UPDATE Tickets.TicketStatus SET ticketStatusName_A = N'طلب توضيح'         WHERE ticketStatusCode = 'CLARIFICATION';
UPDATE Tickets.TicketStatus SET ticketStatusName_A = N'تحكيم'             WHERE ticketStatusCode = 'ARBITRATION';
UPDATE Tickets.TicketStatus SET ticketStatusName_A = N'متوقف'             WHERE ticketStatusCode = 'PAUSED';
UPDATE Tickets.TicketStatus SET ticketStatusName_A = N'تم التنفيذ'        WHERE ticketStatusCode = 'RESOLVED';
UPDATE Tickets.TicketStatus SET ticketStatusName_A = N'مغلق نهائياً'      WHERE ticketStatusCode = 'CLOSED';
UPDATE Tickets.TicketStatus SET ticketStatusName_A = N'مرفوض'             WHERE ticketStatusCode = 'REJECTED';
UPDATE Tickets.TicketStatus SET ticketStatusName_A = N'إعادة فتح'        WHERE ticketStatusCode = 'REOPENED';

-- Priority
UPDATE Tickets.Priority SET priorityName_A = N'حرج'      WHERE priorityCode = 'CRITICAL';
UPDATE Tickets.Priority SET priorityName_A = N'مرتفع'    WHERE priorityCode = 'HIGH';
UPDATE Tickets.Priority SET priorityName_A = N'متوسط'    WHERE priorityCode = 'MEDIUM';
UPDATE Tickets.Priority SET priorityName_A = N'منخفض'    WHERE priorityCode = 'LOW';

-- RequesterType
UPDATE Tickets.RequesterType SET requesterTypeName_A = N'مقيم / مستفيد'  WHERE requesterTypeID = 1;
UPDATE Tickets.RequesterType SET requesterTypeName_A = N'موظف'            WHERE requesterTypeID = 2;

-- TicketClass
UPDATE Tickets.TicketClass SET ticketClassName_A = N'صيانة'      WHERE ticketClassID = 1;
UPDATE Tickets.TicketClass SET ticketClassName_A = N'نظافة'      WHERE ticketClassID = 2;
UPDATE Tickets.TicketClass SET ticketClassName_A = N'إداري'      WHERE ticketClassID = 3;
UPDATE Tickets.TicketClass SET ticketClassName_A = N'تقنية'      WHERE ticketClassID = 4;

-- Service
UPDATE Tickets.Service SET serviceName_A = N'إصلاح صنبور مياه'    WHERE serviceID = 1;
UPDATE Tickets.Service SET serviceName_A = N'إصلاح كهرباء'        WHERE serviceID = 2;
UPDATE Tickets.Service SET serviceName_A = N'صيانة تكييف'         WHERE serviceID = 3;
UPDATE Tickets.Service SET serviceName_A = N'نظافة عامة'          WHERE serviceID = 4;
UPDATE Tickets.Service SET serviceName_A = N'إصلاح سباكة'         WHERE serviceID = 5;

-- PauseReason
UPDATE Tickets.PauseReason SET pauseReasonName_A = N'بانتظار قطع غيار'         WHERE pauseReasonID = 1;
UPDATE Tickets.PauseReason SET pauseReasonName_A = N'بانتظار معلومات'           WHERE pauseReasonID = 2;
UPDATE Tickets.PauseReason SET pauseReasonName_A = N'بانتظار موافقة'            WHERE pauseReasonID = 3;
UPDATE Tickets.PauseReason SET pauseReasonName_A = N'طلب توضيح من الموقع'       WHERE pauseReasonID = 4;

-- ArbitrationReason
UPDATE Tickets.ArbitrationReason SET arbitrationReasonName_A = N'خارج نطاق الخدمة'   WHERE arbitrationReasonID = 1;
UPDATE Tickets.ArbitrationReason SET arbitrationReasonName_A = N'نزاع بين الأطراف'    WHERE arbitrationReasonID = 2;
UPDATE Tickets.ArbitrationReason SET arbitrationReasonName_A = N'تصعيد إداري'          WHERE arbitrationReasonID = 3;

-- QualityReviewResult
UPDATE Tickets.QualityReviewResult SET qualityReviewResultName_A = N'مقبول'            WHERE qualityReviewResultID = 1;
UPDATE Tickets.QualityReviewResult SET qualityReviewResultName_A = N'مرفوض'            WHERE qualityReviewResultID = 2;
UPDATE Tickets.QualityReviewResult SET qualityReviewResultName_A = N'يحتاج مراجعة'    WHERE qualityReviewResultID = 3;

-- TicketHistory - oldStatusName_A/newStatusName_A are computed in the SP via JOINs, not stored columns

-- Ticket records - fix title (Arabic) and description
UPDATE Tickets.Ticket SET title = N'صنبور مياه مكسور في المطبخ' WHERE ticketID = 1;
UPDATE Tickets.Ticket SET title = N'عطل كهربائي في غرفة المعيشة' WHERE ticketID = 2;
UPDATE Tickets.Ticket SET title = N'تكييف لا يعمل'               WHERE ticketID = 3;
UPDATE Tickets.Ticket SET title = N'تنظيف عام للمبنى'            WHERE ticketID = 4;
UPDATE Tickets.Ticket SET title = N'تسرب مياه في الحمام'         WHERE ticketID = 5;

-- PauseSession - fix reason
UPDATE Tickets.PauseSession SET pauseReason = N'بانتظار قطع غيار سباكة من المستودع' WHERE pauseSessionID = 1;
UPDATE Tickets.PauseSession SET pauseReason = N'توضيح موقع من المقيم'               WHERE pauseSessionID = 2;
UPDATE Tickets.PauseSession SET pauseReason = N'بانتظار موافقة إدارية'               WHERE pauseSessionID = 3;
UPDATE Tickets.PauseSession SET pauseReason = N'قطع غيار كهربائية غير متوفرة'       WHERE pauseSessionID = 4;
UPDATE Tickets.PauseSession SET pauseReason = N'تأكيد من الفني المختص'               WHERE pauseSessionID = 5;

-- Ticket location area
UPDATE Tickets.Ticket SET locationArea = N'حي الهزاز'   WHERE ticketID = 1;
UPDATE Tickets.Ticket SET locationArea = N'حي الروابي'  WHERE ticketID = 2;
UPDATE Tickets.Ticket SET locationArea = N'حي السلام'   WHERE ticketID = 3;
UPDATE Tickets.Ticket SET locationArea = N'حي المروج'   WHERE ticketID = 4;
UPDATE Tickets.Ticket SET locationArea = N'حي النسيم'   WHERE ticketID = 5;

PRINT 'Arabic values fixed successfully';
GO
