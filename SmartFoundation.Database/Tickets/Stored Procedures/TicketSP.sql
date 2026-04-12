CREATE PROCEDURE [Tickets].[TicketSP]
(
      @Action                      NVARCHAR(200)
    , @ticketID                    BIGINT          = NULL
    , @parentTicketID_FK           BIGINT          = NULL
    , @serviceID_FK                BIGINT          = NULL
    , @ticketClassID_FK            INT             = NULL
    , @requesterTypeID_FK          INT             = NULL
    , @requesterUserID_FK          INT             = NULL
    , @requesterResidentID_FK      BIGINT          = NULL
    , @title                       NVARCHAR(500)   = NULL
    , @description_                NVARCHAR(4000)  = NULL
    , @suggestedPriorityID_FK      INT             = NULL
    , @ticketStatusID_FK           INT             = NULL
    , @currentDSDID_FK             INT             = NULL
    , @currentQueueDistributorID_FK INT            = NULL
    , @assignedUserID_FK           INT             = NULL
    , @locationBuildingNo          NVARCHAR(100)   = NULL
    , @locationUnitNo              NVARCHAR(50)    = NULL
    , @locationArea                NVARCHAR(200)   = NULL
    , @requiresQualityReview       BIT             = NULL
    , @isOtherService              BIT             = NULL
    , @idaraID_FK                  INT             = NULL
    , @entryData                   NVARCHAR(20)    = NULL
    , @hostName                    NVARCHAR(200)   = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @tc INT = @@TRANCOUNT;
    DECLARE @NewID BIGINT = NULL;
    DECLARE @Note NVARCHAR(MAX) = NULL;
    DECLARE @NewTicketNo NVARCHAR(50) = NULL;

    BEGIN TRY
        IF @tc = 0 BEGIN TRAN;

        IF NULLIF(LTRIM(RTRIM(@Action)), N'') IS NULL
        BEGIN ;THROW 50001, N'Action is required', 1; END

        ----------------------------------------------------------------
        -- INSERT_TICKET
        ----------------------------------------------------------------
        IF @Action = N'INSERT_TICKET'
        BEGIN
            -- BR: title is required
            IF NULLIF(LTRIM(RTRIM(@title)), N'') IS NULL
            BEGIN ;THROW 50001, N'Ticket title is required', 1; END

            -- BR: idaraID is required
            IF @idaraID_FK IS NULL
            BEGIN ;THROW 50001, N'IdaraID is required', 1; END

            -- BR: ticketClassID is required
            IF @ticketClassID_FK IS NULL
            BEGIN ;THROW 50001, N'TicketClassID is required', 1; END

            -- BR: requesterTypeID is required
            IF @requesterTypeID_FK IS NULL
            BEGIN ;THROW 50001, N'RequesterTypeID is required', 1; END

            -- BR-01: Mutual exclusivity — resident vs internal user
            -- RESIDENT (code=1) must have requesterResidentID_FK and no requesterUserID_FK
            -- INTERNAL (code=2+) must have requesterUserID_FK and no requesterResidentID_FK
            DECLARE @reqCode NVARCHAR(50);
            SELECT @reqCode = [requesterTypeCode]
            FROM [Tickets].[RequesterType]
            WHERE [requesterTypeID] = @requesterTypeID_FK;

            IF @reqCode = N'RESIDENT'
            BEGIN
                IF @requesterResidentID_FK IS NULL
                BEGIN ;THROW 50001, N'Resident tickets require a requesterResidentID', 1; END
                IF @requesterUserID_FK IS NOT NULL
                BEGIN ;THROW 50001, N'Resident tickets must not have a requesterUserID', 1; END
            END
            ELSE IF @reqCode IN (N'INTERNAL', N'SUPERVISOR', N'MANAGER')
            BEGIN
                IF @requesterUserID_FK IS NULL
                BEGIN ;THROW 50001, N'Internal tickets require a requesterUserID', 1; END
                IF @requesterResidentID_FK IS NOT NULL
                BEGIN ;THROW 50001, N'Internal tickets must not have a requesterResidentID', 1; END
            END

            -- BR-02: Other tickets do not require ServiceID_FK
            IF @isOtherService IS NULL OR @isOtherService = 0
            BEGIN
                IF @serviceID_FK IS NULL
                BEGIN ;THROW 50001, N'ServiceID is required for non-Other tickets', 1; END
            END

            -- Generate ticketNo: TKT-YYYY-NNNNN
            DECLARE @yr NVARCHAR(4) = CONVERT(NVARCHAR(4), YEAR(GETDATE()));
            DECLARE @seq INT;
            SELECT @seq = ISNULL(MAX(CAST(RIGHT([ticketNo], 5) AS INT)), 0) + 1
            FROM [Tickets].[Ticket]
            WHERE [ticketNo] LIKE N'TKT-' + @yr + N'-%';

            SET @NewTicketNo = N'TKT-' + @yr + N'-' + RIGHT(N'00000' + CAST(@seq AS NVARCHAR(10)), 5);

            -- Determine initial status = NEW (lookup by code)
            DECLARE @statusNewID INT;
            SELECT @statusNewID = [ticketStatusID]
            FROM [Tickets].[TicketStatus]
            WHERE [ticketStatusCode] = N'NEW' AND [ticketStatusActive] = 1;

            IF @statusNewID IS NULL
            BEGIN ;THROW 50002, N'Cannot resolve NEW status from TicketStatus lookup', 1; END

            -- Resolve service-related defaults when serviceID is provided
            DECLARE @svcDSDID INT = @currentDSDID_FK;
            DECLARE @svcRequiresQR BIT = ISNULL(@requiresQualityReview, 0);

            IF @serviceID_FK IS NOT NULL
            BEGIN
                SELECT
                      @svcDSDID = ISNULL(@svcDSDID, s.[defaultPriorityID_FK])
                FROM [Tickets].[Service] s
                WHERE s.[serviceID] = @serviceID_FK AND s.[serviceActive] = 1;

                IF @svcRequiresQR = 0
                BEGIN
                    SELECT @svcRequiresQR = ISNULL(s.[requiresQualityReview], 0)
                    FROM [Tickets].[Service] s
                    WHERE s.[serviceID] = @serviceID_FK;
                END
            END

            -- Resolve effective priority: use suggested if provided, else service default
            DECLARE @effectivePriorityID INT = @suggestedPriorityID_FK;
            IF @effectivePriorityID IS NULL AND @serviceID_FK IS NOT NULL
            BEGIN
                SELECT @effectivePriorityID = s.[defaultPriorityID_FK]
                FROM [Tickets].[Service] s
                WHERE s.[serviceID] = @serviceID_FK;
            END

            -- T037: rootTicketID_FK — for top-level tickets, set to own ID after insert (done below)
            -- For child tickets, parentTicketID_FK and rootTicketID_FK should be passed in
            -- (handled by CREATE_CHILD_TICKET action in later phases)
            -- INSERT without parent => rootTicketID_FK will be set to SCOPE_IDENTITY() after insert
            IF @parentTicketID_FK IS NOT NULL AND @parentTicketID_FK > 0
            BEGIN
                ;THROW 50001, N'Use CREATE_CHILD_TICKET to create child tickets', 1;
            END

            SET @parentTicketID_FK = NULL;

            INSERT INTO [Tickets].[Ticket]
            (
                  [ticketNo]
                , [idaraID_FK]
                , [parentTicketID_FK]
                , [rootTicketID_FK]
                , [serviceID_FK]
                , [ticketClassID_FK]
                , [requesterTypeID_FK]
                , [requesterUserID_FK]
                , [requesterResidentID_FK]
                , [title]
                , [description_]
                , [suggestedPriorityID_FK]
                , [effectivePriorityID_FK]
                , [ticketStatusID_FK]
                , [currentDSDID_FK]
                , [currentQueueDistributorID_FK]
                , [assignedUserID_FK]
                , [locationBuildingNo]
                , [locationUnitNo]
                , [locationArea]
                , [operationalResolutionDate]
                , [finalClosureDate]
                , [requiresQualityReview]
                , [isOtherService]
                , [isParentBlocked]
                , [ticketActive]
                , [entryData]
                , [hostName]
            )
            VALUES
            (
                  @NewTicketNo
                , @idaraID_FK
                , @parentTicketID_FK
                , NULL
                , @serviceID_FK
                , @ticketClassID_FK
                , @requesterTypeID_FK
                , @requesterUserID_FK
                , @requesterResidentID_FK
                , @title
                , @description_
                , @suggestedPriorityID_FK
                , @effectivePriorityID
                , @statusNewID
                , @svcDSDID
                , @currentQueueDistributorID_FK
                , @assignedUserID_FK
                , @locationBuildingNo
                , @locationUnitNo
                , @locationArea
                , NULL
                , NULL
                , @svcRequiresQR
                , ISNULL(@isOtherService, 0)
                , 0
                , 1
                , @entryData
                , @hostName
            );

            SET @NewID = SCOPE_IDENTITY();
            IF @NewID IS NULL OR @NewID <= 0
            BEGIN ;THROW 50002, N'Failed to create ticket - identity error', 1; END

            -- T037: Set rootTicketID_FK = own ID for top-level tickets
            UPDATE [Tickets].[Ticket]
            SET [rootTicketID_FK] = @NewID
            WHERE [ticketID] = @NewID AND [rootTicketID_FK] IS NULL;

            -- T038: Insert TicketHistory creation event
            INSERT INTO [Tickets].[TicketHistory]
            (
                  [ticketID_FK]
                , [idaraID_FK]
                , [actionTypeCode]
                , [oldStatusID_FK]
                , [newStatusID_FK]
                , [oldDSDID_FK]
                , [newDSDID_FK]
                , [oldAssignedUserID]
                , [newAssignedUserID]
                , [performerUserID]
                , [notes]
                , [entryData]
                , [hostName]
            )
            VALUES
            (
                  @NewID
                , @idaraID_FK
                , N'CREATED'
                , NULL
                , @statusNewID
                , NULL
                , @svcDSDID
                , NULL
                , NULL
                , @requesterUserID_FK
                , N'Ticket created'
                , @entryData
                , @hostName
            );

            -- T039: Audit log
            SET @Note = N'{'
                + N'"ticketID":"' + CAST(@NewID AS NVARCHAR(20)) + N'"'
                + N',"ticketNo":"' + ISNULL(@NewTicketNo, N'') + N'"'
                + N',"idaraID_FK":"' + CAST(@idaraID_FK AS NVARCHAR(20)) + N'"'
                + N',"requesterTypeID_FK":"' + CAST(@requesterTypeID_FK AS NVARCHAR(20)) + N'"'
                + N',"serviceID_FK":"' + ISNULL(CAST(@serviceID_FK AS NVARCHAR(20)), N'null') + N'"'
                + N',"isOtherService":"' + CAST(ISNULL(@isOtherService, 0) AS NVARCHAR(5)) + N'"'
                + N',"rootTicketID_FK":"' + CAST(@NewID AS NVARCHAR(20)) + N'"'
                + N'}';

            INSERT INTO dbo.AuditLog (TableName, ActionType, RecordID, PerformedBy, Notes)
            VALUES (N'[Tickets].[Ticket]', N'INSERT_TICKET', @NewID, @entryData, @Note);

            SELECT 1 AS IsSuccessful
                 , N'Ticket created successfully: ' + @NewTicketNo AS Message_
                 , @NewID AS NewTicketID
                 , @NewTicketNo AS NewTicketNo;
            RETURN;
        END

        ----------------------------------------------------------------
        -- Unknown Action
        ----------------------------------------------------------------
        ELSE
        BEGIN
            ;THROW 50001, N'Unknown action for TicketSP', 1;
        END

    END TRY
    BEGIN CATCH
        IF @tc = 0 AND XACT_STATE() <> 0 ROLLBACK;
        ;THROW;
    END CATCH
END
