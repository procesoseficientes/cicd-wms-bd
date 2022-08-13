CREATE TABLE [dbo].[PARAM_PARTIDASFACT01] (
    [NUM_EMP]                INT         NOT NULL,
    [CAPENALTADOCTODESCTO]   VARCHAR (1) NULL,
    [CAPENALTADOCTOIMP]      VARCHAR (1) NULL,
    [CAPENALTADOCTOCOMISION] VARCHAR (1) NULL,
    [CAPALMACENXPARTIDAS]    VARCHAR (1) NULL,
    [CAPENALTADOCTOOBS]      VARCHAR (1) NULL,
    [VERENCSTATIPOPROD]      VARCHAR (1) NULL,
    [VERENCSTANUMSERIE]      VARCHAR (1) NULL,
    [VERENCSTALOTEPED]       VARCHAR (1) NULL,
    [VERENCSTAOBS]           VARCHAR (1) NULL,
    [VERENCSTAAPARTADOS]     VARCHAR (1) NULL,
    [VERENCSTADSGLSGPOPROD]  VARCHAR (1) NULL,
    [VERENCAPTIPOPROD]       VARCHAR (1) NULL,
    [VERENCAPNUMSERIE]       VARCHAR (1) NULL,
    [VERENCAPLOTEPED]        VARCHAR (1) NULL,
    [VERENCAPOBS]            VARCHAR (1) NULL,
    [VERENCAPAPARTADOS]      VARCHAR (1) NULL,
    [VERENCAPDESCRPROD]      VARCHAR (1) NULL,
    [VERENCAPCOSTOPROD]      VARCHAR (1) NULL,
    CONSTRAINT [PK_PARAM_PARTIDASFACT01] PRIMARY KEY CLUSTERED ([NUM_EMP] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de empresa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PARTIDASFACT01', @level2type = N'COLUMN', @level2name = N'NUM_EMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PARTIDASFACT01', @level2type = N'COLUMN', @level2name = N'CAPENALTADOCTODESCTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PARTIDASFACT01', @level2type = N'COLUMN', @level2name = N'CAPENALTADOCTOIMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PARTIDASFACT01', @level2type = N'COLUMN', @level2name = N'CAPENALTADOCTOCOMISION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PARTIDASFACT01', @level2type = N'COLUMN', @level2name = N'CAPALMACENXPARTIDAS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PARTIDASFACT01', @level2type = N'COLUMN', @level2name = N'CAPENALTADOCTOOBS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PARTIDASFACT01', @level2type = N'COLUMN', @level2name = N'VERENCSTATIPOPROD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PARTIDASFACT01', @level2type = N'COLUMN', @level2name = N'VERENCSTANUMSERIE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PARTIDASFACT01', @level2type = N'COLUMN', @level2name = N'VERENCSTALOTEPED';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PARTIDASFACT01', @level2type = N'COLUMN', @level2name = N'VERENCSTAOBS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PARTIDASFACT01', @level2type = N'COLUMN', @level2name = N'VERENCSTAAPARTADOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PARTIDASFACT01', @level2type = N'COLUMN', @level2name = N'VERENCSTADSGLSGPOPROD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PARTIDASFACT01', @level2type = N'COLUMN', @level2name = N'VERENCAPTIPOPROD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PARTIDASFACT01', @level2type = N'COLUMN', @level2name = N'VERENCAPNUMSERIE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PARTIDASFACT01', @level2type = N'COLUMN', @level2name = N'VERENCAPLOTEPED';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PARTIDASFACT01', @level2type = N'COLUMN', @level2name = N'VERENCAPOBS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PARTIDASFACT01', @level2type = N'COLUMN', @level2name = N'VERENCAPAPARTADOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PARTIDASFACT01', @level2type = N'COLUMN', @level2name = N'VERENCAPDESCRPROD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_PARTIDASFACT01', @level2type = N'COLUMN', @level2name = N'VERENCAPCOSTOPROD';

