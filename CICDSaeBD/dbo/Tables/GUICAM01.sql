CREATE TABLE [dbo].[GUICAM01] (
    [CVE_CAMPANIA] VARCHAR (5) NOT NULL,
    [GUIA]         TEXT        NULL,
    CONSTRAINT [PK_GUICAM01] PRIMARY KEY CLUSTERED ([CVE_CAMPANIA] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de la campaña', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GUICAM01', @level2type = N'COLUMN', @level2name = N'CVE_CAMPANIA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GUICAM01', @level2type = N'COLUMN', @level2name = N'GUIA';

