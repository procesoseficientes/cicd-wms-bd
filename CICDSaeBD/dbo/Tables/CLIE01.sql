CREATE TABLE [dbo].[CLIE01] (
    [CLAVE]               VARCHAR (10)  NOT NULL,
    [STATUS]              VARCHAR (1)   NOT NULL,
    [NOMBRE]              VARCHAR (254) NULL,
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
    [ADDENDAT]            VARCHAR (255) NULL,
    [UBICACION_R]         TEXT          NULL,
    [REG_FISC]            VARCHAR (4)   NULL,
    [VAL_RFC]             INT           NULL,
    [NOMBRECOMERCIAL]     VARCHAR (254) NULL,
    CONSTRAINT [PK_CLIE01] PRIMARY KEY CLUSTERED ([CLAVE] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IDX1_CLIE01]
    ON [dbo].[CLIE01]([LISTA_PREC] ASC, [CVE_VEND] ASC);


GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO


