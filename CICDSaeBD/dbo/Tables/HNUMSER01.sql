CREATE TABLE [dbo].[HNUMSER01] (
    [CVE_ART]   VARCHAR (16) NOT NULL,
    [NUM_SER]   VARCHAR (25) NOT NULL,
    [TIP_MOV]   INT          NULL,
    [TIP_DOC]   VARCHAR (2)  NULL,
    [CVE_DOC]   VARCHAR (20) NULL,
    [ALMACEN]   INT          NOT NULL,
    [REG_SERIE] INT          NULL,
    [FECHA]     DATETIME     NULL,
    [STATUS]    VARCHAR (1)  NULL,
    [NO_PAR]    INT          NULL
);


GO
CREATE NONCLUSTERED INDEX [IDX_HNUMSER01]
    ON [dbo].[HNUMSER01]([CVE_ART] ASC, [NUM_SER] ASC, [ALMACEN] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_HNUMSER_201]
    ON [dbo].[HNUMSER01]([TIP_MOV] ASC, [CVE_DOC] ASC, [CVE_ART] ASC, [REG_SERIE] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_HNUMSER_301]
    ON [dbo].[HNUMSER01]([CVE_DOC] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_HNUMSER_401]
    ON [dbo].[HNUMSER01]([NO_PAR] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de artículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HNUMSER01', @level2type = N'COLUMN', @level2name = N'CVE_ART';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de serie', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HNUMSER01', @level2type = N'COLUMN', @level2name = N'NUM_SER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de movimiento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HNUMSER01', @level2type = N'COLUMN', @level2name = N'TIP_MOV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de documento [M]', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HNUMSER01', @level2type = N'COLUMN', @level2name = N'TIP_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HNUMSER01', @level2type = N'COLUMN', @level2name = N'CVE_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de almacén', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HNUMSER01', @level2type = N'COLUMN', @level2name = N'ALMACEN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HNUMSER01', @level2type = N'COLUMN', @level2name = N'REG_SERIE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de movimiento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HNUMSER01', @level2type = N'COLUMN', @level2name = N'FECHA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus en el movimiento [V/D/N/F/B] .: V=Vendido, D=Disponible, N=No disponible, F=Defectuoso, B=Baja', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HNUMSER01', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de partida', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HNUMSER01', @level2type = N'COLUMN', @level2name = N'NO_PAR';

