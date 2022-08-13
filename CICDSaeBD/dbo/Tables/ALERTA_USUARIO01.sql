CREATE TABLE [dbo].[ALERTA_USUARIO01] (
    [CVE_ALERTA] INT         NOT NULL,
    [ID_USUARIO] INT         NOT NULL,
    [ACTIVA]     VARCHAR (1) NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_ALERTA_USUARIO01]
    ON [dbo].[ALERTA_USUARIO01]([CVE_ALERTA] ASC, [ID_USUARIO] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de alerta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ALERTA_USUARIO01', @level2type = N'COLUMN', @level2name = N'CVE_ALERTA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de usuario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ALERTA_USUARIO01', @level2type = N'COLUMN', @level2name = N'ID_USUARIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Activa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ALERTA_USUARIO01', @level2type = N'COLUMN', @level2name = N'ACTIVA';

