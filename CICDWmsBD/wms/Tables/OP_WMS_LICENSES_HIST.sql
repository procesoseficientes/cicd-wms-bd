CREATE TABLE [wms].[OP_WMS_LICENSES_HIST] (
    [LICENSE_ID]                        NUMERIC (18)    NOT NULL,
    [CLIENT_OWNER]                      VARCHAR (25)    NULL,
    [CODIGO_POLIZA]                     VARCHAR (25)    NULL,
    [CURRENT_WAREHOUSE]                 VARCHAR (25)    NULL,
    [CURRENT_LOCATION]                  VARCHAR (25)    NULL,
    [LAST_LOCATION]                     VARCHAR (25)    NULL,
    [LAST_UPDATED]                      DATETIME        NULL,
    [LAST_UPDATED_BY]                   VARCHAR (15)    NULL,
    [STATUS]                            VARCHAR (15)    NULL,
    [REGIMEN]                           VARCHAR (50)    NULL,
    [CREATED_DATE]                      DATETIME        NULL,
    [USED_MT2]                          NUMERIC (18, 2) NULL,
    [CODIGO_POLIZA_RECTIFICACION]       VARCHAR (25)    NULL,
    [PICKING_DEMAND_HEADER_ID]          INT             NULL,
    [WAVE_PICKING_ID]                   INT             NULL,
    [TARGET_LOCATION_REPLENISHMENT]     VARCHAR (30)    NULL,
    [LAST_LICENSE_USED_IN_FAST_PICKING] NUMERIC (18)    NULL
);

