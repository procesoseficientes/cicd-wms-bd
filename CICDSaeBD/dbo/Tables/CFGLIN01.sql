CREATE TABLE [dbo].[CFGLIN01] (
    [CVE_LIN] VARCHAR (5) NOT NULL,
    [LONG1]   INT         NULL,
    [SEP1]    VARCHAR (1) NULL,
    [LONG2]   INT         NULL,
    [SEP2]    VARCHAR (1) NULL,
    [LONG3]   INT         NULL,
    CONSTRAINT [PK_CFGLIN01] PRIMARY KEY CLUSTERED ([CVE_LIN] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de línea', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFGLIN01', @level2type = N'COLUMN', @level2name = N'CVE_LIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'longitud1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFGLIN01', @level2type = N'COLUMN', @level2name = N'LONG1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Separador1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFGLIN01', @level2type = N'COLUMN', @level2name = N'SEP1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Longitud2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFGLIN01', @level2type = N'COLUMN', @level2name = N'LONG2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Separador2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFGLIN01', @level2type = N'COLUMN', @level2name = N'SEP2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Longitud3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CFGLIN01', @level2type = N'COLUMN', @level2name = N'LONG3';

