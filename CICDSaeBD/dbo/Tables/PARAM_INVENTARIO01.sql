CREATE TABLE [dbo].[PARAM_INVENTARIO01] (
    [NUM_EMP]             INT           NOT NULL,
    [INTEGRAFACTURAS]     VARCHAR (1)   NULL,
    [INTEGRACOMPRAS]      VARCHAR (1)   NULL,
    [CAMBIOEXISTENCIAS]   VARCHAR (1)   NULL,
    [DIGITOVERIFICA]      VARCHAR (1)   NULL,
    [MULTIALMACEN]        VARCHAR (1)   NULL,
    [CVEPRECMINIMO]       INT           NULL,
    [MOVTRASPASOENTRADA]  INT           NULL,
    [MOVTRASPASOSALIDA]   INT           NULL,
    [NUMDECIMALES]        INT           NULL,
    [GPOPRODLEYENDASECC1] VARCHAR (8)   NULL,
    [GPOPRODLEYENDASECC2] VARCHAR (8)   NULL,
    [FTOMOVSINVENTARIO]   VARCHAR (256) NULL,
    [VERENALTANUMSERIE]   VARCHAR (1)   NULL,
    [VERENALTALOTEYPED]   VARCHAR (1)   NULL,
    [NOMBREIMP1]          VARCHAR (18)  NULL,
    [NOMBREIMP2]          VARCHAR (18)  NULL,
    [NOMBREIMP3]          VARCHAR (18)  NULL,
    [NOMBREIMP4]          VARCHAR (18)  NULL,
    [PORCENTAJEIMP1]      FLOAT (53)    NULL,
    [PORCENTAJEIMP2]      FLOAT (53)    NULL,
    [PORCENTAJEIMP3]      FLOAT (53)    NULL,
    [PORCENTAJEIMP4]      FLOAT (53)    NULL,
    [ALMACENPREDETER]     INT           NULL,
    [INVINTEGRADO]        VARCHAR (1)   NULL,
    [MODALMACEN]          VARCHAR (1)   NULL,
    [FCHCIERREDOCTOS]     DATETIME      NULL,
    [SERVICIOFLETE]       VARCHAR (16)  NULL,
    [COSTEARXALMACEN]     VARCHAR (1)   NULL,
    [PRODFACTGLOB]        VARCHAR (16)  NULL,
    [NOMBREIMP1SAT]       VARCHAR (3)   NULL,
    [NOMBREIMP2SAT]       VARCHAR (3)   NULL,
    [NOMBREIMP3SAT]       VARCHAR (3)   NULL,
    [NOMBREIMP4SAT]       VARCHAR (3)   NULL,
    CONSTRAINT [PK_PARAM_INVENTARIO01] PRIMARY KEY CLUSTERED ([NUM_EMP] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de empresa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'NUM_EMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Integrado a facturas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'INTEGRAFACTURAS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Integrado a compras', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'INTEGRACOMPRAS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cambio de existencias', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'CAMBIOEXISTENCIAS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'DIGITOVERIFICA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Multialmacén', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'MULTIALMACEN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de precio minimo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'CVEPRECMINIMO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Movimiento de traspaso de entrada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'MOVTRASPASOENTRADA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Movimiento de traspaso de salida', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'MOVTRASPASOSALIDA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de decimales', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'NUMDECIMALES';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Leyenda de la sección 1 de grupos de productos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'GPOPRODLEYENDASECC1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Leyenda de la sección 1 de grupos de productos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'GPOPRODLEYENDASECC2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Formato de movimientos al inventario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'FTOMOVSINVENTARIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Ver en alta numeros de serie', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'VERENALTANUMSERIE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Ver en alta lotes y pedimentos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'VERENALTALOTEYPED';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nombre del impuesto 1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'NOMBREIMP1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nombre del impuesto 2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'NOMBREIMP2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nombre del impuesto 3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'NOMBREIMP3';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nombre del impuesto 4', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'NOMBREIMP4';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Porcentaje del impuesto 1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'PORCENTAJEIMP1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Porcentaje del impuesto 2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'PORCENTAJEIMP2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Porcentaje del impuesto 3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'PORCENTAJEIMP3';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Porcentaje del impuesto 4', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'PORCENTAJEIMP4';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Almacén predeterminado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'ALMACENPREDETER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Inventario integrado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'INVINTEGRADO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'MODALMACEN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'FCHCIERREDOCTOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'SERVICIOFLETE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'COSTEARXALMACEN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave del servicio para facturación global sin desglose', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_INVENTARIO01', @level2type = N'COLUMN', @level2name = N'PRODFACTGLOB';

