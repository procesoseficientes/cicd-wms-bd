CREATE TABLE [dbo].[CUENTA_BENEF01] (
    [CUENTA_BANCARIA] VARCHAR (25) NULL,
    [RFC_BANCO]       VARCHAR (15) NULL,
    [NOMBRE_BANCO]    VARCHAR (40) NULL,
    [CLAVE]           VARCHAR (10) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cuenta bancaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUENTA_BENEF01', @level2type = N'COLUMN', @level2name = N'CUENTA_BANCARIA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'RFC banco', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUENTA_BENEF01', @level2type = N'COLUMN', @level2name = N'RFC_BANCO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nombre del banco', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUENTA_BENEF01', @level2type = N'COLUMN', @level2name = N'NOMBRE_BANCO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUENTA_BENEF01', @level2type = N'COLUMN', @level2name = N'CLAVE';

