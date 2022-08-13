CREATE TABLE [dbo].[PARAM_DATOSGRALES01] (
    [NUM_EMP]                INT           NOT NULL,
    [REDON_MONTOS]           VARCHAR (1)   NULL,
    [REDON_COSTOS]           VARCHAR (1)   NULL,
    [CHARCOMPDOS]            VARCHAR (1)   NULL,
    [POL_DESC]               VARCHAR (1)   NULL,
    [CXCCLIEMOSTR]           VARCHAR (1)   NULL,
    [MULTIMONEDA]            VARCHAR (1)   NULL,
    [VALENLINEA]             VARCHAR (1)   NULL,
    [SOLICITATIPOCAMBIO]     VARCHAR (1)   NULL,
    [MOSTRARIMAGCONSULTA]    VARCHAR (1)   NULL,
    [ESQIMPUESTO]            INT           NULL,
    [DESCCOMERCIAL]          FLOAT (53)    NULL,
    [CAJONINSTALADO]         VARCHAR (1)   NULL,
    [PUERTOCAJON]            VARCHAR (20)  NULL,
    [SECAPERTURA]            VARCHAR (20)  NULL,
    [SECINICIO]              VARCHAR (20)  NULL,
    [SECCONFIRMA]            VARCHAR (20)  NULL,
    [MONEDAPRED]             INT           NULL,
    [IMPGLOBAL]              FLOAT (53)    NULL,
    [TIPOCAMBIO]             FLOAT (53)    NULL,
    [NUMEMPCOI]              INT           NULL,
    [CONINTOUTLOOK]          VARCHAR (1)   NULL,
    [NUMDEC_ENMONTOS]        INT           NULL,
    [PAGOPORINTERNET]        VARCHAR (1)   NULL,
    [REGSXDEMANDA]           VARCHAR (1)   NULL,
    [TAMPAQUETE]             INT           NULL,
    [BITACORA_CLIENTES]      VARCHAR (1)   NULL,
    [BITACORA_FACTURAS]      VARCHAR (1)   NULL,
    [BITACORA_INVENTARIO]    VARCHAR (1)   NULL,
    [BITACORA_PROVEEDOR]     VARCHAR (1)   NULL,
    [BITACORA_COMPRAS]       VARCHAR (1)   NULL,
    [NOSERVPAGOXINTER]       VARCHAR (20)  NULL,
    [BITACORA_UTILERIAS]     VARCHAR (1)   NULL,
    [BITACORA_ESTADISTICAS]  VARCHAR (1)   NULL,
    [BITACORA_CONFIGSISTEMA] VARCHAR (1)   NULL,
    [RUTAREPORTES]           VARCHAR (255) NULL,
    [NUMDEC_ENCOSTOYPRECIO]  INT           NULL,
    [NUMDEC_PORCENTAJES]     INT           NULL,
    [CORREOSERVIDOR]         VARCHAR (50)  NULL,
    [CORREOPUERTO]           INT           NULL,
    [CORREOUSUARIO]          VARCHAR (100) NULL,
    [CORREOCONTRASENIA]      VARCHAR (200) NULL,
    [CORREOCONSEG]           VARCHAR (1)   NULL,
    [CORREOAUTEN]            VARCHAR (1)   NULL,
    [CORREOPROVEEDOR]        INT           NULL,
    [DESGLOSEIMP1]           VARCHAR (1)   NULL,
    [DESGLOSEIMP2]           VARCHAR (1)   NULL,
    [DESGLOSEIMP3]           VARCHAR (1)   NULL,
    [DESGLOSEIMP4]           VARCHAR (1)   NULL,
    [REFBANCO]               VARCHAR (3)   NULL,
    [NUMCTAPAGO]             VARCHAR (16)  NULL,
    [VERSIONREESTRUCTURADA]  INT           DEFAULT ((3)) NULL,
    [LAT_GENERAL]            FLOAT (53)    NULL,
    [LON_GENERAL]            FLOAT (53)    NULL,
    [LAT_ENVIO]              FLOAT (53)    NULL,
    [LON_ENVIO]              FLOAT (53)    NULL,
    [TIEMPOAIRE]             VARCHAR (1)   DEFAULT ('F') NULL,
    CONSTRAINT [PK_PARAM_DATOSGRALES01] PRIMARY KEY CLUSTERED ([NUM_EMP] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de empresa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'NUM_EMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Redondeo montos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'REDON_MONTOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Redondeo costos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'REDON_COSTOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Char compatible con DOS', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'CHARCOMPDOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Politica de descuento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'POL_DESC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cliente mostrador cxc', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'CXCCLIEMOSTR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Multimoneda', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'MULTIMONEDA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'VALENLINEA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Solicitar tipo de cambio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'SOLICITATIPOCAMBIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Mostrar imagen en consulta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'MOSTRARIMAGCONSULTA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Esquema impuesto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'ESQIMPUESTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'DESCCOMERCIAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'CAJONINSTALADO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'PUERTOCAJON';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'SECAPERTURA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'SECINICIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'SECCONFIRMA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'MONEDAPRED';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'IMPGLOBAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'TIPOCAMBIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'NUMEMPCOI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'CONINTOUTLOOK';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'NUMDEC_ENMONTOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'PAGOPORINTERNET';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'REGSXDEMANDA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'TAMPAQUETE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'BITACORA_CLIENTES';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'BITACORA_FACTURAS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'BITACORA_INVENTARIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'BITACORA_PROVEEDOR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'BITACORA_COMPRAS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'NOSERVPAGOXINTER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'BITACORA_UTILERIAS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'BITACORA_ESTADISTICAS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'BITACORA_CONFIGSISTEMA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'RUTAREPORTES';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'NUMDEC_ENCOSTOYPRECIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'NUMDEC_PORCENTAJES';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'CORREOSERVIDOR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'CORREOPUERTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'CORREOUSUARIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'CORREOCONTRASENIA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'CORREOCONSEG';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'CORREOAUTEN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'CORREOPROVEEDOR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'DESGLOSEIMP1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'DESGLOSEIMP2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'DESGLOSEIMP3';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'DESGLOSEIMP4';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Referencia del banco', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'REFBANCO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de cuenta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'NUMCTAPAGO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Vesión reestructurada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'VERSIONREESTRUCTURADA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Latitud para la direccion de datos generales', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'LAT_GENERAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Longitud para la direccion de datos generales', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'LON_GENERAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Latitud para la direccion de datos de envio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'LAT_ENVIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Longitud para la direccion de datos de envio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSGRALES01', @level2type = N'COLUMN', @level2name = N'LON_ENVIO';

