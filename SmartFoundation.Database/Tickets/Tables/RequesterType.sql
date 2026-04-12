CREATE TABLE [Tickets].[RequesterType] (
    [requesterTypeID]     INT             IDENTITY (1, 1) NOT NULL,
    [requesterTypeCode]   NVARCHAR (50)   NOT NULL,
    [requesterTypeName_A] NVARCHAR (200)  NULL,
    [requesterTypeName_E] NVARCHAR (200)  NULL,
    [requesterTypeDesc]   NVARCHAR (1000) NULL,
    [requesterTypeActive] BIT             NULL,
    [entryDate]           DATETIME        CONSTRAINT [DF_Tickets_RequesterType_entryDate] DEFAULT (GETDATE()) NULL,
    [entryData]           NVARCHAR (20)   NULL,
    [hostName]            NVARCHAR (200)  NULL,
    CONSTRAINT [PK_Tickets_RequesterType] PRIMARY KEY CLUSTERED ([requesterTypeID] ASC)
);
