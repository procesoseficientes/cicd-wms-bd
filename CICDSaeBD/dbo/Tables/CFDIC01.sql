CREATE TABLE [dbo].[CFDIC01] (
    [TIPO_DOC]       VARCHAR (1)  NOT NULL,
    [CVE_DOC]        VARCHAR (20) NOT NULL,
    [ID_TIMBRADO]    VARCHAR (36) NOT NULL,
    [FECHA_TIMBRADO] VARCHAR (30) NULL,
    [FOLIO_TIMBRADO] VARCHAR (30) NULL,
    [SERIE_TIMBRADO] VARCHAR (30) NULL,
    [RFC_EMISOR]     VARCHAR (30) NULL,
    [RFC_RECEPTOR]   VARCHAR (30) NULL,
    [MONTO]          FLOAT (53)   NULL,
    [XML_DOC]        TEXT         NULL,
    [RESPUESTA]      VARCHAR (1)  NULL,
    [XML_ACUSE]      TEXT         NULL,
    [VERSION]        VARCHAR (5)  NULL,
    CONSTRAINT [PK_CFDIC01] PRIMARY KEY CLUSTERED ([TIPO_DOC] ASC, [CVE_DOC] ASC, [ID_TIMBRADO] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_VERSION_C01]
    ON [dbo].[CFDIC01]([VERSION] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_CFDIC_CVE_DOC01]
    ON [dbo].[CFDIC01]([CVE_DOC] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo del documento [C/D] .: F=Facturas, D=Devoluciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDIC01', @level2type = N'COLUMN', @level2name = N'TIPO_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDIC01', @level2type = N'COLUMN', @level2name = N'CVE_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Identificador UUID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDIC01', @level2type = N'COLUMN', @level2name = N'ID_TIMBRADO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de creación del UUID ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDIC01', @level2type = N'COLUMN', @level2name = N'FECHA_TIMBRADO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Folio del documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDIC01', @level2type = N'COLUMN', @level2name = N'FOLIO_TIMBRADO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de serie del documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDIC01', @level2type = N'COLUMN', @level2name = N'SERIE_TIMBRADO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'RFC del emisor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDIC01', @level2type = N'COLUMN', @level2name = N'RFC_EMISOR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'RFC del receptor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDIC01', @level2type = N'COLUMN', @level2name = N'RFC_RECEPTOR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDIC01', @level2type = N'COLUMN', @level2name = N'MONTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Documento XML', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDIC01', @level2type = N'COLUMN', @level2name = N'XML_DOC';

