CREATE PROCEDURE [Tickets].[LookupCRUD]
(
      @Action          NVARCHAR(100)
    , @lookupID        INT           = NULL
    , @lookupCode      NVARCHAR(50)  = NULL
    , @lookupName_A    NVARCHAR(200) = NULL
    , @lookupName_E    NVARCHAR(200) = NULL
    , @lookupDesc      NVARCHAR(1000)= NULL
    , @lookupExtra     NVARCHAR(100) = NULL
    , @idaraID_FK      INT           = NULL
    , @entryData       NVARCHAR(20)  = NULL
    , @hostName        NVARCHAR(200) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @trancount INT = @@TRANCOUNT;
    IF @trancount = 0 BEGIN TRANSACTION;
    ELSE SAVE TRANSACTION LookupCRUD_Savepoint;

    BEGIN TRY
        IF @Action = N'INSERT_TICKETCLASS'
        BEGIN
            IF EXISTS (SELECT 1 FROM [Tickets].[TicketClass] WHERE [ticketClassCode] = @lookupCode)
            BEGIN
                THROW 50001, N'كود الفئة موجود مسبقاً', 1;
            END
            INSERT INTO [Tickets].[TicketClass] ([ticketClassCode], [ticketClassName_A], [ticketClassName_E], [ticketClassDesc], [ticketClassActive], [entryData], [hostName])
            VALUES (@lookupCode, @lookupName_A, @lookupName_E, @lookupDesc, 1, @entryData, @hostName);
            SELECT 1 AS IsSuccessful, N'تمت إضافة فئة التذكرة بنجاح' AS Message_;
        END
        ELSE IF @Action = N'UPDATE_TICKETCLASS'
        BEGIN
            UPDATE [Tickets].[TicketClass]
            SET [ticketClassCode] = ISNULL(@lookupCode, [ticketClassCode]),
                [ticketClassName_A] = ISNULL(@lookupName_A, [ticketClassName_A]),
                [ticketClassName_E] = ISNULL(@lookupName_E, [ticketClassName_E]),
                [ticketClassDesc] = @lookupDesc,
                [entryData] = ISNULL(@entryData, [entryData]),
                [hostName] = ISNULL(@hostName, [hostName])
            WHERE [ticketClassID] = @lookupID;
            IF @@ROWCOUNT = 0 THROW 50001, N'لم يتم العثور على فئة التذكرة', 1;
            SELECT 1 AS IsSuccessful, N'تم تعديل فئة التذكرة بنجاح' AS Message_;
        END
        ELSE IF @Action = N'DELETE_TICKETCLASS'
        BEGIN
            UPDATE [Tickets].[TicketClass] SET [ticketClassActive] = 0 WHERE [ticketClassID] = @lookupID;
            IF @@ROWCOUNT = 0 THROW 50001, N'لم يتم العثور على فئة التذكرة', 1;
            SELECT 1 AS IsSuccessful, N'تم حذف فئة التذكرة بنجاح' AS Message_;
        END
        ELSE IF @Action = N'INSERT_PRIORITY'
        BEGIN
            IF EXISTS (SELECT 1 FROM [Tickets].[Priority] WHERE [priorityCode] = @lookupCode)
            BEGIN
                THROW 50001, N'كود الأولوية موجود مسبقاً', 1;
            END
            DECLARE @lvl INT = TRY_CAST(@lookupExtra AS INT);
            INSERT INTO [Tickets].[Priority] ([priorityCode], [priorityName_A], [priorityName_E], [priorityDesc], [priorityLevel], [priorityActive], [entryData], [hostName])
            VALUES (@lookupCode, @lookupName_A, @lookupName_E, @lookupDesc, @lvl, 1, @entryData, @hostName);
            SELECT 1 AS IsSuccessful, N'تمت إضافة الأولوية بنجاح' AS Message_;
        END
        ELSE IF @Action = N'UPDATE_PRIORITY'
        BEGIN
            DECLARE @lvlU INT = TRY_CAST(@lookupExtra AS INT);
            UPDATE [Tickets].[Priority]
            SET [priorityCode] = ISNULL(@lookupCode, [priorityCode]),
                [priorityName_A] = ISNULL(@lookupName_A, [priorityName_A]),
                [priorityName_E] = ISNULL(@lookupName_E, [priorityName_E]),
                [priorityDesc] = @lookupDesc,
                [priorityLevel] = ISNULL(@lvlU, [priorityLevel]),
                [entryData] = ISNULL(@entryData, [entryData]),
                [hostName] = ISNULL(@hostName, [hostName])
            WHERE [priorityID] = @lookupID;
            IF @@ROWCOUNT = 0 THROW 50001, N'لم يتم العثور على الأولوية', 1;
            SELECT 1 AS IsSuccessful, N'تم تعديل الأولوية بنجاح' AS Message_;
        END
        ELSE IF @Action = N'DELETE_PRIORITY'
        BEGIN
            UPDATE [Tickets].[Priority] SET [priorityActive] = 0 WHERE [priorityID] = @lookupID;
            IF @@ROWCOUNT = 0 THROW 50001, N'لم يتم العثور على الأولوية', 1;
            SELECT 1 AS IsSuccessful, N'تم حذف الأولوية بنجاح' AS Message_;
        END
        ELSE IF @Action = N'INSERT_TICKETSTATUS'
        BEGIN
            IF EXISTS (SELECT 1 FROM [Tickets].[TicketStatus] WHERE [ticketStatusCode] = @lookupCode)
            BEGIN
                THROW 50001, N'كود الحالة موجود مسبقاً', 1;
            END
            INSERT INTO [Tickets].[TicketStatus] ([ticketStatusCode], [ticketStatusName_A], [ticketStatusName_E], [ticketStatusDesc], [ticketStatusActive], [entryData], [hostName])
            VALUES (@lookupCode, @lookupName_A, @lookupName_E, @lookupDesc, 1, @entryData, @hostName);
            SELECT 1 AS IsSuccessful, N'تمت إضافة حالة التذكرة بنجاح' AS Message_;
        END
        ELSE IF @Action = N'UPDATE_TICKETSTATUS'
        BEGIN
            UPDATE [Tickets].[TicketStatus]
            SET [ticketStatusCode] = ISNULL(@lookupCode, [ticketStatusCode]),
                [ticketStatusName_A] = ISNULL(@lookupName_A, [ticketStatusName_A]),
                [ticketStatusName_E] = ISNULL(@lookupName_E, [ticketStatusName_E]),
                [ticketStatusDesc] = @lookupDesc,
                [entryData] = ISNULL(@entryData, [entryData]),
                [hostName] = ISNULL(@hostName, [hostName])
            WHERE [ticketStatusID] = @lookupID;
            IF @@ROWCOUNT = 0 THROW 50001, N'لم يتم العثور على حالة التذكرة', 1;
            SELECT 1 AS IsSuccessful, N'تم تعديل حالة التذكرة بنجاح' AS Message_;
        END
        ELSE IF @Action = N'DELETE_TICKETSTATUS'
        BEGIN
            UPDATE [Tickets].[TicketStatus] SET [ticketStatusActive] = 0 WHERE [ticketStatusID] = @lookupID;
            IF @@ROWCOUNT = 0 THROW 50001, N'لم يتم العثور على حالة التذكرة', 1;
            SELECT 1 AS IsSuccessful, N'تم حذف حالة التذكرة بنجاح' AS Message_;
        END
        ELSE IF @Action = N'INSERT_PAUSEREASON'
        BEGIN
            IF EXISTS (SELECT 1 FROM [Tickets].[PauseReason] WHERE [pauseReasonCode] = @lookupCode)
            BEGIN
                THROW 50001, N'كود سبب الإيقاف موجود مسبقاً', 1;
            END
            INSERT INTO [Tickets].[PauseReason] ([pauseReasonCode], [pauseReasonName_A], [pauseReasonName_E], [pauseReasonDesc], [pauseReasonActive], [entryData], [hostName])
            VALUES (@lookupCode, @lookupName_A, @lookupName_E, @lookupDesc, 1, @entryData, @hostName);
            SELECT 1 AS IsSuccessful, N'تمت إضافة سبب الإيقاف بنجاح' AS Message_;
        END
        ELSE IF @Action = N'UPDATE_PAUSEREASON'
        BEGIN
            UPDATE [Tickets].[PauseReason]
            SET [pauseReasonCode] = ISNULL(@lookupCode, [pauseReasonCode]),
                [pauseReasonName_A] = ISNULL(@lookupName_A, [pauseReasonName_A]),
                [pauseReasonName_E] = ISNULL(@lookupName_E, [pauseReasonName_E]),
                [pauseReasonDesc] = @lookupDesc,
                [entryData] = ISNULL(@entryData, [entryData]),
                [hostName] = ISNULL(@hostName, [hostName])
            WHERE [pauseReasonID] = @lookupID;
            IF @@ROWCOUNT = 0 THROW 50001, N'لم يتم العثور على سبب الإيقاف', 1;
            SELECT 1 AS IsSuccessful, N'تم تعديل سبب الإيقاف بنجاح' AS Message_;
        END
        ELSE IF @Action = N'DELETE_PAUSEREASON'
        BEGIN
            UPDATE [Tickets].[PauseReason] SET [pauseReasonActive] = 0 WHERE [pauseReasonID] = @lookupID;
            IF @@ROWCOUNT = 0 THROW 50001, N'لم يتم العثور على سبب الإيقاف', 1;
            SELECT 1 AS IsSuccessful, N'تم حذف سبب الإيقاف بنجاح' AS Message_;
        END
        ELSE IF @Action = N'INSERT_ARBITRATIONREASON'
        BEGIN
            IF EXISTS (SELECT 1 FROM [Tickets].[ArbitrationReason] WHERE [arbitrationReasonCode] = @lookupCode)
            BEGIN
                THROW 50001, N'كود سبب التحكيم موجود مسبقاً', 1;
            END
            INSERT INTO [Tickets].[ArbitrationReason] ([arbitrationReasonCode], [arbitrationReasonName_A], [arbitrationReasonName_E], [arbitrationReasonDesc], [arbitrationReasonActive], [entryData], [hostName])
            VALUES (@lookupCode, @lookupName_A, @lookupName_E, @lookupDesc, 1, @entryData, @hostName);
            SELECT 1 AS IsSuccessful, N'تمت إضافة سبب التحكيم بنجاح' AS Message_;
        END
        ELSE IF @Action = N'UPDATE_ARBITRATIONREASON'
        BEGIN
            UPDATE [Tickets].[ArbitrationReason]
            SET [arbitrationReasonCode] = ISNULL(@lookupCode, [arbitrationReasonCode]),
                [arbitrationReasonName_A] = ISNULL(@lookupName_A, [arbitrationReasonName_A]),
                [arbitrationReasonName_E] = ISNULL(@lookupName_E, [arbitrationReasonName_E]),
                [arbitrationReasonDesc] = @lookupDesc,
                [entryData] = ISNULL(@entryData, [entryData]),
                [hostName] = ISNULL(@hostName, [hostName])
            WHERE [arbitrationReasonID] = @lookupID;
            IF @@ROWCOUNT = 0 THROW 50001, N'لم يتم العثور على سبب التحكيم', 1;
            SELECT 1 AS IsSuccessful, N'تم تعديل سبب التحكيم بنجاح' AS Message_;
        END
        ELSE IF @Action = N'DELETE_ARBITRATIONREASON'
        BEGIN
            UPDATE [Tickets].[ArbitrationReason] SET [arbitrationReasonActive] = 0 WHERE [arbitrationReasonID] = @lookupID;
            IF @@ROWCOUNT = 0 THROW 50001, N'لم يتم العثور على سبب التحكيم', 1;
            SELECT 1 AS IsSuccessful, N'تم حذف سبب التحكيم بنجاح' AS Message_;
        END
        ELSE IF @Action = N'INSERT_QUALITYREVIEWRESULT'
        BEGIN
            IF EXISTS (SELECT 1 FROM [Tickets].[QualityReviewResult] WHERE [qualityReviewResultCode] = @lookupCode)
            BEGIN
                THROW 50001, N'كود نتيجة المراجعة موجود مسبقاً', 1;
            END
            INSERT INTO [Tickets].[QualityReviewResult] ([qualityReviewResultCode], [qualityReviewResultName_A], [qualityReviewResultName_E], [qualityReviewResultDesc], [qualityReviewResultActive], [entryData], [hostName])
            VALUES (@lookupCode, @lookupName_A, @lookupName_E, @lookupDesc, 1, @entryData, @hostName);
            SELECT 1 AS IsSuccessful, N'تمت إضافة نتيجة المراجعة بنجاح' AS Message_;
        END
        ELSE IF @Action = N'UPDATE_QUALITYREVIEWRESULT'
        BEGIN
            UPDATE [Tickets].[QualityReviewResult]
            SET [qualityReviewResultCode] = ISNULL(@lookupCode, [qualityReviewResultCode]),
                [qualityReviewResultName_A] = ISNULL(@lookupName_A, [qualityReviewResultName_A]),
                [qualityReviewResultName_E] = ISNULL(@lookupName_E, [qualityReviewResultName_E]),
                [qualityReviewResultDesc] = @lookupDesc,
                [entryData] = ISNULL(@entryData, [entryData]),
                [hostName] = ISNULL(@hostName, [hostName])
            WHERE [qualityReviewResultID] = @lookupID;
            IF @@ROWCOUNT = 0 THROW 50001, N'لم يتم العثور على نتيجة المراجعة', 1;
            SELECT 1 AS IsSuccessful, N'تم تعديل نتيجة المراجعة بنجاح' AS Message_;
        END
        ELSE IF @Action = N'DELETE_QUALITYREVIEWRESULT'
        BEGIN
            UPDATE [Tickets].[QualityReviewResult] SET [qualityReviewResultActive] = 0 WHERE [qualityReviewResultID] = @lookupID;
            IF @@ROWCOUNT = 0 THROW 50001, N'لم يتم العثور على نتيجة المراجعة', 1;
            SELECT 1 AS IsSuccessful, N'تم حذف نتيجة المراجعة بنجاح' AS Message_;
        END
        ELSE
        BEGIN
            THROW 50001, N'نوع العملية غير معروف. ActionType', 1;
        END

        IF @trancount = 0 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @trancount = 0 ROLLBACK TRANSACTION;
        ELSE IF XACT_STATE() = -1 ROLLBACK TRANSACTION;
        ELSE ROLLBACK TRANSACTION LookupCRUD_Savepoint;

        DECLARE @errNum INT = ERROR_NUMBER();
        DECLARE @errMsg NVARCHAR(4000) = ERROR_MESSAGE();

        IF @errNum BETWEEN 50001 AND 50999
            SELECT 0 AS IsSuccessful, @errMsg AS Message_;
        ELSE
        BEGIN
            INSERT INTO dbo.ErrorLog (ERROR_MESSAGE_, ERROR_SEVERITY_, ERROR_STATE_, SP_NAME, entryDate, entryData, hostName)
            VALUES (@errMsg, ERROR_SEVERITY(), ERROR_STATE(), ERROR_PROCEDURE(), GETDATE(), @entryData, @hostName);
            SELECT 0 AS IsSuccessful, N'حدث خطأ غير متوقع. يرجى المحاولة لاحقاً' AS Message_;
        END
    END CATCH
END
