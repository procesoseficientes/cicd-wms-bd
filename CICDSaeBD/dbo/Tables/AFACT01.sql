CREATE TABLE [dbo].[AFACT01] (
    [CVE_AFACT] INT        NOT NULL,
    [FVTA_COM]  FLOAT (53) NULL,
    [FDESCTO]   FLOAT (53) NULL,
    [FDES_FIN]  FLOAT (53) NULL,
    [FIMP]      FLOAT (53) NULL,
    [FCOMI]     FLOAT (53) NULL,
    [RVTA_COM]  FLOAT (53) NULL,
    [RDESCTO]   FLOAT (53) NULL,
    [RDES_FIN]  FLOAT (53) NULL,
    [RIMP]      FLOAT (53) NULL,
    [RCOMI]     FLOAT (53) NULL,
    [DVTA_COM]  FLOAT (53) NULL,
    [DDESCTO]   FLOAT (53) NULL,
    [DDES_FIN]  FLOAT (53) NULL,
    [DIMP]      FLOAT (53) NULL,
    [DCOMI]     FLOAT (53) NULL,
    [PVTA_COM]  FLOAT (53) NULL,
    [PDESCTO]   FLOAT (53) NULL,
    [PDES_FIN]  FLOAT (53) NULL,
    [PIMP]      FLOAT (53) NULL,
    [PCOMI]     FLOAT (53) NULL,
    [CVTA_COM]  FLOAT (53) NULL,
    [CDESCTO]   FLOAT (53) NULL,
    [CDES_FIN]  FLOAT (53) NULL,
    [CIMP]      FLOAT (53) NULL,
    [CCOMI]     FLOAT (53) NULL,
    [VVTA_COM]  FLOAT (53) NULL,
    [VDESCTO]   FLOAT (53) NULL,
    [VDES_FIN]  FLOAT (53) NULL,
    [VIMP]      FLOAT (53) NULL,
    [VCOMI]     FLOAT (53) NULL,
    [WVTA_COM]  FLOAT (53) NULL,
    [WDESCTO]   FLOAT (53) NULL,
    [WDES_FIN]  FLOAT (53) NULL,
    [WIMP]      FLOAT (53) NULL,
    [WCOMI]     FLOAT (53) NULL,
    [PER_ACUM]  DATETIME   NULL,
    [EVTA_COM]  FLOAT (53) NULL,
    [EDESCTO]   FLOAT (53) NULL,
    [EDES_FIN]  FLOAT (53) NULL,
    [EIMP]      FLOAT (53) NULL,
    [ECOMI]     FLOAT (53) NULL,
    CONSTRAINT [PK_AFACT01] PRIMARY KEY CLUSTERED ([CVE_AFACT] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de acumulado de ventas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'CVE_AFACT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de facturas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'FVTA_COM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de descuento de facturas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'FDESCTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de descuento financiero de facturas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'FDES_FIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de impuestos de facturas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'FIMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de comisión de facturas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'FCOMI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de remisiones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'RVTA_COM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de descuento de remisiones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'RDESCTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de descuento financiero de remisiones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'RDES_FIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de impuestos de remisiones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'RIMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de comisión de remisiones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'RCOMI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de devoluciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'DVTA_COM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de descuento de devoluciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'DDESCTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de descuento financiero de devoluciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'DDES_FIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de impuestos de devoluciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'DIMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de comisión de devoluciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'DCOMI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de pedidos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'PVTA_COM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de descuento de pedidos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'PDESCTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de descuento financiero. de pedidos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'PDES_FIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de impuestos de  pedidos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'PIMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de comisión de pedidos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'PCOMI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de cotizaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'CVTA_COM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de descuento de cotizaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'CDESCTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de descuento financiero de cotizaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'CDES_FIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de impuestos de cotizaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'CIMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de comisión de cotizaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'CCOMI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de notas de venta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'VVTA_COM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de descuento de notas de venta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'VDESCTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de descuento financiero de notas de venta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'VDES_FIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de impuestos de notas de venta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'VIMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de comisión de notas de venta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'VCOMI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de devolución de notas de venta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'WVTA_COM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de descuento de devolución de notas de venta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'WDESCTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de descuento financiero de devolución de notas de venta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'WDES_FIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de impuestos de devolución de notas de venta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'WIMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de comisión de devolución de notas de venta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'WCOMI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha realización de acumulado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AFACT01', @level2type = N'COLUMN', @level2name = N'PER_ACUM';

