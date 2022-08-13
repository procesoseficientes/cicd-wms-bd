CREATE TABLE [dbo].[PARAM_DOMEXPED01] (
    [NUM_EMP]      INT           NOT NULL,
    [CALLE]        VARCHAR (80)  NULL,
    [NUMERO_EXT]   VARCHAR (15)  NULL,
    [NUMERO_INT]   VARCHAR (15)  NULL,
    [COLONIA]      VARCHAR (50)  NULL,
    [LOCALIDAD]    VARCHAR (60)  NULL,
    [REFERENCIA]   VARCHAR (255) NULL,
    [MUNICIPIO]    VARCHAR (50)  NULL,
    [ESTADO]       VARCHAR (50)  NULL,
    [PAIS]         VARCHAR (50)  NULL,
    [CP]           VARCHAR (5)   NULL,
    [CRUZAMIENTO1] VARCHAR (40)  NULL,
    [CRUZAMIENTO2] VARCHAR (40)  NULL,
    [LUGARDEEXPED] VARCHAR (250) NULL,
    CONSTRAINT [PK_PARAM_DOMEXPED01] PRIMARY KEY CLUSTERED ([NUM_EMP] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de empresa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DOMEXPED01', @level2type = N'COLUMN', @level2name = N'NUM_EMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Calle', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DOMEXPED01', @level2type = N'COLUMN', @level2name = N'CALLE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número exterior', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DOMEXPED01', @level2type = N'COLUMN', @level2name = N'NUMERO_EXT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número interior', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DOMEXPED01', @level2type = N'COLUMN', @level2name = N'NUMERO_INT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Colonia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DOMEXPED01', @level2type = N'COLUMN', @level2name = N'COLONIA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Localidad', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DOMEXPED01', @level2type = N'COLUMN', @level2name = N'LOCALIDAD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Referencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DOMEXPED01', @level2type = N'COLUMN', @level2name = N'REFERENCIA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Municipio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DOMEXPED01', @level2type = N'COLUMN', @level2name = N'MUNICIPIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DOMEXPED01', @level2type = N'COLUMN', @level2name = N'ESTADO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Pais', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DOMEXPED01', @level2type = N'COLUMN', @level2name = N'PAIS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Código postal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DOMEXPED01', @level2type = N'COLUMN', @level2name = N'CP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cruzamiento 1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DOMEXPED01', @level2type = N'COLUMN', @level2name = N'CRUZAMIENTO1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cruzamiento 2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DOMEXPED01', @level2type = N'COLUMN', @level2name = N'CRUZAMIENTO2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Lugar de expedición', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DOMEXPED01', @level2type = N'COLUMN', @level2name = N'LUGARDEEXPED';

