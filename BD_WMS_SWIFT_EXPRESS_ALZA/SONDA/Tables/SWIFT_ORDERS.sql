CREATE TABLE [SONDA].[SWIFT_ORDERS] (
    [ORDER_SERIAL]            INT             IDENTITY (1, 1) NOT NULL,
    [ORDER_ID]                VARCHAR (50)    NULL,
    [CREATED_DATESTAMP]       DATETIME        NULL,
    [CREATED_BY]              VARCHAR (25)    NULL,
    [POSTED_DATETIME]         DATETIME        NULL,
    [PRESALE_ROUTE]           VARCHAR (25)    NULL,
    [CLIENT_CODE]             VARCHAR (50)    NULL,
    [CLIENT_NAME]             VARCHAR (250)   NULL,
    [DELIVERY_POINT]          INT             NULL,
    [DELIVERY_BRANCH_NAME]    VARCHAR (50)    NULL,
    [DELIVERY_BRANCH_ADDRESS] VARCHAR (MAX)   NULL,
    [TOTAL_AMOUNT]            DECIMAL (18, 2) NULL,
    [TASK_SOURCE]             INT             NULL,
    [STATUS]                  VARCHAR (50)    NULL,
    [SIGNATURE]               VARCHAR (MAX)   NULL,
    [IMAGE]                   VARCHAR (MAX)   NULL,
    [POSTED_ERP]              DATETIME        NULL,
    [GPS_URL]                 VARCHAR (150)   NULL,
    CONSTRAINT [PK_SWIFT_ORDERS] PRIMARY KEY CLUSTERED ([ORDER_SERIAL] ASC)
);

