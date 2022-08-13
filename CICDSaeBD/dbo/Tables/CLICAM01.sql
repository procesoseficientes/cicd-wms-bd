CREATE TABLE [dbo].[CLICAM01] (
    [CVE_CAMPANIA]     VARCHAR (5)  NOT NULL,
    [CVE_CLIE]         VARCHAR (10) NOT NULL,
    [CVE_ACTIVIDAD]    VARCHAR (5)  NULL,
    [CVE_RESULTADO]    VARCHAR (5)  NULL,
    [FECHA]            DATETIME     NULL,
    [PRIORIDAD]        INT          NULL,
    [STATUS]           VARCHAR (1)  NULL,
    [COMENTARIOS]      VARCHAR (40) NULL,
    [STATUS_ACTIVIDAD] INT          NULL,
    CONSTRAINT [PK_CLICAM01] PRIMARY KEY CLUSTERED ([CVE_CAMPANIA] ASC, [CVE_CLIE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de la campaña', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLICAM01', @level2type = N'COLUMN', @level2name = N'CVE_CAMPANIA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave del cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLICAM01', @level2type = N'COLUMN', @level2name = N'CVE_CLIE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de la actividad', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLICAM01', @level2type = N'COLUMN', @level2name = N'CVE_ACTIVIDAD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave del resultado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLICAM01', @level2type = N'COLUMN', @level2name = N'CVE_RESULTADO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLICAM01', @level2type = N'COLUMN', @level2name = N'FECHA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Prioridad', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLICAM01', @level2type = N'COLUMN', @level2name = N'PRIORIDAD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus [A/B/M/S] .: A=Activo, B=Baja, M=Moroso, S=Suspendido', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLICAM01', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Comentarios', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLICAM01', @level2type = N'COLUMN', @level2name = N'COMENTARIOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus de actividad [A/B] .: A=Activo, B=Baja', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLICAM01', @level2type = N'COLUMN', @level2name = N'STATUS_ACTIVIDAD';

