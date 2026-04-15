# المهام: نظام تذاكر متعدد الإدارات مع كتالوج خدمات

**المدخلات**: مستندات التصميم من `plan.md`
**المتطلبات المسبقة**: `plan.md` (مطلوب)، `spec.md` (لم يتم إنشاؤه بعد — تُشتق قصص المستخدم من مواصفات القسم 19 في `plan.md`)

**الاختبارات**: تم تضمين مهام الاختبار وفقًا لاستراتيجية الاختبار في القسم 20 من `plan.md`.

**التنظيم**: تم تجميع المهام حسب قصة المستخدم (Spec 01–Spec 12 من القسم 19 في `plan.md`) لتمكين التنفيذ والاختبار المستقلين لكل قصة.

## التنسيق: `[ID] [P?] [Story] Description`

- **[P]**: يمكن تشغيلها بالتوازي (ملفات مختلفة، بلا تبعيات)
- **[Story]**: قصة المستخدم التي تنتمي إليها هذه المهمة (مثلًا US1، US2، US3)
- تضمين مسارات الملفات الدقيقة في الأوصاف

## اصطلاحات المسارات

- **جداول قاعدة البيانات**: `SmartFoundation.Database/Tickets/Tables/`
- **الإجراءات المخزنة لقاعدة البيانات**: `SmartFoundation.Database/Tickets/Stored Procedures/`
- **العروض (Views) في قاعدة البيانات**: `SmartFoundation.Database/Tickets/Views/`
- **نصوص البذر (Seed scripts)**: `SmartFoundation.Database/Tickets/Scripts/`
- **خدمات التطبيق**: `SmartFoundation.Application/Services/`
- **متحكمات MVC**: `SmartFoundation.Mvc/Controllers/Tickets/`
- **عروض MVC**: `SmartFoundation.Mvc/Views/Tickets/`

---

## المرحلة 1: الإعداد (البنية التحتية المشتركة)

**الهدف**: إنشاء المخطط `[Tickets]` وتجهيز بنية المجلدات لجميع كائنات قاعدة البيانات.

- [X] T001 إنشاء المخطط `[Tickets]` في `SmartFoundation.Database/Tickets/Scripts/CreateSchema.sql`
- [X] T002 [P] إنشاء بنية المجلدات تحت `SmartFoundation.Database/Tickets/` لـ Tables و Stored Procedures و Views و Functions و Scripts
- [X] T003 [P] إضافة مجلدات Tickets الجديدة إلى `SmartFoundation.Database/SmartFoundation.Database.sqlproj` ضمن `ItemGroup`
- [X] T004 [P] إنشاء بنية المجلدات تحت `SmartFoundation.Mvc/Controllers/Tickets/` للمتحكمات
- [X] T005 [P] إنشاء بنية المجلدات تحت `SmartFoundation.Mvc/Views/Tickets/` للعروض

---

## المرحلة 2: الأساسيات (متطلبات مسبقة مانعة)

**الهدف**: إنشاء جداول القيم المرجعية وبيانات البذر المطلوبة لجميع المواصفات اللاحقة. يجب أن تكتمل هذه المرحلة قبل بدء أي عمل على قصص المستخدم.

**⚠️ حرج**: لا يمكن بدء أي عمل على قصص المستخدم حتى تكتمل هذه المرحلة

- [X] T006 [P] إنشاء جدول القيم المرجعية `[Tickets].[TicketStatus]` في `SmartFoundation.Database/Tickets/Tables/TicketStatus.sql`
- [X] T007 [P] إنشاء جدول القيم المرجعية `[Tickets].[TicketClass]` في `SmartFoundation.Database/Tickets/Tables/TicketClass.sql`
- [X] T008 [P] إنشاء جدول القيم المرجعية `[Tickets].[Priority]` في `SmartFoundation.Database/Tickets/Tables/Priority.sql`
- [X] T009 [P] إنشاء جدول القيم المرجعية `[Tickets].[RequesterType]` في `SmartFoundation.Database/Tickets/Tables/RequesterType.sql`
- [X] T010 [P] إنشاء جدول القيم المرجعية `[Tickets].[PauseReason]` في `SmartFoundation.Database/Tickets/Tables/PauseReason.sql`
- [X] T011 [P] إنشاء جدول القيم المرجعية `[Tickets].[ArbitrationReason]` في `SmartFoundation.Database/Tickets/Tables/ArbitrationReason.sql`
- [X] T012 [P] إنشاء جدول القيم المرجعية `[Tickets].[ClarificationReason]` في `SmartFoundation.Database/Tickets/Tables/ClarificationReason.sql`
- [X] T013 [P] إنشاء جدول القيم المرجعية `[Tickets].[QualityReviewResult]` في `SmartFoundation.Database/Tickets/Tables/QualityReviewResult.sql`
- [X] T014 إنشاء نص بذر لجميع قيم القوائم المرجعية في `SmartFoundation.Database/Tickets/Scripts/SeedLookups.sql`
- [X] T015 إضافة جميع ملفات `.sql` الخاصة بجداول القيم المرجعية ونص البذر إلى `SmartFoundation.Database.sqlproj` ضمن `Build ItemGroup`
- [X] T016 التحقق من تفرد القيم المرجعية وسلامة بيانات البذر عبر اختبارات SQL أولية في `SmartFoundation.Database/Tickets/Scripts/TestLookups.sql`

**نقطة تحقق**: جميع جداول القيم المرجعية موجودة، وتم إدراج قيم البذر، والأكواد فريدة — الأساس جاهز لتنفيذ قصص المستخدم

---

## المرحلة 3: قصة المستخدم 1 — أسس كتالوج الخدمات (الأولوية: P1) 🎯 MVP

**الهدف**: تأسيس كتالوج الخدمات، وقواعد التوجيه، وسياسات SLA، وجداول اقتراحات الكتالوج بالإضافة إلى إجراءات الكتابة ونماذج القراءة الخاصة بها.

**اختبار مستقل**: يمكن إنشاء الخدمات/تحديثها/تعطيلها عبر `ServiceSP`؛ ويمكن إضافة قواعد التوجيه باستخدام `TargetDSDID_FK` صالح؛ ويمكن استرجاع سياسات SLA لكل خدمة وأولوية.

### بنية قاعدة البيانات لـ US1

- [X] T017 [P] [US1] إنشاء الجدول الرئيسي `[Tickets].[Service]` في `SmartFoundation.Database/Tickets/Tables/Service.sql`
- [X] T018 [P] [US1] إنشاء الجدول الرئيسي `[Tickets].[ServiceRoutingRule]` في `SmartFoundation.Database/Tickets/Tables/ServiceRoutingRule.sql`
- [X] T019 [P] [US1] إنشاء الجدول الرئيسي `[Tickets].[ServiceSLAPolicy]` في `SmartFoundation.Database/Tickets/Tables/ServiceSLAPolicy.sql`
- [X] T020 [P] [US1] إنشاء الجدول الرئيسي `[Tickets].[ServiceCatalogSuggestion]` في `SmartFoundation.Database/Tickets/Tables/ServiceCatalogSuggestion.sql`
- [X] T021 [US1] إضافة جميع ملفات جداول US1 إلى `SmartFoundation.Database.sqlproj` ضمن `Build ItemGroup`

### الإجراءات المخزنة لقاعدة البيانات لـ US1

- [X] T022 [US1] إنشاء `[Tickets].[ServiceSP]` مع الإجراءات `INSERT_SERVICE` و `UPDATE_SERVICE` و `DELETE_SERVICE` و `INSERT_ROUTING_RULE` و `CLOSE_ROUTING_RULE` و `UPSERT_SLA_POLICY` و `APPROVE_SERVICE_SUGGESTION` و `REJECT_SERVICE_SUGGESTION` في `SmartFoundation.Database/Tickets/Stored Procedures/ServiceSP.sql`
- [X] T023 [US1] تنفيذ إجراءات إدراج الخدمة/تحديثها/تعطيلها في `[Tickets].[ServiceSP]`
- [X] T024 [US1] تنفيذ إجراءات إدراج/إغلاق قاعدة التوجيه مع التحقق من `TargetDSDID_FK` والتأريخ الفعّال في `[Tickets].[ServiceSP]`
- [X] T025 [US1] تنفيذ إجراء upsert لسياسة SLA في `[Tickets].[ServiceSP]`
- [X] T026 [US1] تنفيذ إجراءات الموافقة على اقتراح الخدمة/رفضه في `[Tickets].[ServiceSP]`

### العروض ونماذج القراءة في قاعدة البيانات لـ US1

- [X] T027 [US1] إنشاء العرض `[Tickets].[V_ServiceFullDefinition]` في `SmartFoundation.Database/Tickets/Views/V_ServiceFullDefinition.sql`
- [X] T028 [US1] إنشاء الإجراء `[Tickets].[ServiceDL]` لعرض الكتالوج، واستعلام قواعد التوجيه، واستعلام سياسات SLA، ومراجعة الاقتراحات في `SmartFoundation.Database/Tickets/Stored Procedures/ServiceDL.sql`

### الاختبارات لـ US1

- [X] T029 [US1] اختبار CRUD للخدمة عبر `ServiceSP` في `SmartFoundation.Database/Tickets/Scripts/TestServiceSP.sql`
- [X] T030 [US1] اختبار إدراج/إغلاق قاعدة التوجيه والاستبدال التاريخي في `SmartFoundation.Database/Tickets/Scripts/TestServiceRoutingRule.sql`
- [X] T031 [US1] اختبار upsert لسياسة SLA واسترجاعها لكل خدمة+أولوية في `SmartFoundation.Database/Tickets/Scripts/TestServiceSLAPolicy.sql`

**نقطة تحقق**: أساس كتالوج الخدمات يعمل بالكامل — يمكن إدارة الخدمات وقواعد التوجيه وسياسات SLA كلها عبر الإجراءات المخزنة

---

## المرحلة 4: قصة المستخدم 2 — العمود الفقري الأساسي للتذكرة (الأولوية: P2)

**الهدف**: تمكين إنشاء التذاكر، وتخزين الحالة الحالية، وتسجيل السجل التاريخي، ونماذج القراءة الأساسية.

**اختبار مستقل**: يمكن إنشاء التذاكر للمقيم أو للمستخدم الداخلي؛ وتعمل تذاكر `Other` دون `ServiceID_FK`؛ ويتلقى `TicketHistory` أحداث الإنشاء؛ ويتم تعيين `rootTicketID_FK` بصورة صحيحة.

### بنية قاعدة البيانات لـ US2

- [X] T032 [P] [US2] إنشاء جدول المعاملات `[Tickets].[Ticket]` في `SmartFoundation.Database/Tickets/Tables/Ticket.sql`
- [X] T033 [P] [US2] إنشاء جدول السجل التاريخي `[Tickets].[TicketHistory]` في `SmartFoundation.Database/Tickets/Tables/TicketHistory.sql`
- [X] T034 [US2] إضافة ملفات جداول US2 إلى `SmartFoundation.Database.sqlproj` ضمن `Build ItemGroup`

### الإجراءات المخزنة لقاعدة البيانات لـ US2

- [X] T035 [US2] إنشاء `[Tickets].[TicketSP]` مع الإجراء `INSERT_TICKET` في `SmartFoundation.Database/Tickets/Stored Procedures/TicketSP.sql`
- [X] T036 [US2] تنفيذ التحقق من نوع مقدم الطلب (مقيم مقابل داخلي، مع الاستبعاد المتبادل) في `[Tickets].[TicketSP]` ضمن `INSERT_TICKET`
- [X] T037 [US2] تنفيذ منطق التهيئة لـ `rootTicketID_FK` في `[Tickets].[TicketSP]` ضمن `INSERT_TICKET`
- [X] T038 [US2] تنفيذ إدراج حدث الإنشاء في `TicketHistory` داخل معاملة `INSERT_TICKET` في `[Tickets].[TicketSP]`
- [X] T039 [US2] تنفيذ تسجيل التدقيق JSON إلى `dbo.AuditLog` داخل `INSERT_TICKET` في `[Tickets].[TicketSP]`

### العروض ونماذج القراءة في قاعدة البيانات لـ US2

- [X] T040 [US2] إنشاء العرض `[Tickets].[V_TicketFullDetails]` في `SmartFoundation.Database/Tickets/Views/V_TicketFullDetails.sql`
- [X] T041 [US2] إنشاء العرض `[Tickets].[V_TicketLastAction]` في `SmartFoundation.Database/Tickets/Views/V_TicketLastAction.sql`
- [X] T042 [US2] إنشاء الإجراء `[Tickets].[TicketDL]` لتفاصيل التذكرة وإجراءات القوائم الأساسية في `SmartFoundation.Database/Tickets/Stored Procedures/TicketDL.sql`

### الاختبارات لـ US2

- [X] T043 [US2] اختبار إنشاء التذكرة لنوع مقدم طلب مقيم في `SmartFoundation.Database/Tickets/Scripts/TestTicketCreation.sql`
- [X] T044 [US2] اختبار إنشاء التذكرة لنوع مقدم طلب مستخدم داخلي في `SmartFoundation.Database/Tickets/Scripts/TestTicketCreation.sql`
- [X] T045 [US2] اختبار إنشاء تذكرة `Other` دون `ServiceID_FK` في `SmartFoundation.Database/Tickets/Scripts/TestTicketCreation.sql`
- [X] T046 [US2] اختبار تسجيل حدث الإنشاء في `TicketHistory` في `SmartFoundation.Database/Tickets/Scripts/TestTicketHistory.sql`

**نقطة تحقق**: إنشاء التذكرة الأساسي يعمل — يمكن تخزين التذاكر، وتسجيل السجل التاريخي، والاستعلام عن التفاصيل الأساسية

---

## المرحلة 5: قصة المستخدم 3 — الإسناد وبدء العمل (الأولوية: P3)

**الهدف**: دعم معالجة الطوابير التنظيمية، والإسناد المباشر للتنفيذ، والرفض من قِبل المشرف.

**اختبار مستقل**: يمكن إسناد المستخدمين المؤهلين فقط ضمن النطاق المسموح؛ ويتم تسجيل تغييرات حالة التذكرة في السجل التاريخي؛ وتُرجع استعلامات صندوق الوارد التذاكر الصحيحة بحسب النطاق.

### الإجراءات المخزنة لقاعدة البيانات لـ US3

- [ ] T047 [US3] تنفيذ الإجراء `ASSIGN_TICKET` مع التحقق من أهلية `UserDistributor` في `[Tickets].[TicketSP]`
- [ ] T048 [US3] تنفيذ الإجراء `MOVE_TO_IN_PROGRESS` في `[Tickets].[TicketSP]`
- [ ] T049 [US3] تنفيذ الإجراء `REJECT_TO_SUPERVISOR` في `[Tickets].[TicketSP]`
- [ ] T050 [US3] تنفيذ إدخالات السجل التاريخي الخاصة بالإسناد وتغيير الحالة داخل كل إجراء في `[Tickets].[TicketSP]`

### نماذج القراءة في قاعدة البيانات لـ US3

- [ ] T051 [US3] توسيع `[Tickets].[TicketDL]` بقراءات نمط صندوق الوارد حسب الطابور الحالي والمُسند إليه في `SmartFoundation.Database/Tickets/Stored Procedures/TicketDL.sql`

### الاختبارات لـ US3

- [ ] T052 [US3] اختبار الإسناد مع نطاق `UserDistributor` صالح وغير صالح في `SmartFoundation.Database/Tickets/Scripts/TestAssignment.sql`
- [ ] T053 [US3] اختبار انتقال الحالة إلى in-progress وتسجيل السجل التاريخي في `SmartFoundation.Database/Tickets/Scripts/TestAssignment.sql`
- [ ] T054 [US3] اختبار إجراء reject-to-supervisor وتسجيل السجل التاريخي في `SmartFoundation.Database/Tickets/Scripts/TestAssignment.sql`
- [ ] T055 [US3] اختبار أن استعلام صندوق الوارد يعيد التذاكر الصحيحة حسب النطاق التنظيمي في `SmartFoundation.Database/Tickets/Scripts/TestAssignment.sql`

**نقطة تحقق**: تدفق الإسناد وبدء العمل يعمل — صندوق وارد الطابور، والإسناد، وانتقالات الحالة كلها تعمل

---

## المرحلة 6: قصة المستخدم 4 — تدفق الاستيضاح (الأولوية: P4)

**الهدف**: دعم معالجة المعلومات الناقصة بشكل منفصل عن نزاعات النطاق، مع التكامل مع جلسات الإيقاف.

**اختبار مستقل**: يمكن فتح الاستيضاح دون استخدام التحكيم؛ وتُحدِّث استجابة الاستيضاح تدفق التذكرة بشكل صحيح؛ ويفتح الاستيضاح المانع جلسة إيقاف صالحة.

### بنية قاعدة البيانات لـ US4

- [X] T056 [US4] إنشاء جدول المعاملات `[Tickets].[ClarificationRequest]` في `SmartFoundation.Database/Tickets/Tables/ClarificationRequest.sql`
- [X] T057 [US4] إضافة ملف جدول `ClarificationRequest` إلى `SmartFoundation.Database.sqlproj` ضمن `Build ItemGroup`

### الإجراءات المخزنة لقاعدة البيانات لـ US4

- [ ] T058 [US4] إنشاء `[Tickets].[ClarificationSP]` مع الإجراءات `OPEN_CLARIFICATION_REQUEST` و `RESPOND_TO_CLARIFICATION` و `CLOSE_CLARIFICATION_REQUEST` في `SmartFoundation.Database/Tickets/Stored Procedures/ClarificationSP.sql`
- [ ] T059 [US4] تنفيذ `OPEN_CLARIFICATION_REQUEST` مع سجل التذكرة وتسجيل التدقيق في `[Tickets].[ClarificationSP]`
- [ ] T060 [US4] تنفيذ `RESPOND_TO_CLARIFICATION` مع تحديث تدفق التذكرة في `[Tickets].[ClarificationSP]`
- [ ] T061 [US4] تنفيذ `CLOSE_CLARIFICATION_REQUEST` في `[Tickets].[ClarificationSP]`
- [ ] T062 [US4] تنفيذ إنشاء جلسة إيقاف عندما يمنع الاستيضاح التنفيذ في `[Tickets].[ClarificationSP]`

### الاختبارات لـ US4

- [ ] T063 [US4] اختبار فتح الاستيضاح دون تشغيل التحكيم في `SmartFoundation.Database/Tickets/Scripts/TestClarification.sql`
- [ ] T064 [US4] اختبار أن استجابة الاستيضاح تحدِّث تدفق التذكرة في `SmartFoundation.Database/Tickets/Scripts/TestClarification.sql`
- [ ] T065 [US4] اختبار أن الاستيضاح المانع ينشئ جلسة إيقاف صالحة في `SmartFoundation.Database/Tickets/Scripts/TestClarification.sql`

**نقطة تحقق**: يعمل تدفق الاستيضاح بشكل مستقل عن التحكيم — تتم معالجة المعلومات الناقصة بشكل صحيح مع تكامل الإيقاف

---

## المرحلة 7: قصة المستخدم 5 — تدفق التحكيم (الأولوية: P5)

**الهدف**: دعم نزاعات النطاق الخاطئ وإعادة التوجيه المنضبط عبر التحكيم.

**اختبار مستقل**: لا يمكن فتح النزاعات إلا عبر التدفق الإشرافي المسموح؛ وتحدّث قرارات التحكيم الطابور المستهدف والسجل التاريخي بشكل صحيح؛ ويمكن عرض عبء التحكيم حسب المستوى التنظيمي.

### بنية قاعدة البيانات لـ US5

- [X] T066 [US5] إنشاء جدول المعاملات `[Tickets].[ArbitrationCase]` في `SmartFoundation.Database/Tickets/Tables/ArbitrationCase.sql`
- [X] T067 [US5] إضافة ملف جدول `ArbitrationCase` إلى `SmartFoundation.Database.sqlproj` ضمن `Build ItemGroup`

### الإجراءات المخزنة لقاعدة البيانات لـ US5

- [ ] T068 [US5] إنشاء `[Tickets].[ArbitrationSP]` مع الإجراءات `OPEN_ARBITRATION_CASE` و `DECIDE_REDIRECT` و `DECIDE_OVERRULE` و `CANCEL_ARBITRATION_CASE` في `SmartFoundation.Database/Tickets/Stored Procedures/ArbitrationSP.sql`
- [ ] T069 [US5] تنفيذ `OPEN_ARBITRATION_CASE` مع التحقق من السلسلة الإشرافية في `[Tickets].[ArbitrationSP]`
- [ ] T070 [US5] تنفيذ `DECIDE_REDIRECT` مع تحديث الطابور المستهدف والسجل التاريخي في `[Tickets].[ArbitrationSP]`
- [ ] T071 [US5] تنفيذ `DECIDE_OVERRULE` في `[Tickets].[ArbitrationSP]`
- [ ] T072 [US5] تنفيذ `CANCEL_ARBITRATION_CASE` في `[Tickets].[ArbitrationSP]`
- [ ] T073 [US5] تنفيذ إدخالات السجل التاريخي المتعلقة بالتحكيم وتسجيل التدقيق في `[Tickets].[ArbitrationSP]`

### نماذج القراءة في قاعدة البيانات لـ US5

- [ ] T074 [US5] إنشاء الإجراء `[Tickets].[ArbitrationDL]` للنزاعات المفتوحة، وسجل النزاع، ومرشحي تصحيح التوجيه في `SmartFoundation.Database/Tickets/Stored Procedures/ArbitrationDL.sql`

### الاختبارات لـ US5

- [ ] T075 [US5] اختبار فتح حالة التحكيم عبر التدفق الإشرافي في `SmartFoundation.Database/Tickets/Scripts/TestArbitration.sql`
- [ ] T076 [US5] اختبار أن قرار إعادة التوجيه يحدّث الطابور المستهدف والسجل التاريخي في `SmartFoundation.Database/Tickets/Scripts/TestArbitration.sql`
- [ ] T077 [US5] اختبار قرارات overrule و cancel في `SmartFoundation.Database/Tickets/Scripts/TestArbitration.sql`
- [ ] T078 [US5] اختبار عرض عبء التحكيم حسب المستوى التنظيمي عبر `ArbitrationDL` في `SmartFoundation.Database/Tickets/Scripts/TestArbitration.sql`

**نقطة تحقق**: يكتمل تدفق التحكيم — تتم معالجة نزاعات النطاق مع التوجيه الإشرافي الصحيح وتتبع القرارات

---

## المرحلة 8: قصة المستخدم 6 — التذاكر الأب-الابن (الأولوية: P6)

**الهدف**: دعم أعمال فرعية تابعة بعلاقات تذاكر أب-ابن.

**اختبار مستقل**: ترث التذاكر الابنة التذكرة الجذرية الصحيحة؛ ويُحمَّل شجر الأب-الابن بشكل صحيح؛ ويُمنع إنشاء الابن عندما لا تكون متطلبات الموافقة مستوفاة.

### الإجراءات المخزنة لقاعدة البيانات لـ US6

- [ ] T079 [US6] تنفيذ الإجراء `CREATE_CHILD_TICKET` مع اشتراط موافقة المشرف في `[Tickets].[TicketSP]`
- [ ] T080 [US6] تنفيذ قواعد وراثة الجذر والأب (`rootTicketID_FK`، `parentTicketID_FK`) في `[Tickets].[TicketSP]`
- [ ] T081 [US6] تنفيذ التحقق من وجود أب واحد فقط للتذاكر الابنة في `[Tickets].[TicketSP]`
- [ ] T082 [US6] تنفيذ إدخال السجل التاريخي لإنشاء التذكرة الابنة في `[Tickets].[TicketSP]`

### نماذج القراءة في قاعدة البيانات لـ US6

- [ ] T083 [US6] توسيع `[Tickets].[TicketDL]` بإجراءات تحميل شجرة الأب/الابن في `SmartFoundation.Database/Tickets/Stored Procedures/TicketDL.sql`

### الاختبارات لـ US6

- [ ] T084 [US6] اختبار إنشاء التذكرة الابنة مع الوراثة الصحيحة للجذر والأب في `SmartFoundation.Database/Tickets/Scripts/TestParentChild.sql`
- [ ] T085 [US6] اختبار تحميل شجرة الأب-الابن عبر `TicketDL` في `SmartFoundation.Database/Tickets/Scripts/TestParentChild.sql`
- [ ] T086 [US6] اختبار منع إنشاء الابن دون موافقة المشرف في `SmartFoundation.Database/Tickets/Scripts/TestParentChild.sql`

**نقطة تحقق**: تعمل التذاكر الأب-الابن — تُنشأ التذاكر الابنة مع الوراثة الصحيحة، ويمكن الاستعلام عن الشجرة

---

## المرحلة 9: قصة المستخدم 7 — الحظر وجلسات الإيقاف (الأولوية: P7)

**الهدف**: دعم نوافذ إيقاف مضبوطة وحظر قائم على التبعيات للتذاكر الأب.

**اختبار مستقل**: تخزّن جلسات الإيقاف وقت البداية والنهاية بشكل صحيح؛ ويظهر سبب إيقاف التذكرة؛ وتُستأنف تذاكر الأب بشكل صحيح بعد فك الحظر الصحيح.

### بنية قاعدة البيانات لـ US7

- [X] T087 [US7] إنشاء جدول المعاملات `[Tickets].[TicketPauseSession]` في `SmartFoundation.Database/Tickets/Tables/TicketPauseSession.sql`
- [X] T088 [US7] إضافة ملف جدول `TicketPauseSession` إلى `SmartFoundation.Database.sqlproj` ضمن `Build ItemGroup`

### الإجراءات المخزنة لقاعدة البيانات لـ US7

- [ ] T089 [US7] تنفيذ الإجراء `PAUSE_TICKET` مع سبب الإيقاف وربط الكيان ذي الصلة في `[Tickets].[TicketSP]`
- [ ] T090 [US7] تنفيذ الإجراء `RESUME_TICKET` مع الطابع الزمني لنهاية الإيقاف في `[Tickets].[TicketSP]`
- [ ] T091 [US7] تنفيذ قواعد التحقق الخاصة بالإيقاف (سبب صالح، وعدم الإيقاف المزدوج) في `[Tickets].[TicketSP]`
- [ ] T092 [US7] تنفيذ حظر التذكرة الأب بسبب وجود تذاكر ابنة مفتوحة في `[Tickets].[TicketSP]`
- [ ] T093 [US7] تنفيذ إدخالات السجل التاريخي الخاصة بالإيقاف/الاستئناف في `[Tickets].[TicketSP]`

### الاختبارات لـ US7

- [ ] T094 [US7] اختبار إنشاء جلسة إيقاف مع الطابعين الزمنيَّين للبداية والنهاية في `SmartFoundation.Database/Tickets/Scripts/TestPauseSessions.sql`
- [ ] T095 [US7] اختبار ظهور سبب الإيقاف في تفاصيل التذكرة في `SmartFoundation.Database/Tickets/Scripts/TestPauseSessions.sql`
- [ ] T096 [US7] اختبار استئناف التذكرة الأب بعد اكتمال التذكرة الابنة في `SmartFoundation.Database/Tickets/Scripts/TestPauseSessions.sql`
- [ ] T097 [US7] اختبار منع الإغلاق النهائي للتذكرة الأب ما دامت التذاكر الابنة مفتوحة في `SmartFoundation.Database/Tickets/Scripts/TestPauseSessions.sql`

**نقطة تحقق**: يعمل الحظر وجلسات الإيقاف — الإيقاف/الاستئناف مضبوط، وحظر الأب مفروض

---

## المرحلة 10: قصة المستخدم 8 — محرك SLA (الأولوية: P8)

**الهدف**: دعم التهيئة والإيقاف والاستئناف وتتبع الاختراق لـ SLA لكل تذكرة.

**اختبار مستقل**: تُهيَّأ ساعات SLA بشكل صحيح؛ وتوقف حالات الحظر الصالحة تقدم SLA؛ ويستمر الحساب بشكل صحيح عند استئناف العمل؛ ويتم تخزين حالة الاختراق وإظهارها.

### بنية قاعدة البيانات لـ US8

- [X] T098 [P] [US8] إنشاء جدول المعاملات `[Tickets].[TicketSLA]` في `SmartFoundation.Database/Tickets/Tables/TicketSLA.sql`
- [X] T099 [P] [US8] إنشاء جدول السجل التاريخي `[Tickets].[TicketSLAHistory]` في `SmartFoundation.Database/Tickets/Tables/TicketSLAHistory.sql`
- [X] T100 [US8] إضافة ملفات جداول US8 إلى `SmartFoundation.Database.sqlproj` ضمن `Build ItemGroup`

### الإجراءات المخزنة لقاعدة البيانات لـ US8

- [ ] T101 [US8] تنفيذ تهيئة SLA من استعلام الخدمة + الأولوية في `[Tickets].[TicketSP]` (أو `[Tickets].[TicketSLASP]` إذا تم فصلها)
- [ ] T102 [US8] تنفيذ حساب إيقاف SLA المرتبط بـ `TicketPauseSession` ضمن منطق SLA
- [ ] T103 [US8] تنفيذ استئناف SLA وإعادة حساب الزمن المنقضي ضمن منطق SLA
- [ ] T104 [US8] تنفيذ منطق اكتشاف الاختراق مع تحديث مؤشر الاختراق ضمن منطق SLA

### العروض في قاعدة البيانات لـ US8

- [ ] T105 [US8] إنشاء العرض `[Tickets].[V_TicketCurrentSLA]` في `SmartFoundation.Database/Tickets/Views/V_TicketCurrentSLA.sql`

### الاختبارات لـ US8

- [ ] T106 [US8] اختبار تهيئة SLA من الخدمة + الأولوية في `SmartFoundation.Database/Tickets/Scripts/TestSLA.sql`
- [ ] T107 [US8] اختبار إيقاف SLA عند arbitration/clarification/dependency في `SmartFoundation.Database/Tickets/Scripts/TestSLA.sql`
- [ ] T108 [US8] اختبار استئناف SLA بعد إزالة التبعية في `SmartFoundation.Database/Tickets/Scripts/TestSLA.sql`
- [ ] T109 [US8] اختبار اكتشاف الاختراق وتخزين المؤشر في `SmartFoundation.Database/Tickets/Scripts/TestSLA.sql`
- [ ] T110 [US8] اختبار اكتمال SLA عند الإغلاق النهائي في `SmartFoundation.Database/Tickets/Scripts/TestSLA.sql`

**نقطة تحقق**: يكتمل محرك SLA — تتم تهيئة الساعات، وإيقافها، واستئنافها، وتتبع الاختراقات بشكل صحيح

---

## المرحلة 11: قصة المستخدم 9 — مراجعة الجودة والإغلاق النهائي (الأولوية: P9)

**الهدف**: دعم إغلاق على مرحلتين مع التحقق من الجودة قبل الإغلاق النهائي.

**اختبار مستقل**: يُمنع الإغلاق النهائي قبل الحل التشغيلي؛ وتحدِّث قرارات مراجعة الجودة التذكرة بشكل صحيح؛ وتعود التذاكر المُعادة إلى حالة العمل المناسبة.

### بنية قاعدة البيانات لـ US9

- [X] T111 [US9] إنشاء جدول المعاملات `[Tickets].[QualityReview]` في `SmartFoundation.Database/Tickets/Tables/QualityReview.sql`
- [X] T112 [US9] إضافة ملف جدول `QualityReview` إلى `SmartFoundation.Database.sqlproj` ضمن `Build ItemGroup`

### الإجراءات المخزنة لقاعدة البيانات لـ US9

- [ ] T113 [US9] تنفيذ الإجراء `RESOLVE_OPERATIONALLY` في `[Tickets].[TicketSP]`
- [ ] T114 [US9] تنفيذ الإجراء `CLOSE_TICKET` مع بوابة مراجعة الجودة في `[Tickets].[TicketSP]`
- [ ] T115 [US9] تنفيذ الإجراء `REOPEN_TICKET` في `[Tickets].[TicketSP]`
- [ ] T116 [US9] إنشاء `[Tickets].[QualityReviewSP]` مع الإجراءات `OPEN_QUALITY_REVIEW` و `APPROVE_FINAL_CLOSURE` و `RETURN_FOR_CORRECTION` و `REJECT_CLOSURE` في `SmartFoundation.Database/Tickets/Stored Procedures/QualityReviewSP.sql`
- [ ] T117 [US9] تنفيذ `OPEN_QUALITY_REVIEW` مع التحقق المسبق من الحل (BR-14) في `[Tickets].[QualityReviewSP]`
- [ ] T118 [US9] تنفيذ `APPROVE_FINAL_CLOSURE` مع تحديث الحالة النهائية في `[Tickets].[QualityReviewSP]`
- [ ] T119 [US9] تنفيذ `RETURN_FOR_CORRECTION` مع التراجع عن الحالة في `[Tickets].[QualityReviewSP]`
- [ ] T120 [US9] تنفيذ `REJECT_CLOSURE` في `[Tickets].[QualityReviewSP]`

### الاختبارات لـ US9

- [ ] T121 [US9] اختبار منع الإغلاق النهائي قبل الحل التشغيلي في `SmartFoundation.Database/Tickets/Scripts/TestQualityReview.sql`
- [ ] T122 [US9] اختبار أن موافقة مراجعة الجودة تحدّث التذكرة إلى final closed في `SmartFoundation.Database/Tickets/Scripts/TestQualityReview.sql`
- [ ] T123 [US9] اختبار أن return-for-correction يعيد التذكرة إلى حالة العمل في `SmartFoundation.Database/Tickets/Scripts/TestQualityReview.sql`
- [ ] T124 [US9] اختبار تدفق رفض الجودة في `SmartFoundation.Database/Tickets/Scripts/TestQualityReview.sql`

**نقطة تحقق**: يكتمل الإغلاق على مرحلتين — الحل التشغيلي منفصل عن الإغلاق النهائي الموثق بالجودة

---

## المرحلة 12: قصة المستخدم 10 — تعلم الكتالوج وتصحيح التوجيه (الأولوية: P10)

**الهدف**: السماح للحالات الواقعية المتكررة بتحسين كتالوج الخدمات بمرور الوقت.

**اختبار مستقل**: يمكن للاقتراحات المعتمدة إنشاء خدمات حقيقية؛ ولا تؤدي تصحيحات التوجيه إلى الكتابة فوق المساءلة التاريخية؛ ويمكن الاستعلام عن سجل تغيير التوجيه.

### بنية قاعدة البيانات لـ US10

- [X] T125 [US10] إنشاء جدول السجل التاريخي `[Tickets].[CatalogRoutingChangeLog]` في `SmartFoundation.Database/Tickets/Tables/CatalogRoutingChangeLog.sql`
- [X] T126 [US10] إضافة ملف جدول `CatalogRoutingChangeLog` إلى `SmartFoundation.Database.sqlproj` ضمن `Build ItemGroup`

### الإجراءات المخزنة لقاعدة البيانات لـ US10

- [ ] T127 [US10] تنفيذ تدفق الموافقة على اقتراح الخدمة (ينشئ خدمة حقيقية من الاقتراح) في `[Tickets].[ServiceSP]` ضمن `APPROVE_SERVICE_SUGGESTION`
- [ ] T128 [US10] تنفيذ تدفق رفض اقتراح الخدمة في `[Tickets].[ServiceSP]` ضمن `REJECT_SERVICE_SUGGESTION`
- [ ] T129 [US10] تنفيذ استبدال قاعدة التوجيه مع التأريخ الفعّال في `[Tickets].[ServiceSP]` ضمن `INSERT_ROUTING_RULE` / `CLOSE_ROUTING_RULE`
- [ ] T130 [US10] تنفيذ تسجيل تصحيح التوجيه المعتمد في `CatalogRoutingChangeLog` داخل `[Tickets].[ServiceSP]`

### الاختبارات لـ US10

- [ ] T131 [US10] اختبار أن الاقتراح المعتمد ينشئ خدمة كتالوج حقيقية في `SmartFoundation.Database/Tickets/Scripts/TestCatalogLearning.sql`
- [ ] T132 [US10] اختبار أن استبدال قاعدة التوجيه يحافظ على المساءلة التاريخية في `SmartFoundation.Database/Tickets/Scripts/TestCatalogLearning.sql`
- [ ] T133 [US10] اختبار إمكانية الاستعلام عن سجل تغيير التوجيه عبر `CatalogRoutingChangeLog` في `SmartFoundation.Database/Tickets/Scripts/TestCatalogLearning.sql`

**نقطة تحقق**: يعمل تعلم الكتالوج — تتحول الاقتراحات إلى خدمات، وتُسجَّل تصحيحات التوجيه تاريخيًا

---

## المرحلة 13: قصة المستخدم 11 — التقارير ولوحات المعلومات (الأولوية: P11)

**الهدف**: توفير نماذج قراءة للرؤية التشغيلية والقيادية.

**اختبار مستقل**: تُرجع استعلامات لوحة المعلومات الأعداد الصحيحة ضمن النطاق؛ وتطابق تقارير التأخير والاختراق بيانات الاختبار المتوقعة؛ ويمكن تصفية عروض القيادة حسب المستوى التنظيمي.

### العروض في قاعدة البيانات لـ US11

- [ ] T134 [P] [US11] إنشاء العرض `[Tickets].[V_TicketInboxByScope]` في `SmartFoundation.Database/Tickets/Views/V_TicketInboxByScope.sql`
- [ ] T135 [P] [US11] إنشاء العرض `[Tickets].[V_TicketArbitrationInbox]` في `SmartFoundation.Database/Tickets/Views/V_TicketArbitrationInbox.sql`
- [ ] T136 [P] [US11] إنشاء العرض `[Tickets].[V_TicketQualityInbox]` في `SmartFoundation.Database/Tickets/Views/V_TicketQualityInbox.sql`

### نماذج القراءة في قاعدة البيانات لـ US11

- [ ] T137 [US11] إنشاء الإجراء `[Tickets].[DashboardDL]` لأعداد الحالات، واختراقات SLA، وعبء التحكيم، وعبء الاستيضاح، وتكرار الخدمات، وقوائم التأخير في `SmartFoundation.Database/Tickets/Stored Procedures/DashboardDL.sql`

### الاختبارات لـ US11

- [ ] T138 [US11] اختبار أعداد لوحة المعلومات حسب الحالة والنطاق التنظيمي في `SmartFoundation.Database/Tickets/Scripts/TestDashboard.sql`
- [ ] T139 [US11] اختبار أن تقارير التأخير والاختراق تطابق بيانات الاختبار في `SmartFoundation.Database/Tickets/Scripts/TestDashboard.sql`
- [ ] T140 [US11] اختبار تقارير تكرار الخدمات في `SmartFoundation.Database/Tickets/Scripts/TestDashboard.sql`
- [ ] T141 [US11] اختبار ظهور صندوق الوارد حسب النطاق في `SmartFoundation.Database/Tickets/Scripts/TestDashboard.sql`

**نقطة تحقق**: تعمل التقارير ولوحات المعلومات — تُرجع جميع نماذج القراءة البيانات الصحيحة

---

## المرحلة 14: التحسينات النهائية والاهتمامات المشتركة

**الهدف**: التحقق من التكامل، والتوصيل النهائي، وفحوصات الجودة الشاملة.

- [X] T142 [P] إضافة جميع العروض والإجراءات المخزنة والدوال الجديدة إلى `SmartFoundation.Database.sqlproj` ضمن `Build ItemGroup`
- [ ] T143 تشغيل البناء الكامل للحل `dotnet build SmartFoundation.sln` ومعالجة أي أخطاء تجميع
- [ ] T144 [P] التحقق من توجيه جميع الإجراءات البوابية: إضافة إدخالات توجيه صفحات `Tickets` إلى `Masters_DataLoad.sql` و `Masters_CRUD.sql` إذا كان نمط البوابة مستخدمًا
- [ ] T145 [P] إنشاء اختبار تكامل شامل يغطي السيناريوهات A–D من القسم 12 في `plan.md` داخل `SmartFoundation.Database/Tickets/Scripts/TestIntegration.sql`
- [ ] T146 [P] التحقق من إدخالات `ProcedureMapper.cs` لأي إجراءات إدخال جديدة في `SmartFoundation.Application/Mapping/ProcedureMapper.cs`
- [ ] T147 تشغيل `dotnet test SmartFoundation.Application.Tests/SmartFoundation.Application.Tests.csproj` للتحقق من عدم وجود تراجعات

---

## التبعيات وترتيب التنفيذ

### تبعيات المراحل

- **الإعداد (المرحلة 1)**: بلا تبعيات — يمكن البدء فورًا
- **الأساسيات (المرحلة 2)**: تعتمد على المرحلة 1 — وتمنع جميع قصص المستخدم
- **US1 – كتالوج الخدمات (المرحلة 3)**: يعتمد على المرحلة 2 فقط
- **US2 – التذكرة الأساسية (المرحلة 4)**: يعتمد على المرحلة 2 + المرحلة 3 (يحتاج إلى Service والقيم المرجعية)
- **US3 – الإسناد (المرحلة 5)**: يعتمد على المرحلة 4 (يحتاج إلى جدول Ticket و `INSERT_TICKET`)
- **US4 – الاستيضاح (المرحلة 6)**: يعتمد على المرحلة 4 (يحتاج إلى Ticket)؛ وله اعتماد مرن على المرحلة 9 من أجل جلسات الإيقاف
- **US5 – التحكيم (المرحلة 7)**: يعتمد على المرحلة 4 (يحتاج إلى Ticket)
- **US6 – الأب-الابن (المرحلة 8)**: يعتمد على المرحلة 4 (يحتاج إلى Ticket و `INSERT_TICKET`)
- **US7 – جلسات الإيقاف (المرحلة 9)**: يعتمد على المرحلة 4 (يحتاج إلى Ticket)؛ ويتكامل مع المرحلة 8 (حظر الابن)
- **US8 – محرك SLA (المرحلة 10)**: يعتمد على المرحلة 3 (يحتاج إلى `ServiceSLAPolicy`) + المرحلة 9 (يحتاج إلى `TicketPauseSession` للإيقاف/الاستئناف)
- **US9 – مراجعة الجودة (المرحلة 11)**: يعتمد على المرحلة 4 (يحتاج إلى Ticket)؛ ويُكمل الإغلاق على مرحلتين
- **US10 – تعلم الكتالوج (المرحلة 12)**: يعتمد على المرحلة 3 (يحتاج إلى جداول Service و `ServiceSP`)
- **US11 – التقارير (المرحلة 13)**: يعتمد على المراحل 3–11 (يحتاج إلى جميع جداول المعاملات والعروض)
- **التحسينات النهائية (المرحلة 14)**: تعتمد على اكتمال جميع قصص المستخدم

### تبعيات قصص المستخدم

```
المرحلة 1 (الإعداد)
  └── المرحلة 2 (القيم المرجعية)
        ├── المرحلة 3 (US1: كتالوج الخدمات)
        │     ├── المرحلة 4 (US2: التذكرة الأساسية)
        │     │     ├── المرحلة 5 (US3: الإسناد)
        │     │     ├── المرحلة 6 (US4: الاستيضاح) ──┐
        │     │     ├── المرحلة 7 (US5: التحكيم)     │
        │     │     └── المرحلة 8 (US6: الأب-الابن)   │
        │     │           └── المرحلة 9 (US7: الإيقاف) ────┘
        │     │                 └── المرحلة 10 (US8: SLA)
        │     └── المرحلة 12 (US10: تعلم الكتالوج)
        └── (تتقارب جميع المسارات)
              └── المرحلة 13 (US11: التقارير)
                    └── المرحلة 14 (التحسينات النهائية)
```

### فرص التنفيذ المتوازي داخل المراحل

- **المرحلة 1**: يمكن تنفيذ جميع مهام إنشاء المجلدات (T002–T005) بالتوازي
- **المرحلة 2**: يمكن تنفيذ جميع مهام إنشاء جداول القيم المرجعية (T006–T013) بالتوازي
- **المرحلة 3**: يمكن تنفيذ جميع مهام إنشاء الجداول (T017–T020) بالتوازي
- **المراحل 7–9**: يمكن تطوير الاستيضاح (المرحلة 6)، والتحكيم (المرحلة 7)، والأب-الابن (المرحلة 8) بالتوازي بعد اكتمال المرحلة 4
- **المرحلة 10**: يمكن تنفيذ مهام إنشاء جداول SLA (T098–T099) بالتوازي
- **المرحلة 13**: يمكن تنفيذ جميع مهام إنشاء العروض (T134–T136) بالتوازي
- **المرحلة 14**: يمكن تنفيذ اختبار التكامل، و `ProcedureMapper`، وتوجيه البوابة بالتوازي

---

## مثال على التنفيذ المتوازي: المرحلة 2 (القيم المرجعية)

```text
T006: إنشاء lookup لـ TicketStatus    في SmartFoundation.Database/Tickets/Tables/TicketStatus.sql
T007: إنشاء lookup لـ TicketClass     في SmartFoundation.Database/Tickets/Tables/TicketClass.sql
T008: إنشاء lookup لـ Priority        في SmartFoundation.Database/Tickets/Tables/Priority.sql
T009: إنشاء lookup لـ RequesterType   في SmartFoundation.Database/Tickets/Tables/RequesterType.sql
T010: إنشاء lookup لـ PauseReason     في SmartFoundation.Database/Tickets/Tables/PauseReason.sql
T011: إنشاء lookup لـ ArbitrationReason في SmartFoundation.Database/Tickets/Tables/ArbitrationReason.sql
T012: إنشاء lookup لـ ClarificationReason في SmartFoundation.Database/Tickets/Tables/ClarificationReason.sql
T013: إنشاء lookup لـ QualityReviewResult في SmartFoundation.Database/Tickets/Tables/QualityReviewResult.sql
```

## مثال على التنفيذ المتوازي: المراحل 6–8 (الاستيضاح / التحكيم / الأب-الابن)

```text
# بعد اكتمال المرحلة 5، يمكن تطوير هذه المواصفات الثلاث بالتوازي:
المرحلة 6 (US4: الاستيضاح) — T056–T065
المرحلة 7 (US5: التحكيم)   — T066–T078
المرحلة 8 (US6: الأب-الابن)  — T079–T086
```

---

## استراتيجية التنفيذ

### MVP أولًا (US1 + US2 + US3 فقط)

1. إكمال المرحلة 1: الإعداد
2. إكمال المرحلة 2: الأساسيات (القيم المرجعية)
3. إكمال المرحلة 3: US1 (كتالوج الخدمات)
4. إكمال المرحلة 4: US2 (العمود الفقري الأساسي للتذكرة)
5. إكمال المرحلة 5: US3 (الإسناد وبدء العمل)
6. **توقف وحقّق**: اختبر إنشاء التذكرة، والتوجيه، والإسناد من البداية إلى النهاية
7. انشر/اعرض توضيحيًا إذا أصبح جاهزًا

### التسليم التدريجي

1. الإعداد + القيم المرجعية → الأساس جاهز
2. إضافة US1 (كتالوج الخدمات) → اختبار مستقل
3. إضافة US2 (التذكرة الأساسية) → اختبار مستقل
4. إضافة US3 (الإسناد) → اختبار مستقل → **MVP Deploy**
5. إضافة US4 + US5 بالتوازي (الاستيضاح + التحكيم) → اختبار
6. إضافة US6 + US7 بالتوازي (الأب-الابن + الإيقاف) → اختبار
7. إضافة US8 (SLA) → اختبار
8. إضافة US9 (مراجعة الجودة) → اختبار → **Full Lifecycle Deploy**
9. إضافة US10 (تعلم الكتالوج) → اختبار
10. إضافة US11 (التقارير) → اختبار → **Full Feature Deploy**
11. التحسينات النهائية والتكامل → تحقق نهائي

---

## ملاحظات

- المهام [P] = ملفات مختلفة، بلا تبعيات
- وسم [Story] يربط المهمة بقصة مستخدم محددة لسهولة التتبع
- يجب أن تكون كل قصة مستخدم قابلة للإكمال والاختبار بشكل مستقل
- تم فصل مهام بنية قاعدة البيانات عن مهام الإجراءات المخزنة وفقًا للقسم 11.3 من `plan.md`
- تم فصل مهام الإجراءات المخزنة عن مهام العروض/DL وفقًا للقسم 11.3 من `plan.md`
- مهام واجهة المستخدم غير مُدرجة في قائمة المهام هذه وفقًا لنطاق القسم 4.1 من `plan.md` ("تصميم قاعدة البيانات فقط") — يجب توليد مهام واجهة المستخدم بشكل منفصل بعد استقرار عقود قاعدة البيانات
- يجب أن تتبع جميع إجراءات الكتابة التحكم في المعاملات، و `THROW` لأخطاء الأعمال، وتدقيق JSON إلى `dbo.AuditLog`، وإدراج السجل التاريخي وفقًا للقسم 16.3 من `plan.md`
- حافظ على نمط البوابة الحالي الخاص بـ Housing (`Masters_DataLoad` / `Masters_CRUD` routing) عند توصيل صفحات Tickets
- نفّذ commit بعد كل مهمة أو مجموعة منطقية؛ وتحقق من نقطة التحقق الخاصة بكل مواصفة قبل المتابعة
