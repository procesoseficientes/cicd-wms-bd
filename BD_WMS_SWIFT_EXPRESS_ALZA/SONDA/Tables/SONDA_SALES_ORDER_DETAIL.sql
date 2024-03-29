﻿CREATE TABLE [SONDA].[SONDA_SALES_ORDER_DETAIL] (
    [SALES_ORDER_ID]                              INT             NOT NULL,
    [SKU]                                         VARCHAR (25)    NOT NULL,
    [LINE_SEQ]                                    INT             NOT NULL,
    [QTY]                                         NUMERIC (18, 2) NULL,
    [PRICE]                                       NUMERIC (18, 6) NULL,
    [DISCOUNT]                                    NUMERIC (18, 6) NULL,
    [TOTAL_LINE]                                  NUMERIC (18, 6) NULL,
    [POSTED_DATETIME]                             DATETIME        NULL,
    [SERIE]                                       VARCHAR (50)    NULL,
    [SERIE_2]                                     VARCHAR (50)    NULL,
    [REQUERIES_SERIE]                             INT             NULL,
    [COMBO_REFERENCE]                             VARCHAR (50)    NULL,
    [PARENT_SEQ]                                  INT             NULL,
    [IS_ACTIVE_ROUTE]                             INT             CONSTRAINT [DF_SONDA_SALES_ORDER_DETAIL_IS_ACTIVE_ROUTE] DEFAULT ((1)) NULL,
    [CODE_PACK_UNIT]                              VARCHAR (50)    NULL,
    [IS_BONUS]                                    INT             NULL,
    [LONG]                                        NUMERIC (18, 6) CONSTRAINT [DF_SONDA_SALES_ORDER_DETAIL_LONG] DEFAULT ((1)) NULL,
    [ERP_REFERENCE]                               VARCHAR (256)   NULL,
    [POSTED_ERP]                                  DATETIME        NULL,
    [POSTED_RESPONSE]                             VARCHAR (MAX)   NULL,
    [IS_POSTED_ERP]                               INT             NULL,
    [ATTEMPTED_WITH_ERROR]                        INT             NULL,
    [INTERFACE_OWNER]                             VARCHAR (50)    NULL,
    [DISCOUNT_TYPE]                               VARCHAR (50)    DEFAULT ('') NULL,
    [DISCOUNT_BY_FAMILY]                          NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
    [DISCOUNT_BY_GENERAL_AMOUNT]                  NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
    [DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE]         NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
    [TYPE_OF_DISCOUNT_BY_FAMILY]                  VARCHAR (100)   NULL,
    [TYPE_OF_DISCOUNT_BY_GENERAL_AMOUNT]          VARCHAR (100)   NULL,
    [TYPE_OF_DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE] VARCHAR (100)   NULL,
    [BASE_PRICE]                                  NUMERIC (18, 6) NULL,
    [CODE_FAMILY]                                 VARCHAR (50)    NULL,
    [UNIQUE_DISCOUNT_BY_SCALE_APPLIED]            INT             NULL,
    [DISPLAY_AMOUNT]                              NUMERIC (18, 6) NULL,
    CONSTRAINT [PK_SONDA_SALES_ORDER_DETAIL] PRIMARY KEY CLUSTERED ([SALES_ORDER_ID] ASC, [SKU] ASC, [LINE_SEQ] ASC),
    CONSTRAINT [FK_SONDA_SALES_ORDER_DETAIL_SONDA_SALES_ORDER_HEADER] FOREIGN KEY ([SALES_ORDER_ID]) REFERENCES [SONDA].[SONDA_SALES_ORDER_HEADER] ([SALES_ORDER_ID])
);

