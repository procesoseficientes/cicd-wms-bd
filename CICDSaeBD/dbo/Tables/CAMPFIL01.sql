CREATE TABLE [dbo].[CAMPFIL01] (
    [CVE_CAMPANIA]          VARCHAR (5)   NOT NULL,
    [CMB_VIGENCIA]          INT           NULL,
    [CRITERIOS_CLIEN]       INT           NULL,
    [CLIE_DESDE]            VARCHAR (10)  NULL,
    [CLIE_HASTA]            VARCHAR (10)  NULL,
    [CLASIFICACION]         VARCHAR (10)  NULL,
    [VENDEDOR]              VARCHAR (5)   NULL,
    [ZONA]                  VARCHAR (6)   NULL,
    [ESTATUS]               VARCHAR (1)   NULL,
    [CMB_VENTA_ANUAL]       INT           NULL,
    [VENTA_ANUAL]           FLOAT (53)    NULL,
    [CMB_DESCUENTO]         INT           NULL,
    [DESCUENTO]             FLOAT (53)    NULL,
    [CMB_SALDO]             INT           NULL,
    [SALDO]                 FLOAT (53)    NULL,
    [CHK_LIMITE]            VARCHAR (1)   NULL,
    [CMB_PORCENTAJE_LIM]    INT           NULL,
    [CMB_DIAS_CARTERA]      INT           NULL,
    [DIAS]                  INT           NULL,
    [CHK_DIAS]              INT           NULL,
    [CMB_DIAS_CREDITO]      INT           NULL,
    [FECH_INICIAL_ULTCOMPR] DATETIME      NULL,
    [FECH_FINAL_ULTCOMPR]   DATETIME      NULL,
    [CMB_ULTIMACOMPRA]      INT           NULL,
    [FECH_INICIAL_APLIC]    DATETIME      NULL,
    [FECH_FINAL_APLIC]      DATETIME      NULL,
    [CMB_APLIC]             INT           NULL,
    [DOCS_DESDE]            VARCHAR (20)  NULL,
    [DOCS_HASTA]            VARCHAR (20)  NULL,
    [FOLIOS_DESDE]          VARCHAR (10)  NULL,
    [FOLIOS_HASTA]          VARCHAR (10)  NULL,
    [CONCEPTOS]             VARCHAR (255) NULL,
    [PERIODO]               VARCHAR (1)   NULL,
    [FECH_PERIODO_INICIAL]  DATETIME      NULL,
    [FECH_PERIODO_FINAL]    DATETIME      NULL,
    [CMB_PERIODO]           INT           NULL,
    [TIPOVENTA]             INT           NULL,
    [VENTAS_DESDE]          VARCHAR (20)  NULL,
    [VENTAS_HASTA]          VARCHAR (20)  NULL,
    [VENTAS_VENDEDOR]       VARCHAR (5)   NULL,
    [VENTAS_MONEDA]         VARCHAR (5)   NULL,
    [VENTAS_ALMACEN]        VARCHAR (5)   NULL,
    [VENTAS_FECH_INICIAL]   DATETIME      NULL,
    [VENTAS_FECH_FINAL]     DATETIME      NULL,
    [CMB_VENTAS]            INT           NULL,
    [CHK_CANCELACIONES]     VARCHAR (1)   NULL,
    [CMB_IMPORTE_VENTA]     INT           NULL,
    [IMPORTE_VENTA]         FLOAT (53)    NULL,
    [PROD_DESDE]            VARCHAR (10)  NULL,
    [PROD_HASTA]            VARCHAR (10)  NULL,
    [PROD_LINEA]            VARCHAR (10)  NULL,
    [INV_PROD]              VARCHAR (1)   NULL,
    [INV_GRUPOP]            VARCHAR (1)   NULL,
    [INV_KITS]              VARCHAR (1)   NULL,
    [INV_SERV]              VARCHAR (1)   NULL,
    [CMB_CANTIDAD]          INT           NULL,
    [INV_CANT]              FLOAT (53)    NULL,
    [GUIA]                  VARCHAR (255) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de campaña', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'CVE_CAMPANIA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Rango predefinido para las fechas de vigencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'CMB_VIGENCIA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Criterios para clientes {0..2} .: 0=Todos, 1=Sin clientes, 2=Usar criterios de selección', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'CRITERIOS_CLIEN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave inicial del cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'CLIE_DESDE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave final del cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'CLIE_HASTA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clasificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'CLASIFICACION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de vendedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'VENDEDOR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de zona', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'ZONA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus del cliente [0/1/2/3] .: 0=Todos, 1=Activos, 2=Suspendidos, 3=Morosos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'ESTATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Operador venta anual {0..6} .: 0 = Todos, 1 = Exacto, 2 = Mayor, 3 = Mayor o menor, 4 = menor, 5 = menor o igual, 6 = diferente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'CMB_VENTA_ANUAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Monto venta anual', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'VENTA_ANUAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Operador descuento {0..6} .: 0=Todos, 1=Exacto, 2=Mayor, 3=Mayor o menor, 4=menor, 5=menor o igual, 6=diferente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'CMB_DESCUENTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Monto descuento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'DESCUENTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Operador saldo {0..6} .: 0=Todos, 1=Exacto, 2=Mayor, 3=Mayor o menor, 4=menor, 5=menor o igual, 6=diferente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'CMB_SALDO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Monto saldo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'SALDO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Vs. Límite de crédito [0/1] .: 0 = Vs Saldo, 1 = Vs Límite', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'CHK_LIMITE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Operador porcentaje de límite de crédito{0..6} .: 0=Todos, 1=Exacto, 2=Mayor, 3=Mayor o menor, 4=menor, 5=menor o igual, 6=diferente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'CMB_PORCENTAJE_LIM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Operador de días de cartera{0..6} .: 0=Todos, 1=Exacto, 2=Mayor, 3=Mayor o menor, 4=menor, 5=menor o igual, 6=diferente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'CMB_DIAS_CARTERA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cantidad de días', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'DIAS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Vs. Días de crédito [0/1] .: 0 = Vs Cartera, 1 = Vs Días de crédito', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'CHK_DIAS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Operador de días de crédito {0..6} .: 0=Todos, 1=Exacto, 2=Mayor, 3=Mayor o menor, 4=menor, 5=menor o igual, 6=diferente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'CMB_DIAS_CREDITO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha inicial de última compra', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'FECH_INICIAL_ULTCOMPR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha final de última compra', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'FECH_FINAL_ULTCOMPR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Rango predefinido de última compra', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'CMB_ULTIMACOMPRA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha inicial de aplicación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'FECH_INICIAL_APLIC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha final de aplicación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'FECH_FINAL_APLIC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Rango predefinido de fechas de aplicación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'CMB_APLIC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Documento inicial', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'DOCS_DESDE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Documento final', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'DOCS_HASTA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Folio inicial', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'FOLIOS_DESDE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Folio final', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'FOLIOS_HASTA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Conceptos {lista de conceptos seleccionados}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'CONCEPTOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Periodo [0/1] .: 0=Aplicacion, 1=Vencimiento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'PERIODO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha incial del período', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'FECH_PERIODO_INICIAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha final del período', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'FECH_PERIODO_FINAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Rango predefinido de fechas para el período', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'CMB_PERIODO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo venta {0..5} .: 0=Todos, 1=Factura, 2=Remisón, 3=Pedido, 4=Cotización, 5=Devolución', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'TIPOVENTA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Documento inicial', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'VENTAS_DESDE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Documento final', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'VENTAS_HASTA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave del vendedor del documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'VENTAS_VENDEDOR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de la moneda del documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'VENTAS_MONEDA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave del almacén del documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'VENTAS_ALMACEN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha inicial del documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'VENTAS_FECH_INICIAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha final del documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'VENTAS_FECH_FINAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Operador del importe {0..6} .: 0=Todos, 1=Exacto, 2=Mayor, 3=Mayor o menor, 4=menor, 5=menor o igual, 6=diferente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'CMB_VENTAS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Incluye Cancelaciones [0/1] .: 0=No incluye, 1=Si incluye', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'CHK_CANCELACIONES';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Operador del importe de ventas {0..6} .: 0=Todos, 1=Exacto, 2=Mayor, 3=Mayor o menor, 4=menor, 5=menor o igual, 6=diferente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'CMB_IMPORTE_VENTA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Monto del importe del documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'IMPORTE_VENTA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Producto inicial', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'PROD_DESDE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Producto final', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'PROD_HASTA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de la línea del producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'PROD_LINEA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de producto P= Producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'INV_PROD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de producto G= Grupo de productos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'INV_GRUPOP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de producto K= Kit', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'INV_KITS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de producto S= Servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'INV_SERV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Operador de la cantidad {0..6} .: 0=Todos, 1=Exacto, 2=Mayor, 3=Mayor o menor, 4=menor, 5=menor o igual, 6=diferente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'CMB_CANTIDAD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cantidad', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'INV_CANT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Opcion de Conceptos [T/L] .: T=Todos, L=Selección de conceptos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMPFIL01', @level2type = N'COLUMN', @level2name = N'GUIA';

