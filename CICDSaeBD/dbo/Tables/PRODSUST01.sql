CREATE TABLE [dbo].[PRODSUST01] (
    [CVE_ART]   VARCHAR (16) NOT NULL,
    [CVE_LISTA] INT          NULL,
    CONSTRAINT [PK_PRODSUST01] PRIMARY KEY CLUSTERED ([CVE_ART] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave del artículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PRODSUST01', @level2type = N'COLUMN', @level2name = N'CVE_ART';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de lista', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PRODSUST01', @level2type = N'COLUMN', @level2name = N'CVE_LISTA';

