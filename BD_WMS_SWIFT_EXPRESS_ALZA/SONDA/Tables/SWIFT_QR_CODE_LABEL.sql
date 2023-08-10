﻿CREATE TABLE [SONDA].[SWIFT_QR_CODE_LABEL] (
    [ID]                NUMERIC (18)  NOT NULL,
    [TASK_ID]           INT           NOT NULL,
    [CUSTOMER_NAME]     VARCHAR (MAX) NULL,
    [CODE_SKU]          VARCHAR (50)  NOT NULL,
    [SERIE]             VARCHAR (75)  NOT NULL,
    [ERP_DOC]           VARCHAR (50)  NOT NULL,
    [SHIP_TO_ADDRESSES] VARCHAR (MAX) NOT NULL,
    [CREATE_DATE]       DATETIME      NOT NULL,
    [STATUS]            VARCHAR (MAX) DEFAULT ('IN_TRANSIT') NOT NULL,
    [UPDATE_DATE]       DATETIME      NULL,
    CONSTRAINT [PK_SWIFT_QR_CODE_LABEL] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [KEY_SWIFT_QR_CODE_LABEL] UNIQUE NONCLUSTERED ([ERP_DOC] ASC, [CODE_SKU] ASC, [SERIE] ASC)
);

