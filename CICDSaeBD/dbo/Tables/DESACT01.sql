CREATE TABLE [dbo].[DESACT01] (
    [CVE_CAMPANIA]  VARCHAR (5)   NOT NULL,
    [CVE_ACTIVIDAD] VARCHAR (5)   NOT NULL,
    [DESCR]         VARCHAR (255) NULL,
    CONSTRAINT [PK_DESACT01] PRIMARY KEY CLUSTERED ([CVE_CAMPANIA] ASC, [CVE_ACTIVIDAD] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de campaña', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DESACT01', @level2type = N'COLUMN', @level2name = N'CVE_CAMPANIA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de actividad', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DESACT01', @level2type = N'COLUMN', @level2name = N'CVE_ACTIVIDAD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Descripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DESACT01', @level2type = N'COLUMN', @level2name = N'DESCR';

