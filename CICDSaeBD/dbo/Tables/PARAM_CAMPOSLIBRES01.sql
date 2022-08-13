CREATE TABLE [dbo].[PARAM_CAMPOSLIBRES01] (
    [NUM_EMP]  INT          NOT NULL,
    [IDTABLA]  VARCHAR (20) NOT NULL,
    [CAMPO]    VARCHAR (30) NOT NULL,
    [ETIQUETA] VARCHAR (30) NULL,
    CONSTRAINT [PK_PARAM_CAMPOSLIBRES01] PRIMARY KEY CLUSTERED ([IDTABLA] ASC, [CAMPO] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de empresa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_CAMPOSLIBRES01', @level2type = N'COLUMN', @level2name = N'NUM_EMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Identificador de la tabla del campo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_CAMPOSLIBRES01', @level2type = N'COLUMN', @level2name = N'IDTABLA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Campo fisico ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_CAMPOSLIBRES01', @level2type = N'COLUMN', @level2name = N'CAMPO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nombre del campo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_CAMPOSLIBRES01', @level2type = N'COLUMN', @level2name = N'ETIQUETA';

