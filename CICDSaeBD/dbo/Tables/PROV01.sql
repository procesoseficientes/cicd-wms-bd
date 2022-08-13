CREATE TABLE [dbo].[PROV01] (
    [CLAVE]           VARCHAR (10)  NOT NULL,
    [STATUS]          VARCHAR (1)   NULL,
    [NOMBRE]          VARCHAR (120) NULL,
    [RFC]             VARCHAR (15)  NULL,
    [CALLE]           VARCHAR (80)  NULL,
    [NUMINT]          VARCHAR (15)  NULL,
    [NUMEXT]          VARCHAR (15)  NULL,
    [CRUZAMIENTOS]    VARCHAR (40)  NULL,
    [CRUZAMIENTOS2]   VARCHAR (40)  NULL,
    [COLONIA]         VARCHAR (50)  NULL,
    [CODIGO]          VARCHAR (5)   NULL,
    [LOCALIDAD]       VARCHAR (50)  NULL,
    [MUNICIPIO]       VARCHAR (50)  NULL,
    [ESTADO]          VARCHAR (50)  NULL,
    [CVE_PAIS]        VARCHAR (2)   NULL,
    [NACIONALIDAD]    VARCHAR (40)  NULL,
    [TELEFONO]        VARCHAR (25)  NULL,
    [CLASIFIC]        VARCHAR (5)   NULL,
    [FAX]             VARCHAR (25)  NULL,
    [PAG_WEB]         VARCHAR (60)  NULL,
    [CURP]            VARCHAR (18)  NULL,
    [CVE_ZONA]        VARCHAR (6)   NULL,
    [CON_CREDITO]     VARCHAR (1)   NULL,
    [DIASCRED]        INT           NULL,
    [LIMCRED]         FLOAT (53)    NULL,
    [CVE_BITA]        INT           NULL,
    [ULT_PAGOD]       VARCHAR (20)  NULL,
    [ULT_PAGOM]       FLOAT (53)    NULL,
    [ULT_PAGOF]       DATETIME      NULL,
    [ULT_COMPD]       VARCHAR (20)  NULL,
    [ULT_COMPM]       FLOAT (53)    NULL,
    [ULT_COMPF]       DATETIME      NULL,
    [SALDO]           FLOAT (53)    NULL,
    [VENTAS]          FLOAT (53)    NULL,
    [DESCUENTO]       FLOAT (53)    NULL,
    [TIP_TERCERO]     INT           NULL,
    [TIP_OPERA]       INT           NULL,
    [CVE_OBS]         INT           NULL,
    [CUENTA_CONTABLE] VARCHAR (28)  NULL,
    [FORMA_PAGO]      INT           NULL,
    [BENEFICIARIO]    VARCHAR (60)  NULL,
    [TITULAR_CUENTA]  VARCHAR (60)  NULL,
    [BANCO]           VARCHAR (3)   NULL,
    [SUCURSAL_BANCO]  VARCHAR (4)   NULL,
    [CUENTA_BANCO]    VARCHAR (16)  NULL,
    [CLABE]           VARCHAR (18)  NULL,
    [DESC_OTROS]      VARCHAR (60)  NULL,
    [IMPRIR]          VARCHAR (1)   NULL,
    [MAIL]            VARCHAR (1)   NULL,
    [NIVELSEC]        INT           NULL,
    [ENVIOSILEN]      VARCHAR (1)   NULL,
    [EMAILPRED]       VARCHAR (60)  NULL,
    [MODELO]          VARCHAR (255) NULL,
    [LAT]             FLOAT (53)    NULL,
    [LON]             FLOAT (53)    NULL,
    CONSTRAINT [PK_PROV01] PRIMARY KEY CLUSTERED ([CLAVE] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de proveedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'CLAVE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus [A/B/S] .: A=Activo, B=Baja, S=Suspendido', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nombre', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'NOMBRE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'RFC', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'RFC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Calle', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'CALLE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número interior', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'NUMINT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número exterior', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'NUMEXT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Entre calle 1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'CRUZAMIENTOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Entre calle 2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'CRUZAMIENTOS2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Colonia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'COLONIA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Código', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'CODIGO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Localidad', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'LOCALIDAD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Municipio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'MUNICIPIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'ESTADO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de país', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'CVE_PAIS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nacionalidad', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'NACIONALIDAD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Teléfono', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'TELEFONO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clasificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'CLASIFIC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fax', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'FAX';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Página web', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'PAG_WEB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'CURP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'CURP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de zona', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'CVE_ZONA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Con crédito', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'CON_CREDITO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Días de crédito', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'DIASCRED';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Límite de crédito', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'LIMCRED';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de bitácora', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'CVE_BITA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Documento del último pago', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'ULT_PAGOD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Monto último pago', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'ULT_PAGOM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de último pago', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'ULT_PAGOF';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Documento de la última compra', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'ULT_COMPD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Monto última compra', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'ULT_COMPM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de última compra', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'ULT_COMPF';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Saldo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'SALDO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Ventas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'VENTAS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Descuento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'DESCUENTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo tercero', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'TIP_TERCERO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo operación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'TIP_OPERA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de observaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'CVE_OBS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cuenta contable', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'CUENTA_CONTABLE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Condición de pago', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'FORMA_PAGO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Beneficiario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'BENEFICIARIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Titular', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'TITULAR_CUENTA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Banco', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'BANCO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Sucursal (Banco)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'SUCURSAL_BANCO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Num. de cuenta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'CUENTA_BANCO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clabe', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'CLABE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Descripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'DESC_OTROS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Imprimir [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'IMPRIR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Enviar por mail [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'MAIL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nivel de seguridad del mail [0..2] ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'NIVELSEC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Envío silencioso [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'ENVIOSILEN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Mail predeterminado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'EMAILPRED';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Documento modelo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'MODELO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Latitud para la direccion del proveedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'LAT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Longitud para la direccion del proveedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV01', @level2type = N'COLUMN', @level2name = N'LON';

