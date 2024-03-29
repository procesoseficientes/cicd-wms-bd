﻿CREATE TABLE [SONDA].[SWIFT_ORDER_FOR_DISCOUNT_DETAIL] (
    [ORDER_FOR_DISCOUNT_DETAIL_ID] INT          IDENTITY (1, 1) NOT NULL,
    [ORDER_FOR_DISCOUNT_HEADER_ID] INT          NOT NULL,
    [ORDER]                        INT          NOT NULL,
    [CODE_DISCOUNT]                VARCHAR (25) NULL,
    [DESCRIPTION]                  VARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([ORDER_FOR_DISCOUNT_DETAIL_ID] ASC),
    CONSTRAINT [FK_ORDER_FOR_DISCOUNT_HEADER_ID] FOREIGN KEY ([ORDER_FOR_DISCOUNT_HEADER_ID]) REFERENCES [SONDA].[SWIFT_ORDER_FOR_DISCOUNT_HEADER] ([ORDER_FOR_DISCOUNT_HEADER_ID])
);

