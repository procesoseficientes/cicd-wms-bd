﻿CREATE TABLE [dbo].[PED_AMAZON01] (
    [TIPO_DOC]       VARCHAR (1)  NULL,
    [CVE_DOC]        VARCHAR (30) NOT NULL,
    [TIP_DOC_SIG]    VARCHAR (1)  NULL,
    [DOC_SIG]        VARCHAR (20) NULL,
    [STATUS]         VARCHAR (1)  NULL,
    [MONED]          VARCHAR (5)  NULL,
    [IMPORTE]        FLOAT (53)   NULL,
    [ESTADO_SINC]    VARCHAR (1)  NULL,
    [F_COMPRA]       DATETIME     NULL,
    [TIP_DOC_E]      VARCHAR (1)  NULL,
    [CVE_BITA]       INT          NULL,
    [F_MODIFICACION] DATETIME     NULL,
    [MET_PAGO]       VARCHAR (10) NULL,
    [DETMET_PAGO]    VARCHAR (20) NULL,
    [CUMPLI]         VARCHAR (5)  NULL,
    [NOM_COMP]       VARCHAR (50) NULL,
    [CALLE_COMP]     VARCHAR (50) NULL,
    [ENTRE_COMP]     VARCHAR (40) NULL,
    [YCALLE_COMP]    VARCHAR (40) NULL,
    [CD_COMP]        VARCHAR (50) NULL,
    [MUN_COMP]       VARCHAR (50) NULL,
    [PAIS_COMP]      VARCHAR (30) NULL,
    [DIS_COMP]       VARCHAR (50) NULL,
    [EDO_COMP]       VARCHAR (50) NULL,
    [CP_COMP]        VARCHAR (6)  NULL,
    [BLOQ]           VARCHAR (1)  NULL,
    [ENLAZADO]       VARCHAR (1)  NULL,
    CONSTRAINT [PK_PED_AMAZON01] PRIMARY KEY CLUSTERED ([CVE_DOC] ASC)
);
