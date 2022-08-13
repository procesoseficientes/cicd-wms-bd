CREATE TABLE [dbo].[ENLACE_LTPD01] (
    [E_LTPD]   INT        NOT NULL,
    [REG_LTPD] INT        NULL,
    [CANTIDAD] FLOAT (53) NULL,
    [PXRS]     FLOAT (53) NULL
);


GO
CREATE NONCLUSTERED INDEX [IDX_ENLACE_LTPD0101]
    ON [dbo].[ENLACE_LTPD01]([E_LTPD] ASC, [REG_LTPD] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Enlace lote y pedimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENLACE_LTPD01', @level2type = N'COLUMN', @level2name = N'E_LTPD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Registro lote y pedimento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENLACE_LTPD01', @level2type = N'COLUMN', @level2name = N'REG_LTPD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cantidad del movimiento {mayor a 0.0}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENLACE_LTPD01', @level2type = N'COLUMN', @level2name = N'CANTIDAD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Pendiente por recibir/surtir {0.0 ..}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ENLACE_LTPD01', @level2type = N'COLUMN', @level2name = N'PXRS';

