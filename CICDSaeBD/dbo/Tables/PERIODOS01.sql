CREATE TABLE [dbo].[PERIODOS01] (
    [CVE_PER]     INT          NOT NULL,
    [TIPO]        VARCHAR (1)  NULL,
    [FECHAINI]    DATETIME     NULL,
    [FECHAFIN]    DATETIME     NULL,
    [DESCRIPCION] VARCHAR (50) NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_CVE_PER01]
    ON [dbo].[PERIODOS01]([CVE_PER] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_PER_FECHA01]
    ON [dbo].[PERIODOS01]([TIPO] ASC, [FECHAINI] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave secuencial del período', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PERIODOS01', @level2type = N'COLUMN', @level2name = N'CVE_PER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de período [S/Q/M/B/T/D/A] .: S=Semanal, Q=Quincenal, M=Mensual, B=Bimestral,T=Trimestral, D=Semestral, A=Anual', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PERIODOS01', @level2type = N'COLUMN', @level2name = N'TIPO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha inicial', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PERIODOS01', @level2type = N'COLUMN', @level2name = N'FECHAINI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha final', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PERIODOS01', @level2type = N'COLUMN', @level2name = N'FECHAFIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Período', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PERIODOS01', @level2type = N'COLUMN', @level2name = N'DESCRIPCION';

