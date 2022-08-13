CREATE TABLE [wms].[OP_WMS_WAREHOUSE_INDICES] (
    [ID]                              BIGINT          IDENTITY (1, 1) NOT NULL,
    [CODE_WAREHOUSE]                  VARCHAR (25)    NULL,
    [MATERIAL_CODE]                   VARCHAR (50)    NULL,
    [BARCODE_ID]                      VARCHAR (25)    NULL,
    [MATERIAL_NAME]                   VARCHAR (150)   NULL,
    [AVARAGE_SALES]                   NUMERIC (18, 6) DEFAULT ((0)) NULL,
    [QTY]                             NUMERIC (18, 4) DEFAULT ((0)) NULL,
    [INVENTORY_COVERAGE]              NUMERIC (18, 6) DEFAULT ((0)) NULL,
    [INVENTORY_ROTATION]              NUMERIC (18, 6) DEFAULT ((0)) NULL,
    [DATE_OF_LAST_RECEPTION]          DATETIME        NULL,
    [DATE_OF_LAST_PICKING]            DATETIME        NULL,
    [DATE_OF_THE_LAST_PHYSICAL_COUNT] DATETIME        NULL,
    [IDLE]                            INT             DEFAULT ((0)) NULL,
    [DATE_START]                      DATE            NULL,
    [DATE_END]                        DATE            NULL,
    [DATE_OF_PROCESS]                 DATETIME        NULL,
    [LAST_PRICE_PURCHASE_BY_ERP]      NUMERIC (18, 6) NULL,
    [LAST_DATE_PURCHASE_BY_ERP]       DATE            NULL,
    CONSTRAINT [PK_OP_WMS_WAREHOUSE_INDICES_ID] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80)
);

