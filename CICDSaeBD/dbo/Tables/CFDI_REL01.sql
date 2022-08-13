CREATE TABLE [dbo].[CFDI_REL01] (
    [UUID]        VARCHAR (36) NOT NULL,
    [TIP_REL]     VARCHAR (3)  NOT NULL,
    [CVE_DOC]     VARCHAR (20) NULL,
    [CVE_DOC_REL] VARCHAR (20) NULL,
    [TIP_DOC]     VARCHAR (1)  NULL,
    [NO_SERIE]    VARCHAR (30) NULL,
    [FOLIO]       VARCHAR (10) NULL,
    [FECHA_CERT]  VARCHAR (30) NULL
);


GO
CREATE NONCLUSTERED INDEX [IDX_CFDI_REL_FG01]
    ON [dbo].[CFDI_REL01]([UUID] ASC, [TIP_REL] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'UUID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDI_REL01', @level2type = N'COLUMN', @level2name = N'UUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de relación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDI_REL01', @level2type = N'COLUMN', @level2name = N'TIP_REL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave del documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDI_REL01', @level2type = N'COLUMN', @level2name = N'CVE_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave del documento relacionado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDI_REL01', @level2type = N'COLUMN', @level2name = N'CVE_DOC_REL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDI_REL01', @level2type = N'COLUMN', @level2name = N'TIP_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de serie', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDI_REL01', @level2type = N'COLUMN', @level2name = N'NO_SERIE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Folio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDI_REL01', @level2type = N'COLUMN', @level2name = N'FOLIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de certificación del documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFDI_REL01', @level2type = N'COLUMN', @level2name = N'FECHA_CERT';

