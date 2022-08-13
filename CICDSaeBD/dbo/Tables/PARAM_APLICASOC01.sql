CREATE TABLE [dbo].[PARAM_APLICASOC01] (
    [NUM_EMP]               INT           NOT NULL,
    [EXECALCULADORA]        VARCHAR (512) NULL,
    [EXEEDITORTEXTOS]       VARCHAR (512) NULL,
    [EXEHOJACALCULO]        VARCHAR (512) NULL,
    [ACTIVARSUGERENCIA]     VARCHAR (1)   NULL,
    [ACTIVARMODOALTCAPTURA] VARCHAR (1)   NULL,
    [IMPRESORA]             VARCHAR (256) NULL,
    CONSTRAINT [PK_PARAM_APLICASOC01] PRIMARY KEY CLUSTERED ([NUM_EMP] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de empresa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_APLICASOC01', @level2type = N'COLUMN', @level2name = N'NUM_EMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Calculadora ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_APLICASOC01', @level2type = N'COLUMN', @level2name = N'EXECALCULADORA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Editor de textos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_APLICASOC01', @level2type = N'COLUMN', @level2name = N'EXEEDITORTEXTOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Hoja de calculo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_APLICASOC01', @level2type = N'COLUMN', @level2name = N'EXEHOJACALCULO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Activa sugerencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_APLICASOC01', @level2type = N'COLUMN', @level2name = N'ACTIVARSUGERENCIA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Activa modo alterno de captura', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_APLICASOC01', @level2type = N'COLUMN', @level2name = N'ACTIVARMODOALTCAPTURA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impresora', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_APLICASOC01', @level2type = N'COLUMN', @level2name = N'IMPRESORA';

