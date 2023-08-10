﻿CREATE TABLE [SONDA].[SWIFT_SEND_SO_ERP_LOG] (
    [ORDER]                INT            IDENTITY (1, 1) NOT NULL,
    [SALES_ORDER_ID]       INT            NOT NULL,
    [ATTEMPTED_WITH_ERROR] INT            NULL,
    [IS_POSTED_ERP]        INT            NULL,
    [POSTED_ERP]           DATETIME       NULL,
    [POSTED_RESPONSE]      VARCHAR (4000) NULL,
    [ERP_REFERENCE]        VARCHAR (256)  NULL,
    PRIMARY KEY CLUSTERED ([ORDER] ASC)
);

