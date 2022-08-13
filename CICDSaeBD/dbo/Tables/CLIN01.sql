CREATE TABLE [dbo].[CLIN01] (
    [CVE_LIN]    VARCHAR (5)  NOT NULL,
    [DESC_LIN]   VARCHAR (20) NULL,
    [ESUNGPO]    VARCHAR (1)  NULL,
    [CUENTA_COI] VARCHAR (28) NULL,
    [STATUS]     VARCHAR (1)  NULL,
    CONSTRAINT [PK_CLIN01] PRIMARY KEY CLUSTERED ([CVE_LIN] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de línea', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIN01', @level2type = N'COLUMN', @level2name = N'CVE_LIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Descripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIN01', @level2type = N'COLUMN', @level2name = N'DESC_LIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Es un grupo  [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIN01', @level2type = N'COLUMN', @level2name = N'ESUNGPO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cuenta contable', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIN01', @level2type = N'COLUMN', @level2name = N'CUENTA_COI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus [A/B] .: A=Activo, B=Baja', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIN01', @level2type = N'COLUMN', @level2name = N'STATUS';

