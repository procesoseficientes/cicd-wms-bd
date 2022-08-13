CREATE TABLE [dbo].[CTRLBLOQUEO01] (
    [USUARIOS]  INT         NOT NULL,
    [BLOQUEADA] VARCHAR (1) NOT NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de usuarios concectados', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CTRLBLOQUEO01', @level2type = N'COLUMN', @level2name = N'USUARIOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Base de datos bloqueada [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CTRLBLOQUEO01', @level2type = N'COLUMN', @level2name = N'BLOQUEADA';

