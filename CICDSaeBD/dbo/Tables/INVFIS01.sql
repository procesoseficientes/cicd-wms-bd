CREATE TABLE [dbo].[INVFIS01] (
    [CVE_ART]   VARCHAR (16) NOT NULL,
    [CVE_ALM]   INT          NOT NULL,
    [EXISTCONG] FLOAT (53)   NULL,
    [SECAPTURO] INT          NULL,
    [EXISTREAL] FLOAT (53)   NULL,
    CONSTRAINT [PK_INVFIS01] PRIMARY KEY CLUSTERED ([CVE_ART] ASC, [CVE_ALM] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de artículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVFIS01', @level2type = N'COLUMN', @level2name = N'CVE_ART';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de almacén', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVFIS01', @level2type = N'COLUMN', @level2name = N'CVE_ALM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Existencias congeladas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVFIS01', @level2type = N'COLUMN', @level2name = N'EXISTCONG';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Se capturó', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVFIS01', @level2type = N'COLUMN', @level2name = N'SECAPTURO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Existencia real', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVFIS01', @level2type = N'COLUMN', @level2name = N'EXISTREAL';

