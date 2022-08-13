CREATE TABLE [dbo].[PARAM_FACTURA01] (
    [NUM_EMP]                 INT          NOT NULL,
    [FACTURASINEXIST]         VARCHAR (1)  NULL,
    [ALTACLIEPROVENCAPTURA]   VARCHAR (1)  NULL,
    [ACUMCOMPVTASENLINEA]     VARCHAR (1)  NULL,
    [MUESTRADESGKITS]         VARCHAR (1)  NULL,
    [VENDCVESEC]              VARCHAR (1)  NULL,
    [NOAFECDOCTOXCLIE]        VARCHAR (1)  NULL,
    [ALTANUMSERIEENVENTAS]    VARCHAR (1)  NULL,
    [FACTURARLOTPEDSINEXIST]  VARCHAR (1)  NULL,
    [PERMITIRVTAPRODCADUCOS]  VARCHAR (1)  NULL,
    [POLIZASENLINEAVTAS]      VARCHAR (1)  NULL,
    [POLIZASENLINEADEVOL]     VARCHAR (1)  NULL,
    [NUMDESCUENTOS]           INT          NULL,
    [NUMIMPUESTO]             INT          NULL,
    [NUMCPTOCOMPVTASPLAZOS]   INT          NULL,
    [NUMCPTOINTXCOMPVTAPLAZO] INT          NULL,
    [NUMCPTORETCLIEPROV]      INT          NULL,
    [NUMMAXPART]              INT          NULL,
    [MANEJOFLETE]             VARCHAR (1)  NULL,
    [MONTOFLETE]              FLOAT (53)   NULL,
    [IMPFLETE]                FLOAT (53)   NULL,
    [FCHCIERREDOCTOS]         DATETIME     NULL,
    [MODULO]                  VARCHAR (22) NULL,
    [ALMACENDEVOLUCION]       INT          NULL,
    [CONALMACENDEVOLUCION]    VARCHAR (1)  NULL,
    [ALMADEVPER]              INT          NULL,
    [MODIFICARALMACEN]        VARCHAR (1)  NULL,
    [REFORMAFISCAL2012]       INT          NULL,
    [NUMCPTONOTAVTA]          INT          NULL,
    [NUMCPTOEFECTIVO]         INT          NULL,
    [NUMCPTOCAMBIO]           INT          NULL,
    [CAPTPRIMEROPROD]         VARCHAR (1)  NULL,
    [ALMACENFACTGLOB]         INT          NULL,
    [POLIZASENLINEANOTACRED]  VARCHAR (1)  NULL,
    CONSTRAINT [PK_PARAM_FACTURA01] PRIMARY KEY CLUSTERED ([NUM_EMP] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de empresa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'NUM_EMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'FACTURASINEXIST';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'ALTACLIEPROVENCAPTURA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'ACUMCOMPVTASENLINEA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'MUESTRADESGKITS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'VENDCVESEC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'NOAFECDOCTOXCLIE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'ALTANUMSERIEENVENTAS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'FACTURARLOTPEDSINEXIST';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'PERMITIRVTAPRODCADUCOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'POLIZASENLINEAVTAS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'POLIZASENLINEADEVOL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'NUMDESCUENTOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'NUMIMPUESTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'NUMCPTOCOMPVTASPLAZOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'NUMCPTOINTXCOMPVTAPLAZO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'NUMCPTORETCLIEPROV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'NUMMAXPART';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'MANEJOFLETE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'MONTOFLETE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'IMPFLETE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'FCHCIERREDOCTOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'MODULO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'ALMACENDEVOLUCION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'CONALMACENDEVOLUCION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'ALMADEVPER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'MODIFICARALMACEN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'REFORMAFISCAL2012';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Concepto de notas de venta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'NUMCPTONOTAVTA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Concepto para Ventas indicando el efectivo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'NUMCPTOEFECTIVO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Concepto para Ventas indicando el cambio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'NUMCPTOCAMBIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Captura primero prod', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'CAPTPRIMEROPROD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Almacén de facturación global', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURA01', @level2type = N'COLUMN', @level2name = N'ALMACENFACTGLOB';

