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
    [REGIMENFISCALSAT]   VARCHAR (4)    NULL,
    [LUGARDEEXPEDICION]  VARCHAR (250)  NULL,
    [PARCIALIDAD]        VARCHAR (1)    NULL,
    [PLANTILLA]          VARCHAR (100)  NULL,
    [FOLIOPERSONALIZADO] VARCHAR (1)    NULL,
    [STATUS]             VARCHAR (1)    NULL,
    [SELLOCERTIF_ARCH]   IMAGE          NULL,
    [SELLOPRIVKEY_ARCH]  IMAGE          NULL,
    [FTOEMISIONCFDI33]   VARCHAR (1024) NULL,
    [UBI_EMI]            TEXT           NULL,
    [CAP_COM_EXT]        VARCHAR (1)    NULL,
    [FTOEMISIONCFDI40]   VARCHAR (1024) NULL,
    [ZONAHORARIABASE]    INT            NULL,
    [ZONAHORARIACP]      INT            NULL,
    CONSTRAINT [PK_PARAM_FOLIOSF01] PRIMARY KEY CLUSTERED ([NUM_EMP] ASC, [TIPODOCTO] ASC, [SERIE] ASC)
);




GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO


