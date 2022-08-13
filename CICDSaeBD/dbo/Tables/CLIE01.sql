CREATE TABLE [dbo].[CLIE01] (
    [CLAVE]               VARCHAR (10)  NOT NULL,
    [STATUS]              VARCHAR (1)   NOT NULL,
    [NOMBRE]              VARCHAR (120) NULL,
    [RFC]                 VARCHAR (15)  NULL,
    [CALLE]               VARCHAR (80)  NULL,
    [NUMINT]              VARCHAR (15)  NULL,
    [NUMEXT]              VARCHAR (15)  NULL,
    [CRUZAMIENTOS]        VARCHAR (40)  NULL,
    [CRUZAMIENTOS2]       VARCHAR (40)  NULL,
    [COLONIA]             VARCHAR (50)  NULL,
    [CODIGO]              VARCHAR (5)   NULL,
    [LOCALIDAD]           VARCHAR (50)  NULL,
    [MUNICIPIO]           VARCHAR (50)  NULL,
    [ESTADO]              VARCHAR (50)  NULL,
    [PAIS]                VARCHAR (50)  NULL,
    [NACIONALIDAD]        VARCHAR (40)  NULL,
    [REFERDIR]            VARCHAR (255) NULL,
    [TELEFONO]            VARCHAR (25)  NULL,
    [CLASIFIC]            VARCHAR (5)   NULL,
    [FAX]                 VARCHAR (25)  NULL,
    [PAG_WEB]             VARCHAR (60)  NULL,
    [CURP]                VARCHAR (18)  NULL,
    [CVE_ZONA]            VARCHAR (6)   NULL,
    [IMPRIR]              VARCHAR (1)   NULL,
    [MAIL]                VARCHAR (1)   NULL,
    [NIVELSEC]            INT           NULL,
    [ENVIOSILEN]          VARCHAR (1)   NULL,
    [EMAILPRED]           VARCHAR (60)  NULL,
    [DIAREV]              VARCHAR (2)   NULL,
    [DIAPAGO]             VARCHAR (2)   NULL,
    [CON_CREDITO]         VARCHAR (1)   NULL,
    [DIASCRED]            INT           NULL,
    [LIMCRED]             FLOAT (53)    NULL,
    [SALDO]               FLOAT (53)    NULL,
    [LISTA_PREC]          INT           NULL,
    [CVE_BITA]            INT           NULL,
    [ULT_PAGOD]           VARCHAR (20)  NULL,
    [ULT_PAGOM]           FLOAT (53)    NULL,
    [ULT_PAGOF]           DATETIME      NULL,
    [DESCUENTO]           FLOAT (53)    NULL,
    [ULT_VENTAD]          VARCHAR (20)  NULL,
    [ULT_COMPM]           FLOAT (53)    NULL,
    [FCH_ULTCOM]          DATETIME      NULL,
    [VENTAS]              FLOAT (53)    NULL,
    [CVE_VEND]            VARCHAR (5)   NULL,
    [CVE_OBS]             INT           NULL,
    [TIPO_EMPRESA]        VARCHAR (1)   NULL,
    [MATRIZ]              VARCHAR (10)  NULL,
    [PROSPECTO]           VARCHAR (1)   NULL,
    [CALLE_ENVIO]         VARCHAR (80)  NULL,
    [NUMINT_ENVIO]        VARCHAR (15)  NULL,
    [NUMEXT_ENVIO]        VARCHAR (15)  NULL,
    [CRUZAMIENTOS_ENVIO]  VARCHAR (40)  NULL,
    [CRUZAMIENTOS_ENVIO2] VARCHAR (40)  NULL,
    [COLONIA_ENVIO]       VARCHAR (50)  NULL,
    [LOCALIDAD_ENVIO]     VARCHAR (50)  NULL,
    [MUNICIPIO_ENVIO]     VARCHAR (50)  NULL,
    [ESTADO_ENVIO]        VARCHAR (50)  NULL,
    [PAIS_ENVIO]          VARCHAR (50)  NULL,
    [CODIGO_ENVIO]        VARCHAR (5)   NULL,
    [CVE_ZONA_ENVIO]      VARCHAR (6)   NULL,
    [REFERENCIA_ENVIO]    VARCHAR (255) NULL,
    [CUENTA_CONTABLE]     VARCHAR (28)  NULL,
    [ADDENDAF]            VARCHAR (255) NULL,
    [ADDENDAD]            VARCHAR (255) NULL,
    [NAMESPACE]           VARCHAR (255) NULL,
    [METODODEPAGO]        VARCHAR (255) NULL,
    [NUMCTAPAGO]          VARCHAR (255) NULL,
    [MODELO]              VARCHAR (255) NULL,
    [DES_IMPU1]           VARCHAR (1)   DEFAULT ('N') NULL,
    [DES_IMPU2]           VARCHAR (1)   DEFAULT ('N') NULL,
    [DES_IMPU3]           VARCHAR (1)   DEFAULT ('N') NULL,
    [DES_IMPU4]           VARCHAR (1)   DEFAULT ('N') NULL,
    [DES_PER]             VARCHAR (1)   DEFAULT ('N') NULL,
    [LAT_GENERAL]         FLOAT (53)    NULL,
    [LON_GENERAL]         FLOAT (53)    NULL,
    [LAT_ENVIO]           FLOAT (53)    NULL,
    [LON_ENVIO]           FLOAT (53)    NULL,
    [UUID]                VARCHAR (50)  NULL,
    [VERSION_SINC]        DATETIME      NULL,
    [USO_CFDI]            VARCHAR (5)   NULL,
    [CVE_PAIS_SAT]        VARCHAR (5)   NULL,
    [NUMIDREGFISCAL]      VARCHAR (128) NULL,
    [FORMADEPAGOSAT]      VARCHAR (5)   NULL,
    [ADDENDAG]            VARCHAR (255) NULL,
    [ADDENDAE]            VARCHAR (255) NULL,
    CONSTRAINT [PK_CLIE01] PRIMARY KEY CLUSTERED ([CLAVE] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX1_CLIE01]
    ON [dbo].[CLIE01]([LISTA_PREC] ASC, [CVE_VEND] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'CLAVE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus [A/B/M/S] .: A=Activo, B=Baja, M=Moroso, S=Suspendido', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nombre', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'NOMBRE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'R.F.C.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'RFC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Calle', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'CALLE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número interior', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'NUMINT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número exterior', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'NUMEXT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Entre calle 1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'CRUZAMIENTOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Entre calle 2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'CRUZAMIENTOS2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Colonia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'COLONIA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Código postal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'CODIGO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Localidad', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'LOCALIDAD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Municipio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'MUNICIPIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'ESTADO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'País', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'PAIS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nacionalidad', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'NACIONALIDAD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Referencia de la dirección', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'REFERDIR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Teléfono', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'TELEFONO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clasificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'CLASIFIC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fax', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'FAX';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Página web', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'PAG_WEB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'C.U.R.P.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'CURP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de zona', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'CVE_ZONA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Imprimir [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'IMPRIR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Enviar por mail [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'MAIL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nivel de seguridad del mail [0..2] ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'NIVELSEC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Envío silencioso [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'ENVIOSILEN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Mail predeterminado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'EMAILPRED';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Día de revisión', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'DIAREV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Día de pago', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'DIAPAGO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Con crédito [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'CON_CREDITO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Días de crédito [0..730]', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'DIASCRED';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Límite de crédito', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'LIMCRED';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Saldo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'SALDO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de lista de precios', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'LISTA_PREC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de bitácora', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'CVE_BITA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Documento del último pago', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'ULT_PAGOD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Monto del último pago', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'ULT_PAGOM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha del último pago', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'ULT_PAGOF';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Descuento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'DESCUENTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Documento de última venta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'ULT_VENTAD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Monto de última venta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'ULT_COMPM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de última venta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'FCH_ULTCOM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Ventas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'VENTAS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de vendedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'CVE_VEND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de las observaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'CVE_OBS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de empresa [M/S] .: M=Matriz, S=Sucursal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'TIPO_EMPRESA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave del cliente Matriz', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'MATRIZ';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Prospecto [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'PROSPECTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Calle de envío', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'CALLE_ENVIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Núm. int de envío', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'NUMINT_ENVIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Núm. ext de envío', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'NUMEXT_ENVIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Entre calle envío 1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'CRUZAMIENTOS_ENVIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Entre calle envío 2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'CRUZAMIENTOS_ENVIO2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Colonia de envío', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'COLONIA_ENVIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Localidad de envío', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'LOCALIDAD_ENVIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Municipio de envío', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'MUNICIPIO_ENVIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estado de envío', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'ESTADO_ENVIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'País de envío', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'PAIS_ENVIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Código postal de envío', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'CODIGO_ENVIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de zona de envío', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'CVE_ZONA_ENVIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Referencia de envío', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'REFERENCIA_ENVIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cuenta contable', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'CUENTA_CONTABLE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Addenda de factura', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'ADDENDAF';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Addenda de devolución', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'ADDENDAD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Namespace del cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'NAMESPACE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Método de pago cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'METODODEPAGO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de cuenta cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'NUMCTAPAGO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Documento modelo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'MODELO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Desglosar impuesto 1 [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'DES_IMPU1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Desglosar impuesto 2 [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'DES_IMPU2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Desglosar impuesto 3 [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'DES_IMPU3';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Desglosar impuesto 4 [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'DES_IMPU4';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Desglose de impuestos personalizado [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'DES_PER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Latitud para la direccion general del cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'LAT_GENERAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Longitud para la direccion general del cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'LON_GENERAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Latitud para la direccion de datos de envio del cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'LAT_ENVIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Longitud para la direccion de datos de envio del cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'LON_ENVIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'ID para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'UUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha y hora para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CLIE01', @level2type = N'COLUMN', @level2name = N'VERSION_SINC';

