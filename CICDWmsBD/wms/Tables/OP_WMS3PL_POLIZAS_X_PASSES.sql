﻿CREATE TABLE [wms].[OP_WMS3PL_POLIZAS_X_PASSES] (
    [PASS_ID]         NUMERIC (18)  NOT NULL,
    [CODIGO_POLIZA]   VARCHAR (15)  NOT NULL,
    [DOC_ID]          NUMERIC (18)  NOT NULL,
    [LAST_UPDATED_BY] VARCHAR (25)  NULL,
    [LAST_UPDATED]    DATETIME      NULL,
    [NUMERO_ORDEN]    VARCHAR (50)  NULL,
    [NUMERO_DUA]      VARCHAR (50)  NULL,
    [CLIENT_NAME]     VARCHAR (250) NULL,
    [CLIENT_CODE]     VARCHAR (25)  NULL
);

