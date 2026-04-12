CREATE TABLE [Tickets].[TicketHistory] (
    [ticketHistoryID]   BIGINT          IDENTITY (1, 1) NOT NULL,
    [ticketID_FK]       BIGINT          NOT NULL,
    [idaraID_FK]        INT             NOT NULL,
    [actionTypeCode]    NVARCHAR (100)  NOT NULL,
    [oldStatusID_FK]    INT             NULL,
    [newStatusID_FK]    INT             NULL,
    [oldDSDID_FK]       INT             NULL,
    [newDSDID_FK]       INT             NULL,
    [oldAssignedUserID] INT             NULL,
    [newAssignedUserID] INT             NULL,
    [performerUserID]   INT             NULL,
    [notes]             NVARCHAR (2000) NULL,
    [actionDate]        DATETIME        CONSTRAINT [DF_Tickets_TicketHistory_actionDate] DEFAULT (GETDATE()) NOT NULL,
    [entryDate]         DATETIME        CONSTRAINT [DF_Tickets_TicketHistory_entryDate] DEFAULT (GETDATE()) NULL,
    [entryData]         NVARCHAR (20)   NULL,
    [hostName]          NVARCHAR (200)  NULL,
    CONSTRAINT [PK_Tickets_TicketHistory] PRIMARY KEY CLUSTERED ([ticketHistoryID] ASC)
);
