﻿CREATE TABLE [wms].[OP_WMS_AUDIT_RECEPTION_SKUS] (
    [AUDIT_ID]        NUMERIC (18)    NOT NULL,
    [CODIGO_POLIZA]   VARCHAR (50)    NOT NULL,
    [MATERIAL_ID]     VARCHAR (50)    NOT NULL,
    [BARCODE_ID]      VARCHAR (50)    NULL,
    [MATERIAL_NAME]   VARCHAR (250)   NULL,
    [SCANNED_COUNT]   NUMERIC (18)    NULL,
    [INPUTED_COUNT]   NUMERIC (18, 4) NULL,
    [LAST_UPDATED]    DATETIME        NULL,
    [LAST_UPDATED_BY] VARCHAR (25)    NULL,
    CONSTRAINT [PK_OP_WMS_RECEPTION_AUDIT_SKUS] PRIMARY KEY CLUSTERED ([AUDIT_ID] ASC, [CODIGO_POLIZA] ASC, [MATERIAL_ID] ASC) WITH (FILLFACTOR = 80)
);

