CREATE TABLE [dbo].[PARAM_CTACONTABLE01] (
    [NUM_EMP]         INT          NOT NULL,
    [VENTAS]          VARCHAR (28) NULL,
    [DESCFINANVTAS]   VARCHAR (28) NULL,
    [IMPXPAGAR]       VARCHAR (28) NULL,
    [DEVOLVENTAS]     VARCHAR (28) NULL,
    [VENTASERVICIOS]  VARCHAR (28) NULL,
    [CLIENTES]        VARCHAR (28) NULL,
    [ALMACEN]         VARCHAR (28) NULL,
    [DESCFINANCOMP]   VARCHAR (28) NULL,
    [IMPXACREDITAR]   VARCHAR (28) NULL,
    [DEVOLCOMPRAS]    VARCHAR (28) NULL,
    [COMPRASERVICIOS] VARCHAR (28) NULL,
    [PROVEEDORES]     VARCHAR (28) NULL,
    [BANCOS]          VARCHAR (28) NULL,
    [OTROSIMPUESTOS]  VARCHAR (28) NULL,
    [IMPUESTOVENTA1]  VARCHAR (28) NULL,
    [IMPUESTOVENTA2]  VARCHAR (28) NULL,
    [IMPUESTOVENTA3]  VARCHAR (28) NULL,
    [DIFCOSTOCOMPRA]  VARCHAR (28) NULL,
    [NOTASCRED]       VARCHAR (28) NULL,
    CONSTRAINT [PK_PARAM_CTACONTABLE01] PRIMARY KEY CLUSTERED ([NUM_EMP] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de empresa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_CTACONTABLE01', @level2type = N'COLUMN', @level2name = N'NUM_EMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Ventas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_CTACONTABLE01', @level2type = N'COLUMN', @level2name = N'VENTAS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cuenta contable', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_CTACONTABLE01', @level2type = N'COLUMN', @level2name = N'DESCFINANVTAS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuesto por pagar', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_CTACONTABLE01', @level2type = N'COLUMN', @level2name = N'IMPXPAGAR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Devolución ventas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_CTACONTABLE01', @level2type = N'COLUMN', @level2name = N'DEVOLVENTAS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Ventas Servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_CTACONTABLE01', @level2type = N'COLUMN', @level2name = N'VENTASERVICIOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_CTACONTABLE01', @level2type = N'COLUMN', @level2name = N'CLIENTES';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Almacén', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_CTACONTABLE01', @level2type = N'COLUMN', @level2name = N'ALMACEN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Desc Finan Comp', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_CTACONTABLE01', @level2type = N'COLUMN', @level2name = N'DESCFINANCOMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuesto x acreditar', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_CTACONTABLE01', @level2type = N'COLUMN', @level2name = N'IMPXACREDITAR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Devolución de compras', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_CTACONTABLE01', @level2type = N'COLUMN', @level2name = N'DEVOLCOMPRAS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Compras servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_CTACONTABLE01', @level2type = N'COLUMN', @level2name = N'COMPRASERVICIOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'proveedores', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_CTACONTABLE01', @level2type = N'COLUMN', @level2name = N'PROVEEDORES';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Bancos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_CTACONTABLE01', @level2type = N'COLUMN', @level2name = N'BANCOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Otros impuestos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_CTACONTABLE01', @level2type = N'COLUMN', @level2name = N'OTROSIMPUESTOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuestos venta 1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_CTACONTABLE01', @level2type = N'COLUMN', @level2name = N'IMPUESTOVENTA1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuestos venta 2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_CTACONTABLE01', @level2type = N'COLUMN', @level2name = N'IMPUESTOVENTA2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuestos venta 3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_CTACONTABLE01', @level2type = N'COLUMN', @level2name = N'IMPUESTOVENTA3';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Diferencia Costo Compra', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_CTACONTABLE01', @level2type = N'COLUMN', @level2name = N'DIFCOSTOCOMPRA';

