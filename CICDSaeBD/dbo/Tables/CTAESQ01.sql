CREATE TABLE [dbo].[CTAESQ01] (
    [NUM_IMPU]   INT          NOT NULL,
    [PORCENTAJE] FLOAT (53)   NOT NULL,
    [CUEN_VENT]  VARCHAR (28) NULL,
    [CUEN_COMP]  VARCHAR (28) NULL,
    CONSTRAINT [PK_CTAESQ01] PRIMARY KEY CLUSTERED ([NUM_IMPU] ASC, [PORCENTAJE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de impuesto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CTAESQ01', @level2type = N'COLUMN', @level2name = N'NUM_IMPU';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Porcentaje', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CTAESQ01', @level2type = N'COLUMN', @level2name = N'PORCENTAJE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cuenta contable ventas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CTAESQ01', @level2type = N'COLUMN', @level2name = N'CUEN_VENT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cuenta contable compras', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CTAESQ01', @level2type = N'COLUMN', @level2name = N'CUEN_COMP';

