CREATE TABLE [dbo].[MINVE01] (
    [CVE_ART]         VARCHAR (16) NOT NULL,
    [ALMACEN]         INT          NOT NULL,
    [NUM_MOV]         INT          NOT NULL,
    [CVE_CPTO]        INT          NOT NULL,
    [FECHA_DOCU]      DATETIME     NULL,
    [TIPO_DOC]        VARCHAR (1)  NULL,
    [REFER]           VARCHAR (20) NULL,
    [CLAVE_CLPV]      VARCHAR (10) NULL,
    [VEND]            VARCHAR (5)  NULL,
    [CANT]            FLOAT (53)   NULL,
    [CANT_COST]       FLOAT (53)   NULL,
    [PRECIO]          FLOAT (53)   NULL,
    [COSTO]           FLOAT (53)   NULL,
    [AFEC_COI]        VARCHAR (1)  NULL,
    [CVE_OBS]         INT          NULL,
    [REG_SERIE]       INT          NULL,
    [UNI_VENTA]       VARCHAR (10) NULL,
    [E_LTPD]          INT          NULL,
    [EXIST_G]         FLOAT (53)   NULL,
    [EXISTENCIA]      FLOAT (53)   NULL,
    [TIPO_PROD]       VARCHAR (1)  NULL,
    [FACTOR_CON]      FLOAT (53)   NULL,
    [FECHAELAB]       DATETIME     NULL,
    [CTLPOL]          INT          NULL,
    [CVE_FOLIO]       VARCHAR (9)  NULL,
    [SIGNO]           INT          NULL,
    [COSTEADO]        VARCHAR (1)  NULL,
    [COSTO_PROM_INI]  FLOAT (53)   NULL,
    [COSTO_PROM_FIN]  FLOAT (53)   NULL,
    [COSTO_PROM_GRAL] FLOAT (53)   NULL,
    [DESDE_INVE]      VARCHAR (1)  NULL,
    [MOV_ENLAZADO]    INT          NULL
);


GO
CREATE NONCLUSTERED INDEX [IDX_MINVE101]
    ON [dbo].[MINVE01]([CVE_ART] ASC, [ALMACEN] ASC, [NUM_MOV] ASC, [CVE_CPTO] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_MINVE201]
    ON [dbo].[MINVE01]([ALMACEN] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_MINVE301]
    ON [dbo].[MINVE01]([FECHA_DOCU] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_MINVE401]
    ON [dbo].[MINVE01]([CVE_CPTO] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_MINVE501]
    ON [dbo].[MINVE01]([NUM_MOV] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_MINVE601]
    ON [dbo].[MINVE01]([E_LTPD] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de artículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'CVE_ART';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de almacén', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'ALMACEN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de movimiento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'NUM_MOV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de concepto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'CVE_CPTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'FECHA_DOCU';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de documento [F/R/D/c/r/d/N/M] .: F=Factura, R=Remisión, D=Devolución de facturas, c = Compra, r=Recepción, d=Devolución de compras,N = Ninguno (Proviene de traducción), M = Movimiento al inventario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'TIPO_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'REFER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave cliente/proveedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'CLAVE_CLPV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de vendedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'VEND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cantidad {mayor a 0.0}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'CANT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cantidad a costear', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'CANT_COST';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Precio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'PRECIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Costo {mayor  0.0}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'COSTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Afecta a COI [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'AFEC_COI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de observaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'CVE_OBS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Registro de serie', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'REG_SERIE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Unidad de venta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'UNI_VENTA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Enlace de lotes y pedimentos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'E_LTPD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Existencia por producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'EXIST_G';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Existencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'EXISTENCIA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de producto [P]', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'TIPO_PROD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Factor de conversión {mayor a 0.0}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'FACTOR_CON';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de elaboración', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'FECHAELAB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Control de póliza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'CTLPOL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Folio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'CVE_FOLIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Signo [1/-1]', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'SIGNO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Movimiento Costeado [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'COSTEADO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Costo promedio inicial', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'COSTO_PROM_INI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Costo promedio final', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'COSTO_PROM_FIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Costo promedio total', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'COSTO_PROM_GRAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Origen del movimiento [S/N] .: S=Si, N=No .: S=Desde Movimientos al inventario, N=Otro módulo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'DESDE_INVE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Movimiento enlazado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MINVE01', @level2type = N'COLUMN', @level2name = N'MOV_ENLAZADO';

