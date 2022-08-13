CREATE TABLE [dbo].[OPER_X_TIPO_TERCERO01] (
    [TIP_TERCERO] INT NOT NULL,
    [OPERACION]   INT NOT NULL,
    CONSTRAINT [PK_OPER_X_TIPO_TERCERO01] PRIMARY KEY CLUSTERED ([TIP_TERCERO] ASC, [OPERACION] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de tercero', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPER_X_TIPO_TERCERO01', @level2type = N'COLUMN', @level2name = N'TIP_TERCERO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Operación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPER_X_TIPO_TERCERO01', @level2type = N'COLUMN', @level2name = N'OPERACION';

