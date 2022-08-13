CREATE TABLE [dbo].[TALLA01] (
    [CVE_LIN] VARCHAR (5)  NOT NULL,
    [VALOR]   VARCHAR (8)  NOT NULL,
    [DESCRIP] VARCHAR (30) NULL,
    CONSTRAINT [PK_TALLA01] PRIMARY KEY CLUSTERED ([CVE_LIN] ASC, [VALOR] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de línea', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TALLA01', @level2type = N'COLUMN', @level2name = N'CVE_LIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Talla', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TALLA01', @level2type = N'COLUMN', @level2name = N'VALOR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Descripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TALLA01', @level2type = N'COLUMN', @level2name = N'DESCRIP';

