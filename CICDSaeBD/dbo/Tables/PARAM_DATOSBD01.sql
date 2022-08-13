CREATE TABLE [dbo].[PARAM_DATOSBD01] (
    [NUM_EMP]     INT            NOT NULL,
    [RUTADATOS]   VARCHAR (256)  NULL,
    [DRIVER]      VARCHAR (256)  NULL,
    [USUARIO]     VARCHAR (30)   NULL,
    [RUTATRABAJO] VARCHAR (1024) NULL,
    [VERSIONBD]   VARCHAR (7)    NULL,
    CONSTRAINT [PK_PARAM_DATOSBD01] PRIMARY KEY CLUSTERED ([NUM_EMP] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de empresa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSBD01', @level2type = N'COLUMN', @level2name = N'NUM_EMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Base de datos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSBD01', @level2type = N'COLUMN', @level2name = N'RUTADATOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Driver', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSBD01', @level2type = N'COLUMN', @level2name = N'DRIVER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Usuario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSBD01', @level2type = N'COLUMN', @level2name = N'USUARIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Ruta de trabajo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSBD01', @level2type = N'COLUMN', @level2name = N'RUTATRABAJO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Versión dela base de datos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSBD01', @level2type = N'COLUMN', @level2name = N'VERSIONBD';

