﻿CREATE TABLE [wms].[OP_WMS_PROJECT] (
    [ID]                UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL,
    [OPPORTUNITY_CODE]  VARCHAR (50)     NOT NULL,
    [OPPORTUNITY_NAME]  VARCHAR (150)    NULL,
    [SHORT_NAME]        VARCHAR (25)     NULL,
    [OBSERVATIONS]      VARCHAR (560)    NULL,
    [CUSTOMER_CODE]     VARCHAR (50)     NULL,
    [STATUS]            VARCHAR (20)     NULL,
    [CREATED_BY]        VARCHAR (50)     NULL,
    [CREATED_DATE]      DATETIME         DEFAULT (getdate()) NULL,
    [LAST_UPDATED_BY]   VARCHAR (50)     NULL,
    [LAST_UPDATED_DATE] DATETIME         NULL,
    [CUSTOMER_NAME]     VARCHAR (300)    NULL,
    [CUSTOMER_OWNER]    VARCHAR (30)     NULL,
    CONSTRAINT [PK_OP_WMS_PROJECT_ID] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80),
    UNIQUE NONCLUSTERED ([OPPORTUNITY_CODE] ASC) WITH (FILLFACTOR = 80)
);
