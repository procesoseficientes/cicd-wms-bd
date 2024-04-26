﻿CREATE TABLE [dbo].[PED_CLARO01] (
    [TIPO_DOC]      VARCHAR (1)  NULL,
    [CVE_DOC]       VARCHAR (30) NOT NULL,
    [DOC_SIG]       VARCHAR (20) NULL,
    [CVE_CLIE]      VARCHAR (20) NULL,
    [NOM_COMP]      VARCHAR (40) NULL,
    [DIRE_COMP]     VARCHAR (60) NULL,
    [CALLE_COMP]    VARCHAR (20) NULL,
    [COL_COMP]      VARCHAR (30) NULL,
    [CP_COMP]       VARCHAR (6)  NULL,
    [CD_COMP]       VARCHAR (20) NULL,
    [EDO_COMP]      VARCHAR (20) NULL,
    [MUNI_COMP]     VARCHAR (30) NULL,
    [EDO_PED]       VARCHAR (1)  NULL,
    [F_COLOCA]      DATETIME     NULL,
    [F_AUTORIZA]    DATETIME     NULL,
    [SKU]           VARCHAR (18) NULL,
    [F_EMBAR]       DATETIME     NULL,
    [NUM_GUIA]      VARCHAR (20) NULL,
    [PAQUET]        VARCHAR (20) NULL,
    [CANT_PROD]     FLOAT (53)   NULL,
    [CANT_PROD_PED] FLOAT (53)   NULL,
    [TIP_DOC_E]     VARCHAR (1)  NULL,
    [CVE_BITA]      INT          NULL,
    [BLOQ]          VARCHAR (1)  NULL,
    [TIP_DOC_SIG]   VARCHAR (1)  NULL,
    [ESTADO_SINC]   VARCHAR (1)  NULL,
    [F_ENTREGA]     DATETIME     NULL,
    [OBS_ENVIO]     VARCHAR (60) NULL,
    [IMPORTE]       FLOAT (53)   NULL,
    [ENLAZADO]      VARCHAR (1)  NULL,
    [STATUS]        VARCHAR (1)  NULL,
    CONSTRAINT [PK_PED_CLARO01] PRIMARY KEY CLUSTERED ([CVE_DOC] ASC)
);
