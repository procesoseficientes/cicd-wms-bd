CREATE TABLE [dbo].[NUMSER01] (
    [CVE_ART]   VARCHAR (16) NOT NULL,
    [NUM_SER]   VARCHAR (25) NOT NULL,
    [STATUS]    VARCHAR (1)  NULL,
    [ALMACEN]   INT          NOT NULL,
    [COSTO]     FLOAT (53)   NULL,
    [DOCTO_ENT] VARCHAR (20) NULL,
    [FECHA_ENT] DATETIME     NULL,
    CONSTRAINT [PK_NUMSER01] PRIMARY KEY CLUSTERED ([CVE_ART] ASC, [NUM_SER] ASC, [ALMACEN] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_SERIE101]
    ON [dbo].[NUMSER01]([ALMACEN] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_SERIE201]
    ON [dbo].[NUMSER01]([NUM_SER] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave del artículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NUMSER01', @level2type = N'COLUMN', @level2name = N'CVE_ART';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de serie', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NUMSER01', @level2type = N'COLUMN', @level2name = N'NUM_SER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus [V/D/N/F/B] .: V= Vendido, D=Disponible, N= No disponible, F= Defectuoso, B=Baja', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NUMSER01', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de almacén', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NUMSER01', @level2type = N'COLUMN', @level2name = N'ALMACEN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Costo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NUMSER01', @level2type = N'COLUMN', @level2name = N'COSTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Documento de entrada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NUMSER01', @level2type = N'COLUMN', @level2name = N'DOCTO_ENT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de entrada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'NUMSER01', @level2type = N'COLUMN', @level2name = N'FECHA_ENT';

