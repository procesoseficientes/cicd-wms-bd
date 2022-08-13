CREATE TABLE [dbo].[PARAM_TIPODOCTOSF01] (
    [NUM_EMP]              INT            NOT NULL,
    [MODULO]               VARCHAR (4)    NOT NULL,
    [TIPODOCTO]            VARCHAR (1)    NOT NULL,
    [FOLIOSECUENCIAL]      VARCHAR (1)    NULL,
    [ARCHCONFIGNOSEC]      VARCHAR (1024) NULL,
    [FTOEMISIONNOSEC]      VARCHAR (1024) NULL,
    [ARCHPLANTILLACORREO]  VARCHAR (1024) NULL,
    [MANEJARVIGENCIACOTIZ] VARCHAR (1)    NULL,
    [DIASVIGENCIACOTIZ]    INT            NULL,
    [IDXFTOFOLIOCONFIG]    INT            NULL,
    [SERIEDEFAULT]         VARCHAR (10)   NULL,
    CONSTRAINT [PK_PARAM_TIPODOCTOSF01] PRIMARY KEY CLUSTERED ([NUM_EMP] ASC, [MODULO] ASC, [TIPODOCTO] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de empresa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_TIPODOCTOSF01', @level2type = N'COLUMN', @level2name = N'NUM_EMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Modulo:Facturas ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_TIPODOCTOSF01', @level2type = N'COLUMN', @level2name = N'MODULO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de documento F,R,C,P,D,A,V', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_TIPODOCTOSF01', @level2type = N'COLUMN', @level2name = N'TIPODOCTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Folio secuencial ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_TIPODOCTOSF01', @level2type = N'COLUMN', @level2name = N'FOLIOSECUENCIAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Archivo de configuración', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_TIPODOCTOSF01', @level2type = N'COLUMN', @level2name = N'ARCHCONFIGNOSEC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Archivo de configuración', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_TIPODOCTOSF01', @level2type = N'COLUMN', @level2name = N'FTOEMISIONNOSEC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Archivo de plantilla de HTML', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_TIPODOCTOSF01', @level2type = N'COLUMN', @level2name = N'ARCHPLANTILLACORREO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Manejar vigencia de cotizaciones ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_TIPODOCTOSF01', @level2type = N'COLUMN', @level2name = N'MANEJARVIGENCIACOTIZ';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de dias de vigencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_TIPODOCTOSF01', @level2type = N'COLUMN', @level2name = N'DIASVIGENCIACOTIZ';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Formato folio de configuracion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_TIPODOCTOSF01', @level2type = N'COLUMN', @level2name = N'IDXFTOFOLIOCONFIG';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Serie default', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_TIPODOCTOSF01', @level2type = N'COLUMN', @level2name = N'SERIEDEFAULT';

