CREATE TABLE [dbo].[PARAM_FOLIOSC01] (
    [NUM_EMP]      INT            NOT NULL,
    [NUMFOLIO]     VARCHAR (10)   NULL,
    [CVEFOLIO]     VARCHAR (20)   NULL,
    [TIPODOCTO]    VARCHAR (1)    NOT NULL,
    [TIPO]         VARCHAR (1)    NULL,
    [SERIE]        VARCHAR (10)   NOT NULL,
    [FOLIOINICIAL] INT            NULL,
    [SEPARADOR]    VARCHAR (1)    NULL,
    [FTOEMISION]   VARCHAR (1024) NULL,
    [ARCHCONFIG]   VARCHAR (1024) NULL,
    [MASCARA]      VARCHAR (10)   NULL,
    [LONGITUD]     INT            NULL,
    CONSTRAINT [PK_PARAM_FOLIOSC01] PRIMARY KEY CLUSTERED ([NUM_EMP] ASC, [TIPODOCTO] ASC, [SERIE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de empresa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSC01', @level2type = N'COLUMN', @level2name = N'NUM_EMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de folio ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSC01', @level2type = N'COLUMN', @level2name = N'NUMFOLIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de folio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSC01', @level2type = N'COLUMN', @level2name = N'CVEFOLIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSC01', @level2type = N'COLUMN', @level2name = N'TIPODOCTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSC01', @level2type = N'COLUMN', @level2name = N'TIPO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSC01', @level2type = N'COLUMN', @level2name = N'SERIE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSC01', @level2type = N'COLUMN', @level2name = N'FOLIOINICIAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSC01', @level2type = N'COLUMN', @level2name = N'SEPARADOR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSC01', @level2type = N'COLUMN', @level2name = N'FTOEMISION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSC01', @level2type = N'COLUMN', @level2name = N'ARCHCONFIG';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSC01', @level2type = N'COLUMN', @level2name = N'MASCARA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSC01', @level2type = N'COLUMN', @level2name = N'LONGITUD';

