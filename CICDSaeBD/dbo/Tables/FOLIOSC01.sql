CREATE TABLE [dbo].[FOLIOSC01] (
    [TIP_DOC]      VARCHAR (1)  NOT NULL,
    [FOLIODESDE]   INT          NOT NULL,
    [FOLIOHASTA]   INT          NULL,
    [SERIE]        VARCHAR (10) NOT NULL,
    [ULT_DOC]      INT          NULL,
    [FECH_ULT_DOC] DATETIME     NULL,
    [STATUS]       VARCHAR (1)  NULL,
    CONSTRAINT [PK_FOLIOSC01] PRIMARY KEY CLUSTERED ([TIP_DOC] ASC, [SERIE] ASC, [FOLIODESDE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de documento [c/d/o/q/r] .: c=Compras, d=Devoluciones, o=Ordenes, q=Requisiciones, r=Recepciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLIOSC01', @level2type = N'COLUMN', @level2name = N'TIP_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Folio inicial', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLIOSC01', @level2type = N'COLUMN', @level2name = N'FOLIODESDE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Folio Final', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLIOSC01', @level2type = N'COLUMN', @level2name = N'FOLIOHASTA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Serie del folio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLIOSC01', @level2type = N'COLUMN', @level2name = N'SERIE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Último documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLIOSC01', @level2type = N'COLUMN', @level2name = N'ULT_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de último documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLIOSC01', @level2type = N'COLUMN', @level2name = N'FECH_ULT_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus [A/B] .: A=Activo, B=Baja', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLIOSC01', @level2type = N'COLUMN', @level2name = N'STATUS';

