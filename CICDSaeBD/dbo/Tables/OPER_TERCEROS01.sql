CREATE TABLE [dbo].[OPER_TERCEROS01] (
    [TIPO]  INT          NOT NULL,
    [DESCR] VARCHAR (60) NULL,
    CONSTRAINT [PK_OPER_TERCEROS01] PRIMARY KEY CLUSTERED ([TIPO] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de operación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPER_TERCEROS01', @level2type = N'COLUMN', @level2name = N'TIPO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Descripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPER_TERCEROS01', @level2type = N'COLUMN', @level2name = N'DESCR';

