CREATE TABLE [dbo].[PARAM_PROVEEDORES01] (
    [NUM_EMP]           INT          NOT NULL,
    [CLAVESECUENCIAL]   VARCHAR (1)  NULL,
    [CXCOPINTEGRADO]    VARCHAR (1)  NULL,
    [TIPOAGRUPADOCTOS]  INT          NULL,
    [GANANCIACAMBIARIA] INT          NULL,
    [PERDIDACAMBIARIA]  INT          NULL,
    [MANEJOFOLIO]       VARCHAR (1)  NULL,
    [FOLIO]             VARCHAR (20) NULL,
    [FECHALIMDEMOV]     DATETIME     NULL,
    [AJUSTECARGO]       INT          NULL,
    [AJUSTEABONO]       INT          NULL,
    CONSTRAINT [PK_PARAM_PROVEEDORES01] PRIMARY KEY CLUSTERED ([NUM_EMP] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de empresa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PROVEEDORES01', @level2type = N'COLUMN', @level2name = N'NUM_EMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave secuencial', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PROVEEDORES01', @level2type = N'COLUMN', @level2name = N'CLAVESECUENCIAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cuentas por pagar integrado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PROVEEDORES01', @level2type = N'COLUMN', @level2name = N'CXCOPINTEGRADO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PROVEEDORES01', @level2type = N'COLUMN', @level2name = N'TIPOAGRUPADOCTOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Ganancia cambiaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PROVEEDORES01', @level2type = N'COLUMN', @level2name = N'GANANCIACAMBIARIA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Perdida cambiaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PROVEEDORES01', @level2type = N'COLUMN', @level2name = N'PERDIDACAMBIARIA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Manejo de folio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PROVEEDORES01', @level2type = N'COLUMN', @level2name = N'MANEJOFOLIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Folio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PROVEEDORES01', @level2type = N'COLUMN', @level2name = N'FOLIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha límite de movimientos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PROVEEDORES01', @level2type = N'COLUMN', @level2name = N'FECHALIMDEMOV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'AjusteCargo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PROVEEDORES01', @level2type = N'COLUMN', @level2name = N'AJUSTECARGO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'AjusteAbono', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PROVEEDORES01', @level2type = N'COLUMN', @level2name = N'AJUSTEABONO';

