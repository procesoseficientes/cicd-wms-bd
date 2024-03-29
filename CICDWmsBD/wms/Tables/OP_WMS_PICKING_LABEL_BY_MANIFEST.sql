﻿CREATE TABLE [wms].[OP_WMS_PICKING_LABEL_BY_MANIFEST] (
    [LABEL_ID]           INT             NOT NULL,
    [MANIFEST_DETAIL_ID] INT             NULL,
    [MATERIAL_ID]        VARCHAR (50)    NULL,
    [QTY]                DECIMAL (18, 4) NULL,
    [CREATED_DATE]       DATETIME        DEFAULT (getdate()) NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_PICKING_LABEL_BY_MANIFEST_MANIFEST_DETAIL_ID]
    ON [wms].[OP_WMS_PICKING_LABEL_BY_MANIFEST]([MANIFEST_DETAIL_ID] ASC)
    INCLUDE([QTY], [LABEL_ID]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_PICKING_LABEL_BY_MANIFEST_LABEL_ID]
    ON [wms].[OP_WMS_PICKING_LABEL_BY_MANIFEST]([LABEL_ID] ASC)
    INCLUDE([MANIFEST_DETAIL_ID]) WITH (FILLFACTOR = 80);

