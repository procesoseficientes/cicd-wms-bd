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
    [DESPLIEGUEKITXML]          INT            NULL,
    [SELLOCERTIF_ARCH]          IMAGE          NULL,
    [SELLOPRIVKEY_ARCH]         IMAGE          NULL,
    [REGIMENFISCALSAT]          VARCHAR (4)    NULL,
    [MTOMAXFACT]                FLOAT (53)     NULL,
    [CANCELAENFORMAMANUAL]      VARCHAR (1)    NULL,
    [RUTAADDENDAE]              VARCHAR (1024) NULL,
    [RUTAADDENDAG]              VARCHAR (1024) NULL,
    CONSTRAINT [PK_PARAM_FACTURAELECTRONICA01] PRIMARY KEY CLUSTERED ([NUM_EMP] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de empresa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURAELECTRONICA01', @level2type = N'COLUMN', @level2name = N'NUM_EMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURAELECTRONICA01', @level2type = N'COLUMN', @level2name = N'SELLOCERTIF';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURAELECTRONICA01', @level2type = N'COLUMN', @level2name = N'SELLOPRIVKEY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURAELECTRONICA01', @level2type = N'COLUMN', @level2name = N'CVEACCESOCERT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURAELECTRONICA01', @level2type = N'COLUMN', @level2name = N'AVISASELLO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURAELECTRONICA01', @level2type = N'COLUMN', @level2name = N'RFCMOSTR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURAELECTRONICA01', @level2type = N'COLUMN', @level2name = N'RUTAADDENDAF';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURAELECTRONICA01', @level2type = N'COLUMN', @level2name = N'RUTAADDENDAD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURAELECTRONICA01', @level2type = N'COLUMN', @level2name = N'RUTANAMESPACE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURAELECTRONICA01', @level2type = N'COLUMN', @level2name = N'DESGDESC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURAELECTRONICA01', @level2type = N'COLUMN', @level2name = N'VERSIONCOMPROBANTEDIGITAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURAELECTRONICA01', @level2type = N'COLUMN', @level2name = N'TIPOPACGENERAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURAELECTRONICA01', @level2type = N'COLUMN', @level2name = N'USUARIOPAC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURAELECTRONICA01', @level2type = N'COLUMN', @level2name = N'PASSWORDPAC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURAELECTRONICA01', @level2type = N'COLUMN', @level2name = N'PROVEEDORPAC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURAELECTRONICA01', @level2type = N'COLUMN', @level2name = N'FIRMACONTRATO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURAELECTRONICA01', @level2type = N'COLUMN', @level2name = N'IDSESIONPACGRAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURAELECTRONICA01', @level2type = N'COLUMN', @level2name = N'USUARIOPAC_CANCEL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURAELECTRONICA01', @level2type = N'COLUMN', @level2name = N'PASSWORDPAC_CANCEL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURAELECTRONICA01', @level2type = N'COLUMN', @level2name = N'PROVEEDORPAC_CANCEL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURAELECTRONICA01', @level2type = N'COLUMN', @level2name = N'NOTIFICACANCELACIONENAUTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURAELECTRONICA01', @level2type = N'COLUMN', @level2name = N'REGIMENFISCAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURAELECTRONICA01', @level2type = N'COLUMN', @level2name = N'DESPLIEGUEKITXML';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURAELECTRONICA01', @level2type = N'COLUMN', @level2name = N'SELLOCERTIF_ARCH';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_FACTURAELECTRONICA01', @level2type = N'COLUMN', @level2name = N'SELLOPRIVKEY_ARCH';

