CREATE TABLE [dbo].[OPROV01] (
    [CVE_OBS] INT           NOT NULL,
    [STR_OBS] VARCHAR (255) NULL,
    CONSTRAINT [PK_OPROV01] PRIMARY KEY CLUSTERED ([CVE_OBS] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de observacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPROV01', @level2type = N'COLUMN', @level2name = N'CVE_OBS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Observaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OPROV01', @level2type = N'COLUMN', @level2name = N'STR_OBS';

