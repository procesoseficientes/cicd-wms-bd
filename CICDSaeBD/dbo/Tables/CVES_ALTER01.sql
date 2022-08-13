CREATE TABLE [dbo].[CVES_ALTER01] (
    [CVE_ART]   VARCHAR (16) NOT NULL,
    [CVE_ALTER] VARCHAR (16) NOT NULL,
    [TIPO]      VARCHAR (1)  NULL,
    [CVE_CLPV]  VARCHAR (10) NULL,
    CONSTRAINT [PK_CVES_ALTER01] PRIMARY KEY CLUSTERED ([CVE_ART] ASC, [CVE_ALTER] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave del artículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CVES_ALTER01', @level2type = N'COLUMN', @level2name = N'CVE_ART';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave alterna', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CVES_ALTER01', @level2type = N'COLUMN', @level2name = N'CVE_ALTER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de clave [C/P/N] .: C=Cliente, P=Proveedor, N=Ninguno ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CVES_ALTER01', @level2type = N'COLUMN', @level2name = N'TIPO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave del cliente/proveedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CVES_ALTER01', @level2type = N'COLUMN', @level2name = N'CVE_CLPV';

