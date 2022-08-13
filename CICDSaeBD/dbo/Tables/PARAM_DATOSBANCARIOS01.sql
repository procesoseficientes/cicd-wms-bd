CREATE TABLE [dbo].[PARAM_DATOSBANCARIOS01] (
    [NUM_EMP] INT           NOT NULL,
    [BANCO]   VARCHAR (300) NULL,
    [RFC]     VARCHAR (30)  NULL,
    [CUENTA]  VARCHAR (40)  NULL,
    CONSTRAINT [PK_PARAM_DATOSBANCARIOS01] PRIMARY KEY CLUSTERED ([NUM_EMP] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de empresa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSBANCARIOS01', @level2type = N'COLUMN', @level2name = N'NUM_EMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nombre del banco', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSBANCARIOS01', @level2type = N'COLUMN', @level2name = N'BANCO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'RFC del emisor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSBANCARIOS01', @level2type = N'COLUMN', @level2name = N'RFC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de Cuenta del emisor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSBANCARIOS01', @level2type = N'COLUMN', @level2name = N'CUENTA';

