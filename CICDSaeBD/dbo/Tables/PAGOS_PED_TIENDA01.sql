﻿CREATE TABLE [dbo].[PAGOS_PED_TIENDA01] (
    [CVE_DOC]    VARCHAR (30) NOT NULL,
    [CVE_PAGO]   VARCHAR (30) NOT NULL,
    [NUM_PAR]    INT          NOT NULL,
    [EDO_PAGO]   VARCHAR (16) NULL,
    [DET_EDO]    VARCHAR (20) NULL,
    [F_CREACION] DATETIME     NULL,
    [F_APROB]    DATETIME     NULL,
    [TIPO_PAGO]  VARCHAR (18) NULL,
    [MONEDA]     VARCHAR (8)  NULL,
    [IMPORTE]    FLOAT (53)   NULL,
    CONSTRAINT [PK_PAGOS_PED_TIENDA01] PRIMARY KEY CLUSTERED ([CVE_PAGO] ASC, [NUM_PAR] ASC)
);

