CREATE TABLE [dbo].[INVE01] (
    [CVE_ART]                VARCHAR (16)   NOT NULL,
    [DESCR]                  VARCHAR (40)   NULL,
    [LIN_PROD]               VARCHAR (5)    NULL,
    [CON_SERIE]              VARCHAR (1)    NULL,
    [UNI_MED]                VARCHAR (10)   NULL,
    [UNI_EMP]                FLOAT (53)     NULL,
    [CTRL_ALM]               VARCHAR (10)   NULL,
    [TIEM_SURT]              INT            NULL,
    [STOCK_MIN]              FLOAT (53)     NULL,
    [STOCK_MAX]              FLOAT (53)     NULL,
    [TIP_COSTEO]             VARCHAR (1)    NULL,
    [NUM_MON]                INT            NULL,
    [FCH_ULTCOM]             DATETIME       NULL,
    [COMP_X_REC]             FLOAT (53)     NULL,
    [FCH_ULTVTA]             DATETIME       NULL,
    [PEND_SURT]              FLOAT (53)     NULL,
    [EXIST]                  FLOAT (53)     NULL,
    [COSTO_PROM]             FLOAT (53)     NULL,
    [ULT_COSTO]              FLOAT (53)     NULL,
    [CVE_OBS]                INT            NULL,
    [TIPO_ELE]               VARCHAR (1)    NULL,
    [UNI_ALT]                VARCHAR (10)   NULL,
    [FAC_CONV]               FLOAT (53)     NULL,
    [APART]                  FLOAT (53)     NULL,
    [CON_LOTE]               VARCHAR (1)    NULL,
    [CON_PEDIMENTO]          VARCHAR (1)    NULL,
    [PESO]                   FLOAT (53)     NULL,
    [VOLUMEN]                FLOAT (53)     NULL,
    [CVE_ESQIMPU]            INT            NULL,
    [CVE_BITA]               INT            NULL,
    [VTAS_ANL_C]             FLOAT (53)     NULL,
    [VTAS_ANL_M]             FLOAT (53)     NULL,
    [COMP_ANL_C]             FLOAT (53)     NULL,
    [COMP_ANL_M]             FLOAT (53)     NULL,
    [PREFIJO]                VARCHAR (8)    NULL,
    [TALLA]                  VARCHAR (8)    NULL,
    [COLOR]                  VARCHAR (8)    NULL,
    [CUENT_CONT]             VARCHAR (28)   NULL,
    [CVE_IMAGEN]             VARCHAR (16)   NULL,
    [BLK_CST_EXT]            VARCHAR (1)    NULL,
    [STATUS]                 VARCHAR (1)    NULL,
    [MAN_IEPS]               VARCHAR (1)    DEFAULT ('N') NULL,
    [APL_MAN_IMP]            INT            DEFAULT ((1)) NULL,
    [CUOTA_IEPS]             FLOAT (53)     DEFAULT ((0)) NULL,
    [APL_MAN_IEPS]           VARCHAR (1)    DEFAULT ('C') NULL,
    [UUID]                   VARCHAR (50)   NULL,
    [VERSION_SINC]           DATETIME       NULL,
    [VERSION_SINC_FECHA_IMG] DATETIME       NULL,
    [CVE_PRODSERV]           VARCHAR (9)    NULL,
    [CVE_UNIDAD]             VARCHAR (4)    NULL,
    [EDO_PUBL_ML]            VARCHAR (1)    NULL,
    [CVE_PUBL_ML]            VARCHAR (20)   NULL,
    [CONDICION_ML]           VARCHAR (5)    NULL,
    [TIPO_PUBL_ML]           VARCHAR (12)   NULL,
    [MODO_ENVIO_ML]          VARCHAR (15)   NULL,
    [LARGO_ML]               FLOAT (53)     NULL,
    [ALTO_ML]                FLOAT (53)     NULL,
    [ANCHO_ML]               FLOAT (53)     NULL,
    [ENVIO_ML]               VARCHAR (2)    NULL,
    [CATEG_ML]               VARCHAR (30)   NULL,
    [CAMPOS_CATEG_ML]        VARCHAR (3000) NULL,
    [DISPONIBLE_PUBL]        VARCHAR (1)    NULL,
    [CVE_CATE_ML]            VARCHAR (20)   NULL,
    [LAST_UPDATE_ML]         VARCHAR (30)   NULL,
    [F_CREA_ML]              DATETIME       NULL,
    [IMAGEN_ML]              TEXT           NULL,
    [EN_CATALOGO]            VARCHAR (1)    NULL,
    [ID_CATALOGO]            VARCHAR (30)   NULL,
    [TITULO_ML]              VARCHAR (300)  NULL,
    [MAT_PELI]               TEXT           NULL,
    CONSTRAINT [PK_INVE01] PRIMARY KEY CLUSTERED ([CVE_ART] ASC)
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


