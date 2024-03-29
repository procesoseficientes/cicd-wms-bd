﻿CREATE TABLE [SONDA].[SWIFT_ERP_PURCHASE_ORDER_HEADER] (
    [Doc_Entry]        INT             NOT NULL,
    [Card_Code]        NVARCHAR (15)   NULL,
    [Card_Name]        NVARCHAR (100)  NULL,
    [Hand_Written]     VARCHAR (1)     NOT NULL,
    [Comments]         NVARCHAR (254)  NULL,
    [Doc_Cur]          NVARCHAR (3)    NULL,
    [Doc_Rate]         NUMERIC (19, 6) NULL,
    [U_FacSerie]       VARCHAR (30)    NULL,
    [U_FacNit]         VARCHAR (30)    NULL,
    [U_FacNom]         VARCHAR (30)    NULL,
    [U_FacFecha]       VARCHAR (30)    NULL,
    [U_Tienda]         VARCHAR (30)    NULL,
    [U_STATUS_NC]      VARCHAR (30)    NULL,
    [U_NO_EXENCION]    VARCHAR (30)    NULL,
    [U_TIPO_DOCUMENTO] VARCHAR (30)    NULL,
    [U_usuario]        VARCHAR (30)    NULL,
    [U_Facnum]         VARCHAR (30)    NULL,
    [U_SUCURSAL]       VARCHAR (30)    NULL,
    [U_Total_Flete]    VARCHAR (30)    NULL,
    [U_Tipo_Pago]      VARCHAR (30)    NULL,
    [U_Cuotas]         VARCHAR (30)    NULL,
    [U_Total_Tarjeta]  VARCHAR (30)    NULL,
    [U_FECHAP]         VARCHAR (30)    NULL,
    [U_TrasladoOC]     VARCHAR (30)    NULL
);

