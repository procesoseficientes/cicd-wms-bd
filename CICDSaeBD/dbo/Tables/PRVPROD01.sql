CREATE TABLE [dbo].[PRVPROD01] (
    [CVE_ART]   VARCHAR (16) NOT NULL,
    [CVE_PROV]  VARCHAR (10) NOT NULL,
    [COSTO]     FLOAT (53)   NULL,
    [T_ENTREGA] INT          NULL,
    CONSTRAINT [PK_PRVPROD01] PRIMARY KEY CLUSTERED ([CVE_ART] ASC, [CVE_PROV] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de artículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PRVPROD01', @level2type = N'COLUMN', @level2name = N'CVE_ART';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de proveedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PRVPROD01', @level2type = N'COLUMN', @level2name = N'CVE_PROV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Costo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PRVPROD01', @level2type = N'COLUMN', @level2name = N'COSTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tiempo de entrega', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PRVPROD01', @level2type = N'COLUMN', @level2name = N'T_ENTREGA';

