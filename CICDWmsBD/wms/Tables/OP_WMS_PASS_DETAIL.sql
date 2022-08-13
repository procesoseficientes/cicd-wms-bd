CREATE TABLE [wms].[OP_WMS_PASS_DETAIL] (
    [PASS_DETAIL_ID]           INT             IDENTITY (1, 1) NOT NULL,
    [PASS_HEADER_ID]           NUMERIC (18)    NULL,
    [CLIENT_CODE]              VARCHAR (50)    NULL,
    [CLIENT_NAME]              VARCHAR (200)   NULL,
    [PICKING_DEMAND_HEADER_ID] INT             NULL,
    [DOC_NUM]                  INT             NULL,
    [MATERIAL_ID]              VARCHAR (50)    NULL,
    [MATERIAL_NAME]            VARCHAR (200)   NULL,
    [QTY]                      NUMERIC (18, 4) NULL,
    [DOC_NUM_POLIZA]           INT             NULL,
    [CODIGO_POLIZA]            VARCHAR (25)    NULL,
    [NUMERO_ORDEN_POLIZA]      VARCHAR (25)    NULL,
    [WAVE_PICKING_ID]          INT             NULL,
    [CREATED_DATE]             DATETIME        NULL,
    [CODE_WAREHOUSE]           VARCHAR (25)    NULL,
    [TYPE_DEMAND_CODE]         INT             NULL,
    [TYPE_DEMAND_NAME]         VARCHAR (50)    NULL,
    [LINE_NUM]                 INT             NULL,
    PRIMARY KEY CLUSTERED ([PASS_DETAIL_ID] ASC) WITH (FILLFACTOR = 80),
    FOREIGN KEY ([PASS_HEADER_ID]) REFERENCES [wms].[OP_WMS3PL_PASSES] ([PASS_ID])
);

