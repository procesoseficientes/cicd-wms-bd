﻿CREATE TABLE [wms].[OP_WMS_POLIZA_DETAIL] (
    [DOC_ID]               NUMERIC (18)    NOT NULL,
    [LINE_NUMBER]          NUMERIC (18)    NOT NULL,
    [SKU_DESCRIPTION]      VARCHAR (250)   NOT NULL,
    [SAC_CODE]             VARCHAR (50)    NOT NULL,
    [BULTOS]               NUMERIC (18, 4) NOT NULL,
    [CLASE]                VARCHAR (25)    NULL,
    [NET_WEIGTH]           NUMERIC (18, 2) NULL,
    [WEIGTH_UNIT]          VARCHAR (25)    NULL,
    [QTY]                  NUMERIC (18, 3) NULL,
    [CUSTOMS_AMOUNT]       NUMERIC (18, 2) NULL,
    [QTY_UNIT]             VARCHAR (25)    NULL,
    [VOLUME]               NUMERIC (18, 3) NULL,
    [VOLUME_UNIT]          VARCHAR (25)    NULL,
    [DAI]                  NUMERIC (18, 2) NOT NULL,
    [IVA]                  NUMERIC (18, 2) NOT NULL,
    [MISC_TAXES]           NUMERIC (18, 2) CONSTRAINT [DF_OP_WMS_POLIZA_DETAIL_MISC_TAXES] DEFAULT ((0)) NOT NULL,
    [FOB_USD]              NUMERIC (18, 2) NULL,
    [FREIGTH_USD]          NUMERIC (18, 2) NULL,
    [INSURANCE_USD]        NUMERIC (18, 2) NULL,
    [MISC_EXPENSES]        NUMERIC (18, 2) NULL,
    [ORIGIN_COUNTRY]       VARCHAR (50)    NULL,
    [REGION_CP]            VARCHAR (50)    NULL,
    [AGREEMENT_1]          VARCHAR (50)    NULL,
    [AGREEMENT_2]          VARCHAR (50)    NULL,
    [RELATED_POLIZA]       VARCHAR (15)    NULL,
    [LAST_UPDATED_BY]      VARCHAR (25)    NULL,
    [LAST_UPDATED]         DATETIME        NULL,
    [ORIGIN_DOC_ID]        NUMERIC (18)    NULL,
    [CODIGO_POLIZA_ORIGEN] VARCHAR (15)    NULL,
    [CLIENT_CODE]          VARCHAR (25)    NULL,
    [ACUERDO_COMERCIAL]    VARCHAR (25)    NULL,
    [PCTDAI]               NUMERIC (18, 3) NULL,
    [ORIGIN_LINE_NUMBER]   NUMERIC (18)    NULL,
    [PICKING_STATUS]       VARCHAR (25)    CONSTRAINT [DF_OP_WMS_POLIZA_DETAIL_PICKING_STATUS] DEFAULT ('PENDING') NULL,
    [TAX]                  NUMERIC (18, 9) NULL,
    [MATERIAL_ID]          VARCHAR (50)    NULL,
    [UNITARY_PRICE]        NUMERIC (18, 2) NULL,
    [IS_AUTHORIZED]        INT             DEFAULT ((0)) NULL,
    [QTY_PENDING]          NUMERIC (18, 3) NULL,
    CONSTRAINT [PK_OP_WMS_POLIZA_DETAIL] PRIMARY KEY CLUSTERED ([DOC_ID] ASC, [LINE_NUMBER] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IX_OP_WMS_POLIZA_DETAIL]
    ON [wms].[OP_WMS_POLIZA_DETAIL]([ORIGIN_DOC_ID] ASC, [ORIGIN_LINE_NUMBER] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_OP_WMS_POLIZA_DETAIL_1]
    ON [wms].[OP_WMS_POLIZA_DETAIL]([ACUERDO_COMERCIAL] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_OP_WMS_POLIZA_DETAIL_2]
    ON [wms].[OP_WMS_POLIZA_DETAIL]([RELATED_POLIZA] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_OP_WMS_POLIZA_DETAIL_3]
    ON [wms].[OP_WMS_POLIZA_DETAIL]([ORIGIN_DOC_ID] ASC, [SKU_DESCRIPTION] ASC) WITH (FILLFACTOR = 80);

