CREATE TABLE [dbo].[FOLCXC01] (
    [CVE_FOLIO]  VARCHAR (9)  NOT NULL,
    [IMPUESTO1]  FLOAT (53)   NULL,
    [IMPUESTO2]  FLOAT (53)   NULL,
    [IMPUESTO3]  FLOAT (53)   NULL,
    [IMPUESTO4]  FLOAT (53)   NULL,
    [REFERENCIA] VARCHAR (20) NULL,
    [STATUS]     VARCHAR (1)  NULL,
    [FECHA]      DATETIME     NULL,
    [FECHAELAB]  DATETIME     NULL,
    [USUARIO]    SMALLINT     NULL,
    CONSTRAINT [PK_FOLCXC01] PRIMARY KEY CLUSTERED ([CVE_FOLIO] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave del Folio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLCXC01', @level2type = N'COLUMN', @level2name = N'CVE_FOLIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuesto 1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLCXC01', @level2type = N'COLUMN', @level2name = N'IMPUESTO1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuesto 2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLCXC01', @level2type = N'COLUMN', @level2name = N'IMPUESTO2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuesto 3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLCXC01', @level2type = N'COLUMN', @level2name = N'IMPUESTO3';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuesto 4', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLCXC01', @level2type = N'COLUMN', @level2name = N'IMPUESTO4';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Referencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLCXC01', @level2type = N'COLUMN', @level2name = N'REFERENCIA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus [A/B] .: A=Activo, B=Baja', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLCXC01', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLCXC01', @level2type = N'COLUMN', @level2name = N'FECHA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de elaboración', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLCXC01', @level2type = N'COLUMN', @level2name = N'FECHAELAB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Usuario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FOLCXC01', @level2type = N'COLUMN', @level2name = N'USUARIO';

