CREATE TABLE [wms].[OP_WMS_LICENSES_HISTORY] (
    [LICENSE_ID]                  NUMERIC (18)    NOT NULL,
    [CLIENT_OWNER]                VARCHAR (25)    NULL,
    [CODIGO_POLIZA]               VARCHAR (25)    NULL,
    [CURRENT_WAREHOUSE]           VARCHAR (25)    NULL,
    [CURRENT_LOCATION]            VARCHAR (25)    NULL,
    [LAST_LOCATION]               VARCHAR (25)    NULL,
    [LAST_UPDATED]                DATETIME        NULL,
    [LAST_UPDATED_BY]             VARCHAR (15)    NULL,
    [STATUS]                      VARCHAR (15)    NULL,
    [REGIMEN]                     VARCHAR (50)    NULL,
    [CREATED_DATE]                DATETIME        NULL,
    [USED_MT2]                    NUMERIC (18, 2) NULL,
    [CODIGO_POLIZA_RECTIFICACION] VARCHAR (25)    NULL,
    CONSTRAINT [PK_OP_WMS_LICENCIAS_HISTORY] PRIMARY KEY CLUSTERED ([LICENSE_ID] ASC) WITH (FILLFACTOR = 80)
);

