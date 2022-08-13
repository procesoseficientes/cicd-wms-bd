CREATE TABLE [dbo].[FOLIOSCXC01] (
    [CVE_FOLIO] VARCHAR (10) NOT NULL,
    [ULT_FOLIO] INT          NULL,
    CONSTRAINT [PK_FOLIOSCXC01] PRIMARY KEY CLUSTERED ([CVE_FOLIO] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave del folio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLIOSCXC01', @level2type = N'COLUMN', @level2name = N'CVE_FOLIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Último folio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLIOSCXC01', @level2type = N'COLUMN', @level2name = N'ULT_FOLIO';

