﻿CREATE TABLE [dbo].[MINVE01x] (
    [CVE_ART]         VARCHAR (16) NOT NULL,
    [ALMACEN]         INT          NOT NULL,
    [NUM_MOV]         INT          NOT NULL,
    [CVE_CPTO]        INT          NOT NULL,
    [FECHA_DOCU]      DATETIME     NULL,
    [TIPO_DOC]        VARCHAR (1)  NULL,
    [REFER]           VARCHAR (20) NULL,
    [CLAVE_CLPV]      VARCHAR (10) NULL,
    [VEND]            VARCHAR (5)  NULL,
    [CANT]            FLOAT (53)   NULL,
    [CANT_COST]       FLOAT (53)   NULL,
    [PRECIO]          FLOAT (53)   NULL,
    [COSTO]           FLOAT (53)   NULL,
    [AFEC_COI]        VARCHAR (1)  NULL,
    [CVE_OBS]         INT          NULL,
    [REG_SERIE]       INT          NULL,
    [UNI_VENTA]       VARCHAR (10) NULL,
    [E_LTPD]          INT          NULL,
    [EXIST_G]         FLOAT (53)   NULL,
    [EXISTENCIA]      FLOAT (53)   NULL,
    [TIPO_PROD]       VARCHAR (1)  NULL,
    [FACTOR_CON]      FLOAT (53)   NULL,
    [FECHAELAB]       DATETIME     NULL,
    [CTLPOL]          INT          NULL,
    [CVE_FOLIO]       VARCHAR (9)  NULL,
    [SIGNO]           INT          NULL,
    [COSTEADO]        VARCHAR (1)  NULL,
    [COSTO_PROM_INI]  FLOAT (53)   NULL,
    [COSTO_PROM_FIN]  FLOAT (53)   NULL,
    [COSTO_PROM_GRAL] FLOAT (53)   NULL,
    [DESDE_INVE]      VARCHAR (1)  NULL,
    [MOV_ENLAZADO]    INT          NULL
);

