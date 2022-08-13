CREATE TABLE [dbo].[PARAM_FOLIOSF01] (
    [NUM_EMP]            INT            NOT NULL,
    [NUMFOLIO]           VARCHAR (10)   NULL,
    [CVEFOLIO]           VARCHAR (20)   NULL,
    [TIPODOCTO]          VARCHAR (1)    NOT NULL,
    [TIPO]               VARCHAR (1)    NULL,
    [SERIE]              VARCHAR (10)   NOT NULL,
    [SEPARADOR]          VARCHAR (1)    NULL,
    [FTOEMISION]         VARCHAR (1024) NULL,
    [MASCARA]            VARCHAR (10)   NULL,
    [FOLIOINICIAL]       INT            NULL,
    [FOLIOFINAL]         INT            NULL,
    [ARCHCONFIG]         VARCHAR (1024) NULL,
    [LONGITUD]           INT            NULL,
    [CALLE]              VARCHAR (80)   NULL,
    [NUMEROEXT]          VARCHAR (15)   NULL,
    [NUMEROINT]          VARCHAR (15)   NULL,
    [COLONIA]            VARCHAR (50)   NULL,
    [LOCALIDAD]          VARCHAR (50)   NULL,
    [REFERENCIA]         VARCHAR (255)  NULL,
    [MUNICIPIO]          VARCHAR (50)   NULL,
    [ESTADO]             VARCHAR (50)   NULL,
    [PAIS]               VARCHAR (50)   NULL,
    [CP]                 VARCHAR (5)    NULL,
    [CRUZAMIENTO1]       VARCHAR (40)   NULL,
    [CRUZAMIENTO2]       VARCHAR (40)   NULL,
    [SELLOCERTIF]        VARCHAR (1024) NULL,
    [SELLOPRIVKEY]       VARCHAR (1024) NULL,
    [CVEACCESOCERT]      VARCHAR (256)  NULL,
    [AVISASELLO]         INT            NULL,
    [USUARIOPAC]         VARCHAR (255)  NULL,
    [PASSWORDPAC]        VARCHAR (255)  NULL,
    [PROVEEDORPAC]       VARCHAR (30)   NULL,
    [FIRMACONTRATO]      VARCHAR (1)    NULL,
    [IDSESIONPAC]        VARCHAR (50)   NULL,
    [REGIMENFISCAL]      VARCHAR (255)  NULL,
    [LUGARDEEXPEDICION]  VARCHAR (250)  NULL,
    [PARCIALIDAD]        VARCHAR (1)    NULL,
    [PLANTILLA]          VARCHAR (100)  NULL,
    [FOLIOPERSONALIZADO] VARCHAR (1)    NULL,
    [STATUS]             VARCHAR (1)    NULL,
    [SELLOCERTIF_ARCH]   IMAGE          NULL,
    [SELLOPRIVKEY_ARCH]  IMAGE          NULL,
    [REGIMENFISCALSAT]   VARCHAR (4)    NULL,
    [FTOEMISIONCFDI33]   VARCHAR (1024) NULL,
    CONSTRAINT [PK_PARAM_FOLIOSF01] PRIMARY KEY CLUSTERED ([NUM_EMP] ASC, [TIPODOCTO] ASC, [SERIE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de empresa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'NUM_EMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de folio ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'NUMFOLIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de folio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'CVEFOLIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'TIPODOCTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'TIPO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'SERIE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'SEPARADOR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'FTOEMISION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'MASCARA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'FOLIOINICIAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'FOLIOFINAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'ARCHCONFIG';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'LONGITUD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'CALLE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'NUMEROEXT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'NUMEROINT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'COLONIA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'LOCALIDAD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'REFERENCIA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'MUNICIPIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'ESTADO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'PAIS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'CP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'CRUZAMIENTO1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'CRUZAMIENTO2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'SELLOCERTIF';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'SELLOPRIVKEY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'CVEACCESOCERT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'AVISASELLO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'USUARIOPAC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'PASSWORDPAC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'PROVEEDORPAC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'FIRMACONTRATO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'IDSESIONPAC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'REGIMENFISCAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'LUGARDEEXPEDICION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'PARCIALIDAD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'PLANTILLA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'FOLIOPERSONALIZADO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'SELLOCERTIF_ARCH';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FOLIOSF01', @level2type = N'COLUMN', @level2name = N'SELLOPRIVKEY_ARCH';

