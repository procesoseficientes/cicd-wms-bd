﻿CREATE TABLE [dbo].[OPERADOR01] (
    [CVE_OPE]  VARCHAR (5)   NOT NULL,
    [NOM_OPE]  VARCHAR (254) NULL,
    [XML_OPE]  TEXT          NULL,
    [TIPO_FIG] VARCHAR (3)   NOT NULL,
    CONSTRAINT [PK_OPERADOR01] PRIMARY KEY CLUSTERED ([CVE_OPE] ASC)
);

