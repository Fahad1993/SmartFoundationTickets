/*  Patch Masters_DataLoad: add Tickets routing before the PAGE NOT FOUND block  */
DECLARE @def  NVARCHAR(MAX) = OBJECT_DEFINITION(OBJECT_ID('dbo.Masters_DataLoad'));
DECLARE @find NVARCHAR(MAX) = N'    -------------------------------------------------------------------
    --                     PAGE NOT FOUND
    --            DO NOT TOUCH DOWN THIS LINE PLEASE
    -------------------------------------------------------------------
        ELSE';

DECLARE @insert NVARCHAR(MAX) = N'
        -- ============================================================
        --                       TICKETS MODULE
        -- ============================================================
        ELSE IF @pageName_ IN (N''TicketList'', N''TicketDetails'', N''TicketHistory'', N''StatusDDL'',
                               N''ChildTickets'', N''PauseSessions'', N''TicketSLAs'',
                               N''QualityReviews'', N''ArbitrationCases'', N''TicketAttachments'',
                               N''PauseReasonDDL'', N''ArbitrationReasonDDL'', N''QualityReviewResultDDL'',
                               N''RequesterTypeDDL'', N''TicketClassDDL'', N''PriorityDDL'',
                               N''OpenArbitrations'', N''PendingReviews'', N''BreachedSLAs'',
                               N''TicketAdminLookup'', N''ResidentDDL'', N''BuildingDDL'',
                               N''TicketReasonDDL'', N''TicketDescriptionTemplateDDL'')
        BEGIN
            EXEC [Tickets].[TicketDL]
                  @pageName_   = @pageName_
                , @idaraID     = @idaraID
                , @entryData   = @entrydata
                , @hostName    = @hostname
                , @filterTicketID       = @parameter_01
                , @filterTicketNo       = @parameter_02
                , @filterStatusID       = @parameter_03
                , @filterServiceID      = @parameter_04
                , @filterAssignedUserID = @parameter_05
                , @filterDSDID          = @parameter_06;
        END

    -------------------------------------------------------------------
    --                     PAGE NOT FOUND
    --            DO NOT TOUCH DOWN THIS LINE PLEASE
    -------------------------------------------------------------------
        ELSE';

SET @def = REPLACE(@def, @find, @insert);

/* Change CREATE to ALTER so we can update the existing SP */
SET @def = STUFF(@def, 1, 6, N'ALTER');

EXEC sp_executesql @def;
GO
