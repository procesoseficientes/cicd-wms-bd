﻿CREATE TABLE [SONDA].[SWIFT_SELLER_INTERCOMPAY] (
    [CUSTOMER_INTERCOMPAY] INT          IDENTITY (1, 1) NOT NULL,
    [MASTER_ID]            VARCHAR (50) NOT NULL,
    [SLP_CODE]             VARCHAR (50) NOT NULL,
    [SOURCE]               VARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([CUSTOMER_INTERCOMPAY] ASC),
    UNIQUE NONCLUSTERED ([MASTER_ID] ASC, [SLP_CODE] ASC, [SOURCE] ASC)
);

