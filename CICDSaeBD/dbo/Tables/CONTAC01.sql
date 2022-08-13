CREATE TABLE [dbo].[CONTAC01] (
    [CVE_CLIE]     VARCHAR (10)  NOT NULL,
    [NCONTACTO]    INT           NOT NULL,
    [NOMBRE]       VARCHAR (60)  NULL,
    [DIRECCION]    VARCHAR (100) NULL,
    [TELEFONO]     VARCHAR (75)  NULL,
    [EMAIL]        VARCHAR (60)  NULL,
    [TIPOCONTAC]   VARCHAR (1)   NULL,
    [STATUS]       VARCHAR (1)   NULL,
    [USUARIO]      VARCHAR (15)  NULL,
    [LAT]          FLOAT (53)    NULL,
    [LON]          FLOAT (53)    NULL,
    [UUID]         VARCHAR (50)  NULL,
    [VERSION_SINC] DATETIME      NULL,
    CONSTRAINT [PK_CONTAC01] PRIMARY KEY CLUSTERED ([NCONTACTO] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_CONTACTOC01]
    ON [dbo].[CONTAC01]([CVE_CLIE] ASC, [NCONTACTO] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave del cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONTAC01', @level2type = N'COLUMN', @level2name = N'CVE_CLIE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave del contacto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONTAC01', @level2type = N'COLUMN', @level2name = N'NCONTACTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nombre', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONTAC01', @level2type = N'COLUMN', @level2name = N'NOMBRE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Dirección', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONTAC01', @level2type = N'COLUMN', @level2name = N'DIRECCION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Teléfono', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONTAC01', @level2type = N'COLUMN', @level2name = N'TELEFONO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Correo electrónico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONTAC01', @level2type = N'COLUMN', @level2name = N'EMAIL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de contacto [V/C/P/L/O/A/T] .: V=Ventas, C=Cobranza, P=Pagos, L=Almacen, O=Compras, A=Administración, T=Otros', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONTAC01', @level2type = N'COLUMN', @level2name = N'TIPOCONTAC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus [A/B] .: A=Activo, B=Baja', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONTAC01', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de usuario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONTAC01', @level2type = N'COLUMN', @level2name = N'USUARIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Latitud para la direccion del contacto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONTAC01', @level2type = N'COLUMN', @level2name = N'LAT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Longitud para la direccion del contacto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONTAC01', @level2type = N'COLUMN', @level2name = N'LON';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'ID para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONTAC01', @level2type = N'COLUMN', @level2name = N'UUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha y hora para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONTAC01', @level2type = N'COLUMN', @level2name = N'VERSION_SINC';

