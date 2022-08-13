CREATE TABLE [dbo].[ZONA01] (
    [CVE_ZONA]   VARCHAR (6)   NOT NULL,
    [CVE_PADRE]  VARCHAR (6)   NULL,
    [TEXTO]      VARCHAR (60)  NULL,
    [TNODO]      VARCHAR (1)   NULL,
    [CTA_CONT]   VARCHAR (28)  NULL,
    [IMPUEFLETE] FLOAT (53)    NULL,
    [MONTOFLETE] FLOAT (53)    NULL,
    [FORMULA]    VARCHAR (255) NULL,
    [STATUS]     VARCHAR (1)   NULL,
    CONSTRAINT [PK_ZONA01] PRIMARY KEY CLUSTERED ([CVE_ZONA] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave zona', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ZONA01', @level2type = N'COLUMN', @level2name = N'CVE_ZONA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave padre', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ZONA01', @level2type = N'COLUMN', @level2name = N'CVE_PADRE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Zona', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ZONA01', @level2type = N'COLUMN', @level2name = N'TEXTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de nodo [A/B/C] .: A=Zona Principal, B= Zona hijo, C=Zona Operativa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ZONA01', @level2type = N'COLUMN', @level2name = N'TNODO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cuenta contable', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ZONA01', @level2type = N'COLUMN', @level2name = N'CTA_CONT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuesto del flete', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ZONA01', @level2type = N'COLUMN', @level2name = N'IMPUEFLETE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Monto del flete', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ZONA01', @level2type = N'COLUMN', @level2name = N'MONTOFLETE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fórmula para el cálculo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ZONA01', @level2type = N'COLUMN', @level2name = N'FORMULA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus [A/B] .: A=Activo, B=Baja', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ZONA01', @level2type = N'COLUMN', @level2name = N'STATUS';

