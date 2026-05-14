-- ============================================================================
-- Multi-Department Ticketing System — MSSQL Stored Procedures
-- ============================================================================
-- Description: All CRUD and business logic stored procedures with error
--              handling (TRY/CATCH), transactions, and automatic audit trail
--              logging via TicketHistories.
-- Target:      Microsoft SQL Server 2019+
-- Date:        April 16, 2026
-- ============================================================================

USE [TicketingSystem];
GO

-- ============================================================================
-- HELPER: Ticket Number Generator
-- ============================================================================
IF OBJECT_ID('dbo.fn_GenerateTicketNo', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_GenerateTicketNo;
GO

CREATE FUNCTION dbo.fn_GenerateTicketNo()
RETURNS NVARCHAR(30)
AS
BEGIN
    DECLARE @NextId INT;
    SELECT @NextId = ISNULL(MAX(Id), 0) + 1 FROM dbo.Tickets;
    RETURN N'TKT-' + CAST(YEAR(GETUTCDATE()) AS NVARCHAR(4)) + N'-' + RIGHT('0000' + CAST(@NextId AS NVARCHAR(4)), 4);
END;
GO

-- ============================================================================
-- 1. sp_CreateTicket
--    Creates a new ticket with auto-routing from service catalogue
-- ============================================================================
IF OBJECT_ID('dbo.sp_CreateTicket', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_CreateTicket;
GO

CREATE PROCEDURE dbo.sp_CreateTicket
    @Title              NVARCHAR(300),
    @Description        NVARCHAR(MAX),
    @Priority           NVARCHAR(20),
    @RequesterType      NVARCHAR(20),
    @RequesterName      NVARCHAR(200),
    @ServiceId          INT             = NULL,     -- NULL if "Other"
    @Location           NVARCHAR(300),
    @Performer          NVARCHAR(200)   = N'System',
    @NewTicketId        INT             OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @TicketNo       NVARCHAR(30);
        DECLARE @ServiceName    NVARCHAR(200);
        DECLARE @IsOtherService BIT;
        DECLARE @Department     NVARCHAR(100);
        DECLARE @Division       NVARCHAR(100);
        DECLARE @Section        NVARCHAR(100);
        DECLARE @CurrentQueue   NVARCHAR(200);
        DECLARE @Status         NVARCHAR(30);
        DECLARE @SlaResponseMin INT;
        DECLARE @SlaCompletionMin INT;
        DECLARE @Now            DATETIME2(7) = GETUTCDATE();

        -- Generate ticket number
        SELECT @TicketNo = N'TKT-' + CAST(YEAR(@Now) AS NVARCHAR(4)) + N'-' +
            RIGHT('0000' + CAST((ISNULL((SELECT MAX(Id) FROM dbo.Tickets), 0) + 1) AS NVARCHAR(4)), 4);

        -- Determine routing based on service
        IF @ServiceId IS NOT NULL
        BEGIN
            SELECT
                @ServiceName    = NameEn,
                @IsOtherService = 0,
                @Department     = Department,
                @Division       = Division,
                @Section        = Section,
                @CurrentQueue   = Division + N' - ' + Section,
                @Status         = N'Open',
                @SlaResponseMin = SlaResponseMin,
                @SlaCompletionMin = SlaCompletionMin
            FROM dbo.Services
            WHERE Id = @ServiceId AND IsActive = 1;

            IF @ServiceName IS NULL
            BEGIN
                RAISERROR('Service not found or inactive.', 16, 1);
                RETURN;
            END;
        END
        ELSE
        BEGIN
            -- "Other" service — goes to arbitration
            SET @ServiceName    = N'Other';
            SET @IsOtherService = 1;
            SET @Department     = N'Unassigned';
            SET @Division       = N'-';
            SET @Section        = N'-';
            SET @CurrentQueue   = N'Arbitration Queue';
            SET @Status         = N'PendingArbitration';
            SET @SlaResponseMin = 60;
            SET @SlaCompletionMin = 1440;
        END;

        -- Insert the ticket
        INSERT INTO dbo.Tickets (
            TicketNo, Title, Description, Status, Priority, RequesterType, RequesterName,
            ServiceId, ServiceName, IsOtherService, Department, Division, Section, CurrentQueue,
            AssignedUser, ParentTicketId, IsParentBlocked, RequiresQualityReview,
            CreatedAt, UpdatedAt, ResolvedAt, ClosedAt,
            SlaBreached, SlaResponseRemainMin, SlaCompletionRemainMin, Location
        )
        VALUES (
            @TicketNo, @Title, @Description, @Status, @Priority, @RequesterType, @RequesterName,
            @ServiceId, @ServiceName, @IsOtherService, @Department, @Division, @Section, @CurrentQueue,
            NULL, NULL, 0, 0,
            @Now, @Now, NULL, NULL,
            0, @SlaResponseMin, @SlaCompletionMin, @Location
        );

        SET @NewTicketId = SCOPE_IDENTITY();

        -- Log history: Ticket Created
        INSERT INTO dbo.TicketHistories (TicketId, Action, OldStatus, NewStatus, Performer, Notes, Date)
        VALUES (@NewTicketId, N'Ticket Created', NULL, @Status, @Performer,
                N'Ticket created by ' + LOWER(@RequesterType) + N' ' + @RequesterName, @Now);

        -- Log history: Auto-routed
        INSERT INTO dbo.TicketHistories (TicketId, Action, OldStatus, NewStatus, Performer, Notes, Date)
        VALUES (@NewTicketId, N'Routed to Queue', @Status, @Status, N'System',
                N'Auto-routed to ' + @CurrentQueue + N' based on service routing rule',
                DATEADD(SECOND, 5, @Now));

        -- If "Other", auto-create arbitration case
        IF @IsOtherService = 1
        BEGIN
            INSERT INTO dbo.ArbitrationCases (TicketId, RaisedBy, FromDSD, Reason, Status, Arbitrator, Decision, DecisionTarget, CreatedAt, ResolvedAt)
            VALUES (@NewTicketId, N'System', N'N/A',
                    N'Unknown service - requires arbitration to determine responsible department',
                    N'Open', N'Central Operations Manager', NULL, NULL, @Now, NULL);
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ============================================================================
-- 2. sp_AssignTicket
--    Assigns a ticket to a user (Open -> Assigned)
-- ============================================================================
IF OBJECT_ID('dbo.sp_AssignTicket', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_AssignTicket;
GO

CREATE PROCEDURE dbo.sp_AssignTicket
    @TicketId       INT,
    @AssignedUser   NVARCHAR(200),
    @Performer      NVARCHAR(200),
    @Notes          NVARCHAR(MAX) = N''
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @OldStatus NVARCHAR(30);
        DECLARE @Now DATETIME2(7) = GETUTCDATE();

        SELECT @OldStatus = Status FROM dbo.Tickets WHERE Id = @TicketId;

        IF @OldStatus IS NULL
        BEGIN
            RAISERROR('Ticket not found.', 16, 1);
            RETURN;
        END;

        IF @OldStatus <> 'Open'
        BEGIN
            RAISERROR('Ticket must be in Open status to assign. Current status: %s', 16, 1, @OldStatus);
            RETURN;
        END;

        UPDATE dbo.Tickets
        SET Status = N'Assigned',
            AssignedUser = @AssignedUser,
            UpdatedAt = @Now
        WHERE Id = @TicketId;

        INSERT INTO dbo.TicketHistories (TicketId, Action, OldStatus, NewStatus, Performer, Notes, Date)
        VALUES (@TicketId, N'Assigned', @OldStatus, N'Assigned', @Performer,
                CASE WHEN @Notes = N'' THEN N'Assigned to ' + @AssignedUser ELSE @Notes END, @Now);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ============================================================================
-- 3. sp_StartWork
--    Starts work on a ticket (Assigned -> InProgress)
-- ============================================================================
IF OBJECT_ID('dbo.sp_StartWork', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_StartWork;
GO

CREATE PROCEDURE dbo.sp_StartWork
    @TicketId   INT,
    @Performer  NVARCHAR(200),
    @Notes      NVARCHAR(MAX) = N''
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @OldStatus NVARCHAR(30);
        DECLARE @Now DATETIME2(7) = GETUTCDATE();

        SELECT @OldStatus = Status FROM dbo.Tickets WHERE Id = @TicketId;

        IF @OldStatus IS NULL
        BEGIN
            RAISERROR('Ticket not found.', 16, 1);
            RETURN;
        END;

        IF @OldStatus <> 'Assigned'
        BEGIN
            RAISERROR('Ticket must be in Assigned status to start work. Current status: %s', 16, 1, @OldStatus);
            RETURN;
        END;

        UPDATE dbo.Tickets
        SET Status = N'InProgress',
            UpdatedAt = @Now
        WHERE Id = @TicketId;

        INSERT INTO dbo.TicketHistories (TicketId, Action, OldStatus, NewStatus, Performer, Notes, Date)
        VALUES (@TicketId, N'Work Started', @OldStatus, N'InProgress', @Performer,
                CASE WHEN @Notes = N'' THEN N'Work started on ticket' ELSE @Notes END, @Now);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ============================================================================
-- 4. sp_PauseTicket
--    Pauses a ticket (InProgress -> Paused) and creates a PauseSession
-- ============================================================================
IF OBJECT_ID('dbo.sp_PauseTicket', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_PauseTicket;
GO

CREATE PROCEDURE dbo.sp_PauseTicket
    @TicketId               INT,
    @Reason                 NVARCHAR(50),
    @Notes                  NVARCHAR(MAX) = N'',
    @Performer              NVARCHAR(200) = N'System',
    @RelatedChildTicketId   INT = NULL,
    @RelatedArbitrationId   INT = NULL,
    @RelatedClarificationId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @OldStatus NVARCHAR(30);
        DECLARE @Now DATETIME2(7) = GETUTCDATE();

        SELECT @OldStatus = Status FROM dbo.Tickets WHERE Id = @TicketId;

        IF @OldStatus IS NULL
        BEGIN
            RAISERROR('Ticket not found.', 16, 1);
            RETURN;
        END;

        IF @OldStatus <> 'InProgress'
        BEGIN
            RAISERROR('Ticket must be in InProgress status to pause. Current status: %s', 16, 1, @OldStatus);
            RETURN;
        END;

        UPDATE dbo.Tickets
        SET Status = N'Paused',
            UpdatedAt = @Now
        WHERE Id = @TicketId;

        -- Create pause session
        INSERT INTO dbo.PauseSessions (TicketId, Reason, RelatedChildTicketId, RelatedArbitrationId, RelatedClarificationId, StartedAt, EndedAt, Notes)
        VALUES (@TicketId, @Reason, @RelatedChildTicketId, @RelatedArbitrationId, @RelatedClarificationId, @Now, NULL,
                CASE WHEN @Notes = N'' THEN N'Paused due to ' + @Reason ELSE @Notes END);

        INSERT INTO dbo.TicketHistories (TicketId, Action, OldStatus, NewStatus, Performer, Notes, Date)
        VALUES (@TicketId, N'Paused', @OldStatus, N'Paused', @Performer,
                CASE WHEN @Notes = N'' THEN N'Paused due to ' + @Reason ELSE @Notes END, @Now);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ============================================================================
-- 5. sp_ResumeTicket
--    Resumes a paused ticket (Paused -> InProgress) and ends active pause sessions
-- ============================================================================
IF OBJECT_ID('dbo.sp_ResumeTicket', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ResumeTicket;
GO

CREATE PROCEDURE dbo.sp_ResumeTicket
    @TicketId   INT,
    @Performer  NVARCHAR(200),
    @Notes      NVARCHAR(MAX) = N''
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @OldStatus NVARCHAR(30);
        DECLARE @Now DATETIME2(7) = GETUTCDATE();

        SELECT @OldStatus = Status FROM dbo.Tickets WHERE Id = @TicketId;

        IF @OldStatus IS NULL
        BEGIN
            RAISERROR('Ticket not found.', 16, 1);
            RETURN;
        END;

        IF @OldStatus <> 'Paused'
        BEGIN
            RAISERROR('Ticket must be in Paused status to resume. Current status: %s', 16, 1, @OldStatus);
            RETURN;
        END;

        -- End all active pause sessions for this ticket
        UPDATE dbo.PauseSessions
        SET EndedAt = @Now
        WHERE TicketId = @TicketId AND EndedAt IS NULL;

        -- Update ticket status
        UPDATE dbo.Tickets
        SET Status = N'InProgress',
            IsParentBlocked = 0,
            UpdatedAt = @Now
        WHERE Id = @TicketId;

        INSERT INTO dbo.TicketHistories (TicketId, Action, OldStatus, NewStatus, Performer, Notes, Date)
        VALUES (@TicketId, N'Resumed', @OldStatus, N'InProgress', @Performer,
                CASE WHEN @Notes = N'' THEN N'Work resumed' ELSE @Notes END, @Now);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ============================================================================
-- 6. sp_ResolveTicket
--    Resolves a ticket (InProgress -> Resolved)
-- ============================================================================
IF OBJECT_ID('dbo.sp_ResolveTicket', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ResolveTicket;
GO

CREATE PROCEDURE dbo.sp_ResolveTicket
    @TicketId   INT,
    @Performer  NVARCHAR(200),
    @Notes      NVARCHAR(MAX) = N''
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @OldStatus NVARCHAR(30);
        DECLARE @Now DATETIME2(7) = GETUTCDATE();

        SELECT @OldStatus = Status FROM dbo.Tickets WHERE Id = @TicketId;

        IF @OldStatus IS NULL
        BEGIN
            RAISERROR('Ticket not found.', 16, 1);
            RETURN;
        END;

        IF @OldStatus <> 'InProgress'
        BEGIN
            RAISERROR('Ticket must be in InProgress status to resolve. Current status: %s', 16, 1, @OldStatus);
            RETURN;
        END;

        UPDATE dbo.Tickets
        SET Status = N'Resolved',
            ResolvedAt = @Now,
            UpdatedAt = @Now
        WHERE Id = @TicketId;

        INSERT INTO dbo.TicketHistories (TicketId, Action, OldStatus, NewStatus, Performer, Notes, Date)
        VALUES (@TicketId, N'Resolved', @OldStatus, N'Resolved', @Performer,
                CASE WHEN @Notes = N'' THEN N'Ticket resolved' ELSE @Notes END, @Now);

        -- If this is a child ticket, check if parent can be unblocked
        DECLARE @ParentId INT;
        SELECT @ParentId = ParentTicketId FROM dbo.Tickets WHERE Id = @TicketId;

        IF @ParentId IS NOT NULL
        BEGIN
            -- Check if all child tickets of the parent are resolved/closed
            DECLARE @UnresolvedChildren INT;
            SELECT @UnresolvedChildren = COUNT(*)
            FROM dbo.Tickets
            WHERE ParentTicketId = @ParentId
              AND Status NOT IN ('Resolved', 'Closed')
              AND Id <> @TicketId;

            IF @UnresolvedChildren = 0
            BEGIN
                -- Unblock parent
                UPDATE dbo.Tickets
                SET IsParentBlocked = 0,
                    UpdatedAt = @Now
                WHERE Id = @ParentId;

                -- End child dependency pause sessions on parent
                UPDATE dbo.PauseSessions
                SET EndedAt = @Now
                WHERE TicketId = @ParentId
                  AND Reason = N'ChildDependency'
                  AND EndedAt IS NULL;

                -- If parent is Paused, resume it
                DECLARE @ParentStatus NVARCHAR(30);
                SELECT @ParentStatus = Status FROM dbo.Tickets WHERE Id = @ParentId;

                IF @ParentStatus = 'Paused'
                BEGIN
                    -- Check if there are other active pause sessions
                    DECLARE @OtherActivePauses INT;
                    SELECT @OtherActivePauses = COUNT(*)
                    FROM dbo.PauseSessions
                    WHERE TicketId = @ParentId AND EndedAt IS NULL;

                    IF @OtherActivePauses = 0
                    BEGIN
                        UPDATE dbo.Tickets
                        SET Status = N'InProgress',
                            UpdatedAt = @Now
                        WHERE Id = @ParentId;

                        INSERT INTO dbo.TicketHistories (TicketId, Action, OldStatus, NewStatus, Performer, Notes, Date)
                        VALUES (@ParentId, N'Resumed', N'Paused', N'InProgress', N'System',
                                N'Auto-resumed: all child tickets resolved', @Now);
                    END;
                END;
            END;
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ============================================================================
-- 7. sp_CloseTicket
--    Closes a resolved ticket (Resolved -> Closed)
-- ============================================================================
IF OBJECT_ID('dbo.sp_CloseTicket', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_CloseTicket;
GO

CREATE PROCEDURE dbo.sp_CloseTicket
    @TicketId   INT,
    @Performer  NVARCHAR(200),
    @Notes      NVARCHAR(MAX) = N''
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @OldStatus NVARCHAR(30);
        DECLARE @Now DATETIME2(7) = GETUTCDATE();

        SELECT @OldStatus = Status FROM dbo.Tickets WHERE Id = @TicketId;

        IF @OldStatus IS NULL
        BEGIN
            RAISERROR('Ticket not found.', 16, 1);
            RETURN;
        END;

        IF @OldStatus <> 'Resolved'
        BEGIN
            RAISERROR('Ticket must be in Resolved status to close. Current status: %s', 16, 1, @OldStatus);
            RETURN;
        END;

        UPDATE dbo.Tickets
        SET Status = N'Closed',
            ClosedAt = @Now,
            UpdatedAt = @Now
        WHERE Id = @TicketId;

        INSERT INTO dbo.TicketHistories (TicketId, Action, OldStatus, NewStatus, Performer, Notes, Date)
        VALUES (@TicketId, N'Closed', @OldStatus, N'Closed', @Performer,
                CASE WHEN @Notes = N'' THEN N'Ticket closed' ELSE @Notes END, @Now);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ============================================================================
-- 8. sp_CreateChildTicket
--    Creates a child ticket and optionally pauses the parent
-- ============================================================================
IF OBJECT_ID('dbo.sp_CreateChildTicket', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_CreateChildTicket;
GO

CREATE PROCEDURE dbo.sp_CreateChildTicket
    @ParentTicketId     INT,
    @Title              NVARCHAR(300),
    @Description        NVARCHAR(MAX),
    @Priority           NVARCHAR(20),
    @ServiceId          INT = NULL,
    @Location           NVARCHAR(300),
    @Performer          NVARCHAR(200),
    @Notes              NVARCHAR(MAX) = N'',
    @PauseParent        BIT = 1,
    @NewChildTicketId   INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Now DATETIME2(7) = GETUTCDATE();
        DECLARE @ParentStatus NVARCHAR(30);
        DECLARE @ParentRequesterType NVARCHAR(20);
        DECLARE @ParentRequesterName NVARCHAR(200);

        -- Validate parent ticket
        SELECT
            @ParentStatus = Status,
            @ParentRequesterType = RequesterType,
            @ParentRequesterName = RequesterName
        FROM dbo.Tickets
        WHERE Id = @ParentTicketId;

        IF @ParentStatus IS NULL
        BEGIN
            RAISERROR('Parent ticket not found.', 16, 1);
            RETURN;
        END;

        IF @ParentStatus IN ('Resolved', 'Closed')
        BEGIN
            RAISERROR('Cannot create child ticket for a resolved or closed parent.', 16, 1);
            RETURN;
        END;

        -- Create the child ticket using sp_CreateTicket
        EXEC dbo.sp_CreateTicket
            @Title = @Title,
            @Description = @Description,
            @Priority = @Priority,
            @RequesterType = @ParentRequesterType,
            @RequesterName = @ParentRequesterName,
            @ServiceId = @ServiceId,
            @Location = @Location,
            @Performer = @Performer,
            @NewTicketId = @NewChildTicketId OUTPUT;

        -- Set parent reference on child
        UPDATE dbo.Tickets
        SET ParentTicketId = @ParentTicketId
        WHERE Id = @NewChildTicketId;

        -- Log on parent: child created
        INSERT INTO dbo.TicketHistories (TicketId, Action, OldStatus, NewStatus, Performer, Notes, Date)
        VALUES (@ParentTicketId, N'Child Ticket Created', @ParentStatus, @ParentStatus, @Performer,
                N'Created child ticket ' + (SELECT TicketNo FROM dbo.Tickets WHERE Id = @NewChildTicketId) +
                CASE WHEN @Notes = N'' THEN N'' ELSE N' - ' + @Notes END, @Now);

        -- Optionally pause the parent
        IF @PauseParent = 1 AND @ParentStatus = 'InProgress'
        BEGIN
            UPDATE dbo.Tickets
            SET Status = N'Paused',
                IsParentBlocked = 1,
                UpdatedAt = @Now
            WHERE Id = @ParentTicketId;

            INSERT INTO dbo.PauseSessions (TicketId, Reason, RelatedChildTicketId, RelatedArbitrationId, RelatedClarificationId, StartedAt, EndedAt, Notes)
            VALUES (@ParentTicketId, N'ChildDependency', @NewChildTicketId, NULL, NULL, @Now, NULL,
                    N'Waiting for child ticket completion');

            INSERT INTO dbo.TicketHistories (TicketId, Action, OldStatus, NewStatus, Performer, Notes, Date)
            VALUES (@ParentTicketId, N'Paused', @ParentStatus, N'Paused', N'System',
                    N'Paused due to child dependency (' + (SELECT TicketNo FROM dbo.Tickets WHERE Id = @NewChildTicketId) + N')',
                    DATEADD(SECOND, 5, @Now));
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ============================================================================
-- 9. sp_RequestClarification
--    Creates a clarification request and changes ticket status
-- ============================================================================
IF OBJECT_ID('dbo.sp_RequestClarification', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_RequestClarification;
GO

CREATE PROCEDURE dbo.sp_RequestClarification
    @TicketId       INT,
    @RequestedBy    NVARCHAR(200),
    @TargetUser     NVARCHAR(200),
    @Reason         NVARCHAR(200),
    @RequestNotes   NVARCHAR(MAX),
    @NewRequestId   INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @OldStatus NVARCHAR(30);
        DECLARE @Now DATETIME2(7) = GETUTCDATE();

        SELECT @OldStatus = Status FROM dbo.Tickets WHERE Id = @TicketId;

        IF @OldStatus IS NULL
        BEGIN
            RAISERROR('Ticket not found.', 16, 1);
            RETURN;
        END;

        IF @OldStatus IN ('Resolved', 'Closed')
        BEGIN
            RAISERROR('Cannot request clarification on a resolved or closed ticket.', 16, 1);
            RETURN;
        END;

        -- Create clarification request
        INSERT INTO dbo.ClarificationRequests (TicketId, RequestedBy, TargetUser, Reason, Status, RequestNotes, ResponseNotes, CreatedAt, RespondedAt)
        VALUES (@TicketId, @RequestedBy, @TargetUser, @Reason, N'Open', @RequestNotes, NULL, @Now, NULL);

        SET @NewRequestId = SCOPE_IDENTITY();

        -- Update ticket status to PendingClarification
        UPDATE dbo.Tickets
        SET Status = N'PendingClarification',
            UpdatedAt = @Now
        WHERE Id = @TicketId;

        INSERT INTO dbo.TicketHistories (TicketId, Action, OldStatus, NewStatus, Performer, Notes, Date)
        VALUES (@TicketId, N'Clarification Requested', @OldStatus, N'PendingClarification', @RequestedBy,
                N'Clarification requested from ' + @TargetUser + N': ' + @Reason, @Now);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ============================================================================
-- 10. sp_RespondToClarification
--     Records a response to a clarification request
-- ============================================================================
IF OBJECT_ID('dbo.sp_RespondToClarification', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_RespondToClarification;
GO

CREATE PROCEDURE dbo.sp_RespondToClarification
    @ClarificationId    INT,
    @ResponseNotes      NVARCHAR(MAX),
    @Performer          NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @TicketId INT;
        DECLARE @ClarStatus NVARCHAR(30);
        DECLARE @OldTicketStatus NVARCHAR(30);
        DECLARE @Now DATETIME2(7) = GETUTCDATE();

        SELECT @TicketId = TicketId, @ClarStatus = Status
        FROM dbo.ClarificationRequests
        WHERE Id = @ClarificationId;

        IF @TicketId IS NULL
        BEGIN
            RAISERROR('Clarification request not found.', 16, 1);
            RETURN;
        END;

        IF @ClarStatus <> 'Open'
        BEGIN
            RAISERROR('Clarification request is not in Open status.', 16, 1);
            RETURN;
        END;

        -- Update clarification request
        UPDATE dbo.ClarificationRequests
        SET Status = N'Responded',
            ResponseNotes = @ResponseNotes,
            RespondedAt = @Now
        WHERE Id = @ClarificationId;

        -- Check if there are other open clarification requests for this ticket
        DECLARE @OtherOpenClarifications INT;
        SELECT @OtherOpenClarifications = COUNT(*)
        FROM dbo.ClarificationRequests
        WHERE TicketId = @TicketId AND Status = N'Open' AND Id <> @ClarificationId;

        SELECT @OldTicketStatus = Status FROM dbo.Tickets WHERE Id = @TicketId;

        -- If no other open clarifications, revert ticket to previous active status
        IF @OtherOpenClarifications = 0 AND @OldTicketStatus = 'PendingClarification'
        BEGIN
            -- Determine what status to revert to (check if assigned user exists)
            DECLARE @AssignedUser NVARCHAR(200);
            SELECT @AssignedUser = AssignedUser FROM dbo.Tickets WHERE Id = @TicketId;

            DECLARE @NewStatus NVARCHAR(30);
            SET @NewStatus = CASE
                WHEN @AssignedUser IS NOT NULL THEN N'InProgress'
                ELSE N'Open'
            END;

            UPDATE dbo.Tickets
            SET Status = @NewStatus,
                UpdatedAt = @Now
            WHERE Id = @TicketId;

            INSERT INTO dbo.TicketHistories (TicketId, Action, OldStatus, NewStatus, Performer, Notes, Date)
            VALUES (@TicketId, N'Clarification Responded', @OldTicketStatus, @NewStatus, @Performer,
                    N'Clarification response received. Ticket status updated.', @Now);
        END
        ELSE
        BEGIN
            INSERT INTO dbo.TicketHistories (TicketId, Action, OldStatus, NewStatus, Performer, Notes, Date)
            VALUES (@TicketId, N'Clarification Responded', @OldTicketStatus, @OldTicketStatus, @Performer,
                    N'Clarification response received.', @Now);
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ============================================================================
-- 11. sp_RaiseArbitration
--     Creates an arbitration case and changes ticket status
-- ============================================================================
IF OBJECT_ID('dbo.sp_RaiseArbitration', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_RaiseArbitration;
GO

CREATE PROCEDURE dbo.sp_RaiseArbitration
    @TicketId       INT,
    @RaisedBy       NVARCHAR(200),
    @Reason         NVARCHAR(MAX),
    @Arbitrator     NVARCHAR(200) = N'Central Operations Manager',
    @Notes          NVARCHAR(MAX) = N'',
    @NewCaseId      INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @OldStatus NVARCHAR(30);
        DECLARE @FromDSD NVARCHAR(200);
        DECLARE @Now DATETIME2(7) = GETUTCDATE();

        SELECT @OldStatus = Status,
               @FromDSD = Department + N' / ' + Division + N' / ' + Section
        FROM dbo.Tickets
        WHERE Id = @TicketId;

        IF @OldStatus IS NULL
        BEGIN
            RAISERROR('Ticket not found.', 16, 1);
            RETURN;
        END;

        IF @OldStatus IN ('Resolved', 'Closed')
        BEGIN
            RAISERROR('Cannot raise arbitration on a resolved or closed ticket.', 16, 1);
            RETURN;
        END;

        -- Create arbitration case
        INSERT INTO dbo.ArbitrationCases (TicketId, RaisedBy, FromDSD, Reason, Status, Arbitrator, Decision, DecisionTarget, CreatedAt, ResolvedAt)
        VALUES (@TicketId, @RaisedBy, @FromDSD, @Reason, N'Open', @Arbitrator, NULL, NULL, @Now, NULL);

        SET @NewCaseId = SCOPE_IDENTITY();

        -- Update ticket status
        UPDATE dbo.Tickets
        SET Status = N'PendingArbitration',
            UpdatedAt = @Now
        WHERE Id = @TicketId;

        INSERT INTO dbo.TicketHistories (TicketId, Action, OldStatus, NewStatus, Performer, Notes, Date)
        VALUES (@TicketId, N'Arbitration Raised', @OldStatus, N'PendingArbitration', @RaisedBy,
                N'Arbitration case raised: ' + @Reason +
                CASE WHEN @Notes = N'' THEN N'' ELSE N' - ' + @Notes END, @Now);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ============================================================================
-- 12. sp_ResolveArbitration
--     Resolves an arbitration case with a decision
-- ============================================================================
IF OBJECT_ID('dbo.sp_ResolveArbitration', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ResolveArbitration;
GO

CREATE PROCEDURE dbo.sp_ResolveArbitration
    @ArbitrationId      INT,
    @Decision           NVARCHAR(200),      -- e.g., 'Redirect', 'Overruled', 'Cancelled'
    @DecisionTarget     NVARCHAR(200) = NULL,
    @NewDepartment      NVARCHAR(100) = NULL,
    @NewDivision        NVARCHAR(100) = NULL,
    @NewSection         NVARCHAR(100) = NULL,
    @Performer          NVARCHAR(200),
    @Notes              NVARCHAR(MAX) = N''
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @TicketId INT;
        DECLARE @ArbStatus NVARCHAR(30);
        DECLARE @OldTicketStatus NVARCHAR(30);
        DECLARE @Now DATETIME2(7) = GETUTCDATE();

        SELECT @TicketId = TicketId, @ArbStatus = Status
        FROM dbo.ArbitrationCases
        WHERE Id = @ArbitrationId;

        IF @TicketId IS NULL
        BEGIN
            RAISERROR('Arbitration case not found.', 16, 1);
            RETURN;
        END;

        IF @ArbStatus <> 'Open'
        BEGIN
            RAISERROR('Arbitration case is not in Open status.', 16, 1);
            RETURN;
        END;

        -- Determine new arbitration status based on decision
        DECLARE @NewArbStatus NVARCHAR(30);
        SET @NewArbStatus = CASE
            WHEN @Decision = N'Redirect' THEN N'Redirected'
            WHEN @Decision = N'Overrule' THEN N'Overruled'
            WHEN @Decision = N'Cancel' THEN N'Cancelled'
            ELSE N'Redirected'
        END;

        -- Update arbitration case
        UPDATE dbo.ArbitrationCases
        SET Status = @NewArbStatus,
            Decision = @Decision,
            DecisionTarget = @DecisionTarget,
            ResolvedAt = @Now
        WHERE Id = @ArbitrationId;

        SELECT @OldTicketStatus = Status FROM dbo.Tickets WHERE Id = @TicketId;

        -- If redirected, update ticket routing
        IF @Decision = N'Redirect' AND @NewDepartment IS NOT NULL
        BEGIN
            UPDATE dbo.Tickets
            SET Department = @NewDepartment,
                Division = ISNULL(@NewDivision, Division),
                Section = ISNULL(@NewSection, Section),
                CurrentQueue = ISNULL(@NewDivision, Division) + N' - ' + ISNULL(@NewSection, Section),
                Status = N'Open',
                UpdatedAt = @Now
            WHERE Id = @TicketId;

            INSERT INTO dbo.TicketHistories (TicketId, Action, OldStatus, NewStatus, Performer, Notes, Date)
            VALUES (@TicketId, N'Arbitration Resolved', @OldTicketStatus, N'Open', @Performer,
                    N'Decision: ' + @Decision + N' to ' + ISNULL(@DecisionTarget, N'N/A') +
                    CASE WHEN @Notes = N'' THEN N'' ELSE N' - ' + @Notes END, @Now);
        END
        ELSE
        BEGIN
            -- Revert to Open status
            UPDATE dbo.Tickets
            SET Status = N'Open',
                UpdatedAt = @Now
            WHERE Id = @TicketId;

            INSERT INTO dbo.TicketHistories (TicketId, Action, OldStatus, NewStatus, Performer, Notes, Date)
            VALUES (@TicketId, N'Arbitration Resolved', @OldTicketStatus, N'Open', @Performer,
                    N'Decision: ' + @Decision +
                    CASE WHEN @Notes = N'' THEN N'' ELSE N' - ' + @Notes END, @Now);
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ============================================================================
-- 13. sp_SubmitQualityReview
--     Submits a quality review result for a resolved ticket
-- ============================================================================
IF OBJECT_ID('dbo.sp_SubmitQualityReview', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SubmitQualityReview;
GO

CREATE PROCEDURE dbo.sp_SubmitQualityReview
    @TicketId       INT,
    @Reviewer       NVARCHAR(200),
    @Result         NVARCHAR(30) = NULL,    -- NULL = create pending review; 'Approved'/'ReturnedForCorrection'/'Rejected' = submit result
    @Notes          NVARCHAR(MAX),
    @ReviewId       INT = NULL              -- If provided, update existing review; otherwise create new
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Now DATETIME2(7) = GETUTCDATE();
        DECLARE @OldStatus NVARCHAR(30);

        SELECT @OldStatus = Status FROM dbo.Tickets WHERE Id = @TicketId;

        IF @OldStatus IS NULL
        BEGIN
            RAISERROR('Ticket not found.', 16, 1);
            RETURN;
        END;

        IF @ReviewId IS NOT NULL
        BEGIN
            -- Update existing review
            UPDATE dbo.QualityReviews
            SET Result = @Result,
                Notes = @Notes,
                ReviewedAt = @Now
            WHERE Id = @ReviewId AND TicketId = @TicketId;

            INSERT INTO dbo.TicketHistories (TicketId, Action, OldStatus, NewStatus, Performer, Notes, Date)
            VALUES (@TicketId, N'Quality Review Submitted', @OldStatus, @OldStatus, @Reviewer,
                    N'Quality review result: ' + ISNULL(@Result, N'Pending') + N' - ' + @Notes, @Now);

            -- If result is Approved, close the ticket
            IF @Result = N'Approved'
            BEGIN
                UPDATE dbo.Tickets
                SET Status = N'Closed',
                    ClosedAt = @Now,
                    UpdatedAt = @Now
                WHERE Id = @TicketId;

                INSERT INTO dbo.TicketHistories (TicketId, Action, OldStatus, NewStatus, Performer, Notes, Date)
                VALUES (@TicketId, N'Closed', @OldStatus, N'Closed', N'System',
                        N'Auto-closed after quality review approval', @Now);
            END
            ELSE IF @Result = N'ReturnedForCorrection'
            BEGIN
                -- Reopen the ticket
                UPDATE dbo.Tickets
                SET Status = N'InProgress',
                    ResolvedAt = NULL,
                    UpdatedAt = @Now
                WHERE Id = @TicketId;

                INSERT INTO dbo.TicketHistories (TicketId, Action, OldStatus, NewStatus, Performer, Notes, Date)
                VALUES (@TicketId, N'Returned for Correction', @OldStatus, N'InProgress', @Reviewer,
                        N'Quality review returned for correction', @Now);
            END;
        END
        ELSE
        BEGIN
            -- Create new pending review
            INSERT INTO dbo.QualityReviews (TicketId, Reviewer, Result, Notes, CreatedAt, ReviewedAt)
            VALUES (@TicketId, @Reviewer, @Result, @Notes, @Now,
                    CASE WHEN @Result IS NOT NULL THEN @Now ELSE NULL END);

            INSERT INTO dbo.TicketHistories (TicketId, Action, OldStatus, NewStatus, Performer, Notes, Date)
            VALUES (@TicketId, N'Quality Review Created', @OldStatus, @OldStatus, @Reviewer,
                    N'Quality review initiated: ' + @Notes, @Now);
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ============================================================================
-- 14. sp_GetTicketById
--     Retrieves a single ticket with all related data
-- ============================================================================
IF OBJECT_ID('dbo.sp_GetTicketById', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetTicketById;
GO

CREATE PROCEDURE dbo.sp_GetTicketById
    @TicketId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Result Set 1: Ticket detail
    SELECT * FROM dbo.vw_TicketDetail WHERE Id = @TicketId;

    -- Result Set 2: Child tickets
    SELECT
        Id, TicketNo, Title, Status, Priority, CreatedAt
    FROM dbo.Tickets
    WHERE ParentTicketId = @TicketId
    ORDER BY CreatedAt;

    -- Result Set 3: Ticket history (audit trail)
    SELECT
        Id, TicketId, Action, OldStatus, NewStatus, Performer, Notes, Date
    FROM dbo.TicketHistories
    WHERE TicketId = @TicketId
    ORDER BY Date DESC;

    -- Result Set 4: Arbitration cases
    SELECT *
    FROM dbo.ArbitrationCases
    WHERE TicketId = @TicketId
    ORDER BY CreatedAt DESC;

    -- Result Set 5: Clarification requests
    SELECT *
    FROM dbo.ClarificationRequests
    WHERE TicketId = @TicketId
    ORDER BY CreatedAt DESC;

    -- Result Set 6: Quality reviews
    SELECT *
    FROM dbo.QualityReviews
    WHERE TicketId = @TicketId
    ORDER BY CreatedAt DESC;

    -- Result Set 7: Pause sessions
    SELECT *
    FROM dbo.PauseSessions
    WHERE TicketId = @TicketId
    ORDER BY StartedAt DESC;
END;
GO

-- ============================================================================
-- 15. sp_GetTicketQueue
--     Retrieves filtered ticket list for the Ticket Queue page
-- ============================================================================
IF OBJECT_ID('dbo.sp_GetTicketQueue', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetTicketQueue;
GO

CREATE PROCEDURE dbo.sp_GetTicketQueue
    @SearchTerm     NVARCHAR(200)   = NULL,
    @StatusFilter   NVARCHAR(30)    = NULL,
    @PriorityFilter NVARCHAR(20)    = NULL,
    @DepartmentFilter NVARCHAR(100) = NULL,
    @PageNumber     INT             = 1,
    @PageSize       INT             = 50,
    @SortColumn     NVARCHAR(50)    = N'CreatedAt',
    @SortDirection  NVARCHAR(4)     = N'DESC'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    -- Total count for pagination
    SELECT COUNT(*) AS TotalCount
    FROM dbo.Tickets t
    WHERE (@SearchTerm IS NULL OR (
        t.TicketNo LIKE N'%' + @SearchTerm + N'%' OR
        t.Title LIKE N'%' + @SearchTerm + N'%' OR
        t.RequesterName LIKE N'%' + @SearchTerm + N'%' OR
        t.ServiceName LIKE N'%' + @SearchTerm + N'%'
    ))
    AND (@StatusFilter IS NULL OR t.Status = @StatusFilter)
    AND (@PriorityFilter IS NULL OR t.Priority = @PriorityFilter)
    AND (@DepartmentFilter IS NULL OR t.Department = @DepartmentFilter);

    -- Paginated results
    SELECT
        t.Id,
        t.TicketNo,
        t.Title,
        t.Status,
        t.Priority,
        t.RequesterType,
        t.RequesterName,
        t.ServiceName,
        t.IsOtherService,
        t.Department,
        t.AssignedUser,
        t.SlaBreached,
        t.SlaCompletionRemainMin,
        t.CreatedAt,
        CASE WHEN t.Status NOT IN ('Resolved', 'Closed') THEN 1 ELSE 0 END AS IsActive
    FROM dbo.Tickets t
    WHERE (@SearchTerm IS NULL OR (
        t.TicketNo LIKE N'%' + @SearchTerm + N'%' OR
        t.Title LIKE N'%' + @SearchTerm + N'%' OR
        t.RequesterName LIKE N'%' + @SearchTerm + N'%' OR
        t.ServiceName LIKE N'%' + @SearchTerm + N'%'
    ))
    AND (@StatusFilter IS NULL OR t.Status = @StatusFilter)
    AND (@PriorityFilter IS NULL OR t.Priority = @PriorityFilter)
    AND (@DepartmentFilter IS NULL OR t.Department = @DepartmentFilter)
    ORDER BY
        CASE WHEN @SortColumn = N'CreatedAt' AND @SortDirection = N'DESC' THEN t.CreatedAt END DESC,
        CASE WHEN @SortColumn = N'CreatedAt' AND @SortDirection = N'ASC' THEN t.CreatedAt END ASC,
        CASE WHEN @SortColumn = N'Priority' AND @SortDirection = N'DESC' THEN
            CASE t.Priority WHEN 'Critical' THEN 1 WHEN 'High' THEN 2 WHEN 'Medium' THEN 3 WHEN 'Low' THEN 4 END
        END ASC,
        CASE WHEN @SortColumn = N'Priority' AND @SortDirection = N'ASC' THEN
            CASE t.Priority WHEN 'Critical' THEN 1 WHEN 'High' THEN 2 WHEN 'Medium' THEN 3 WHEN 'Low' THEN 4 END
        END DESC,
        CASE WHEN @SortColumn = N'TicketNo' AND @SortDirection = N'DESC' THEN t.TicketNo END DESC,
        CASE WHEN @SortColumn = N'TicketNo' AND @SortDirection = N'ASC' THEN t.TicketNo END ASC,
        t.CreatedAt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- ============================================================================
-- 16. sp_GetDashboardStats
--     Retrieves all data needed for the Dashboard page
-- ============================================================================
IF OBJECT_ID('dbo.sp_GetDashboardStats', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetDashboardStats;
GO

CREATE PROCEDURE dbo.sp_GetDashboardStats
AS
BEGIN
    SET NOCOUNT ON;

    -- Result Set 1: KPI summary
    SELECT * FROM dbo.vw_TicketDashboard;

    -- Result Set 2: Status counts
    SELECT StatusName, TicketCount FROM dbo.vw_StatusCounts ORDER BY
        CASE StatusName
            WHEN 'Open' THEN 1
            WHEN 'Assigned' THEN 2
            WHEN 'InProgress' THEN 3
            WHEN 'Paused' THEN 4
            WHEN 'Resolved' THEN 5
            WHEN 'Closed' THEN 6
            WHEN 'PendingArbitration' THEN 7
            WHEN 'PendingClarification' THEN 8
        END;

    -- Result Set 3: Recent activity (top 8)
    SELECT TOP 8
        ra.Id, ra.TicketId, ra.Action, ra.OldStatus, ra.NewStatus,
        ra.Performer, ra.Notes, ra.Date, ra.TicketNo, ra.TicketTitle
    FROM dbo.vw_RecentActivity ra
    ORDER BY ra.Date DESC;

    -- Result Set 4: Department counts
    SELECT Department, TotalTickets
    FROM dbo.vw_DepartmentWorkload
    ORDER BY TotalTickets DESC;

    -- Result Set 5: Service frequency (top 6)
    SELECT TOP 6 ServiceName, TicketCount, Rank
    FROM dbo.vw_ServiceFrequency
    ORDER BY Rank;

    -- Result Set 6: Active tickets by priority
    SELECT PriorityName, TicketCount
    FROM dbo.vw_ActiveTicketsByPriority
    ORDER BY
        CASE PriorityName
            WHEN 'Critical' THEN 1
            WHEN 'High' THEN 2
            WHEN 'Medium' THEN 3
            WHEN 'Low' THEN 4
        END;
END;
GO

-- ============================================================================
-- 17. sp_GetReportsData
--     Retrieves all data needed for the Reports & Analytics page
-- ============================================================================
IF OBJECT_ID('dbo.sp_GetReportsData', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetReportsData;
GO

CREATE PROCEDURE dbo.sp_GetReportsData
AS
BEGIN
    SET NOCOUNT ON;

    -- Result Set 1: Summary KPIs
    SELECT
        (SELECT COUNT(*) FROM dbo.Tickets) AS TotalTickets,
        (SELECT COUNT(*) FROM dbo.Tickets WHERE SlaBreached = 1) AS SlaBreaches,
        (SELECT COUNT(*) FROM dbo.Tickets WHERE Status NOT IN ('Resolved', 'Closed') AND SlaCompletionRemainMin < 240) AS NearOverdue,
        (SELECT COUNT(*) FROM dbo.ArbitrationCases WHERE Status = N'Open') AS OpenArbitrations,
        (SELECT COUNT(*) FROM dbo.ClarificationRequests WHERE Status = N'Open') AS OpenClarifications;

    -- Result Set 2: Status distribution
    SELECT StatusName, TicketCount FROM dbo.vw_StatusCounts ORDER BY
        CASE StatusName
            WHEN 'Open' THEN 1
            WHEN 'Assigned' THEN 2
            WHEN 'InProgress' THEN 3
            WHEN 'Paused' THEN 4
            WHEN 'Resolved' THEN 5
            WHEN 'Closed' THEN 6
            WHEN 'PendingArbitration' THEN 7
            WHEN 'PendingClarification' THEN 8
        END;

    -- Result Set 3: Service request frequency (all services)
    SELECT ServiceName, TicketCount, Rank
    FROM dbo.vw_ServiceFrequency
    ORDER BY Rank;

    -- Result Set 4: Department workload
    SELECT Department, TotalTickets, ActiveTickets, SlaBreachedTickets, HealthStatus
    FROM dbo.vw_DepartmentWorkload
    ORDER BY TotalTickets DESC;

    -- Result Set 5: Overdue and at-risk tickets
    SELECT *
    FROM dbo.vw_OverdueTickets
    ORDER BY SlaCompletionRemainMin ASC;

    -- Result Set 6: SLA breached tickets
    SELECT *
    FROM dbo.vw_SLABreachedTickets
    ORDER BY CreatedAt DESC;
END;
GO

-- ============================================================================
-- 18. sp_GetServiceCatalogue
--     Retrieves the service catalogue with optional search
-- ============================================================================
IF OBJECT_ID('dbo.sp_GetServiceCatalogue', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetServiceCatalogue;
GO

CREATE PROCEDURE dbo.sp_GetServiceCatalogue
    @SearchTerm NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Result Set 1: Summary counts
    SELECT
        COUNT(*) AS TotalServices,
        SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END) AS ActiveServices
    FROM dbo.Services;

    -- Result Set 2: Service list
    SELECT
        Id,
        Code,
        NameEn,
        Department,
        Division,
        Section,
        DefaultPriority,
        IsActive,
        SlaResponseMin,
        SlaAssignMin,
        SlaCompletionMin,
        SlaClosureMin
    FROM dbo.Services
    WHERE @SearchTerm IS NULL OR (
        NameEn LIKE N'%' + @SearchTerm + N'%' OR
        Code LIKE N'%' + @SearchTerm + N'%' OR
        Department LIKE N'%' + @SearchTerm + N'%'
    )
    ORDER BY Code;
END;
GO

-- ============================================================================
-- End of Stored Procedures Script
-- ============================================================================
PRINT 'All stored procedures created successfully.';
GO