CREATE TABLE [wms].[OP_WMS_DISPATCH_LICENSE_EXIT_DETAIL] (
    [DISPATCH_LICENSE_EXIT_DETAIL]    INT             IDENTITY (1, 1) NOT NULL,
    [DISPATCH_LICENSE_EXIT_HEADER_ID] INT             NULL,
    [CLIENT_CODE]                     VARCHAR (50)    NULL,
    [CLIENT_NAME]                     VARCHAR (200)   NULL,
    [PICKING_DEMAND_HEADER_ID]        INT             NULL,
    [DOC_NUM]                         INT             NULL,
    [MATERIAL_ID]                     VARCHAR (50)    NULL,
    [MATERIAL_NAME]                   VARCHAR (200)   NULL,
    [QTY]                             NUMERIC (18, 4) NULL,
    [DOC_NUM_POLIZA]                  INT             NULL,
    [CODIGO_POLIZA]                   VARCHAR (25)    NULL,
    [NUMERO_ORDEN_POLIZA]             VARCHAR (25)    NULL,
    [WAVE_PICKING_ID]                 INT             NULL,
    [CREATED_DATE]                    DATETIME        NULL,
    [CODE_WAREHOUSE]                  VARCHAR (25)    NULL,
    [TYPE_DEMAND_CODE]                INT             NULL,
    [TYPE_DEMAND_NAME]                VARCHAR (50)    NULL,
    [LINE_NUM]                        INT             NULL,
    CONSTRAINT [PK_OP_WMS_DISPATCH_LICENSE_EXIT_DETAIL_DISPATCH_LICENSE_EXIT_DETAIL] PRIMARY KEY CLUSTERED ([DISPATCH_LICENSE_EXIT_DETAIL] ASC) WITH (FILLFACTOR = 80),
    FOREIGN KEY ([DISPATCH_LICENSE_EXIT_HEADER_ID]) REFERENCES [wms].[OP_WMS_DISPATCH_LICENSE_EXIT_HEADER] ([DISPATCH_LICENSE_EXIT_HEADER_ID])
);

