CREATE TABLE [dbo].[INVE01] (
    [CVE_ART]                VARCHAR (16) NOT NULL,
    [DESCR]                  VARCHAR (40) NULL,
    [LIN_PROD]               VARCHAR (5)  NULL,
    [CON_SERIE]              VARCHAR (1)  NULL,
    [UNI_MED]                VARCHAR (10) NULL,
    [UNI_EMP]                FLOAT (53)   NULL,
    [CTRL_ALM]               VARCHAR (10) NULL,
    [TIEM_SURT]              INT          NULL,
    [STOCK_MIN]              FLOAT (53)   NULL,
    [STOCK_MAX]              FLOAT (53)   NULL,
    [TIP_COSTEO]             VARCHAR (1)  NULL,
    [NUM_MON]                INT          NULL,
    [FCH_ULTCOM]             DATETIME     NULL,
    [COMP_X_REC]             FLOAT (53)   NULL,
    [FCH_ULTVTA]             DATETIME     NULL,
    [PEND_SURT]              FLOAT (53)   NULL,
    [EXIST]                  FLOAT (53)   NULL,
    [COSTO_PROM]             FLOAT (53)   NULL,
    [ULT_COSTO]              FLOAT (53)   NULL,
    [CVE_OBS]                INT          NULL,
    [TIPO_ELE]               VARCHAR (1)  NULL,
    [UNI_ALT]                VARCHAR (10) NULL,
    [FAC_CONV]               FLOAT (53)   NULL,
    [APART]                  FLOAT (53)   NULL,
    [CON_LOTE]               VARCHAR (1)  NULL,
    [CON_PEDIMENTO]          VARCHAR (1)  NULL,
    [PESO]                   FLOAT (53)   NULL,
    [VOLUMEN]                FLOAT (53)   NULL,
    [CVE_ESQIMPU]            INT          NULL,
    [CVE_BITA]               INT          NULL,
    [VTAS_ANL_C]             FLOAT (53)   NULL,
    [VTAS_ANL_M]             FLOAT (53)   NULL,
    [COMP_ANL_C]             FLOAT (53)   NULL,
    [COMP_ANL_M]             FLOAT (53)   NULL,
    [PREFIJO]                VARCHAR (8)  NULL,
    [TALLA]                  VARCHAR (8)  NULL,
    [COLOR]                  VARCHAR (8)  NULL,
    [CUENT_CONT]             VARCHAR (28) NULL,
    [CVE_IMAGEN]             VARCHAR (16) NULL,
    [BLK_CST_EXT]            VARCHAR (1)  NULL,
    [STATUS]                 VARCHAR (1)  NULL,
    [MAN_IEPS]               VARCHAR (1)  DEFAULT ('N') NULL,
    [APL_MAN_IMP]            INT          DEFAULT ((1)) NULL,
    [CUOTA_IEPS]             FLOAT (53)   DEFAULT ((0)) NULL,
    [APL_MAN_IEPS]           VARCHAR (1)  DEFAULT ('C') NULL,
    [UUID]                   VARCHAR (50) NULL,
    [VERSION_SINC]           DATETIME     NULL,
    [VERSION_SINC_FECHA_IMG] DATETIME     NULL,
    [CVE_PRODSERV]           VARCHAR (9)  NULL,
    [CVE_UNIDAD]             VARCHAR (4)  NULL,
    CONSTRAINT [PK_INVE01] PRIMARY KEY CLUSTERED ([CVE_ART] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX1_INVE01]
    ON [dbo].[INVE01]([VERSION_SINC] ASC);


GO
-- =============================================
-- Author:		<Author,		Diego Espinoza>
-- Create date: <Create Date,	Octubre 5 -2020>
-- Description:	<Description,	Para replicar en automatico los codigos creados en SAE.
--				 Req. by Diego E.>
-- =============================================
CREATE TRIGGER [dbo].[Tri_ReplicaExistenciasWMS] 
   ON  [dbo].[INVE01]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	--EXEC OP_WMS_ALZA.wms.BULK_DATA_SP_PROCESS
	PRINT 1

END

GO
DISABLE TRIGGER [dbo].[Tri_ReplicaExistenciasWMS]
    ON [dbo].[INVE01];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave del artículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'CVE_ART';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Descripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'DESCR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de línea', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'LIN_PROD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Con serie [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'CON_SERIE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Unidad de entrada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'UNI_MED';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Unidad de empaque {mayores a 0.0}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'UNI_EMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Control de almacén', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'CTRL_ALM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tiempo de surtido {0.0..}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'TIEM_SURT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Stock mínimo {0.0 .. }', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'STOCK_MIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Stock máximo {0.0 ..}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'STOCK_MAX';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de costeo [P/I/U/S/E] .: P=Promedio, I=Identificado, U=UEPS, S=Estandar, E=PEPS', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'TIP_COSTEO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de moneda', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'NUM_MON';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de última compra', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'FCH_ULTCOM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Pendientes por recibir', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'COMP_X_REC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de última venta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'FCH_ULTVTA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Pendientes por surtir {0.0 ..]', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'PEND_SURT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Existencias {0.0 ..}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'EXIST';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Costo promedio {0.0 ..}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'COSTO_PROM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Último costo {0.0 ..}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'ULT_COSTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de observaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'CVE_OBS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de elemento [P/K/G/S] .: P=Producto, K=Kits, G=Grupo, S=Servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'TIPO_ELE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Unidad de salida', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'UNI_ALT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Factor entre unidades {mayores a  0.0}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'FAC_CONV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Apartados {0.0 ..}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'APART';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Con lote [S / N]', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'CON_LOTE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Con pedimento [S / N]', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'CON_PEDIMENTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Peso {0.0 ..}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'PESO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Volumen {0.0..}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'VOLUMEN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de esquema', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'CVE_ESQIMPU';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de bitácora', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'CVE_BITA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cantidad de ventas anuales', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'VTAS_ANL_C';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Monto de ventas anuales', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'VTAS_ANL_M';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cantidad de compras anuales', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'COMP_ANL_C';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Monto de compras anuales', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'COMP_ANL_M';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Modelo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'PREFIJO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Talla', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'TALLA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Color', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'COLOR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cuenta contable', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'CUENT_CONT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nombre de la imagen', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'CVE_IMAGEN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Bloqueado por costos-existencias. [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'BLK_CST_EXT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus [A/B] .: A=Activo, B=Baja', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Manejo del IEPS. [S/N]: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'MAN_IEPS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de impuesto para aplicarle el manejo del IEPS. [1-4]', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'APL_MAN_IMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cuota que maneja el IEPS.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'CUOTA_IEPS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Forma en que se aplicará el manejo del IEPS [C/M/A]. C=Cuota, M=Más alto, A=Ambos.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'APL_MAN_IEPS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'ID para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'UUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha y hora para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'VERSION_SINC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha y hora para sincronisación de la imagen del producto para SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE01', @level2type = N'COLUMN', @level2name = N'VERSION_SINC_FECHA_IMG';

