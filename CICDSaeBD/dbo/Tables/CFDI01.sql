CREATE TABLE [dbo].[CFDI01] (
    [TIPO_DOC]        VARCHAR (1)  NOT NULL,
    [CVE_DOC]         VARCHAR (20) NOT NULL,
    [VERSION]         VARCHAR (5)  NULL,
    [UUID]            VARCHAR (36) NULL,
    [NO_SERIE]        VARCHAR (30) NULL,
    [FECHA_CERT]      VARCHAR (30) NULL,
    [FECHA_CANCELA]   VARCHAR (30) NULL,
    [XML_DOC]         TEXT         NULL,
    [XML_DOC_CANCELA] TEXT         NULL,
    [DESGLOCEIMP1]    VARCHAR (1)  NULL,
    [DESGLOCEIMP2]    VARCHAR (1)  NULL,
    [DESGLOCEIMP3]    VARCHAR (1)  NULL,
    [DESGLOCEIMP4]    VARCHAR (1)  NULL,
    [MSJ_CANC]        VARCHAR (80) NULL,
    [PENDIENTE]       VARCHAR (2)  NULL,
    [CVE_USUARIO]     INT          NULL,
    CONSTRAINT [PK_CFDI01] PRIMARY KEY CLUSTERED ([TIPO_DOC] ASC, [CVE_DOC] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_PENDIENTE01]
    ON [dbo].[CFDI01]([PENDIENTE] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_VERSION_V01]
    ON [dbo].[CFDI01]([VERSION] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_USUARIO01]
    ON [dbo].[CFDI01]([CVE_USUARIO] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_CFDI_CVE_DOC01]
    ON [dbo].[CFDI01]([CVE_DOC] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo del documento [F/D/A] .: F=Facturas, D=Devoluciones, A=Parcialidades', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDI01', @level2type = N'COLUMN', @level2name = N'TIPO_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave del documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDI01', @level2type = N'COLUMN', @level2name = N'CVE_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Versión del timbre', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDI01', @level2type = N'COLUMN', @level2name = N'VERSION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Identificador del timbre', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDI01', @level2type = N'COLUMN', @level2name = N'UUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de serie del timbre', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDI01', @level2type = N'COLUMN', @level2name = N'NO_SERIE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de timbrado del documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDI01', @level2type = N'COLUMN', @level2name = N'FECHA_CERT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de cancelación del documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDI01', @level2type = N'COLUMN', @level2name = N'FECHA_CANCELA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Documento XML', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDI01', @level2type = N'COLUMN', @level2name = N'XML_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Documento XML de acuse de cancelación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDI01', @level2type = N'COLUMN', @level2name = N'XML_DOC_CANCELA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Desgloce impuesto 1 [S/N] .: S = Si, N= No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDI01', @level2type = N'COLUMN', @level2name = N'DESGLOCEIMP1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Desgloce impuesto 2 [S/N] .: S = Si, N= No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDI01', @level2type = N'COLUMN', @level2name = N'DESGLOCEIMP2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Desgloce impuesto 3 [S/N] .: S = Si, N= No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDI01', @level2type = N'COLUMN', @level2name = N'DESGLOCEIMP3';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Desgloce impuesto 4 [S/N] .: S = Si, N= No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDI01', @level2type = N'COLUMN', @level2name = N'DESGLOCEIMP4';

