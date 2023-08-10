﻿CREATE TABLE [SONDA].[SONDA_INVOICE_LOG_EXISTS] (
    [LOG_ID]          INT           IDENTITY (1, 1) NOT NULL,
    [LOG_DATETIME]    DATETIME      NOT NULL,
    [EXISTS_INVOICE]  INT           NOT NULL,
    [DOC_RESOLUTION]  VARCHAR (100) NOT NULL,
    [DOC_SERIE]       VARCHAR (100) NOT NULL,
    [DOC_NUM]         INT           NOT NULL,
    [CODE_ROUTE]      VARCHAR (50)  NULL,
    [CODE_CUSTOMER]   VARCHAR (50)  NULL,
    [POSTED_DATETIME] DATETIME      NOT NULL,
    [XML]             XML           NULL,
    [JSON]            VARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([LOG_ID] ASC)
);

