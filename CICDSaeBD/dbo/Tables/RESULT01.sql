CREATE TABLE [dbo].[RESULT01] (
    [CVE_RESULTADO] VARCHAR (5)  NOT NULL,
    [DESCR]         VARCHAR (45) NULL,
    [STATUS]        VARCHAR (1)  NULL,
    CONSTRAINT [PK_RESULT01] PRIMARY KEY CLUSTERED ([CVE_RESULTADO] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave del resultado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RESULT01', @level2type = N'COLUMN', @level2name = N'CVE_RESULTADO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Descripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RESULT01', @level2type = N'COLUMN', @level2name = N'DESCR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus [A/B] .: A=Activo, B=Baja', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RESULT01', @level2type = N'COLUMN', @level2name = N'STATUS';

