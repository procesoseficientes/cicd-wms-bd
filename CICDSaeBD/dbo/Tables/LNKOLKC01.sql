CREATE TABLE [dbo].[LNKOLKC01] (
    [NCONTACTO]         INT          NOT NULL,
    [USUARIOSAE]        SMALLINT     NULL,
    [ID_OUTLOOK]        VARCHAR (48) NULL,
    [NOMBRE_USUARIOSAE] VARCHAR (15) NULL,
    CONSTRAINT [PK_LNKOLKC01] PRIMARY KEY CLUSTERED ([NCONTACTO] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de contacto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LNKOLKC01', @level2type = N'COLUMN', @level2name = N'NCONTACTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Usuario SAE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LNKOLKC01', @level2type = N'COLUMN', @level2name = N'USUARIOSAE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Identificador en outlook', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LNKOLKC01', @level2type = N'COLUMN', @level2name = N'ID_OUTLOOK';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nombre del usuario SAE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LNKOLKC01', @level2type = N'COLUMN', @level2name = N'NOMBRE_USUARIOSAE';

