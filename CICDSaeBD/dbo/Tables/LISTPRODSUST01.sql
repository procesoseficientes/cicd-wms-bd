CREATE TABLE [dbo].[LISTPRODSUST01] (
    [CVE_LISTA]   INT          NOT NULL,
    [DESCRIPCION] VARCHAR (40) NULL,
    CONSTRAINT [PK_LISTPRODSUST01] PRIMARY KEY CLUSTERED ([CVE_LISTA] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de la lista', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LISTPRODSUST01', @level2type = N'COLUMN', @level2name = N'CVE_LISTA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Descripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LISTPRODSUST01', @level2type = N'COLUMN', @level2name = N'DESCRIPCION';

