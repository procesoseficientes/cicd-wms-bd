CREATE TABLE [dbo].[COMPACTACION01] (
    [ULT_COMPACTACION] DATETIME NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Última compactación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPACTACION01', @level2type = N'COLUMN', @level2name = N'ULT_COMPACTACION';

