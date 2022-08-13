CREATE TABLE [dbo].[LTPD01] (
    [CVE_ART]      VARCHAR (16) NOT NULL,
    [LOTE]         VARCHAR (12) NULL,
    [PEDIMENTO]    VARCHAR (21) NULL,
    [CVE_ALM]      INT          NULL,
    [FCHCADUC]     DATETIME     NULL,
    [FCHADUANA]    DATETIME     NULL,
    [FCHULTMOV]    DATETIME     NULL,
    [NOM_ADUAN]    VARCHAR (40) NULL,
    [CANTIDAD]     FLOAT (53)   NULL,
    [REG_LTPD]     INT          NOT NULL,
    [CVE_OBS]      INT          NULL,
    [CIUDAD]       VARCHAR (60) NULL,
    [FRONTERA]     VARCHAR (60) NULL,
    [FEC_PROD_LT]  DATETIME     NULL,
    [GLN]          VARCHAR (13) NULL,
    [STATUS]       VARCHAR (1)  NULL,
    [PEDIMENTOSAT] VARCHAR (21) NULL,
    CONSTRAINT [PK_LTPD01] PRIMARY KEY CLUSTERED ([REG_LTPD] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_LTPD01]
    ON [dbo].[LTPD01]([CVE_ART] ASC, [LOTE] ASC, [PEDIMENTO] ASC, [CVE_ALM] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de artículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LTPD01', @level2type = N'COLUMN', @level2name = N'CVE_ART';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Lote', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LTPD01', @level2type = N'COLUMN', @level2name = N'LOTE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Pedimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LTPD01', @level2type = N'COLUMN', @level2name = N'PEDIMENTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de almacén', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LTPD01', @level2type = N'COLUMN', @level2name = N'CVE_ALM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de caducidad', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LTPD01', @level2type = N'COLUMN', @level2name = N'FCHCADUC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de aduana', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LTPD01', @level2type = N'COLUMN', @level2name = N'FCHADUANA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de último movimiento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LTPD01', @level2type = N'COLUMN', @level2name = N'FCHULTMOV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Aduana', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LTPD01', @level2type = N'COLUMN', @level2name = N'NOM_ADUAN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cantidad {0.0 ..}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LTPD01', @level2type = N'COLUMN', @level2name = N'CANTIDAD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de Registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LTPD01', @level2type = N'COLUMN', @level2name = N'REG_LTPD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de observaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LTPD01', @level2type = N'COLUMN', @level2name = N'CVE_OBS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Ciudad', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LTPD01', @level2type = N'COLUMN', @level2name = N'CIUDAD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Frontera', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LTPD01', @level2type = N'COLUMN', @level2name = N'FRONTERA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de producción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LTPD01', @level2type = N'COLUMN', @level2name = N'FEC_PROD_LT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'G. L. N.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LTPD01', @level2type = N'COLUMN', @level2name = N'GLN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus [A/B] .: A=Activo, B=Baja', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LTPD01', @level2type = N'COLUMN', @level2name = N'STATUS';

