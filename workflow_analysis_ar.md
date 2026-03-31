# نظام التذاكر متعدد الأقسام - تحليل سير العمل

---

## 1. طبقات البنية المعمارية

```mermaid
graph TB
    subgraph P["طبقة العرض (خارج نطاق الإصدار الأول)"]
        UI[واجهة المستخدم / طبقة API]
    end

    subgraph R["طبقة نماذج القراءة"]
        V1[V_TicketFullDetails - تفاصيل التذكرة الكاملة]
        V2[V_TicketInboxByScope - صندوق الوارد حسب النطاق]
        V3[V_TicketCurrentSLA - SLA الحالي للتذكرة]
        DL1[TicketDL - إجراءات التذاكر]
        DL2[ServiceDL - إجراءات الخدمات]
        DL3[ArbitrationDL - إجراءات التحكيم]
        DL4[DashboardDL - إجراءات لوحة المعلومات]
    end

    subgraph B["طبقة منطق الأعمال"]
        SP1[TicketSP - إجراءات التذاكر]
        SP2[ArbitrationSP - إجراءات التحكيم]
        SP3[ClarificationSP - إجراءات التوضيح]
        SP4[QualityReviewSP - إجراءات مراجعة الجودة]
        SP5[ServiceSP - إجراءات الخدمات]
        SP6[TicketSLASP - إجراءات SLA للتذاكر]
    end

    subgraph D["طبقة نموذج البيانات"]
        subgraph M["الجداول الرئيسية"]
            MT1[Service - الخدمة]
            MT2[ServiceRoutingRule - قاعدة توجيه الخدمة]
            MT3[ServiceSLAPolicy - سياسة SLA للخدمة]
            MT4[ServiceCatalogSuggestion - اقتراح كتالوج الخدمة]
        end

        subgraph T["جداول المعاملات"]
            TT1[Ticket - التذكرة]
            TT2[ArbitrationCase - قضية التحكيم]
            TT3[ClarificationRequest - طلب التوضيح]
            TT4[QualityReview - مراجعة الجودة]
            TT5[TicketPauseSession - جلسة إيقاف التذكرة]
            TT6[TicketSLA - SLA التذكرة]
        end

        subgraph H["جداول التاريخ"]
            HT1[TicketHistory - تاريخ التذكرة]
            HT2[TicketSLAHistory - تاريخ SLA التذكرة]
            HT3[CatalogRoutingChangeLog - سجل تغيير توجيه الكتالوج]
        end

        subgraph L["جداول البحث"]
            L1[TicketStatus - حالة التذكرة]
            L2[TicketClass - فئة التذكرة]
            L3[Priority - الأولوية]
            L4[RequesterType - نوع الطالب]
            L5[PauseReason - سبب الإيقاف]
            L6[ArbitrationReason - سبب التحكيم]
            L7[ClarificationReason - سبب التوضيح]
            L8[QualityReviewResult - نتيجة مراجعة الجودة]
        end
    end

    subgraph E["أنظمة المؤسسة الموجودة"]
        EU1[User - المستخدم]
        EU2[Distributor - الموزع]
        EU3[UserDistributor - موزع المستخدم]
        EU4[Idara/Dept/Div/Section - الهيكل التنظيمي]
        EU5[DSDID Routing - توجيه DSDID]
        EU6[dbo.AuditLog - سجل التدقيق]
    end

    UI --> R
    R --> B
    B --> D
    B --> E
    D --> E

    style P fill:#e1f5ff
    style R fill:#fff4e1
    style B fill:#ffe1f5
    style D fill:#e1ffe1
    style E fill:#f0f0f0
```

---

## 2. تبعيات المواصفات

```mermaid
graph TB
    subgraph M0["<span style='color:black'المرحلة التمهيدية 0: المتطلبات الأساسية"]
        PREREQ[توثيق المخططات الموجودة<br/>تحديد آلة الحالة<br/>إنشاء بيانات الاختبار]
    end

    subgraph M1["المرحلة 1: طبقة الأساس"]
        S01[المواصفة 01<br/>أسس جداول البحث]
        S02[المواصفة 02<br/>كتالوج الخدمات]
        S03[المواصفة 03<br/>العمود الفقري للتذكرة الأساسية]
    end

    subgraph M2["المرحلة 2: طبقة التكليف"]
        S04[المواصفة 04<br/>التكليف وبدء العمل]
    end

    subgraph M3["المرحلة 3: معالجة الاستثناءات"]
        S05[المواصفة 05<br/>تدفق التوضيح]
        S06[المواصفة 06<br/>تدفق التحكيم]
    end

    subgraph M4["المرحلة 4: طبقة التبعيات"]
        S07[المواصفة 07<br/>تذاكر الأب والابن]
        S08[المواصفة 08<br/>الحظر وجلسات الإيقاف]
    end

    subgraph M5["المرحلة 5: طبقة الإنجاز"]
        S09[المواصفة 09<br/>محرك SLA]
        S10[المواصفة 10<br/>مراجعة الجودة]
        S11[المواصفة 11<br/>تعلم الكتالوج]
    end

    subgraph M6["المرحلة 6: طبقة الرؤية"]
        S12[المواصفة 12<br/>التقارير ولوحات المعلومات]
    end

    PREREQ --> S01
    S01 --> S02
    S01 --> S03
    S01 -.-> S12
    S02 --> S04
    S03 --> S04
    S04 --> S05
    S04 --> S06
    S05 --> S07
    S05 --> S08
    S06 --> S08
    S07 --> S09
    S08 --> S09
    S09 --> S10
    S09 --> S11
    S10 --> S12
    S11 --> S12

    style M0 fill:#fff0f0
    style M1 fill:#f0fff0
    style M2 fill:#f0f0ff
    style M3 fill:#fff0ff
    style M4 fill:#f0fff0
    style M5 fill:#f0f0ff
    style M6 fill:#fff0f0
```

---

## 3. ترتيب إنشاء الجداول

```mermaid
graph LR
    subgraph P1["المرحلة 1: جداول البحث (المواصفة 01)"]
        L1[TicketStatus - حالة التذكرة]
        L2[TicketClass - فئة التذكرة]
        L3[Priority - الأولوية]
        L4[RequesterType - نوع الطالب]
        L5[PauseReason - سبب الإيقاف]
        L6[ArbitrationReason - سبب التحكيم]
        L7[ClarificationReason - سبب التوضيح]
        L8[QualityReviewResult - نتيجة مراجعة الجودة]
    end

    subgraph P2["المرحلة 2: الجداول الرئيسية (المواصفة 02)"]
        M1[Service - الخدمة]
        M2[ServiceRoutingRule - قاعدة التوجيه]
        M3[ServiceSLAPolicy - سياسة SLA]
        M4[ServiceCatalogSuggestion - اقتراح الكتالوج]
    end

    subgraph P3["المرحلة 3: جداول المعاملات"]
        T1[Ticket - التذكرة<br/>المواصفة 03]
        T5[ClarificationRequest - طلب التوضيح<br/>المواصفة 05]
        T2[ArbitrationCase - قضية التحكيم<br/>المواصفة 06]
        T6[QualityReview - مراجعة الجودة<br/>المواصفة 10]
        T3[TicketPauseSession - جلسة الإيقاف<br/>المواصفة 08]
        T4[TicketSLA - SLA التذكرة<br/>المواصفة 09]
        T7[CatalogRoutingChangeLog - سجل التوجيه<br/>المواصفة 11]
    end

    subgraph P4["المرحلة 4: جداول التاريخ"]
        H1[TicketHistory - تاريخ التذكرة<br/>المواصفة 03]
        H2[TicketSLAHistory - تاريخ SLA<br/>المواصفة 09]
        H3[CatalogRoutingChangeLog - سجل التوجيه<br/>المواصفة 11]
    end

    P1 --> P2
    P2 --> P3
    P3 --> P4

    style P1 fill:#e1f5ff
    style P2 fill:#fff4e1
    style P3 fill:#ffe1f5
    style P4 fill:#e1ffe1
```

---

## 4. آلة حالة التذكرة (مستنتجة - تحتاج للتعريف)

```mermaid
stateDiagram-v2
    [*] --> New: INSERT_TICKET
    New --> Queue: ASSIGN_TICKET - تكليف التذكرة
    Queue --> InProgress: MOVE_TO_IN_PROGRESS - الانتقال للعمل
    InProgress --> OperationalResolved: RESOLVE_OPERATIONALLY - الحل التشغيلي
    InProgress --> Clarification: OPEN_CLARIFICATION - طلب توضيح
    InProgress --> Arbitration: OPEN_ARBITRATION - فتح التحكيم
    InProgress --> Paused: PAUSE_TICKET - إيقاف التذكرة
    Queue --> Rejected: REJECT_TO_SUPERVISOR - الرفض للمشرف
    Rejected --> Queue: REASSIGN - إعادة التكليف

    Clarification --> InProgress: RESPOND/RESUME - الرد/الاستئناف
    Arbitration --> Redirected: DECIDE_REDIRECT - قرار إعادة التوجيه
    Arbitration --> InProgress: DECIDE_OVERRULE - قرار الرفض
    Arbitration --> Cancelled: CANCEL_ARBITRATION - إلغاء التحكيم
    Redirected --> Queue

    Paused --> InProgress: RESUME_TICKET - استئناف التذكرة

    OperationalResolved --> QualityReview: OPEN_QUALITY_REVIEW - فتح مراجعة الجودة
    QualityReview --> FinallyClosed: APPROVE_FINAL_CLOSURE - الموافقة على الإغلاق النهائي
    QualityReview --> InProgress: RETURN_FOR_CORRECTION - إعادة للتصحيح
    QualityReview --> OperationalResolved: REJECT_CLOSURE - رفض الإغلاق

    FinallyClosed --> [*]

    note right of OperationalResolved
        جاهز لمراجعة الجودة
        لا يمكن إعادة فتحه بدون
        ترخيص خاص
    end note

    note right of Paused
        ساعة SLA متوقفة
        قد يتم حظر التذكرة الأب
    end note
```

---

## 5. تبعيات الإجراءات المخزنة

```mermaid
graph TB
    subgraph SPs["الإجراءات المخزنة"]
        TicketSP[TicketSP - إجراءات التذاكر]
        ServiceSP[ServiceSP - إجراءات الخدمات]
        ArbitrationSP[ArbitrationSP - إجراءات التحكيم]
        ClarificationSP[ClarificationSP - إجراءات التوضيح]
        QualityReviewSP[QualityReviewSP - إجراءات مراجعة الجودة]
        TicketSLASP[TicketSLASP - إجراءات SLA التذاكر]
    end

    subgraph Tables["تبعيات الجداول"]
        Lkp[جداول البحث<br/>المواصفة 01]
        Svc[جداول الخدمات<br/>المواصفة 02]
        Tkt[جدول التذاكر<br/>المواصفة 03]
    end

    TicketSP --> Lkp
    TicketSP --> Svc
    TicketSP --> Tkt

    ServiceSP --> Lkp

    ArbitrationSP --> Tkt
    ArbitrationSP --> Lkp

    ClarificationSP --> Tkt
    ClarificationSP --> Lkp

    QualityReviewSP --> Tkt
    QualityReviewSP --> Lkp

    TicketSLASP --> Svc
    TicketSLASP --> Lkp

    style SPs fill:#ffe1f5
    style Tables fill:#e1ffe1
```

---

## 6. تدفق تنفيذ المراحل

```mermaid
graph LR
    subgraph M0["المرحلة التمهيدية 0: المتطلبات الأساسية"]
        TASK0[توثيق المخططات<br/>تحديد آلة الحالة<br/>إنشاء بيانات الاختبار]
    end

    subgraph M1["المرحلة 1: الأساس"]
        TASK1[إنشاء جداول البحث<br/>بناء كتالوج الخدمات<br/>إنشاء التذكرة الأساسية]
        CHECK1[نقطة التحقق:<br/>يمكن إنشاء تذكرة؟]
    end

    subgraph M2["المرحلة 2: التكليف"]
        TASK2[معالجة الطابور<br/>تكليف المستخدم<br/>بدء العمل]
        CHECK2[نقطة التحقق:<br/>يمكن التكليف وبدء العمل؟]
    end

    subgraph M3["المرحلة 3: الاستثناءات"]
        TASK3[تدفق التوضيح<br/>تدفق التحكيم<br/>نزاعات النطاق]
        CHECK3[نقطة التحقق:<br/>يمكن معالجة الاستثناءات؟]
    end

    subgraph M4["المرحلة 4: التبعيات"]
        TASK4[تذاكر الأب والابن<br/>منطق الحظر<br/>جلسات الإيقاف]
        CHECK4[نقطة التحقق:<br/>يمكن نمذجة التبعيات؟]
    end

    subgraph M5["المرحلة 5: الإنجاز"]
        TASK5[محرك SLA<br/>مراجعة الجودة<br/>تعلم الكتالوج]
        CHECK5[نقطة التحقق:<br/>الدورة الكاملة تعمل؟]
    end

    subgraph M6["المرحلة 6: الرؤية"]
        TASK6[طرق عرض لوحة المعلومات<br/>إجراءات التقارير<br/>مقاييس القيادة]
        CHECK6[نقطة التحقق:<br/>النظام الكامل جاهز؟]
    end

    TASK0 --> TASK1 --> CHECK1
    CHECK1 --> TASK2 --> CHECK2
    CHECK2 --> TASK3 --> CHECK3
    CHECK3 --> TASK4 --> CHECK4
    CHECK4 --> TASK5 --> CHECK5
    CHECK5 --> TASK6 --> CHECK6

    style TASK0 fill:#fff0f0
    style TASK1 fill:#f0fff0
    style TASK2 fill:#f0f0ff
    style TASK3 fill:#fff0ff
    style TASK4 fill:#f0fff0
    style TASK5 fill:#f0f0ff
    style TASK6 fill:#fff0f0

    style CHECK1 fill:#ffd700
    style CHECK2 fill:#ffd700
    style CHECK3 fill:#ffd700
    style CHECK4 fill:#ffd700
    style CHECK5 fill:#ffd700
    style CHECK6 fill:#ffd700
```

---

## 7. ملخص الفجوات الحرجة

```mermaid
mindmap
  root((الفجوات الحرجة))
    تكامل المخططات
      G1 هيكل Distributor غير معرف
      G2 تنسيق JSON في AuditLog غير معرف
      G3 نمط التحقق من UserDistributor
      G1 موقع جدول هوية المقيم
    منطق الأعمال
      G4 وحدة وقت SLA (دقائق أم ساعات)
      G5 رموز وحالات التذكرة والانتقالات
      G6 منطق هوية مراجع الجودة
      G7 خوارزمية اختيار المحكم
      D5 شروط إعادة فتح التذكرة
    تصميم البيانات
      D1 حد عمق شجرة التذكرة
      D4 معالجة تداخل جلسات الإيقاف
      D6 مصادر اقتراح الخدمة
    التكامل
      I2 تبعيات الإشعارات
      I3 موقع تخزين المرفقات
      I4 نمط طبقة التفويض
    الاختبار
      T1 استراتيجية بيانات الاختبار
      T2 معايير الأداء
      T3 معالجة التزامن
```

---

## 8. مصفوفة التنفيذ حسب الأولوية

```mermaid
graph TB
    subgraph P0["الأولوية P0: الأساس الجوهري"]
        S01[المواصفة 01<br/>أسس جداول البحث]
        S02[المواصفة 02<br/>كتالوج الخدمات]
        S03[المواصفة 03<br/>العمود الفقري للتذكرة الأساسية]
    end

    subgraph P1["الأولوية P1: حالة الاستخدام الأساسية"]
        S04[المواصفة 04<br/>التكليف وبدء العمل]
    end

    subgraph P2["الأولوية P2: معالجة الاستثناءات"]
        S05[المواصفة 05<br/>تدفق التوضيح]
        S06[المواصفة 06<br/>تدفق التحكيم]
    end

    subgraph P3["الأولوية P3: تتبع الوقت"]
        S09[المواصفة 09<br/>محرك SLA]
    end

    subgraph P4["الأولوية P4: الميزات المتقدمة"]
        S07[المواصفة 07<br/>تذاكر الأب والابن]
        S08[المواصفة 08<br/>الحظر وجلسات الإيقاف]
    end

    subgraph P5["الأولوية P5: ميزات النضج"]
        S10[المواصفة 10<br/>مراجعة الجودة]
        S11[المواصفة 11<br/>تعلم الكتالوج]
    end

    subgraph P6["الأولوية P6: الرؤية"]
        S12[المواصفة 12<br/>التقارير ولوحات المعلومات]
    end

    P0 --> P1 --> P2 --> P3 --> P4 --> P5 --> P6

    style P0 fill:#ffcccc
    style P1 fill:#ffddcc
    style P2 fill:#ffeecc
    style P3 fill:#ffffcc
    style P4 fill:#ffffdd
    style P5 fill:#ffffee
    style P6 fill:#f0f0f0
```

---

## 9. تدفق البيانات: تذكرة بخدمة معروفة

```mermaid
sequenceDiagram
    participant R as الطالب
    participant UI as طبقة واجهة المستخدم
    participant SP as TicketSP
    participant T as جدول التذاكر
    participant S as جداول الخدمات
    participant H as تاريخ التذاكر
    participant A as سجل التدقيق

    R->>UI: اختيار الخدمة (مثلاً: إصلاح صنبور المياه)
    UI->>S: البحث عن قاعدة توجيه الخدمة
    S-->>UI: إرجاع TargetDSDID
    UI->>SP: INSERT_TICKET (مع ServiceID)
    SP->>SP: التحقق من نوع الطالب
    SP->>SP: الحصول على التوجيه الافتراضي
    SP->>SP: تهيئة rootTicketID_FK
    SP->>T: إدراج سجل التذكرة
    SP->>H: كتابة تاريخ الإنشاء
    SP->>A: كتابة إدخال JSON للتدقيق
    SP-->>UI: التذكرة تم إنشاؤها
    UI-->>R: تأكيد مع رقم التذكرة

    Note over R,A: التذكرة الآن في الطابور المناسب
```

---

## 10. تدفق البيانات: قضية التحكيم

```mermaid
sequenceDiagram
    participant U as مستخدم الوحدة
    participant S as المشرف
    participant A as ArbitratorSP
    participant AC as ArbitrationCase
    participant T as التذكرة
    participant H as تاريخ التذكرة

    U->>S: رفض التذكرة (نطاق خاطئ)
    S->>A: OPEN_ARBITRATION_CASE
    A->>AC: إدراج سجل القضية
    A->>T: تحديث حالة التذكرة
    A->>H: كتابة تاريخ التحكيم
    A-->>S: تم فتح القضية

    Note over A: المحكم يراجع...

    A->>A: DECIDE_REDIRECT
    A->>T: تحديث TargetDSDID_FK
    A->>T: تحديث QueueDistributorID_FK
    A->>AC: تحديث حالة القضية والقرار
    A->>H: كتابة تاريخ إعادة التوجيه
    A-->>S: تمت إعادة التوجيه لطابور جديد
```

---

## 11. تدفق حظر الأب والابن

```mermaid
graph LR
    subgraph Parent["التذكرة الأب"]
        P1[Ticket ID: 100]
        P2[الحالة: جاري العمل]
        P3[isParentBlocked: صحيح]
    end

    subgraph Child["التذكرة الابن"]
        C1[Ticket ID: 101]
        C2[parentTicketID_FK: 100]
        C3[الحالة: جاري العمل]
    end

    subgraph Pause["جلسة الإيقاف"]
        PS1[ticketID_FK: 100]
        PS2[pauseReason: تبعية]
        PS3[relatedChildTicketID_FK: 101]
    end

    P3 -.->|محظور بسبب| PS3
    PS3 -.->|في انتظار| C3

    C3 -->|مكتمل| Done[الابن مكتمل]
    Done -->|استئناف| Resume[الأب يستأنف]
    Resume --> P3b[isParentBlocked: خطأ]

    style Parent fill:#ffe1f5
    style Child fill:#e1f5ff
    style Pause fill:#fff4e1
    style Done fill:#e1ffe1
```

---

## 12: مرجع سريع - مخرجات المواصفات

```mermaid
graph TB
    subgraph Legend["الدليل"]
        LDB[مهام قاعدة البيانات]
        LSP[الإجراءات المخزنة]
        LV[طرق العرض / إجراءات القراءة]
        LUI[مهام واجهة المستخدم]
    end

    subgraph Spec01["المواصفة 01: أسس جداول البحث"]
        S01DB[8 جداول بحث<br/>برامج تشغيل البيانات الأولية]
        S01T[اختبارات التفرد]
    end

    subgraph Spec02["المواصفة 02: كتالوج الخدمات"]
        S02DB[4 جداول رئيسية]
        S02SP[ServiceSP - 8 إجراءات]
        S02R[V_ServiceFullDefinition<br/>ServiceDL]
        S02UI[5 شاشات إدارة]
    end

    subgraph Spec03["المواصفة 03: التذكرة الأساسية"]
        S03DB[Ticket + TicketHistory]
        S03SP[TicketSP - INSERT_TICKET]
        S03R[V_TicketFullDetails<br/>V_TicketLastAction<br/>TicketDL]
        S03UI[الإنشاء + التفاصيل + القائمة]
    end

    subgraph Spec04["المواصفة 04: التكليف"]
        S04SP[TicketSP - 4 إجراءات]
        S04R[ملحقات الطابور]
        S04UI[4 شاشات تكليف]
    end

    subgraph Spec05["المواصفة 05: التوضيح"]
        S05DB[ClarificationRequest]
        S05SP[ClarificationSP - 3 إجراءات]
        S05UI[شاشتا توضيح]
    end

    subgraph Spec06["المواصفة 06: التحكيم"]
        S06DB[ArbitrationCase]
        S06SP[ArbitrationSP - 4 إجراءات]
        S06R[ArbitrationDL]
        S06UI[شاشتا تحكيم]
    end

    subgraph Spec07["المواصفة 07: الأب والابن"]
        S07SP[TicketSP - CREATE_CHILD]
        S07R[ملحق تحميل الشجرة]
        S07UI[شاشتا أب وابن]
    end

    subgraph Spec08["المواصفة 08: الحظر"]
        S08DB[TicketPauseSession]
        S08SP[TicketSP - إجراءان]
        S08UI[3 شاشات إيقاف/استئناف]
    end

    subgraph Spec09["المواصفة 09: SLA"]
        S09DB[TicketSLA + History]
        S09SP[TicketSLASP]
        S09R[V_TicketCurrentSLA]
        S09UI[شارات SLA + القوائم]
    end

    subgraph Spec10["المواصفة 10: الجودة"]
        S10DB[QualityReview]
        S10SP[QualityReviewSP - 4 إجراءات]
        S10UI[3 شاشات جودة]
    end

    subgraph Spec11["المواصفة 11: التعلم"]
        S11DB[CatalogRoutingChangeLog]
        S11SP[ServiceSP - إجراءان]
        S11UI[3 شاشات تعلم]
    end

    subgraph Spec12["المواصفة 12: التقارير"]
        S12R[3 طرق عرض طابور<br/>DashboardDL]
        S12UI[4 شاشات لوحة معلومات]
    end

    style LDB fill:#e1ffe1
    style LSP fill:#ffe1f5
    style LV fill:#fff4e1
    style LUI fill:#e1f5ff
```

---

---

## الملخص التنفيذي

### الأهداف غير القابلة للتفاوض

| الرمز | الهدف | السبب |
|-------|-------|-------|
| O1 | نظام تذاكر يعتمد على قاعدة البيانات أولاً | جميع عمليات الكتابة عبر الإجراءات المخزنة |
| O2 | دعم مصادر طلبات متعددة | المقيمون/المستفيدون والمستخدمون الداخليون |
| O3 | التوجيه الهرمي عبر الهيكل التنظيمي | DSDID هو مصدر الحقيقة للتوجيه |
| O4 | فصل المشاكل التشغيلية في تدفقات مميزة | توجيه خاطئ، معلومات ناقصة، تبعيات |
| O5 | إغلاق على مرحلتين مع التحقق من الجودة | إغلاق تشغيلي ← إغلاق نهائي/تحقق |
| O6 | سجل تدقيق كامل | كل تغيير ذي معنى يجب أن يكون قابلاً للتتبع |
| O7 | علاقات تذاكر الأب والابن مع منطق الحظر | أب واحد فقط، مرجع جذر التذكرة إلزامي |
| O8 | تتبع SLA مع سلوك الإيقاف/الاستئناف | ساعات SLA تتوقف أثناء نوافذ الحظر الصحيحة |
| O9 | كتالوج الخدمات مع إمكانية التعلم | طلبات "أخرى" يمكن أن تتطور لخدمات رسمية |
| O10 | IdaraID_FK في معظم الجداول | للتصفية، التقارير، لوحات المعلومات |

### الفجوات الحرجة التي تتطلب الحل

| الفجوة | الوصف | التأثير |
|---------|-------|---------|
| G1 | هياكل المخطط الموجودة غير معرفة | لا يمكن إنشاء مفاتيح خارجية |
| G2 | سجل التدقيق غير معرف | لا يمكن تنفيذ تسجيل JSON |
| G3 | نمط التحقق من UserDistributor غير محدد | لا يمكن التحقق من أهلية التكليف |
| G4 | وحدة وقت SLA غامضة | دقائق أم ساعات؟ |
| G5 | رموز حالة التذكرة غير معرفة | ضرورية لمنطق آلة الحالة |
| G6 | هوية مراجع الجودة غير معرفة | من يجري المراجعة؟ |
| G7 | منطق اختيار المحكم غير معرف | كيف يتم تحديد المحكم؟ |
| G8 | سير عمل الموافقة على التذكرة الابن غير معرف | آلية الموافقة غير محددة |

---

*تم إنشاؤه من تحليل plan.md*
*آخر تحديث: 2026-03-31*
