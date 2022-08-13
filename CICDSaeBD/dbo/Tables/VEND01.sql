CREATE TABLE [dbo].[VEND01] (
    [CVE_VEND]     VARCHAR (5)  NOT NULL,
    [STATUS]       VARCHAR (1)  NULL,
    [NOMBRE]       VARCHAR (30) NULL,
    [COMI]         FLOAT (53)   NULL,
    [CLASIFIC]     VARCHAR (5)  NULL,
    [CORREOE]      VARCHAR (60) NULL,
    [UUID]         VARCHAR (50) NULL,
    [VERSION_SINC] DATETIME     NULL,
    CONSTRAINT [PK_VEND01] PRIMARY KEY CLUSTERED ([CVE_VEND] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de vendedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VEND01', @level2type = N'COLUMN', @level2name = N'CVE_VEND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus [A/B] .: A=Activo, B=Baja', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VEND01', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nombre', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VEND01', @level2type = N'COLUMN', @level2name = N'NOMBRE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Comisión', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VEND01', @level2type = N'COLUMN', @level2name = N'COMI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clasificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VEND01', @level2type = N'COLUMN', @level2name = N'CLASIFIC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Correo electrónico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VEND01', @level2type = N'COLUMN', @level2name = N'CORREOE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'ID para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VEND01', @level2type = N'COLUMN', @level2name = N'UUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha y hora para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VEND01', @level2type = N'COLUMN', @level2name = N'VERSION_SINC';

