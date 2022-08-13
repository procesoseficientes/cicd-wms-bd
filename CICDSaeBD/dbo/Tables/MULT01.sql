CREATE TABLE [dbo].[MULT01] (
    [CVE_ART]      VARCHAR (16) NOT NULL,
    [CVE_ALM]      INT          NOT NULL,
    [STATUS]       VARCHAR (1)  NULL,
    [CTRL_ALM]     VARCHAR (10) NULL,
    [EXIST]        FLOAT (53)   NULL,
    [STOCK_MIN]    FLOAT (53)   NULL,
    [STOCK_MAX]    FLOAT (53)   NULL,
    [COMP_X_REC]   FLOAT (53)   NULL,
    [UUID]         VARCHAR (50) NULL,
    [VERSION_SINC] DATETIME     NULL,
    CONSTRAINT [PK_MULT01] PRIMARY KEY CLUSTERED ([CVE_ART] ASC, [CVE_ALM] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_MULT_CVE_ART01]
    ON [dbo].[MULT01]([CVE_ART] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_MULT_CVE_ALM01]
    ON [dbo].[MULT01]([CVE_ALM] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de artículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MULT01', @level2type = N'COLUMN', @level2name = N'CVE_ART';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de almacén', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MULT01', @level2type = N'COLUMN', @level2name = N'CVE_ALM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus [A/B] .: A=Activo, B=Baja', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MULT01', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Control de almacén', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MULT01', @level2type = N'COLUMN', @level2name = N'CTRL_ALM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Existencias {0.0 ..}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MULT01', @level2type = N'COLUMN', @level2name = N'EXIST';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Stock mínimo {0.0 ..}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MULT01', @level2type = N'COLUMN', @level2name = N'STOCK_MIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Stock máximo {0.0 ..}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MULT01', @level2type = N'COLUMN', @level2name = N'STOCK_MAX';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Compras por recibir {0.0 ..}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MULT01', @level2type = N'COLUMN', @level2name = N'COMP_X_REC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'ID para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MULT01', @level2type = N'COLUMN', @level2name = N'UUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha y hora para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MULT01', @level2type = N'COLUMN', @level2name = N'VERSION_SINC';

