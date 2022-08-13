CREATE TABLE [dbo].[ALERTA01] (
    [CVE_ALERTA] INT           NOT NULL,
    [MENSAJE]    VARCHAR (150) NULL,
    [CANT_DOC]   INT           NOT NULL,
    CONSTRAINT [PK_ALERTA01] PRIMARY KEY CLUSTERED ([CVE_ALERTA] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Alertas del sistema', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ALERTA01', @level2type = N'COLUMN', @level2name = N'CVE_ALERTA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Mensaje de alerta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ALERTA01', @level2type = N'COLUMN', @level2name = N'MENSAJE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cantidad de documentos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ALERTA01', @level2type = N'COLUMN', @level2name = N'CANT_DOC';

