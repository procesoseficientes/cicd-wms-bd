CREATE TABLE [dbo].[ALMACENES01] (
    [CVE_ALM]      INT          NOT NULL,
    [DESCR]        VARCHAR (40) NULL,
    [DIRECCION]    VARCHAR (60) NULL,
    [ENCARGADO]    VARCHAR (60) NULL,
    [TELEFONO]     VARCHAR (16) NULL,
    [LISTA_PREC]   INT          NULL,
    [CUEN_CONT]    VARCHAR (28) NULL,
    [CVE_MENT]     INT          NULL,
    [CVE_MSAL]     INT          NULL,
    [STATUS]       VARCHAR (1)  NULL,
    [LAT]          FLOAT (53)   NULL,
    [LON]          FLOAT (53)   NULL,
    [UUID]         VARCHAR (50) NULL,
    [VERSION_SINC] DATETIME     NULL,
    CONSTRAINT [PK_ALMACENES01] PRIMARY KEY CLUSTERED ([CVE_ALM] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de almacén', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ALMACENES01', @level2type = N'COLUMN', @level2name = N'CVE_ALM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Descripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ALMACENES01', @level2type = N'COLUMN', @level2name = N'DESCR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Dirección', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ALMACENES01', @level2type = N'COLUMN', @level2name = N'DIRECCION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Encargado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ALMACENES01', @level2type = N'COLUMN', @level2name = N'ENCARGADO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Teléfono', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ALMACENES01', @level2type = N'COLUMN', @level2name = N'TELEFONO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de lista de precios', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ALMACENES01', @level2type = N'COLUMN', @level2name = N'LISTA_PREC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cuenta contable', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ALMACENES01', @level2type = N'COLUMN', @level2name = N'CUEN_CONT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Movimiento de entrada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ALMACENES01', @level2type = N'COLUMN', @level2name = N'CVE_MENT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Movimiento de salida', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ALMACENES01', @level2type = N'COLUMN', @level2name = N'CVE_MSAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus [A/B] .: A=Activo, B=Baja', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ALMACENES01', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Latitud para la direccion del almacen', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ALMACENES01', @level2type = N'COLUMN', @level2name = N'LAT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Longitud para la direccion del almacen', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ALMACENES01', @level2type = N'COLUMN', @level2name = N'LON';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'ID para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ALMACENES01', @level2type = N'COLUMN', @level2name = N'UUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha y hora para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ALMACENES01', @level2type = N'COLUMN', @level2name = N'VERSION_SINC';

