CREATE TABLE [dbo].[PARAM_DATOSGRALES01] (
    [NUM_EMP]                INT           NOT NULL,
    [REDON_MONTOS]           VARCHAR (1)   NULL,
    [REDON_COSTOS]           VARCHAR (1)   NULL,
    [CHARCOMPDOS]            VARCHAR (1)   NULL,
    [POL_DESC]               VARCHAR (1)   NULL,
    [CXCCLIEMOSTR]           VARCHAR (1)   NULL,
    [MULTIMONEDA]            VARCHAR (1)   NULL,
    [VALENLINEA]             VARCHAR (1)   NULL,
    [SOLICITATIPOCAMBIO]     VARCHAR (1)   NULL,
    [MOSTRARIMAGCONSULTA]    VARCHAR (1)   NULL,
    [ESQIMPUESTO]            INT           NULL,
    [DESCCOMERCIAL]          FLOAT (53)    NULL,
    [CAJONINSTALADO]         VARCHAR (1)   NULL,
    [PUERTOCAJON]            VARCHAR (20)  NULL,
    [SECAPERTURA]            VARCHAR (20)  NULL,
    [SECINICIO]              VARCHAR (20)  NULL,
    [SECCONFIRMA]            VARCHAR (20)  NULL,
    [MONEDAPRED]             INT           NULL,
    [IMPGLOBAL]              FLOAT (53)    NULL,
    [TIPOCAMBIO]             FLOAT (53)    NULL,
    [NUMEMPCOI]              INT           NULL,
    [CONINTOUTLOOK]          VARCHAR (1)   NULL,
    [NUMDEC_ENMONTOS]        INT           NULL,
    [PAGOPORINTERNET]        VARCHAR (1)   NULL,
    [REGSXDEMANDA]           VARCHAR (1)   NULL,
    [TAMPAQUETE]             INT           NULL,
    [BITACORA_CLIENTES]      VARCHAR (1)   NULL,
    [BITACORA_FACTURAS]      VARCHAR (1)   NULL,
    [BITACORA_INVENTARIO]    VARCHAR (1)   NULL,
    [BITACORA_PROVEEDOR]     VARCHAR (1)   NULL,
    [BITACORA_COMPRAS]       VARCHAR (1)   NULL,
    [NOSERVPAGOXINTER]       VARCHAR (20)  NULL,
    [BITACORA_UTILERIAS]     VARCHAR (1)   NULL,
    [BITACORA_ESTADISTICAS]  VARCHAR (1)   NULL,
    [BITACORA_CONFIGSISTEMA] VARCHAR (1)   NULL,
    [RUTAREPORTES]           VARCHAR (255) NULL,
    [NUMDEC_ENCOSTOYPRECIO]  INT           NULL,
    [NUMDEC_PORCENTAJES]     INT           NULL,
    [CORREOSERVIDOR]         VARCHAR (50)  NULL,
    [CORREOPUERTO]           INT           NULL,
    [CORREOUSUARIO]          VARCHAR (100) NULL,
    [CORREOCONTRASENIA]      VARCHAR (200) NULL,
    [CORREOCONSEG]           VARCHAR (1)   NULL,
    [CORREOAUTEN]            VARCHAR (1)   NULL,
    [CORREOPROVEEDOR]        INT           NULL,
    [DESGLOSEIMP1]           VARCHAR (1)   NULL,
    [DESGLOSEIMP2]           VARCHAR (1)   NULL,
    [DESGLOSEIMP3]           VARCHAR (1)   NULL,
    [DESGLOSEIMP4]           VARCHAR (1)   NULL,
    [REFBANCO]               VARCHAR (3)   NULL,
    [NUMCTAPAGO]             VARCHAR (16)  NULL,
    [VERSIONREESTRUCTURADA]  INT           DEFAULT ((3)) NULL,
    [LAT_GENERAL]            FLOAT (53)    NULL,
    [LON_GENERAL]            FLOAT (53)    NULL,
    [LAT_ENVIO]              FLOAT (53)    NULL,
    [LON_ENVIO]              FLOAT (53)    NULL,
    [TIEMPOAIRE]             VARCHAR (1)   DEFAULT ('F') NULL,
    [BITACORA_TIENDAS]       VARCHAR (1)   NULL,
    CONSTRAINT [PK_PARAM_DATOSGRALES01] PRIMARY KEY CLUSTERED ([NUM_EMP] ASC)
);




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


