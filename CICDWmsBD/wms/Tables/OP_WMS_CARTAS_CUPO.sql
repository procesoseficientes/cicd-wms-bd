CREATE TABLE [wms].[OP_WMS_CARTAS_CUPO] (
    [CARTA_ID]             NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [ACCOUNT_ID]           VARCHAR (140)   NOT NULL,
    [ACCOUNT_NAME]         VARCHAR (100)   NULL,
    [ADUANA_INGRESO]       VARCHAR (200)   NULL,
    [AGENTE_ADUANA]        VARCHAR (15)    NULL,
    [AGENTE_ADUANA_NOMBRE] VARCHAR (200)   NULL,
    [NUMEROS_POLIZA]       VARCHAR (500)   NULL,
    [UNIDAD_MEDIDA]        VARCHAR (15)    NULL,
    [CANTIDAD]             NUMERIC (18, 2) NULL,
    [DESCRIPCION]          VARCHAR (1500)  NULL,
    [CONTENEDOR]           VARCHAR (150)   NULL,
    [CIF]                  MONEY           NULL,
    [LAST_UPDATE]          DATETIME        NULL,
    [LAST_UPDATE_BY]       VARCHAR (25)    NULL,
    [LAST_ACTION]          VARCHAR (50)    NULL,
    [STATUS]               VARCHAR (25)    NULL
);

