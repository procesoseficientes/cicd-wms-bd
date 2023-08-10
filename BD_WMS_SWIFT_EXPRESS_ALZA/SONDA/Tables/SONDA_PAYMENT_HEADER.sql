CREATE TABLE [SONDA].[SONDA_PAYMENT_HEADER] (
    [PAYMENT_NUM]            NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [CLIENT_ID]              VARCHAR (50)    NULL,
    [CLIENT_NAME]            VARCHAR (150)   NULL,
    [TOTAL_AMOUNT]           NUMERIC (18, 6) NULL,
    [POSTED_DATETIME]        DATETIME        NULL,
    [POS_TERMINAL]           VARCHAR (50)    NULL,
    [GPS]                    VARCHAR (50)    NULL,
    [DOC_DATE]               DATETIME        NULL,
    [DEPOSIT_TO_DATE]        DATETIME        NULL,
    [IS_POSTED]              VARCHAR (50)    NULL,
    [STATUS]                 VARCHAR (20)    NULL,
    [PAYMENT_HH_NUM]         INT             NULL,
    [IS_ACTIVE_ROUTE]        INT             CONSTRAINT [DF_SONDA_PAYMENT_HEADER_IS_ACTIVE_ROUTE] DEFAULT ((1)) NULL,
    [DOC_SERIE]              VARCHAR (100)   NULL,
    [DOC_NUM]                INT             NULL,
    [LIQUIDATION_ID]         BIGINT          NULL,
    [SERVER_POSTED_DATETIME] DATETIME        DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([PAYMENT_NUM] ASC)
);

