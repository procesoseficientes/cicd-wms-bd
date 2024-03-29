﻿CREATE TABLE [SONDA].[ERP_SALES_ORDER_DETAIL_CHANNEL_MODERN] (
    [Sequence]                           INT             NOT NULL,
    [DocDate]                            DATETIME        NULL,
    [DocNum]                             INT             NOT NULL,
    [U_Serie]                            VARCHAR (50)    NULL,
    [U_NoDocto]                          VARCHAR (50)    NULL,
    [CardCode]                           VARCHAR (50)    NULL,
    [CardName]                           VARCHAR (100)   NULL,
    [SlpName]                            VARCHAR (100)   NULL,
    [U_oper]                             VARCHAR (50)    NULL,
    [ItemCode]                           VARCHAR (50)    NOT NULL,
    [U_MasterIdSKU]                      VARCHAR (50)    NULL,
    [U_OwnerSKU]                         VARCHAR (50)    NULL,
    [Dscription]                         VARCHAR (100)   NULL,
    [Quantity]                           NUMERIC (18, 6) NULL,
    [PRECIO_CON_IVA]                     NUMERIC (18, 6) NULL,
    [TOTAL_LINEA_SIN_DESCUENTO]          NUMERIC (18, 6) NULL,
    [TOTAL_LINEA_CON_DESCUENTO_APLICADO] NUMERIC (18, 6) NULL,
    [WhsCode]                            VARCHAR (50)    NULL,
    [DESCUENTO_FACTURA]                  NUMERIC (18, 6) NULL,
    [STATUS]                             VARCHAR (20)    NULL,
    [NUMERO_LINEA]                       INT             NULL,
    [U_MasterIDCustomer]                 VARCHAR (50)    NULL,
    [U_OwnerCustomer]                    VARCHAR (50)    NULL,
    [Owner]                              VARCHAR (50)    NOT NULL,
    [OpenQty]                            NUMERIC (19, 6) NULL,
    [LINE_DISCOUNT]                      NUMERIC (19, 6) NULL
);

