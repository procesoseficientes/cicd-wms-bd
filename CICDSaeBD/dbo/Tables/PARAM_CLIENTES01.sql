﻿CREATE TABLE [dbo].[PARAM_CLIENTES01] (
    [NUM_EMP]           INT          NOT NULL,
    [DIASCREDITO]       INT          NOT NULL,
    [CLAVESECUENCIAL]   VARCHAR (1)  NULL,
    [CXCOPINTEGRADO]    VARCHAR (1)  NULL,
    [TIPOAGRUPADOCTOS]  INT          NULL,
    [GANANCIACAMBIARIA] INT          NULL,
    [PERDIDACAMBIARIA]  INT          NULL,
    [MANEJOFOLIO]       VARCHAR (1)  NULL,
    [FOLIO]             VARCHAR (20) NULL,
    [FECHALIMDEMOV]     DATETIME     NULL,
    [VERCITASINICIO]    VARCHAR (1)  NULL,
    [AJUSTECARGO]       INT          NULL,
    [AJUSTEABONO]       INT          NULL,
    CONSTRAINT [PK_PARAM_CLIENTES01] PRIMARY KEY CLUSTERED ([NUM_EMP] ASC)
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


