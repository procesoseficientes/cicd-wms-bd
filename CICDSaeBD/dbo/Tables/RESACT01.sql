CREATE TABLE [dbo].[RESACT01] (
    [CVE_CAMPANIA]  VARCHAR (5) NOT NULL,
    [CVE_ACTIVIDAD] VARCHAR (5) NOT NULL,
    [CVE_RESULTADO] VARCHAR (5) NOT NULL,
    [ORDEN]         INT         NULL,
    [CVE_ACTSIG]    VARCHAR (5) NULL,
    [DURACION]      INT         NULL,
    [FINALIZA]      VARCHAR (1) NULL,
    [GENERA_BITA]   VARCHAR (1) NULL,
    CONSTRAINT [PK_RESACT01] PRIMARY KEY CLUSTERED ([CVE_CAMPANIA] ASC, [CVE_ACTIVIDAD] ASC, [CVE_RESULTADO] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de la campaña', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RESACT01', @level2type = N'COLUMN', @level2name = N'CVE_CAMPANIA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de la actividad', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RESACT01', @level2type = N'COLUMN', @level2name = N'CVE_ACTIVIDAD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave del resultado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RESACT01', @level2type = N'COLUMN', @level2name = N'CVE_RESULTADO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Orden {0..5}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RESACT01', @level2type = N'COLUMN', @level2name = N'ORDEN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de la actividad siguiente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RESACT01', @level2type = N'COLUMN', @level2name = N'CVE_ACTSIG';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tiempo a permanecer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RESACT01', @level2type = N'COLUMN', @level2name = N'DURACION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Es actividad terminal [S/N] .: S=Si, N=No ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RESACT01', @level2type = N'COLUMN', @level2name = N'FINALIZA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Genera bitácora [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RESACT01', @level2type = N'COLUMN', @level2name = N'GENERA_BITA';

