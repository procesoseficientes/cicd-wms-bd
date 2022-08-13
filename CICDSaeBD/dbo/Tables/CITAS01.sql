CREATE TABLE [dbo].[CITAS01] (
    [CVE_CLIE]   VARCHAR (10) NOT NULL,
    [ASUNTO]     VARCHAR (42) NULL,
    [ID_OUTLOOK] VARCHAR (48) NULL,
    [FECHA_HORA] DATETIME     NULL,
    [STATUS]     VARCHAR (1)  NULL,
    [USUARIO]    VARCHAR (15) NULL,
    [CVE_CITA]   SMALLINT     NULL
);


GO
CREATE NONCLUSTERED INDEX [IDX_CITAS01]
    ON [dbo].[CITAS01]([CVE_CLIE] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave del cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CITAS01', @level2type = N'COLUMN', @level2name = N'CVE_CLIE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Asunto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CITAS01', @level2type = N'COLUMN', @level2name = N'ASUNTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Identificador de outlook', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CITAS01', @level2type = N'COLUMN', @level2name = N'ID_OUTLOOK';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha y hora', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CITAS01', @level2type = N'COLUMN', @level2name = N'FECHA_HORA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus [A/B] .: A=Activo, B=Baja', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CITAS01', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de usuario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CITAS01', @level2type = N'COLUMN', @level2name = N'USUARIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de cita', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CITAS01', @level2type = N'COLUMN', @level2name = N'CVE_CITA';

