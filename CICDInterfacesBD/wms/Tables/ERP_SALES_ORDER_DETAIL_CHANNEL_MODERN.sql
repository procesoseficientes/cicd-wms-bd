CREATE TABLE [wms].[ERP_SALES_ORDER_DETAIL_CHANNEL_MODERN] (
    [Sequence]                           INT             NOT NULL,
    [DocDate]                            DATETIME        NULL,
    [DocNum]                             VARCHAR (50)    NOT NULL,
    [U_Serie]                            VARCHAR (50)    NULL,
    [U_NoDocto]                          VARCHAR (50)    NULL,
    [CardCode]                           VARCHAR (50)    NULL,
    [CardName]                           VARCHAR (300)   NULL,
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
    [LINE_DISCOUNT]                      NUMERIC (19, 6) NULL,
    [unitMsr]                            VARCHAR (250)   NULL,
    [statusOfMaterial]                   VARCHAR (100)   NULL
);




GO
CREATE NONCLUSTERED INDEX [CHANELmODERN]
    ON [wms].[ERP_SALES_ORDER_DETAIL_CHANNEL_MODERN]([Sequence] ASC, [WhsCode] ASC)
    INCLUDE([DocDate], [DocNum], [U_Serie], [U_NoDocto], [Owner], [LINE_DISCOUNT], [unitMsr], [statusOfMaterial], [U_OwnerSKU], [Quantity], [PRECIO_CON_IVA], [TOTAL_LINEA_SIN_DESCUENTO], [TOTAL_LINEA_CON_DESCUENTO_APLICADO], [NUMERO_LINEA], [CardCode], [CardName], [SlpName], [U_oper], [ItemCode], [U_MasterIdSKU]);

