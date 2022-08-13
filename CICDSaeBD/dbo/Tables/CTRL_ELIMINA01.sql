CREATE TABLE [dbo].[CTRL_ELIMINA01] (
    [TABLA]        VARCHAR (80) NOT NULL,
    [UUID_REG]     VARCHAR (50) NOT NULL,
    [VERSION_SINC] DATETIME     NOT NULL,
    [UUID]         VARCHAR (50) NOT NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nombre de la tabla donde se elimino el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CTRL_ELIMINA01', @level2type = N'COLUMN', @level2name = N'TABLA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Identificador del regitro eliminado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CTRL_ELIMINA01', @level2type = N'COLUMN', @level2name = N'UUID_REG';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de eliminacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CTRL_ELIMINA01', @level2type = N'COLUMN', @level2name = N'VERSION_SINC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Identificador de la tabla de control', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CTRL_ELIMINA01', @level2type = N'COLUMN', @level2name = N'UUID';

