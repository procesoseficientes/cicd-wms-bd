CREATE TABLE [dbo].[KITS01] (
    [CVE_ART]  VARCHAR (16) NOT NULL,
    [CVE_PROD] VARCHAR (16) NOT NULL,
    [PORCEN]   FLOAT (53)   NULL,
    [CANTIDAD] FLOAT (53)   NULL,
    CONSTRAINT [PK_KITS01] PRIMARY KEY CLUSTERED ([CVE_ART] ASC, [CVE_PROD] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave del artículo kit', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'KITS01', @level2type = N'COLUMN', @level2name = N'CVE_ART';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de producto elemento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'KITS01', @level2type = N'COLUMN', @level2name = N'CVE_PROD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Porcentaje {0.0 .. 100.0}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'KITS01', @level2type = N'COLUMN', @level2name = N'PORCEN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cantidad {mayor a 0.0}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'KITS01', @level2type = N'COLUMN', @level2name = N'CANTIDAD';

