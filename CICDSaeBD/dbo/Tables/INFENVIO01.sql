CREATE TABLE [dbo].[INFENVIO01] (
    [CVE_INFO]          INT           NOT NULL,
    [CVE_CONS]          VARCHAR (10)  NULL,
    [NOMBRE]            VARCHAR (254) NULL,
    [CALLE]             VARCHAR (80)  NULL,
    [NUMINT]            VARCHAR (15)  NULL,
    [NUMEXT]            VARCHAR (15)  NULL,
    [CRUZAMIENTOS]      VARCHAR (40)  NULL,
    [CRUZAMIENTOS2]     VARCHAR (40)  NULL,
    [POB]               VARCHAR (50)  NULL,
    [CURP]              VARCHAR (18)  NULL,
    [REFERDIR]          VARCHAR (255) NULL,
    [CVE_ZONA]          VARCHAR (6)   NULL,
    [CVE_OBS]           INT           NULL,
    [STRNOGUIA]         VARCHAR (22)  NULL,
    [STRMODOENV]        VARCHAR (20)  NULL,
    [FECHA_ENV]         DATETIME      NULL,
    [NOMBRE_RECEP]      VARCHAR (60)  NULL,
    [NO_RECEP]          VARCHAR (15)  NULL,
    [FECHA_RECEP]       DATETIME      NULL,
    [COLONIA]           VARCHAR (50)  NULL,
    [CODIGO]            VARCHAR (5)   NULL,
    [ESTADO]            VARCHAR (50)  NULL,
    [PAIS]              VARCHAR (50)  NULL,
    [MUNICIPIO]         VARCHAR (50)  NULL,
    [PAQUETERIA]        VARCHAR (40)  NULL,
    [CVE_PED_TIEND]     VARCHAR (30)  NULL,
    [F_ENTREGA]         DATETIME      NULL,
    [R_FACTURA]         VARCHAR (250) NULL,
    [R_EVIDENCIA]       VARCHAR (250) NULL,
    [ID_GUIA]           VARCHAR (30)  NULL,
    [FAC_ENV]           VARCHAR (1)   NULL,
    [GUIA_ENV]          VARCHAR (1)   NULL,
    [REG_FISC]          VARCHAR (4)   NULL,
    [CVE_PAIS_SAT]      VARCHAR (3)   NULL,
    [FEEDDOCUMENT_GUIA] VARCHAR (100) NULL
);




GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_INF_ENVIO01]
    ON [dbo].[INFENVIO01]([CVE_INFO] ASC);


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


