/****** Object:  Table [dbo].[WorkOrders]    Script Date: 6/20/2023 9:41:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkOrders](
	[workOrdersID] [bigint] IDENTITY(1,1) NOT NULL,
	[workOrdersTypeID_FK] [int] NULL,
	[userID_FK] [decimal](10, 0) NULL,
	[workOrdersDate] [datetime] NULL,
	[workOrdersStatusID_FK] [int] NULL,
 CONSTRAINT [PK_WorkOrders] PRIMARY KEY CLUSTERED 
(
	[workOrdersID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WorkOrderAction]    Script Date: 4/1/2026 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkOrderAction](
	[workOrderActionID] [bigint] IDENTITY(1,1) NOT NULL,
	[workOrdersID_FK] [bigint] NOT NULL,
	[actionTypeCode] [varchar](30) NOT NULL,
	[oldWorkOrdersStatusID_FK] [int] NULL,
	[newWorkOrdersStatusID_FK] [int] NULL,
	[oldUserID_FK] [decimal](10, 0) NULL,
	[newUserID_FK] [decimal](10, 0) NULL,
	[actionNotes] [nvarchar](max) NULL,
	[actionData] [nvarchar](max) NULL,
	[actionSource] [varchar](30) NULL,
	[performedBy] [varchar](100) NULL,
	[performedByUserID_FK] [decimal](10, 0) NULL,
	[performedAt] [datetime2] NOT NULL CONSTRAINT DF_WorkOrderAction_PerformedAt DEFAULT SYSDATETIME(),
	[ipAddress] [varchar](50) NULL,
	[entryData] [varchar](100) NULL,
	[hostName] [varchar](100) NULL,
	[createdAt] [datetime2] NOT NULL CONSTRAINT DF_WorkOrderAction_CreatedAt DEFAULT SYSDATETIME(),
 CONSTRAINT PK_WorkOrderAction PRIMARY KEY CLUSTERED 
(
	[workOrderActionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[WorkOrderAction]
ADD CONSTRAINT FK_WorkOrderAction_WorkOrders
	FOREIGN KEY ([workOrdersID_FK]) REFERENCES [dbo].[WorkOrders]([workOrdersID]);

ALTER TABLE [dbo].[WorkOrderAction]
ADD CONSTRAINT FK_WorkOrderAction_OldStatus
	FOREIGN KEY ([oldWorkOrdersStatusID_FK]) REFERENCES [dbo].[WorkOrdersStatus]([workOrdersStatusID]);

ALTER TABLE [dbo].[WorkOrderAction]
ADD CONSTRAINT FK_WorkOrderAction_NewStatus
	FOREIGN KEY ([newWorkOrdersStatusID_FK]) REFERENCES [dbo].[WorkOrdersStatus]([workOrdersStatusID]);
GO

CREATE NONCLUSTERED INDEX IX_WorkOrderAction_WorkOrdersID
ON [dbo].[WorkOrderAction] ([workOrdersID_FK]);

CREATE NONCLUSTERED INDEX IX_WorkOrderAction_ActionTypeCode
ON [dbo].[WorkOrderAction] ([actionTypeCode]);

CREATE NONCLUSTERED INDEX IX_WorkOrderAction_PerformedAt
ON [dbo].[WorkOrderAction] ([performedAt] DESC);

CREATE NONCLUSTERED INDEX IX_WorkOrderAction_Timeline
ON [dbo].[WorkOrderAction] ([workOrdersID_FK], [performedAt] DESC)
INCLUDE ([actionTypeCode], [oldWorkOrdersStatusID_FK], [newWorkOrdersStatusID_FK], [performedBy]);
GO
/****** Object:  Table [dbo].[WorkOrdersCategory]    Script Date: 6/20/2023 9:41:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkOrdersCategory](
	[workOrdersCategoryID] [int] IDENTITY(1,1) NOT NULL,
	[name_A] [nvarchar](50) NULL,
	[name_E] [nvarchar](50) NULL,
	[description] [nvarchar](200) NULL,
 CONSTRAINT [PK_WorkOrdersCategory] PRIMARY KEY CLUSTERED 
(
	[workOrdersCategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WorkOrdersStatus]    Script Date: 6/20/2023 9:41:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkOrdersStatus](
	[workOrdersStatusID] [int] IDENTITY(1,1) NOT NULL,
	[name_A] [nvarchar](50) NULL,
	[name_E] [nvarchar](50) NULL,
	[description] [nvarchar](200) NULL,
 CONSTRAINT [PK_WorkOrdersStatus] PRIMARY KEY CLUSTERED 
(
	[workOrdersStatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WorkOrdersType]    Script Date: 6/20/2023 9:41:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkOrdersType](
	[workOrdersTypeID] [int] IDENTITY(1,1) NOT NULL,
	[name_A] [nvarchar](50) NULL,
	[name_E] [nvarchar](50) NULL,
	[code] [nvarchar](10) NULL,
	[description] [nvarchar](400) NULL,
	[workOrdersCategoryID_FK] [int] NULL,
	[allowedForDisplay] [bit] NULL,
	[parentworkOrdersTypeID] [int] NULL,
 CONSTRAINT [PK_WorkOrdersType] PRIMARY KEY CLUSTERED 
(
	[workOrdersTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WorkOrderTypeFields]    Script Date: 6/20/2023 9:41:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkOrderTypeFields](
	[workOrderTypeFieldID] [int] IDENTITY(1,1) NOT NULL,
	[workOrdersTypeID_FK] [int] NULL,
	[fieldName] [nvarchar](100) NULL,
	[isMandatory] [bit] NOT NULL,
	[arabicFieldName] [nvarchar](100) NULL,
	[controlTypeID_FK] [int] NULL,
	[regularExpressionID_FK] [int] NULL,
	[theQuery] [nvarchar](max) NULL,
	[theQueryParameters] [nvarchar](max) NULL,
	[class] [nvarchar](50) NULL,
	[serial] [int] NULL,
	[theSP] [nvarchar](max) NULL,
 CONSTRAINT [PK_WorkOrderTypeFields] PRIMARY KEY CLUSTERED 
(
	[workOrderTypeFieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO