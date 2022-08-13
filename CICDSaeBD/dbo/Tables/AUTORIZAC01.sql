CREATE TABLE [dbo].[AUTORIZAC01] (
    [CVE_AUT]   INT          NOT NULL,
    [DOCTO_AUT] VARCHAR (20) NULL,
    [NUM_AUT]   VARCHAR (10) NULL,
    [MES_VENC]  INT          NULL,
    [ANIO_VENC] INT          NULL,
    CONSTRAINT [PK_AUTORIZAC01] PRIMARY KEY CLUSTERED ([CVE_AUT] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de autorización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AUTORIZAC01', @level2type = N'COLUMN', @level2name = N'CVE_AUT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Documento de autorización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AUTORIZAC01', @level2type = N'COLUMN', @level2name = N'DOCTO_AUT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de autorización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AUTORIZAC01', @level2type = N'COLUMN', @level2name = N'NUM_AUT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Mes de vencimiento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AUTORIZAC01', @level2type = N'COLUMN', @level2name = N'MES_VENC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Año de vencimiento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AUTORIZAC01', @level2type = N'COLUMN', @level2name = N'ANIO_VENC';

