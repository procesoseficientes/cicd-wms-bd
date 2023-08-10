CREATE TABLE [dbo].[PARAM_FACTURAELECTRONICA01] (
    [NUM_EMP]                   INT            NOT NULL,
    [SELLOCERTIF]               VARCHAR (1024) NULL,
    [SELLOPRIVKEY]              VARCHAR (1024) NULL,
    [CVEACCESOCERT]             VARCHAR (256)  NULL,
    [AVISASELLO]                INT            NULL,
    [RFCMOSTR]                  VARCHAR (15)   NULL,
    [RUTAADDENDAF]              VARCHAR (1024) NULL,
    [RUTAADDENDAD]              VARCHAR (1024) NULL,
    [RUTANAMESPACE]             VARCHAR (1024) NULL,
    [DESGDESC]                  VARCHAR (1)    NULL,
    [VERSIONCOMPROBANTEDIGITAL] INT            NULL,
    [TIPOPACGENERAL]            VARCHAR (1)    NULL,
    [USUARIOPAC]                VARCHAR (255)  NULL,
    [PASSWORDPAC]               VARCHAR (255)  NULL,
    [PROVEEDORPAC]              VARCHAR (30)   NULL,
    [FIRMACONTRATO]             VARCHAR (1)    NULL,
    [IDSESIONPACGRAL]           VARCHAR (50)   NULL,
    [USUARIOPAC_CANCEL]         VARCHAR (255)  NULL,
    [PASSWORDPAC_CANCEL]        VARCHAR (255)  NULL,
    [PROVEEDORPAC_CANCEL]       VARCHAR (30)   NULL,
    [NOTIFICACANCELACIONENAUTO] VARCHAR (1)    NULL,
    [REGIMENFISCAL]             VARCHAR (255)  NULL,
    [REGIMENFISCALSAT]          VARCHAR (4)    NULL,
    [DESPLIEGUEKITXML]          INT            NULL,
    [SELLOCERTIF_ARCH]          IMAGE          NULL,
    [SELLOPRIVKEY_ARCH]         IMAGE          NULL,
    [CANCELAENFORMAMANUAL]      VARCHAR (1)    NULL,
    [MTOMAXFACT]                FLOAT (53)     NULL,
    [RUTAADDENDAG]              VARCHAR (1024) NULL,
    [RUTAADDENDAE]              VARCHAR (1024) NULL,
    [RUTAADDENDAT]              VARCHAR (1024) NULL,
    CONSTRAINT [PK_PARAM_FACTURAELECTRONICA01] PRIMARY KEY CLUSTERED ([NUM_EMP] ASC)
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


