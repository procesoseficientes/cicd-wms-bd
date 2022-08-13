CREATE TABLE [dbo].[CONS_PER01] (
    [CVE_CONS] INT          NOT NULL,
    [TITULO]   VARCHAR (50) NULL,
    [USUARIO]  SMALLINT     NULL,
    [TIPO]     INT          NULL,
    [ARCHIVO]  VARCHAR (60) NULL,
    CONSTRAINT [PK_CONS_PER01] PRIMARY KEY CLUSTERED ([CVE_CONS] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONS_PER01', @level2type = N'COLUMN', @level2name = N'CVE_CONS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Título de la consulta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONS_PER01', @level2type = N'COLUMN', @level2name = N'TITULO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Usuario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONS_PER01', @level2type = N'COLUMN', @level2name = N'USUARIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de consulta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONS_PER01', @level2type = N'COLUMN', @level2name = N'TIPO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Archivo de la consulta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONS_PER01', @level2type = N'COLUMN', @level2name = N'ARCHIVO';

