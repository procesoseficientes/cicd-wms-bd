CREATE TABLE [dbo].[PAIS01] (
    [CVE_PAIS] VARCHAR (2)   NOT NULL,
    [DESCR]    VARCHAR (120) NULL,
    CONSTRAINT [PK_PAIS01] PRIMARY KEY CLUSTERED ([CVE_PAIS] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de país', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAIS01', @level2type = N'COLUMN', @level2name = N'CVE_PAIS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Descripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAIS01', @level2type = N'COLUMN', @level2name = N'DESCR';

