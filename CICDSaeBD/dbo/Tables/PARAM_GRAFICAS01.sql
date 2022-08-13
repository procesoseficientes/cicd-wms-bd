CREATE TABLE [dbo].[PARAM_GRAFICAS01] (
    [NUM_EMP]          INT         NOT NULL,
    [AJUSTVALMAX]      VARCHAR (1) NULL,
    [GRAFICACUM]       VARCHAR (1) NULL,
    [NUMMAXVAL]        INT         NULL,
    [NUMSALTOS]        INT         NULL,
    [COPIARASCII]      VARCHAR (1) NULL,
    [COPIARLOTUS]      VARCHAR (1) NULL,
    [COPIAREXCEL]      VARCHAR (1) NULL,
    [COPIARCONENCAB]   VARCHAR (1) NULL,
    [COPIARCONTOTALES] VARCHAR (1) NULL,
    CONSTRAINT [PK_PARAM_GRAFICAS01] PRIMARY KEY CLUSTERED ([NUM_EMP] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de empresa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_GRAFICAS01', @level2type = N'COLUMN', @level2name = N'NUM_EMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Ajustar valor máximo ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_GRAFICAS01', @level2type = N'COLUMN', @level2name = N'AJUSTVALMAX';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Graficar acumulados', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_GRAFICAS01', @level2type = N'COLUMN', @level2name = N'GRAFICACUM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número máximo de valores', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_GRAFICAS01', @level2type = N'COLUMN', @level2name = N'NUMMAXVAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de saltos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_GRAFICAS01', @level2type = N'COLUMN', @level2name = N'NUMSALTOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Copiar ASCII', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_GRAFICAS01', @level2type = N'COLUMN', @level2name = N'COPIARASCII';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Copiar Lotus', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_GRAFICAS01', @level2type = N'COLUMN', @level2name = N'COPIARLOTUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Copiar excel', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_GRAFICAS01', @level2type = N'COLUMN', @level2name = N'COPIAREXCEL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Copiar con encabezado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_GRAFICAS01', @level2type = N'COLUMN', @level2name = N'COPIARCONENCAB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Copiar con totales', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_GRAFICAS01', @level2type = N'COLUMN', @level2name = N'COPIARCONTOTALES';

