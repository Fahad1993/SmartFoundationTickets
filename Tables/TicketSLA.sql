-- ============================================================================
-- Table: TicketSLA
-- Schema: [Tickets]
-- Purpose: Stores the current state of each SLA clock per ticket
-- Notes: Supports SLA initialization, pause/resume, and breach tracking.
--          Four SLA types: First Response, Assignment, Operational Completion, Final Closure.
-- ============================================================================

IF OBJECT_ID('[Tickets].[TicketSLA]', 'U') IS NOT NULL
    DROP TABLE [Tickets].[TicketSLA];
GO

CREATE TABLE [Tickets].[TicketSLA] (
    -- Primary Key
    [TicketSLAID] BIGINT IDENTITY(1,1) NOT NULL,

    -- Ticket Reference
    [TicketID FK] BIGINT NOT NULL,

    -- IdaraID FK is mandatory for filtering and reporting
    [IdaraID FK] INT NOT NULL,

    -- SLA Type (four distinct clocks per ticket)
    [SLATypeCode] VARCHAR(30) NOT NULL,
    -- Values: FIRST_RESPONSE, ASSIGNMENT, OPERATIONAL_COMPLETION, FINAL_CLOSURE

    -- Target Time (in minutes, from ServiceSLAPolicy)
    [TargetMinutes] INT NOT NULL,

    -- Elapsed Time (calculated, excludes paused periods)
    [ElapsedMinutes] INT NOT NULL CONSTRAINT DF_TicketSLA_ElapsedMinutes DEFAULT 0,

    -- Remaining Time (calculated as Target - Elapsed)
    [RemainingMinutes] INT NOT NULL,
    -- Can be negative if breached

    -- Breach Detection
    [IsBreached] BIT NOT NULL CONSTRAINT DF_TicketSLA_IsBreached DEFAULT 0,
    [BreachDetectedAt] DATETIME2 NULL,
    [BreachMinutes] INT NULL, -- How many minutes past target when breach detected

    -- Timeline Tracking
    [SLAStartedAt] DATETIME2 NOT NULL, -- When this SLA clock started
    [SLAPausedAt] DATETIME2 NULL, -- When SLA was paused (if any)
    [SLAResumedAt] DATETIME2 NULL, -- When SLA was resumed
    [SLACompletedAt] DATETIME2 NULL, -- When SLA was met (ticket progressed)

    -- Pause Tracking (total paused time to subtract from elapsed)
    [TotalPausedMinutes] INT NOT NULL CONSTRAINT DF_TicketSLA_TotalPausedMinutes DEFAULT 0,

    -- Priority Context
    [PriorityID FK] INT NULL, -- Current priority when SLA was set

    -- Calculation Metadata
    [LastCalculatedAt] DATETIME2 NOT NULL CONSTRAINT DF_TicketSLA_LastCalculatedAt DEFAULT SYSDATETIME(),
    [CalculationVersion] INT NULL, -- For SLA calculation algorithm updates

    -- Audit Columns
    [CreatedAt] DATETIME2 NOT NULL CONSTRAINT DF_TicketSLA_CreatedAt DEFAULT SYSDATETIME(),
    [UpdatedAt] DATETIME2 NOT NULL CONSTRAINT DF_TicketSLA_UpdatedAt DEFAULT SYSDATETIME(),
    [CreatedBy] VARCHAR(100) NULL,
    [UpdatedBy] VARCHAR(100) NULL,

    -- Primary Key Constraint
    CONSTRAINT PK_TicketSLA PRIMARY KEY CLUSTERED ([TicketSLAID]))
;
GO

-- Foreign Key Constraints
ALTER TABLE [Tickets].[TicketSLA]
ADD CONSTRAINT FK_TicketSLA_Ticket
    FOREIGN KEY ([TicketID FK]) REFERENCES [Tickets].[Ticket]([TicketID]);

ALTER TABLE [Tickets].[TicketSLA]
ADD CONSTRAINT FK_TicketSLA_Priority
    FOREIGN KEY ([PriorityID FK]) REFERENCES [Tickets].[Priority]([PriorityID]));
GO

-- Unique Constraint: One SLA record per ticket per SLA type (active)
ALTER TABLE [Tickets].[TicketSLA]
ADD CONSTRAINT UQ_TicketSLA_Ticket_SLAType UNIQUE ([TicketID FK], [SLATypeCode], [SLACompletedAt]);
GO

-- Indexes
CREATE NONCLUSTERED INDEX IX_TicketSLA_TicketID
ON [Tickets].[TicketSLA] ([TicketID FK]);

CREATE NONCLUSTERED INDEX IX_TicketSLA_SLATypeCode
ON [Tickets].[TicketSLA] ([SLATypeCode]);

CREATE NONCLUSTERED INDEX IX_TicketSLA_LastCalculatedAt
ON [Tickets].[TicketSLA] ([LastCalculatedAt]);

CREATE NONCLUSTERED INDEX IX_TicketSLA_IsBreached
ON [Tickets].[TicketSLA] ([IsBreached]);

CREATE NONCLUSTERED INDEX IX_TicketSLA_BreachMonitoring
ON [Tickets].[TicketSLA] ([IsBreached], [BreachDetectedAt] DESC)
INCLUDE ([TicketID FK], [RemainingMinutes], [TargetMinutes], [SLATypeCode]);

CREATE NONCLUSTERED INDEX IX_TicketSLA_RemainingMinutes
ON [Tickets].[TicketSLA] ([RemainingMinutes]) -- Includes negative values for breached
INCLUDE ([TicketID FK], [SLATypeCode], [IsBreached], [BreachDetectedAt]);
GO

-- Comment: Each ticket has up to 4 SLA records (one per type).
-- SLA types are:
--   FIRST_RESPONSE: Time to acknowledge/respond to ticket
--   ASSIGNMENT: Time to assign to a user
--   OPERATIONAL_COMPLETION: Time to complete the work
--   FINAL_CLOSURE: Time for final quality closure
-- ElapsedMinutes excludes paused periods (TotalPausedMinutes is subtracted).
-- RemainingMinutes = TargetMinutes - (ElapsedMinutes - TotalPausedMinutes).
-- IsBreached is TRUE when RemainingMinutes <= 0.
-- When SLA is completed (e.g., ticket assigned), SLACompletedAt is set and record becomes read-only.
-- New SLA records for same ticket+type would have different SLACompletedAt.
-- SLA calculation is performed by stored procedures, not by triggers.
