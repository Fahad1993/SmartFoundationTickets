-- Seed data for TicketDescriptionTemplate
INSERT INTO [Tickets].[TicketDescriptionTemplate] ([templateCode], [templateName_A], [templateName_E], [templateContent_A], [templateContent_E], [templateDesc], [serviceID_FK], [ticketClassID_FK], [displayOrder], [templateActive], [idaraID_FK], [entryData], [hostName])
VALUES
-- Internet Related Templates
('INT_001', N'لا يوجد اتصال بالإنترنت', N'No Internet Connection', N'لا يوجد اتصال بالإنترنت في وحدتي السكنية. يرجى التحقق من المشكلة وإصلاحها في أسرع وقت ممكن.', N'No internet connection in my housing unit. Please check and fix the issue as soon as possible.', N'قالب وصف لمشكلة الإنترنت - لا يوجد اتصال', NULL, NULL, 1, 1, NULL, 1, 'System'),
('INT_002', N'إنترنت بطيء جداً', N'Very Slow Internet', N'سرعة الإنترنت في وحدتي السكنية بطيئة جداً ولا تسمح باستخدام الخدمات الأساسية.', N'The internet speed in my housing unit is very slow and does not allow using basic services.', N'قالب وصف لمشكلة الإنترنت - سرعة بطيئة', NULL, NULL, 2, 1, NULL, 1, 'System'),

-- Electrical Related Templates
('ELE_001', N'انقطاع كهرباء', N'Power Outage', N'هناك انقطاع في الكهرباء في وحدتي السكنية. يرجى التحقق من المشكلة وإصلاحها.', N'There is a power outage in my housing unit. Please check and fix the issue.', N'قالب وصف لمشكلة كهربائية - انقطاع', NULL, NULL, 3, 1, NULL, 1, 'System'),
('ELE_002', N'مشكلة في الإضاءة', N'Lighting Issue', N'هناك مشكلة في الإضاءة في وحدتي السكنية. بعض الإضاءة لا تعمل بشكل صحيح.', N'There is a lighting issue in my housing unit. Some lights are not working properly.', N'قالب وصف لمشكلة كهربائية - إضاءة', NULL, NULL, 4, 1, NULL, 1, 'System'),

-- Water Related Templates
('WAT_001', N'لا يوجد ماء', N'No Water Supply', N'لا يوجد إمداد ماء في وحدتي السكنية. يرجى التحقق من المشكلة وإصلاحها في أسرع وقت.', N'There is no water supply in my housing unit. Please check and fix the issue as soon as possible.', N'قالب وصف لمشكلة المياه - لا يوجد ماء', NULL, NULL, 5, 1, NULL, 1, 'System'),
('WAT_002', N'تسريب مياه', N'Water Leak', N'هناك تسريب مياه في وحدتي السكنية/المبنى. يرجى التحقق من المشكلة وإصلاحها في أسرع وقت لتجنب الأضرار.', N'There is a water leak in my housing unit/building. Please check and fix the issue as soon as possible to avoid damages.', N'قالب وصف لمشكلة المياه - تسريب', NULL, NULL, 6, 1, NULL, 1, 'System'),

-- AC Related Templates
('AC_001', N'لا يعمل التكييف', N'AC Not Working', N'نظام التكييف في وحدتي السكنية لا يعمل. يرجى التحقق من المشكلة وإصلاحها.', N'The AC system in my housing unit is not working. Please check and fix the issue.', N'قالب وصف لمشكلة التكييف - لا يعمل', NULL, NULL, 7, 1, NULL, 1, 'System'),
('AC_002', N'تكييف غير كافٍ', N'Insufficient Cooling', N'نظام التكييف في وحدتي السكنية لا يوفر تبريداً كافياً.', N'The AC system in my housing unit does not provide sufficient cooling.', N'قالب وصف لمشكلة التكييف - تبريد غير كافٍ', NULL, NULL, 8, 1, NULL, 1, 'System'),

-- General Maintenance Templates
('GEN_001', N'طلب صيانة عامة', N'General Maintenance Request', N'أحتاج إلى صيانة عامة لوحدتي السكنية. يرجى التواصل معي لتحديد الموعد المناسب.', N'I need general maintenance for my housing unit. Please contact me to arrange a suitable time.', N'قالب وصف عام لطلب الصيانة', NULL, NULL, 9, 1, NULL, 1, 'System'),

-- Elevator Templates
('ELV_001', N'المصعد عالق', N'Elevator Stuck', N'المصعد عالق ولا يتحرك. يرجى التدخل العاجل لإطلاق أي شخص محاصر بداخله.', N'The elevator is stuck and not moving. Please intervene urgently to free anyone trapped inside.', N'قالب وصف لمشكلة المصعد - عالق', NULL, NULL, 10, 1, NULL, 1, 'System'),
('ELV_002', N'المصعد لا يعمل', N'Elevator Not Working', N'المصعد لا يعمل بشكل صحيح. يرجى التحقق من المشكلة وإصلاحها.', N'The elevator is not working properly. Please check and fix the issue.', N'قالب وصف لمشكلة المصعد - لا يعمل', NULL, NULL, 11, 1, NULL, 1, 'System'),

-- Security Templates
('SEC_001', N'طلب ترقية الأمن', N'Security Upgrade Request', N'أرغب في طلب ترقية إجراءات الأمن في المبنى/المنطقة السكنية.', N'I would like to request security upgrades for the building/residential area.', N'قالب وصف لمشكلة الأمن - ترقية', NULL, NULL, 12, 1, NULL, 1, 'System'),

-- Cleaning Templates
('CLN_001', N'طلب تنظيف', N'Cleaning Request', N'أحتاج إلى طلب خدمة تنظيف لوحدتي السكنية/المنطقة العامة.', N'I need to request a cleaning service for my housing unit/common area.', N'قالب وصف لمشكلة النظافة', NULL, NULL, 13, 1, NULL, 1, 'System'),

-- Furniture Templates
('FRN_001', N'استبدال مفروشات تالفة', N'Replace Damaged Furniture', N'أحتاج إلى استبدال بعض المفروشات التالفة في وحدتي السكنية.', N'I need to replace some damaged furniture in my housing unit.', N'قالب وصف لطلب استبدال المفروشات', NULL, NULL, 14, 1, NULL, 1, 'System'),

-- Appliance Templates
('APL_001', N'إصلاح جهاز تالف', N'Repair Damaged Appliance', N'أحتاج إلى إصلاح جهاز تالف في وحدتي السكنية.', N'I need to repair a damaged appliance in my housing unit.', N'قالب وصف لطلب إصلاح جهاز', NULL, NULL, 15, 1, NULL, 1, 'System'),

-- Plumbing Templates
('PLB_001', N'انسداد في الصرف الصحي', N'Drainage Clog', N'هناك انسداد في نظام الصرف الصحي في وحدتي السكنية.', N'There is a clog in the drainage system in my housing unit.', N'قالب وصف لمشكلة السباكة - انسداد', NULL, NULL, 16, 1, NULL, 1, 'System'),

-- Other Templates
('OTH_001', N'مشكلة أخرى', N'Other Issue', N'لدي مشكلة أخرى تحتاج إلى متابعة. سأقوم بتوضيح التفاصيل عند التواصل.', N'I have another issue that needs follow-up. I will provide details upon contact.', N'قالب وصف عام لأي مشكلة أخرى', NULL, NULL, 17, 1, NULL, 1, 'System');
