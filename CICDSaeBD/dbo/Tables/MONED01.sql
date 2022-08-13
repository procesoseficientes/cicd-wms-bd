CREATE TABLE [dbo].[MONED01] (
    [NUM_MONED]    INT          NOT NULL,
    [DESCR]        VARCHAR (20) NULL,
    [SIMBOLO]      VARCHAR (4)  NULL,
    [TCAMBIO]      FLOAT (53)   NULL,
    [FULTCAMB]     DATETIME     NULL,
    [STATUS]       VARCHAR (1)  NULL,
    [UUID]         VARCHAR (50) NULL,
    [VERSION_SINC] DATETIME     NULL,
    [CVE_MONED]    VARCHAR (4)  NULL,
    CONSTRAINT [PK_MONED01] PRIMARY KEY CLUSTERED ([NUM_MONED] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de moneda', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MONED01', @level2type = N'COLUMN', @level2name = N'NUM_MONED';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Descripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MONED01', @level2type = N'COLUMN', @level2name = N'DESCR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Símbolo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MONED01', @level2type = N'COLUMN', @level2name = N'SIMBOLO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de cambio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MONED01', @level2type = N'COLUMN', @level2name = N'TCAMBIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de último tipo cambio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MONED01', @level2type = N'COLUMN', @level2name = N'FULTCAMB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus [A/B] .: A=Activo, B=Baja', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MONED01', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'ID para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MONED01', @level2type = N'COLUMN', @level2name = N'UUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha y hora para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MONED01', @level2type = N'COLUMN', @level2name = N'VERSION_SINC';

