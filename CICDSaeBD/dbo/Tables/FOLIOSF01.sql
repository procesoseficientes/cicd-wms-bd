CREATE TABLE [dbo].[FOLIOSF01] (
    [TIP_DOC]            VARCHAR (1)  NOT NULL,
    [FOLIODESDE]         INT          NOT NULL,
    [FOLIOHASTA]         INT          NULL,
    [AUTORIZA]           INT          NULL,
    [SERIE]              VARCHAR (10) NOT NULL,
    [AUTOANIO]           VARCHAR (4)  NULL,
    [ULT_DOC]            INT          NULL,
    [TIPO]               VARCHAR (1)  NULL,
    [FECH_ULT_DOC]       DATETIME     NULL,
    [CBB]                VARCHAR (50) NULL,
    [FECHAAPROBCBB]      DATETIME     NULL,
    [IMGCBB]             IMAGE        NULL,
    [FOLIOPERSONALIZADO] VARCHAR (1)  NULL,
    [PARCIALIDAD]        VARCHAR (1)  NULL,
    [STATUS]             VARCHAR (1)  NULL,
    CONSTRAINT [PK_FOLIOSF01] PRIMARY KEY CLUSTERED ([TIP_DOC] ASC, [SERIE] ASC, [FOLIODESDE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de documento [F/R/P/C/D] .: F=Facturas, R=Remisiones, P=Pedidos, C=Cotizaciones, D=Devoluciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLIOSF01', @level2type = N'COLUMN', @level2name = N'TIP_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Valor inicial del folio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLIOSF01', @level2type = N'COLUMN', @level2name = N'FOLIODESDE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Valor final del folio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLIOSF01', @level2type = N'COLUMN', @level2name = N'FOLIOHASTA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Autoriza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLIOSF01', @level2type = N'COLUMN', @level2name = N'AUTORIZA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Serie del folio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLIOSF01', @level2type = N'COLUMN', @level2name = N'SERIE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Año de autorización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLIOSF01', @level2type = N'COLUMN', @level2name = N'AUTOANIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Ultimo documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLIOSF01', @level2type = N'COLUMN', @level2name = N'ULT_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de folio [D/I] .: D=Digital, I=Impreso', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLIOSF01', @level2type = N'COLUMN', @level2name = N'TIPO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de último documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLIOSF01', @level2type = N'COLUMN', @level2name = N'FECH_ULT_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Código de barras bidimensional', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLIOSF01', @level2type = N'COLUMN', @level2name = N'CBB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de aprovabación de codigo de barras bidimencional', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLIOSF01', @level2type = N'COLUMN', @level2name = N'FECHAAPROBCBB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Imagen del código de barras bidimensional', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLIOSF01', @level2type = N'COLUMN', @level2name = N'IMGCBB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Personalizarción de Folio [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLIOSF01', @level2type = N'COLUMN', @level2name = N'FOLIOPERSONALIZADO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Serie para parcialidades [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLIOSF01', @level2type = N'COLUMN', @level2name = N'PARCIALIDAD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus [D/B] .: D=Disponible, B = Bloqueado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLIOSF01', @level2type = N'COLUMN', @level2name = N'STATUS';

