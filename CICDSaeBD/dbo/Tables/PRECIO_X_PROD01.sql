CREATE TABLE [dbo].[PRECIO_X_PROD01] (
    [CVE_ART]      VARCHAR (16) NOT NULL,
    [CVE_PRECIO]   INT          NOT NULL,
    [PRECIO]       FLOAT (53)   NULL,
    [UUID]         VARCHAR (50) NULL,
    [VERSION_SINC] DATETIME     NULL,
    CONSTRAINT [PK_PRECIO_X_PROD01] PRIMARY KEY CLUSTERED ([CVE_ART] ASC, [CVE_PRECIO] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_PP_CVE_ART01]
    ON [dbo].[PRECIO_X_PROD01]([CVE_ART] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_PP_CVE_PREC01]
    ON [dbo].[PRECIO_X_PROD01]([CVE_PRECIO] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX1_PXP01]
    ON [dbo].[PRECIO_X_PROD01]([VERSION_SINC] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de artículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PRECIO_X_PROD01', @level2type = N'COLUMN', @level2name = N'CVE_ART';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de precio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PRECIO_X_PROD01', @level2type = N'COLUMN', @level2name = N'CVE_PRECIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Precio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PRECIO_X_PROD01', @level2type = N'COLUMN', @level2name = N'PRECIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'ID para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PRECIO_X_PROD01', @level2type = N'COLUMN', @level2name = N'UUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha y hora para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PRECIO_X_PROD01', @level2type = N'COLUMN', @level2name = N'VERSION_SINC';

