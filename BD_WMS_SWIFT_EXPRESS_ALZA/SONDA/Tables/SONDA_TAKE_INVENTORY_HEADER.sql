CREATE TABLE [SONDA].[SONDA_TAKE_INVENTORY_HEADER] (
    [TAKE_INVENTORY_ID]      INT           IDENTITY (1, 1) NOT NULL,
    [POSTED_DATETIME]        DATETIME      NULL,
    [CLIENT_ID]              VARCHAR (50)  NULL,
    [CODE_ROUTE]             VARCHAR (25)  NULL,
    [GPS_URL]                VARCHAR (150) NULL,
    [POSTED_BY]              VARCHAR (25)  NULL,
    [DEVICE_BATERY_FACTOR]   INT           NULL,
    [IS_ACTIVE_ROUTE]        INT           NULL,
    [GPS_EXPECTED]           VARCHAR (150) NULL,
    [TAKE_INVENTORY_ID_HH]   INT           NULL,
    [DOC_SERIE]              VARCHAR (100) NULL,
    [DOC_NUM]                INT           NULL,
    [IS_VOID]                INT           NULL,
    [TASK_ID]                INT           NULL,
    [SERVER_POSTED_DATETIME] DATETIME      DEFAULT (getdate()) NOT NULL,
    [DEVICE_NETWORK_TYPE]    VARCHAR (15)  NULL,
    [IS_POSTED_OFFLINE]      INT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_SONDA_TAKE_INVENTORY_HEADER] PRIMARY KEY CLUSTERED ([TAKE_INVENTORY_ID] ASC)
);

