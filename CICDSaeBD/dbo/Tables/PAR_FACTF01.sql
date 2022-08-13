CREATE TABLE [dbo].[PAR_FACTF01] (
    [CVE_DOC]      VARCHAR (20) NOT NULL,
    [NUM_PAR]      INT          NOT NULL,
    [CVE_ART]      VARCHAR (16) NULL,
    [CANT]         FLOAT (53)   NULL,
    [PXS]          FLOAT (53)   NULL,
    [PREC]         FLOAT (53)   NULL,
    [COST]         FLOAT (53)   NULL,
    [IMPU1]        FLOAT (53)   NULL,
    [IMPU2]        FLOAT (53)   NULL,
    [IMPU3]        FLOAT (53)   NULL,
    [IMPU4]        FLOAT (53)   NULL,
    [IMP1APLA]     SMALLINT     NULL,
    [IMP2APLA]     SMALLINT     NULL,
    [IMP3APLA]     SMALLINT     NULL,
    [IMP4APLA]     SMALLINT     NULL,
    [TOTIMP1]      FLOAT (53)   NULL,
    [TOTIMP2]      FLOAT (53)   NULL,
    [TOTIMP3]      FLOAT (53)   NULL,
    [TOTIMP4]      FLOAT (53)   NULL,
    [DESC1]        FLOAT (53)   NULL,
    [DESC2]        FLOAT (53)   NULL,
    [DESC3]        FLOAT (53)   NULL,
    [COMI]         FLOAT (53)   NULL,
    [APAR]         FLOAT (53)   NULL,
    [ACT_INV]      VARCHAR (1)  NULL,
    [NUM_ALM]      INT          NULL,
    [POLIT_APLI]   VARCHAR (1)  NULL,
    [TIP_CAM]      FLOAT (53)   NULL,
    [UNI_VENTA]    VARCHAR (10) NULL,
    [TIPO_PROD]    VARCHAR (1)  NULL,
    [CVE_OBS]      INT          NULL,
    [REG_SERIE]    INT          NULL,
    [E_LTPD]       INT          NULL,
    [TIPO_ELEM]    VARCHAR (1)  NULL,
    [NUM_MOV]      INT          NULL,
    [TOT_PARTIDA]  FLOAT (53)   NULL,
    [IMPRIMIR]     VARCHAR (1)  NULL,
    [UUID]         VARCHAR (50) NULL,
    [VERSION_SINC] DATETIME     NULL,
    [MAN_IEPS]     VARCHAR (1)  NULL,
    [APL_MAN_IMP]  INT          NULL,
    [CUOTA_IEPS]   FLOAT (53)   NULL,
    [APL_MAN_IEPS] VARCHAR (1)  NULL,
    [MTO_PORC]     FLOAT (53)   NULL,
    [MTO_CUOTA]    FLOAT (53)   NULL,
    [CVE_ESQ]      INT          NULL,
    [DESCR_ART]    VARCHAR (40) NULL,
    CONSTRAINT [PK_PAR_FACTF01] PRIMARY KEY CLUSTERED ([CVE_DOC] ASC, [NUM_PAR] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_PAR_DOC_FF01]
    ON [dbo].[PAR_FACTF01]([CVE_DOC] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'CVE_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de partida', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'NUM_PAR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de artículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'CVE_ART';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cantidad', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'CANT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Productos por surtir', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'PXS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Precio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'PREC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Costo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'COST';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuesto 1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'IMPU1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuesto 2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'IMPU2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuesto 3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'IMPU3';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuesto 4', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'IMPU4';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuesto 1 a plazos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'IMP1APLA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuesto 2 a plazos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'IMP2APLA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuesto 3 a plazos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'IMP3APLA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuesto 4 a plazos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'IMP4APLA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Total impuesto 1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'TOTIMP1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Total impuesto 2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'TOTIMP2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Total impuesto 3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'TOTIMP3';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Total impuesto 4', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'TOTIMP4';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Descripción 1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'DESC1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Descripción 2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'DESC2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Descripción 3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'DESC3';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Comisión', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'COMI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Apartados', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'APAR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Actualiza inventario [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'ACT_INV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de almacén', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'NUM_ALM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Política aplicada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'POLIT_APLI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de cambio aplicado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'TIP_CAM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Unidad de venta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'UNI_VENTA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de producto[P/S/G/K] .: P=Producto, S=Servicios, G=Grupo, K=Kits', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'TIPO_PROD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de observaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'CVE_OBS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Registro de serie', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'REG_SERIE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cnlace de lotes y pedimentos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'E_LTPD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de elemento [P/N/G/K] .: P=Producto, N=Ninguno, G=Grupo,K=Kit', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'TIPO_ELEM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de movimiento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'NUM_MOV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Importe total de la partida', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'TOT_PARTIDA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Imprimir [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'IMPRIMIR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'ID para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'UUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha y hora para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'VERSION_SINC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Manejo de IEPS', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'MAN_IEPS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de impuesto para aplicarle el manejo del IEPS [1-4]', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'APL_MAN_IMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cuota que maneja el IEPS.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'CUOTA_IEPS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Forma en que se aplicará el manejo del IEPS [C/M/A]. C=Cuota, M=Más alto, A=Ambos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'APL_MAN_IEPS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Monto por pocentaje', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'MTO_PORC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Monto por cuota', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'MTO_CUOTA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de esquema', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTF01', @level2type = N'COLUMN', @level2name = N'CVE_ESQ';

