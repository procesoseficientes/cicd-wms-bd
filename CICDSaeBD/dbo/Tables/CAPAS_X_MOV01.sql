CREATE TABLE [dbo].[CAPAS_X_MOV01] (
    [CVE_ART]     VARCHAR (16) NOT NULL,
    [NUM_MOV]     INT          NOT NULL,
    [NUM_MOV_AFT] INT          NOT NULL,
    [CANT_AFT]    FLOAT (53)   NULL,
    [COSTO_AFT]   FLOAT (53)   NULL,
    CONSTRAINT [PK_CAPAS_X_MOV01] PRIMARY KEY CLUSTERED ([CVE_ART] ASC, [NUM_MOV] ASC, [NUM_MOV_AFT] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de artículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAPAS_X_MOV01', @level2type = N'COLUMN', @level2name = N'CVE_ART';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de movimiento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAPAS_X_MOV01', @level2type = N'COLUMN', @level2name = N'NUM_MOV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de movimiento afectado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAPAS_X_MOV01', @level2type = N'COLUMN', @level2name = N'NUM_MOV_AFT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cantidad afectada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAPAS_X_MOV01', @level2type = N'COLUMN', @level2name = N'CANT_AFT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Costo afectado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAPAS_X_MOV01', @level2type = N'COLUMN', @level2name = N'COSTO_AFT';

