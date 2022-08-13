CREATE TABLE [wms].[OP_WMS_LOG_INVENTORY_RESERVED_BY_PROJECT] (
    [ID]                       BIGINT           IDENTITY (1, 1) NOT NULL,
    [TYPE_LOG]                 VARCHAR (20)     NOT NULL,
    [PROJECT_ID]               UNIQUEIDENTIFIER NOT NULL,
    [PK_LINE]                  NUMERIC (18)     NOT NULL,
    [LICENSE_ID]               NUMERIC (18)     NOT NULL,
    [MATERIAL_ID]              VARCHAR (50)     NOT NULL,
    [MATERIAL_NAME]            VARCHAR (150)    NULL,
    [QTY_LICENSE]              NUMERIC (18, 4)  NOT NULL,
    [QTY_RESERVED]             NUMERIC (18, 4)  NOT NULL,
    [QTY_DISPATCHED]           NUMERIC (18, 4)  NULL,
    [PICKING_DEMAND_HEADER_ID] INT              NULL,
    [WAVE_PICKING_ID]          NUMERIC (18)     NULL,
    [CREATED_BY]               VARCHAR (64)     NULL,
    [CREATED_DATE]             DATETIME         NULL
);

