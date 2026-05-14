SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @ticketSp NVARCHAR(MAX) = OBJECT_DEFINITION(OBJECT_ID(N'[Tickets].[TicketSP]'));
    IF @ticketSp IS NULL
        THROW 50001, N'Could not load [Tickets].[TicketSP] definition.', 1;

    IF @ticketSp NOT LIKE N'%ELSE IF @Action = N''UPDATE_PRIORITY''%'
    BEGIN
        DECLARE @ticketFind NVARCHAR(MAX) = N'
        ----------------------------------------------------------------
        -- START_WORK
        ----------------------------------------------------------------';

        DECLARE @ticketInsert NVARCHAR(MAX) = N'
        ----------------------------------------------------------------
        -- UPDATE_PRIORITY
        ----------------------------------------------------------------
        ELSE IF @Action = N''UPDATE_PRIORITY''
        BEGIN
            IF @ticketID IS NULL
            BEGIN ;THROW 50001, N''معرف التذكرة مطلوب'', 1; END
            IF @suggestedPriorityID_FK IS NULL
            BEGIN ;THROW 50001, N''الأولوية الجديدة مطلوبة'', 1; END

            DECLARE @upOldStatus INT, @upOldSuggestedPriority INT, @upOldEffectivePriority INT;
            SELECT
                  @upOldStatus = [ticketStatusID_FK]
                , @upOldSuggestedPriority = [suggestedPriorityID_FK]
                , @upOldEffectivePriority = [effectivePriorityID_FK]
            FROM [Tickets].[Ticket]
            WHERE [ticketID] = @ticketID
              AND [ticketActive] = 1;

            IF @upOldStatus IS NULL
            BEGIN ;THROW 50001, N''لم يتم العثور على تذكرة نشطة'', 1; END

            IF @upOldStatus IN
            (
                SELECT [ticketStatusID]
                FROM [Tickets].[TicketStatus]
                WHERE [ticketStatusCode] IN (N''CLOSED'', N''REJECTED'')
                  AND [ticketStatusActive] = 1
            )
            BEGIN ;THROW 50001, N''لا يمكن تعديل أولوية التذكرة في حالتها الحالية'', 1; END

            IF NOT EXISTS
            (
                SELECT 1
                FROM [Tickets].[Priority]
                WHERE [priorityID] = @suggestedPriorityID_FK
                  AND [priorityActive] = 1
            )
            BEGIN ;THROW 50001, N''الأولوية المحددة غير صالحة أو غير نشطة'', 1; END

            UPDATE [Tickets].[Ticket]
            SET [suggestedPriorityID_FK] = @suggestedPriorityID_FK
              , [effectivePriorityID_FK] = @suggestedPriorityID_FK
                         , [entryData] = @entryData
                         , [hostName]  = @hostName
            WHERE [ticketID] = @ticketID;

            INSERT INTO [Tickets].[TicketHistory]
            ( [ticketID_FK], [idaraID_FK], [actionTypeCode], [oldStatusID_FK], [newStatusID_FK]
            , [oldDSDID_FK], [newDSDID_FK], [oldAssignedUserID], [newAssignedUserID]
            , [performerUserID], [notes], [notes_A], [entryData], [hostName] )
            VALUES
            ( @ticketID, @idaraID_FK, N''UPDATE_PRIORITY'', @upOldStatus, @upOldStatus
            , NULL, NULL, NULL, NULL
            , @performerUserID, ISNULL(@notes, N''تم تعديل أولوية التذكرة''), COALESCE(@notes_A, ISNULL(@notes, N''تم تعديل أولوية التذكرة'')), @entryData, @hostName );

            SET @Note = N''{""ticketID"":""'' + CAST(@ticketID AS NVARCHAR(20))
                + N''"",""oldSuggestedPriorityID"":""'' + COALESCE(CAST(@upOldSuggestedPriority AS NVARCHAR(20)), N'''')
                + N''"",""oldEffectivePriorityID"":""'' + COALESCE(CAST(@upOldEffectivePriority AS NVARCHAR(20)), N'''')
                + N''"",""newPriorityID"":""'' + CAST(@suggestedPriorityID_FK AS NVARCHAR(20)) + N''""}'';

            INSERT INTO dbo.AuditLog (TableName, ActionType, RecordID, PerformedBy, Notes)
            VALUES (N''[Tickets].[Ticket]'', N''UPDATE_PRIORITY'', @ticketID, @entryData, @Note);

            SELECT 1 AS IsSuccessful, N''تم تحديث أولوية التذكرة بنجاح'' AS Message_;
        END

        ----------------------------------------------------------------
        -- START_WORK
        ----------------------------------------------------------------';

                SET @ticketSp = REPLACE(@ticketSp, @ticketFind, @ticketInsert);

                IF @ticketSp NOT LIKE N'%ELSE IF @Action = N''UPDATE_PRIORITY''%'
                BEGIN
                        DECLARE @anchor INT = CHARINDEX(N'ELSE IF @Action = N''START_WORK''', @ticketSp);
                        IF @anchor <= 0
                                THROW 50001, N'Could not find START_WORK anchor in [Tickets].[TicketSP].', 1;

                        DECLARE @ticketInsertBlock NVARCHAR(MAX) = N'

                ----------------------------------------------------------------
                -- UPDATE_PRIORITY
                ----------------------------------------------------------------
                ELSE IF @Action = N''UPDATE_PRIORITY''
                BEGIN
                        IF @ticketID IS NULL
                        BEGIN ;THROW 50001, N''معرف التذكرة مطلوب'', 1; END
                        IF @suggestedPriorityID_FK IS NULL
                        BEGIN ;THROW 50001, N''الأولوية الجديدة مطلوبة'', 1; END

                        DECLARE @upOldStatus INT, @upOldSuggestedPriority INT, @upOldEffectivePriority INT;
                        SELECT
                                    @upOldStatus = [ticketStatusID_FK]
                                , @upOldSuggestedPriority = [suggestedPriorityID_FK]
                                , @upOldEffectivePriority = [effectivePriorityID_FK]
                        FROM [Tickets].[Ticket]
                        WHERE [ticketID] = @ticketID
                            AND [ticketActive] = 1;

                        IF @upOldStatus IS NULL
                        BEGIN ;THROW 50001, N''لم يتم العثور على تذكرة نشطة'', 1; END

                        IF @upOldStatus IN
                        (
                                SELECT [ticketStatusID]
                                FROM [Tickets].[TicketStatus]
                                WHERE [ticketStatusCode] IN (N''CLOSED'', N''REJECTED'')
                                    AND [ticketStatusActive] = 1
                        )
                        BEGIN ;THROW 50001, N''لا يمكن تعديل أولوية التذكرة في حالتها الحالية'', 1; END

                        IF NOT EXISTS
                        (
                                SELECT 1
                                FROM [Tickets].[Priority]
                                WHERE [priorityID] = @suggestedPriorityID_FK
                                    AND [priorityActive] = 1
                        )
                        BEGIN ;THROW 50001, N''الأولوية المحددة غير صالحة أو غير نشطة'', 1; END

                        UPDATE [Tickets].[Ticket]
                        SET [suggestedPriorityID_FK] = @suggestedPriorityID_FK
                            , [effectivePriorityID_FK] = @suggestedPriorityID_FK
                               , [entryData] = @entryData
                               , [hostName]  = @hostName
                        WHERE [ticketID] = @ticketID;

                        INSERT INTO [Tickets].[TicketHistory]
                        ( [ticketID_FK], [idaraID_FK], [actionTypeCode], [oldStatusID_FK], [newStatusID_FK]
                        , [oldDSDID_FK], [newDSDID_FK], [oldAssignedUserID], [newAssignedUserID]
                        , [performerUserID], [notes], [notes_A], [entryData], [hostName] )
                        VALUES
                        ( @ticketID, @idaraID_FK, N''UPDATE_PRIORITY'', @upOldStatus, @upOldStatus
                        , NULL, NULL, NULL, NULL
                        , @performerUserID, ISNULL(@notes, N''تم تعديل أولوية التذكرة''), COALESCE(@notes_A, ISNULL(@notes, N''تم تعديل أولوية التذكرة'')), @entryData, @hostName );

                        SET @Note = N''{""ticketID"":""'' + CAST(@ticketID AS NVARCHAR(20))
                                + N''"",""oldSuggestedPriorityID"":""'' + COALESCE(CAST(@upOldSuggestedPriority AS NVARCHAR(20)), N'''')
                                + N''"",""oldEffectivePriorityID"":""'' + COALESCE(CAST(@upOldEffectivePriority AS NVARCHAR(20)), N'''')
                                + N''"",""newPriorityID"":""'' + CAST(@suggestedPriorityID_FK AS NVARCHAR(20)) + N''""}'';

                        INSERT INTO dbo.AuditLog (TableName, ActionType, RecordID, PerformedBy, Notes)
                        VALUES (N''[Tickets].[Ticket]'', N''UPDATE_PRIORITY'', @ticketID, @entryData, @Note);

                        SELECT 1 AS IsSuccessful, N''تم تحديث أولوية التذكرة بنجاح'' AS Message_;
                END

                ';

                        SET @ticketSp = STUFF(@ticketSp, @anchor, 0, @ticketInsertBlock);
                END

        SET @ticketSp = REPLACE(@ticketSp, N'CREATE PROCEDURE', N'ALTER PROCEDURE');
        SET @ticketSp = REPLACE(@ticketSp, N'CREATE   PROCEDURE', N'ALTER   PROCEDURE');
        SET @ticketSp = REPLACE(@ticketSp, N'CREATE  PROCEDURE', N'ALTER  PROCEDURE');
        EXEC sp_executesql @ticketSp;
    END

    IF @ticketSp LIKE N'%ELSE IF @Action = N''UPDATE_PRIORITY''%'
    BEGIN
        DECLARE @ticketSpFixed NVARCHAR(MAX) = @ticketSp;

        SET @ticketSpFixed = REPLACE(
            @ticketSpFixed,
            N'SELECT 1 AS IsSuccessful, N''ØªÙ… ØªØ­Ø¯ÙŠØ« Ø£ÙˆÙ„ÙˆÙŠØ© Ø§Ù„ØªØ°ÙƒØ±Ø© Ø¨Ù†Ø¬Ø§Ø­'' AS Message_;',
            N'SELECT 1 AS IsSuccessful, N''تم تحديث أولوية التذكرة بنجاح'' AS Message_;'
        );

        SET @ticketSpFixed = REPLACE(
            @ticketSpFixed,
            N'ISNULL(@notes, N''ØªÙ… ØªØ¹Ø¯ÙŠÙ„ Ø£ÙˆÙ„ÙˆÙŠØ© Ø§Ù„ØªØ°ÙƒØ±Ø©''), COALESCE(@notes_A, ISNULL(@notes, N''ØªÙ… ØªØ¹Ø¯ÙŠÙ„ Ø£ÙˆÙ„ÙˆÙŠØ© Ø§Ù„ØªØ°ÙƒØ±Ø©''))',
            N'ISNULL(@notes, N''تم تعديل أولوية التذكرة''), COALESCE(@notes_A, ISNULL(@notes, N''تم تعديل أولوية التذكرة''))'
        );

        SET @ticketSpFixed = REPLACE(
            @ticketSpFixed,
            N'[entryData] = ISNULL(ISNULL([entryData],N'''') + N'','' + @entryData, [entryData])',
            N'[entryData] = @entryData'
        );

        SET @ticketSpFixed = REPLACE(
            @ticketSpFixed,
            N'[hostName]  = ISNULL(ISNULL(@hostName,N'''') + N'','' + [hostName], [hostName])',
            N'[hostName]  = @hostName'
        );

        IF @ticketSpFixed <> @ticketSp
        BEGIN
            SET @ticketSpFixed = REPLACE(@ticketSpFixed, N'CREATE PROCEDURE', N'ALTER PROCEDURE');
            SET @ticketSpFixed = REPLACE(@ticketSpFixed, N'CREATE   PROCEDURE', N'ALTER   PROCEDURE');
            SET @ticketSpFixed = REPLACE(@ticketSpFixed, N'CREATE  PROCEDURE', N'ALTER  PROCEDURE');
            EXEC sp_executesql @ticketSpFixed;
            SET @ticketSp = @ticketSpFixed;
        END
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'UPDATE_PRIORITY')
    BEGIN
        DECLARE @adminRoleID BIGINT;
        SELECT TOP 1 @adminRoleID = roleID FROM dbo.[Role] WHERE roleName_E = N'Admin' OR roleName_A LIKE N'%مدير%' ORDER BY roleID;
        IF @adminRoleID IS NULL SELECT TOP 1 @adminRoleID = roleID FROM dbo.[Role] ORDER BY roleID;

        INSERT INTO dbo.PermissionType (permissionTypeName_A, permissionTypeName_E, permissionTypeActive, RoleID_FK)
        VALUES (N'تعديل أولوية التذكرة', N'UPDATE_PRIORITY', 1, @adminRoleID);
    END


    DECLARE @crudSp NVARCHAR(MAX) = OBJECT_DEFINITION(OBJECT_ID(N'[dbo].[Masters_CRUD]'));
    IF @crudSp IS NULL
        THROW 50001, N'Could not load [dbo].[Masters_CRUD] definition.', 1;

    IF @crudSp NOT LIKE N'%ELSE IF @ActionType = ''UPDATE_PRIORITY''%'
    BEGIN
        DECLARE @crudFind NVARCHAR(MAX) = N'
                        ELSE IF @ActionType IN (''START_WORK'', ''RESOLVE_TICKET'', ''RESUME_TICKET'', ''CLOSE_TICKET'', ''REOPEN_TICKET'', ''REJECT_TICKET'')';

        DECLARE @crudInsert NVARCHAR(MAX) = N'
                        ELSE IF @ActionType = ''UPDATE_PRIORITY''
                        BEGIN
                                INSERT INTO @Result(IsSuccessful, Message_)
                                EXEC [Tickets].[TicketSP]
                                            @Action                         = @ActionType
                                        , @ticketID                       = @parameter_01
                                        , @suggestedPriorityID_FK         = @parameter_02
                                        , @notes_A                        = @parameter_03
                                        , @idaraID_FK                     = @idaraID
                                        , @entryData                      = @entrydata
                                        , @hostName                       = @hostName
                                        , @performerUserID                = @entrydata;
                        END
                        ELSE IF @ActionType IN (''START_WORK'', ''RESOLVE_TICKET'', ''RESUME_TICKET'', ''CLOSE_TICKET'', ''REOPEN_TICKET'', ''REJECT_TICKET'')';

        SET @crudSp = REPLACE(@crudSp, @crudFind, @crudInsert);
        SET @crudSp = REPLACE(@crudSp, N'CREATE PROCEDURE', N'ALTER PROCEDURE');
        SET @crudSp = REPLACE(@crudSp, N'CREATE   PROCEDURE', N'ALTER   PROCEDURE');
        SET @crudSp = REPLACE(@crudSp, N'CREATE  PROCEDURE', N'ALTER  PROCEDURE');
        EXEC sp_executesql @crudSp;
    END

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW;
END CATCH;

SELECT
    TicketSpHasUpdatePriority = CASE WHEN OBJECT_DEFINITION(OBJECT_ID(N'[Tickets].[TicketSP]')) LIKE N'%ELSE IF @Action = N''UPDATE_PRIORITY''%' THEN 1 ELSE 0 END,
    MastersCrudHasUpdatePriority = CASE WHEN OBJECT_DEFINITION(OBJECT_ID(N'[dbo].[Masters_CRUD]')) LIKE N'%ELSE IF @ActionType = ''UPDATE_PRIORITY''%' THEN 1 ELSE 0 END,
    PermissionTypeExists = CASE WHEN EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'UPDATE_PRIORITY' AND permissionTypeActive = 1) THEN 1 ELSE 0 END;
