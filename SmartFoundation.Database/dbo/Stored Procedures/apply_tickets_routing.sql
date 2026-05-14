/*
    Apply Tickets routing to the LIVE Masters_DataLoad procedure.
    Run this script once against the target database.
    It inserts the Tickets routing block just before the "PAGE NOT FOUND" guard.
*/
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

IF CHARINDEX(@find, @def) = 0
BEGIN
    RAISERROR(N'Could not find the PAGE NOT FOUND marker in Masters_DataLoad. The procedure may have already been patched or the marker was changed.', 16, 1);
    RETURN;
END

SET @def = REPLACE(@def, @find, @insert);
SET @def = STUFF(@def, 1, 6, N'ALTER');

EXEC sp_executesql @def;

PRINT N'Masters_DataLoad patched successfully — Tickets routing added.';
GO
