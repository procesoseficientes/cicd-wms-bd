CREATE TABLE [dbo].[FOTO_INVE01] (
    [CVE_ART] VARCHAR (16) NOT NULL,
    [FOTO]    IMAGE        NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave del producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOTO_INVE01', @level2type = N'COLUMN', @level2name = N'CVE_ART';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Foto del producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOTO_INVE01', @level2type = N'COLUMN', @level2name = N'FOTO';

