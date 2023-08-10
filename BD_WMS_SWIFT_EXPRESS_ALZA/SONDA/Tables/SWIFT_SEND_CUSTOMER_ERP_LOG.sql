CREATE TABLE [SONDA].[SWIFT_SEND_CUSTOMER_ERP_LOG] (
    [SEND_CUSTOMER_ERP_LOG_ID] INT           IDENTITY (1, 1) NOT NULL,
    [ID]                       INT           NULL,
    [ATTEMPTED_WITH_ERROR]     INT           NULL,
    [IS_POSTED_ERP]            INT           NULL,
    [POSTED_ERP]               DATETIME      NULL,
    [POSTED_RESPONSE]          VARCHAR (250) NULL,
    [ERP_REFERENCE]            VARCHAR (250) NULL,
    [TYPE]                     VARCHAR (250) NULL
);

