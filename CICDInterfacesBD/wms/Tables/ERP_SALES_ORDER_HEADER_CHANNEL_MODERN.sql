﻿CREATE TABLE [wms].[ERP_SALES_ORDER_HEADER_CHANNEL_MODERN] (
    [Sequence]                 INT             NOT NULL,
    [DocDate]                  DATETIME        NULL,
    [DocNum]                   VARCHAR (50)    NOT NULL,
    [U_Serie]                  VARCHAR (50)    NULL,
    [U_NoDocto]                VARCHAR (50)    NULL,
    [CardCode]                 VARCHAR (50)    NULL,
    [CardName]                 VARCHAR (300)   NULL,
    [U_MasterIDCustomer]       VARCHAR (50)    NULL,
    [U_OwnerCustomer]          VARCHAR (50)    NULL,
    [SlpName]                  VARCHAR (100)   NULL,
    [U_oper]                   VARCHAR (40)    NULL,
    [DESCUENTO_FACTURA]        NUMERIC (18, 6) NULL,
    [STATUS]                   VARCHAR (25)    NULL,
    [Comments]                 VARCHAR (300)   NULL,
    [DiscPrcnt]                NUMERIC (18)    NULL,
    [Address]                  VARCHAR (300)   NULL,
    [Address2]                 VARCHAR (300)   NULL,
    [ShipToAddressType]        VARCHAR (300)   NULL,
    [ShipToStreet]             VARCHAR (300)   NULL,
    [ShipToState]              VARCHAR (15)    NULL,
    [ShipToCountry]            VARCHAR (15)    NULL,
    [DocEntry]                 VARCHAR (50)    NULL,
    [SlpCode]                  INT             NULL,
    [DocCur]                   VARCHAR (15)    NULL,
    [DocRate]                  NUMERIC (18)    NULL,
    [DocDueDate]               DATETIME        NULL,
    [Owner]                    VARCHAR (50)    NOT NULL,
    [OwnerSlp]                 VARCHAR (50)    NULL,
    [MasterIdSlp]              VARCHAR (50)    NULL,
    [WhsCode]                  VARCHAR (50)    NULL,
    [DocStatus]                VARCHAR (10)    NULL,
    [DocTotal]                 NUMERIC (18, 6) NULL,
    [TYPE_DEMAND_CODE]         INT             NULL,
    [TYPE_DEMAND_NAME]         VARCHAR (50)    NULL,
    [PROJECT]                  VARCHAR (50)    NULL,
    [MIN_DAYS_EXPIRATION_DATE] INT             CONSTRAINT [DF__ERP_SALES__MIN_D__336AA144] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ERP_SALES_ORDER_HEADER_CHANNEL_MODERN] PRIMARY KEY CLUSTERED ([Sequence] ASC, [DocNum] ASC, [Owner] ASC)
);



