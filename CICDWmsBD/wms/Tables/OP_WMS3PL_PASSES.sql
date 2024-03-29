﻿CREATE TABLE [wms].[OP_WMS3PL_PASSES] (
    [CLIENT_CODE]     VARCHAR (25)   NULL,
    [CLIENT_NAME]     VARCHAR (200)  NULL,
    [PASS_ID]         NUMERIC (18)   IDENTITY (1, 1) NOT NULL,
    [LAST_UPDATED_BY] VARCHAR (25)   NULL,
    [LAST_UPDATED]    DATETIME       NULL,
    [ISEMPTY]         VARCHAR (1)    NULL,
    [VEHICLE_PLATE]   VARCHAR (25)   NOT NULL,
    [VEHICLE_DRIVER]  VARCHAR (200)  NOT NULL,
    [VEHICLE_ID]      INT            NULL,
    [DRIVER_ID]       INT            NULL,
    [AUTORIZED_BY]    VARCHAR (250)  NULL,
    [HANDLER]         VARCHAR (250)  NULL,
    [CARRIER]         VARCHAR (250)  NULL,
    [TXT]             VARCHAR (4000) NULL,
    [LOADUNLOAD]      VARCHAR (1)    NULL,
    [LOADWITH]        VARCHAR (4000) NULL,
    [AUDIT_ID]        NUMERIC (18)   NULL,
    [CREATED_DATE]    DATETIME       DEFAULT (getdate()) NULL,
    [CREATED_BY]      VARCHAR (25)   NULL,
    [STATUS]          VARCHAR (25)   DEFAULT ('CREATED') NULL,
    [TYPE]            VARCHAR (25)   NULL,
    [LICENSE_NUMBER]  VARCHAR (50)   NULL,
    CONSTRAINT [PK_OP_WMS3PL_PASSES] PRIMARY KEY CLUSTERED ([PASS_ID] ASC) WITH (FILLFACTOR = 80)
);

