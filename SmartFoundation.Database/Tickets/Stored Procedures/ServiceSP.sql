CREATE PROCEDURE [Tickets].[ServiceSP]
(
      @Action                      NVARCHAR(200)
    , @serviceID                   BIGINT          = NULL
    , @serviceCode                 NVARCHAR(100)   = NULL
    , @serviceName_A               NVARCHAR(500)   = NULL
    , @serviceName_E               NVARCHAR(500)   = NULL
    , @serviceDesc                 NVARCHAR(2000)  = NULL
    , @idaraID_FK                  INT             = NULL
    , @ticketClassID_FK            INT             = NULL
    , @defaultPriorityID_FK        INT             = NULL
    , @requiresLocation            BIT             = NULL
    , @allowsChildTickets          BIT             = NULL
    , @requiresQualityReview       BIT             = NULL
    , @targetDSDID_FK              INT             = NULL
    , @queueDistributorID_FK       INT             = NULL
    , @changeReason                NVARCHAR(1000)  = NULL
    , @approvedByUserID            INT             = NULL
    , @serviceSLAPolicyID          BIGINT          = NULL
    , @priorityID_FK               INT             = NULL
    , @firstResponseTargetMinutes  INT             = NULL
    , @assignmentTargetMinutes     INT             = NULL
    , @operationalCompletionTargetMinutes INT       = NULL
    , @finalClosureTargetMinutes   INT             = NULL
    , @serviceCatalogSuggestionID  BIGINT          = NULL
    , @proposedServiceName_A       NVARCHAR(500)   = NULL
    , @proposedServiceName_E       NVARCHAR(500)   = NULL
    , @proposedServiceDesc_A       NVARCHAR(2000)  = NULL
    , @proposedServiceDesc         NVARCHAR(2000)  = NULL
    , @proposedTargetDSDID_FK      INT             = NULL
    , @proposedPriorityID_FK       INT             = NULL
    , @approvalNotes_A             NVARCHAR(2000)  = NULL
    , @approvalNotes               NVARCHAR(2000)  = NULL
    , @effectiveFrom               DATETIME        = NULL
    , @entryData                   NVARCHAR (20)   = NULL
    , @hostName                    NVARCHAR (200)  = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tc INT = @@TRANCOUNT;
    DECLARE @NewID BIGINT = NULL;
    DECLARE @Note NVARCHAR(MAX) = NULL;

    BEGIN TRY
        IF @tc = 0 BEGIN TRAN;

        IF NULLIF(LTRIM(RTRIM(@Action)), N'') IS NULL
        BEGIN ;THROW 50001, N'نوع الإجراء مطلوب', 1; END

        ----------------------------------------------------------------
        -- INSERT_SERVICE
        ----------------------------------------------------------------
        IF @Action = N'INSERT_SERVICE'
        BEGIN
            IF NULLIF(LTRIM(RTRIM(@serviceName_A)), N'') IS NULL
            BEGIN ;THROW 50001, N'اسم الخدمة بالعربية مطلوب', 1; END

            IF @idaraID_FK IS NULL
            BEGIN ;THROW 50001, N'معرف الإدارة مطلوب', 1; END

            IF EXISTS (
                SELECT 1 FROM [Tickets].[Service]
                WHERE [serviceName_A] = @serviceName_A
                  AND [serviceActive] = 1
                  AND [idaraID_FK] = @idaraID_FK
            )
            BEGIN ;THROW 50001, N'توجد خدمة بنفس الاسم العربي لهذه الإدارة مسبقاً', 1; END

            INSERT INTO [Tickets].[Service]
            (
                  [serviceCode], [serviceName_A], [serviceName_E], [serviceDesc]
                , [idaraID_FK], [ticketClassID_FK], [defaultPriorityID_FK]
                , [requiresLocation], [allowsChildTickets], [requiresQualityReview]
                , [serviceActive], [entryData], [hostName]
            )
            VALUES
            (
                  @serviceCode, @serviceName_A, @serviceName_E, @serviceDesc
                , @idaraID_FK, @ticketClassID_FK, @defaultPriorityID_FK
                , ISNULL(@requiresLocation, 0), ISNULL(@allowsChildTickets, 0), ISNULL(@requiresQualityReview, 0)
                , 1, @entryData, @hostName
            );

            SET @NewID = SCOPE_IDENTITY();
            IF @NewID IS NULL OR @NewID <= 0
            BEGIN ;THROW 50002, N'فشل إنشاء الخدمة بسبب خطأ في توليد المعرف', 1; END

            SET @Note = N'{"serviceID":"' + CAST(@NewID AS NVARCHAR(20))
                + N'","serviceCode":"' + ISNULL(@serviceCode, N'')
                + N'","serviceName_A":"' + ISNULL(@serviceName_A, N'') + N'"}';

            INSERT INTO dbo.AuditLog (TableName, ActionType, RecordID, PerformedBy, Notes)
            VALUES (N'[Tickets].[Service]', N'INSERT_SERVICE', @NewID, @entryData, @Note);

            SELECT 1 AS IsSuccessful, N'تم إنشاء الخدمة بنجاح' AS Message_;
            RETURN;
        END

        ----------------------------------------------------------------
        -- UPDATE_SERVICE
        ----------------------------------------------------------------
        ELSE IF @Action = N'UPDATE_SERVICE'
        BEGIN
            IF @serviceID IS NULL
            BEGIN ;THROW 50001, N'معرف الخدمة مطلوب للتحديث', 1; END

            IF NOT EXISTS (SELECT 1 FROM [Tickets].[Service] WHERE [serviceID] = @serviceID AND [serviceActive] = 1)
            BEGIN ;THROW 50001, N'لم يتم العثور على الخدمة أو أنها غير نشطة', 1; END

            UPDATE [Tickets].[Service]
            SET
                  [serviceCode]           = ISNULL(@serviceCode, [serviceCode])
                , [serviceName_A]         = ISNULL(@serviceName_A, [serviceName_A])
                , [serviceName_E]         = ISNULL(@serviceName_E, [serviceName_E])
                , [serviceDesc]           = ISNULL(@serviceDesc, [serviceDesc])
                , [ticketClassID_FK]      = ISNULL(@ticketClassID_FK, [ticketClassID_FK])
                , [defaultPriorityID_FK]  = ISNULL(@defaultPriorityID_FK, [defaultPriorityID_FK])
                , [requiresLocation]      = ISNULL(@requiresLocation, [requiresLocation])
                , [allowsChildTickets]    = ISNULL(@allowsChildTickets, [allowsChildTickets])
                , [requiresQualityReview] = ISNULL(@requiresQualityReview, [requiresQualityReview])
                                , [entryData] = @entryData
                                , [hostName]  = @hostName
            WHERE [serviceID] = @serviceID;

            IF @@ROWCOUNT = 0
            BEGIN ;THROW 50002, N'لم يتم تحديث أي صفوف', 1; END

            SET @Note = N'{"serviceID":"' + CAST(@serviceID AS NVARCHAR(20)) + N'"}';

            INSERT INTO dbo.AuditLog (TableName, ActionType, RecordID, PerformedBy, Notes)
            VALUES (N'[Tickets].[Service]', N'UPDATE_SERVICE', @serviceID, @entryData, @Note);

            SELECT 1 AS IsSuccessful, N'تم تحديث الخدمة بنجاح' AS Message_;
            RETURN;
        END

        ----------------------------------------------------------------
        -- DELETE_SERVICE (soft delete)
        ----------------------------------------------------------------
        ELSE IF @Action = N'DELETE_SERVICE'
        BEGIN
            IF @serviceID IS NULL
            BEGIN ;THROW 50001, N'معرف الخدمة مطلوب للحذف', 1; END

            IF NOT EXISTS (SELECT 1 FROM [Tickets].[Service] WHERE [serviceID] = @serviceID AND [serviceActive] = 1)
            BEGIN ;THROW 50001, N'لم يتم العثور على الخدمة أو أنها غير نشطة مسبقاً', 1; END

            UPDATE [Tickets].[Service]
            SET [serviceActive] = 0
                            , [entryData] = @entryData
                            , [hostName]  = @hostName
            WHERE [serviceID] = @serviceID;

            IF @@ROWCOUNT = 0
            BEGIN ;THROW 50002, N'لم يتم حذف أي صفوف', 1; END

            SET @Note = N'{"serviceID":"' + CAST(@serviceID AS NVARCHAR(20)) + N'"}';

            INSERT INTO dbo.AuditLog (TableName, ActionType, RecordID, PerformedBy, Notes)
            VALUES (N'[Tickets].[Service]', N'DELETE_SERVICE', @serviceID, @entryData, @Note);

            SELECT 1 AS IsSuccessful, N'تم تعطيل الخدمة بنجاح' AS Message_;
            RETURN;
        END

        ----------------------------------------------------------------
        -- INSERT_ROUTING_RULE
        ----------------------------------------------------------------
        ELSE IF @Action = N'INSERT_ROUTING_RULE'
        BEGIN
            IF @serviceID IS NULL
            BEGIN ;THROW 50001, N'معرف الخدمة مطلوب لقاعدة التوجيه', 1; END

            IF @targetDSDID_FK IS NULL
            BEGIN ;THROW 50001, N'معرف الجهة المستهدفة مطلوب لقاعدة التوجيه', 1; END

            IF @idaraID_FK IS NULL
            BEGIN ;THROW 50001, N'معرف الإدارة مطلوب لقاعدة التوجيه', 1; END

            IF NOT EXISTS (SELECT 1 FROM [Tickets].[Service] WHERE [serviceID] = @serviceID AND [serviceActive] = 1)
            BEGIN ;THROW 50001, N'لم يتم العثور على خدمة نشطة', 1; END

                        IF NOT EXISTS (
                                SELECT 1
                                FROM dbo.[V_GetFullStructureForDSD]
                                WHERE [DSDID] = @targetDSDID_FK
                                    AND [IdaraID] = @idaraID_FK
                        )
                        BEGIN ;THROW 50001, N'الجهة المستهدفة غير صالحة لهذه الإدارة', 1; END

            DECLARE @EffFrom DATETIME = ISNULL(@effectiveFrom, GETDATE());

                        UPDATE [Tickets].[ServiceRoutingRule]
                        SET [effectiveTo] = CASE
                                                                        WHEN [effectiveFrom] < @EffFrom THEN DATEADD(SECOND, -1, @EffFrom)
                                                                        ELSE @EffFrom
                                                                END
                            , [serviceRoutingRuleActive] = 0
                            , [entryData] = @entryData
                            , [hostName]  = @hostName
                        WHERE [serviceID_FK] = @serviceID
                            AND [serviceRoutingRuleActive] = 1
                            AND [effectiveFrom] <= @EffFrom
                            AND ([effectiveTo] IS NULL OR [effectiveTo] >= @EffFrom);

            INSERT INTO [Tickets].[ServiceRoutingRule]
            (
                  [serviceID_FK], [idaraID_FK], [targetDSDID_FK], [queueDistributorID_FK]
                , [effectiveFrom], [changeReason], [approvedByUserID]
                , [serviceRoutingRuleActive], [entryData], [hostName]
            )
            VALUES
            (
                  @serviceID, @idaraID_FK, @targetDSDID_FK, @queueDistributorID_FK
                , @EffFrom, @changeReason, @approvedByUserID
                , 1, @entryData, @hostName
            );

            SET @NewID = SCOPE_IDENTITY();
            IF @NewID IS NULL OR @NewID <= 0
            BEGIN ;THROW 50002, N'فشل إنشاء قاعدة التوجيه', 1; END

            SET @Note = N'{"serviceRoutingRuleID":"' + CAST(@NewID AS NVARCHAR(20))
                + N'","serviceID":"' + CAST(@serviceID AS NVARCHAR(20))
                + N'","targetDSDID_FK":"' + CAST(@targetDSDID_FK AS NVARCHAR(20)) + N'"}';

            INSERT INTO dbo.AuditLog (TableName, ActionType, RecordID, PerformedBy, Notes)
            VALUES (N'[Tickets].[ServiceRoutingRule]', N'INSERT_ROUTING_RULE', @NewID, @entryData, @Note);

            SELECT 1 AS IsSuccessful, N'تم إنشاء قاعدة التوجيه بنجاح' AS Message_;
            RETURN;
        END

        ----------------------------------------------------------------
        -- CLOSE_ROUTING_RULE
        ----------------------------------------------------------------
        ELSE IF @Action = N'CLOSE_ROUTING_RULE'
        BEGIN
            DECLARE @RuleID BIGINT = @serviceID;

            IF @RuleID IS NULL
            BEGIN ;THROW 50001, N'معرف قاعدة توجيه الخدمة (الممرر كـ @serviceID) مطلوب', 1; END

            IF NOT EXISTS (SELECT 1 FROM [Tickets].[ServiceRoutingRule] WHERE [serviceRoutingRuleID] = @RuleID AND [serviceRoutingRuleActive] = 1)
            BEGIN ;THROW 50001, N'لم يتم العثور على قاعدة توجيه نشطة', 1; END

            UPDATE [Tickets].[ServiceRoutingRule]
            SET [effectiveTo] = GETDATE()
              , [serviceRoutingRuleActive] = 0
                            , [entryData] = @entryData
                            , [hostName]  = @hostName
            WHERE [serviceRoutingRuleID] = @RuleID;

            IF @@ROWCOUNT = 0
            BEGIN ;THROW 50002, N'لم يتم إغلاق أي قاعدة توجيه', 1; END

            SET @Note = N'{"serviceRoutingRuleID":"' + CAST(@RuleID AS NVARCHAR(20)) + N'"}';

            INSERT INTO dbo.AuditLog (TableName, ActionType, RecordID, PerformedBy, Notes)
            VALUES (N'[Tickets].[ServiceRoutingRule]', N'CLOSE_ROUTING_RULE', @RuleID, @entryData, @Note);

            SELECT 1 AS IsSuccessful, N'تم إغلاق قاعدة التوجيه بنجاح' AS Message_;
            RETURN;
        END

        ----------------------------------------------------------------
        -- UPSERT_SLA_POLICY
        ----------------------------------------------------------------
        ELSE IF @Action = N'UPSERT_SLA_POLICY'
        BEGIN
            IF @serviceID IS NULL
            BEGIN ;THROW 50001, N'معرف الخدمة مطلوب لسياسة SLA', 1; END

            IF @priorityID_FK IS NULL
            BEGIN ;THROW 50001, N'معرف الأولوية مطلوب لسياسة SLA', 1; END

            IF @idaraID_FK IS NULL
            BEGIN ;THROW 50001, N'معرف الإدارة مطلوب لسياسة SLA', 1; END

            IF EXISTS (
                SELECT 1 FROM [Tickets].[ServiceSLAPolicy]
                WHERE [serviceID_FK] = @serviceID
                  AND [priorityID_FK] = @priorityID_FK
                  AND [idaraID_FK] = @idaraID_FK
                  AND [slaPolicyActive] = 1
            )
            BEGIN
                UPDATE [Tickets].[ServiceSLAPolicy]
                SET
                      [firstResponseTargetMinutes]         = ISNULL(@firstResponseTargetMinutes, [firstResponseTargetMinutes])
                    , [assignmentTargetMinutes]            = ISNULL(@assignmentTargetMinutes, [assignmentTargetMinutes])
                    , [operationalCompletionTargetMinutes] = ISNULL(@operationalCompletionTargetMinutes, [operationalCompletionTargetMinutes])
                    , [finalClosureTargetMinutes]          = ISNULL(@finalClosureTargetMinutes, [finalClosureTargetMinutes])
                                        , [entryData] = @entryData
                                        , [hostName]  = @hostName
                WHERE [serviceID_FK] = @serviceID
                  AND [priorityID_FK] = @priorityID_FK
                  AND [idaraID_FK] = @idaraID_FK
                  AND [slaPolicyActive] = 1;

                SET @Note = N'{"action":"UPDATED","serviceID":"' + CAST(@serviceID AS NVARCHAR(20))
                    + N'","priorityID_FK":"' + CAST(@priorityID_FK AS NVARCHAR(20)) + N'"}';

                INSERT INTO dbo.AuditLog (TableName, ActionType, RecordID, PerformedBy, Notes)
                VALUES (N'[Tickets].[ServiceSLAPolicy]', N'UPSERT_SLA_POLICY', @serviceID, @entryData, @Note);

                SELECT 1 AS IsSuccessful, N'تم تحديث سياسة SLA بنجاح' AS Message_;
                RETURN;
            END
            ELSE
            BEGIN
                INSERT INTO [Tickets].[ServiceSLAPolicy]
                (
                      [idaraID_FK], [serviceID_FK], [priorityID_FK]
                    , [firstResponseTargetMinutes], [assignmentTargetMinutes]
                    , [operationalCompletionTargetMinutes], [finalClosureTargetMinutes]
                    , [effectiveFrom], [slaPolicyActive], [entryData], [hostName]
                )
                VALUES
                (
                      @idaraID_FK, @serviceID, @priorityID_FK
                    , @firstResponseTargetMinutes, @assignmentTargetMinutes
                    , @operationalCompletionTargetMinutes, @finalClosureTargetMinutes
                    , GETDATE(), 1, @entryData, @hostName
                );

                SET @NewID = SCOPE_IDENTITY();

                SET @Note = N'{"action":"INSERTED","serviceSLAPolicyID":"' + ISNULL(CAST(@NewID AS NVARCHAR(20)), N'')
                    + N'","serviceID":"' + CAST(@serviceID AS NVARCHAR(20))
                    + N'","priorityID_FK":"' + CAST(@priorityID_FK AS NVARCHAR(20)) + N'"}';

                INSERT INTO dbo.AuditLog (TableName, ActionType, RecordID, PerformedBy, Notes)
                VALUES (N'[Tickets].[ServiceSLAPolicy]', N'UPSERT_SLA_POLICY', @NewID, @entryData, @Note);

                SELECT 1 AS IsSuccessful, N'تم إنشاء سياسة SLA بنجاح' AS Message_;
                RETURN;
            END
        END

        ----------------------------------------------------------------
        -- APPROVE_SERVICE_SUGGESTION
        ----------------------------------------------------------------
        ELSE IF @Action = N'APPROVE_SERVICE_SUGGESTION'
        BEGIN
            IF @serviceCatalogSuggestionID IS NULL
            BEGIN ;THROW 50001, N'معرف اقتراح دليل الخدمة مطلوب', 1; END

            DECLARE @SugID BIGINT = @serviceCatalogSuggestionID;
            DECLARE @SugIdaraID INT;
            DECLARE @SugName_A NVARCHAR(500);
            DECLARE @SugName_E NVARCHAR(500);
            DECLARE @SugDesc NVARCHAR(2000);
            DECLARE @SugDSDID INT;
            DECLARE @SugPriorityID INT;

            SELECT
                  @SugIdaraID  = [idaraID_FK]
                , @SugName_A   = [proposedServiceName_A]
                , @SugName_E   = [proposedServiceName_E]
                                , @SugDesc     = COALESCE([proposedServiceDesc_A], [proposedServiceDesc])
                , @SugDSDID    = [proposedTargetDSDID_FK]
                , @SugPriorityID = [proposedPriorityID_FK]
            FROM [Tickets].[ServiceCatalogSuggestion]
            WHERE [serviceCatalogSuggestionID] = @SugID
              AND [approvalStatus] = N'PENDING';

            IF @SugName_A IS NULL
            BEGIN ;THROW 50001, N'لم يتم العثور على الاقتراح أو أنه ليس في حالة PENDING', 1; END

            INSERT INTO [Tickets].[Service]
            (
                  [serviceCode], [serviceName_A], [serviceName_E], [serviceDesc]
                , [idaraID_FK], [defaultPriorityID_FK]
                , [requiresLocation], [allowsChildTickets], [requiresQualityReview]
                , [serviceActive], [entryData], [hostName]
            )
            VALUES
            (
                  N'SUG-' + CAST(@SugID AS NVARCHAR(20))
                , @SugName_A, @SugName_E, @SugDesc
                , @SugIdaraID, @SugPriorityID
                , 1, 0, 1
                , 1, @entryData, @hostName
            );

            SET @NewID = SCOPE_IDENTITY();

            UPDATE [Tickets].[ServiceCatalogSuggestion]
            SET
                  [approvalStatus]    = N'APPROVED'
                , [approvedByUserID]  = @approvedByUserID
                , [approvalDate]      = GETDATE()
                                , [approvalNotes_A]   = ISNULL(@approvalNotes_A, @approvalNotes)
                                , [approvalNotes]     = ISNULL(@approvalNotes, @approvalNotes_A)
                , [createdServiceID_FK] = @NewID
                                , [entryData] = @entryData
                                , [hostName]  = @hostName
            WHERE [serviceCatalogSuggestionID] = @SugID;

            IF @SugDSDID IS NOT NULL
            BEGIN
                INSERT INTO [Tickets].[ServiceRoutingRule]
                (
                      [serviceID_FK], [idaraID_FK], [targetDSDID_FK]
                    , [effectiveFrom], [changeReason], [approvedByUserID]
                    , [serviceRoutingRuleActive], [entryData], [hostName]
                )
                VALUES
                (
                      @NewID, @SugIdaraID, @SugDSDID
                    , GETDATE(), N'تم الإنشاء تلقائياً من اقتراح معتمد رقم ' + CAST(@SugID AS NVARCHAR(20))
                    , @approvedByUserID
                    , 1, @entryData, @hostName
                );
            END

            SET @Note = N'{"suggestionID":"' + CAST(@SugID AS NVARCHAR(20))
                + N'","createdServiceID":"' + CAST(@NewID AS NVARCHAR(20)) + N'"}';

            INSERT INTO dbo.AuditLog (TableName, ActionType, RecordID, PerformedBy, Notes)
            VALUES (N'[Tickets].[ServiceCatalogSuggestion]', N'APPROVE_SERVICE_SUGGESTION', @SugID, @entryData, @Note);

            SELECT 1 AS IsSuccessful, N'تمت الموافقة على الاقتراح وإنشاء الخدمة' AS Message_;
            RETURN;
        END

        ----------------------------------------------------------------
        -- REJECT_SERVICE_SUGGESTION
        ----------------------------------------------------------------
        ELSE IF @Action = N'REJECT_SERVICE_SUGGESTION'
        BEGIN
            IF @serviceCatalogSuggestionID IS NULL
            BEGIN ;THROW 50001, N'معرف اقتراح دليل الخدمة مطلوب', 1; END

            SET @SugID = @serviceCatalogSuggestionID;

            IF NOT EXISTS (
                SELECT 1 FROM [Tickets].[ServiceCatalogSuggestion]
                WHERE [serviceCatalogSuggestionID] = @SugID
                  AND [approvalStatus] = N'PENDING'
            )
            BEGIN ;THROW 50001, N'لم يتم العثور على الاقتراح أو أنه ليس في حالة PENDING', 1; END

            UPDATE [Tickets].[ServiceCatalogSuggestion]
            SET
                  [approvalStatus]   = N'REJECTED'
                , [approvedByUserID] = @approvedByUserID
                , [approvalDate]     = GETDATE()
                                , [approvalNotes_A]  = ISNULL(@approvalNotes_A, @approvalNotes)
                                , [approvalNotes]    = ISNULL(@approvalNotes, @approvalNotes_A)
                , [suggestionActive] = 0
                                , [entryData] = @entryData
                                , [hostName]  = @hostName
            WHERE [serviceCatalogSuggestionID] = @SugID;

            IF @@ROWCOUNT = 0
            BEGIN ;THROW 50002, N'لم يتم تحديث أي اقتراح', 1; END

            SET @Note = N'{"suggestionID":"' + CAST(@SugID AS NVARCHAR(20)) + N'"}';

            INSERT INTO dbo.AuditLog (TableName, ActionType, RecordID, PerformedBy, Notes)
            VALUES (N'[Tickets].[ServiceCatalogSuggestion]', N'REJECT_SERVICE_SUGGESTION', @SugID, @entryData, @Note);

            SELECT 1 AS IsSuccessful, N'تم رفض الاقتراح' AS Message_;
            RETURN;
        END

        ----------------------------------------------------------------
        -- Unknown Action
        ----------------------------------------------------------------
        ELSE
        BEGIN
            ;THROW 50001, N'نوع الإجراء غير معروف في ServiceSP', 1;
        END

    END TRY
    BEGIN CATCH
        IF @tc = 0 AND XACT_STATE() <> 0 ROLLBACK;
        ;THROW;
    END CATCH
END

