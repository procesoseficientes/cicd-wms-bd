CREATE TABLE [dbo].[ACTIVI01] (
    [CVE_ACTIVIDAD] VARCHAR (5)  NOT NULL,
    [DESCR]         VARCHAR (30) NULL,
    [PRIORIDAD]     INT          NULL,
    [STATUS]        VARCHAR (1)  NULL,
    CONSTRAINT [PK_ACTIVI01] PRIMARY KEY CLUSTERED ([CVE_ACTIVIDAD] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de actividad', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACTIVI01', @level2type = N'COLUMN', @level2name = N'CVE_ACTIVIDAD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Actividad', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACTIVI01', @level2type = N'COLUMN', @level2name = N'DESCR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Prioridad {1..5}', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACTIVI01', @level2type = N'COLUMN', @level2name = N'PRIORIDAD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus [A/B] .: A=Activo, B=Baja', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACTIVI01', @level2type = N'COLUMN', @level2name = N'STATUS';

