-- Seed data for TicketReason
INSERT INTO [Tickets].[TicketReason] ([ticketReasonCode], [ticketReasonName_A], [ticketReasonName_E], [ticketReasonDesc], [serviceID_FK], [ticketClassID_FK], [priorityID_FK], [displayOrder], [ticketReasonActive], [idaraID_FK], [entryData], [hostName])
VALUES
-- General Ticket Reasons
('GEN_001', N'مشكلة في الإنترنت', N'Internet Issue', N'مشكلة في الاتصال بالإنترنت', NULL, NULL, 2, 1, 1, NULL, 1, 'System'),
('GEN_002', N'مشكلة في الكهرباء', N'Electrical Issue', N'مشكلة في الكهرباء أو الإضاءة', NULL, NULL, 2, 2, 1, NULL, 1, 'System'),
('GEN_003', N'مشكلة في المياه', N'Water Issue', N'مشكلة في إمدادات المياه', NULL, NULL, 2, 3, 1, NULL, 1, 'System'),
('GEN_004', N'مشكلة في التكييف', N'AC Issue', N'مشكلة في نظام التكييف', NULL, NULL, 2, 4, 1, NULL, 1, 'System'),
('GEN_005', N'طلب صيانة عامة', N'General Maintenance Request', N'طلب صيانة عامة', NULL, NULL, 3, 5, 1, NULL, 1, 'System'),
('GEN_006', N'تسريب مياه', N'Water Leak', N'تسريب مياه في المبنى', NULL, NULL, 1, 6, 1, NULL, 1, 'System'),
('GEN_007', N'مشكلة في المصعد', N'Elevator Issue', N'مشكلة في عمل المصعد', NULL, NULL, 1, 7, 1, NULL, 1, 'System'),
('GEN_008', N'مشكلة في الأبواب', N'Door Issue', N'مشكلة في الأبواب أو الأقفال', NULL, NULL, 2, 8, 1, NULL, 1, 'System'),
('GEN_009', N'مشكلة في النظافة', N'Cleaning Issue', N'مشكلة في نظافة المبنى أو الوحدة', NULL, NULL, 2, 9, 1, NULL, 1, 'System'),
('GEN_010', N'مشكلة في الأمن', N'Security Issue', N'مشكلة أمنية أو سرقة', NULL, NULL, 1, 10, 1, NULL, 1, 'System'),
('GEN_011', N'مشكلة في التلفزيون', N'TV/Cable Issue', N'مشكلة في التلفزيون أو البث', NULL, NULL, 3, 11, 1, NULL, 1, 'System'),
('GEN_012', N'استبدال مفروشات', N'Furniture Replacement', N'طلب استبدال المفروشات', NULL, NULL, 3, 12, 1, NULL, 1, 'System'),
('GEN_013', N'طلب إصلاح جهاز', N'Appliance Repair', N'طلب إصلاح جهاز منزلي', NULL, NULL, 3, 13, 1, NULL, 1, 'System'),
('GEN_014', N'مشكلة في السباكة', N'Plumbing Issue', N'مشكلة في السباكة أو الصرف الصحي', NULL, NULL, 2, 14, 1, NULL, 1, 'System'),
('GEN_015', N'آخر', N'Other', N'أي مشكلة أخرى', NULL, NULL, 3, 15, 1, NULL, 1, 'System');
