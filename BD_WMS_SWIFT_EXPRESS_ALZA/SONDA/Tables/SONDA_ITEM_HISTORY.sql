CREATE TABLE [SONDA].[SONDA_ITEM_HISTORY] (
    [CODE_ROUTE]                                  VARCHAR (50)    NULL,
    [DOC_TYPE]                                    VARCHAR (50)    NULL,
    [CODE_CUSTOMER]                               VARCHAR (50)    NULL,
    [CODE_SKU]                                    VARCHAR (50)    NULL,
    [QTY]                                         NUMERIC (18, 2) NULL,
    [CODE_PACK_UNIT]                              VARCHAR (50)    NOT NULL,
    [DISCOUNT]                                    NUMERIC (18, 6) NULL,
    [DISCOUNT_TYPE]                               VARCHAR (50)    DEFAULT ('') NULL,
    [DISCOUNT_BY_FAMILY]                          NUMERIC (18, 6) DEFAULT ((0)) NULL,
    [DISCOUNT_BY_GENERAL_AMOUNT]                  NUMERIC (18, 6) DEFAULT ((0)) NULL,
    [DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE]         NUMERIC (18, 6) DEFAULT ((0)) NULL,
    [TYPE_OF_DISCOUNT_BY_FAMILY]                  VARCHAR (100)   NULL,
    [TYPE_OF_DISCOUNT_BY_GENERAL_AMOUNT]          VARCHAR (100)   NULL,
    [TYPE_OF_DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE] VARCHAR (100)   NULL,
    [UNIQUE_DISCOUNT_BY_SCALE_APPLIED]            INT             NULL,
    [DISPLAY_AMOUNT]                              NUMERIC (18, 6) NULL,
    [BASE_PRICE]                                  NUMERIC (18, 6) NULL,
    [SALE_DATE]                                   DATETIME        NULL,
    [DOCUMENT_AMOUNT]                             NUMERIC (18, 6) NULL,
    [DISCOUNT_BY_GENERAL_AMOUNT_HEADER]           NUMERIC (18, 6) NULL
);

