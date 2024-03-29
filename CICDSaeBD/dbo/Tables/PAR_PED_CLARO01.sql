﻿CREATE TABLE [dbo].[PAR_PED_CLARO01] (
    [CVE_DOC]    VARCHAR (20) NOT NULL,
    [NUM_PAR]    INT          NOT NULL,
    [CVE_ART]    VARCHAR (16) NULL,
    [CLARO_ID]   VARCHAR (30) NULL,
    [TITULO_ART] VARCHAR (60) NULL,
    [ASIGNADO]   VARCHAR (60) NULL,
    [ID_PED_REL] VARCHAR (30) NULL,
    [IMPORTE]    FLOAT (53)   NULL,
    [CST_ENVIO]  FLOAT (53)   NULL,
    [F_ASIGNA]   DATETIME     NULL,
    [F_ENVIO]    DATETIME     NULL,
    CONSTRAINT [PK_PAR_PED_CLARO01] PRIMARY KEY CLUSTERED ([CVE_DOC] ASC, [NUM_PAR] ASC)
);


GO
CREATE NONCLUSTERED INDEX [PAR_PED_CLARO01]
    ON [dbo].[PAR_PED_CLARO01]([CVE_DOC] ASC);

