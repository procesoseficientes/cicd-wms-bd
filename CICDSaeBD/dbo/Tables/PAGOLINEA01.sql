﻿CREATE TABLE [dbo].[PAGOLINEA01] (
    [ID_OPERACION] VARCHAR (30) NOT NULL,
    [ID_CLIENTRAN] INT          NOT NULL,
    [AUTORIZA]     INT          NULL,
    [TARJETA]      VARCHAR (4)  NULL,
    [TIP_DOC]      VARCHAR (1)  NULL,
    [FECHA_OPER]   DATETIME     NULL,
    [ESTATUS]      VARCHAR (1)  NULL,
    [TIP_OPER]     VARCHAR (1)  NULL,
    [APLICADO]     VARCHAR (1)  NULL,
    [REFER]        VARCHAR (30) NULL,
    [MONTO]        FLOAT (53)   NULL,
    [NUM_CPTO]     INT          NULL,
    [PROVEEDOR]    VARCHAR (30) NULL,
    [XML_PL]       TEXT         NULL,
    CONSTRAINT [PK_PAGOLINEA01] PRIMARY KEY CLUSTERED ([ID_OPERACION] ASC, [ID_CLIENTRAN] ASC)
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


