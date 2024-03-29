﻿CREATE TABLE [SONDA].[SWIFT_SEND_INVOICE_ERP_LOG] (
    [SEND_INVOICE_ERP_LOG_ID] INT           IDENTITY (1, 1) NOT NULL,
    [ID]                      INT           NOT NULL,
    [ATTEMPTED_WITH_ERROR]    INT           NULL,
    [IS_POSTED_ERP]           INT           NULL,
    [POSTED_ERP]              DATETIME      NULL,
    [POSTED_RESPONSE]         VARCHAR (150) NULL,
    [ERP_REFERENCE]           VARCHAR (256) NULL,
    PRIMARY KEY CLUSTERED ([SEND_INVOICE_ERP_LOG_ID] ASC)
);

