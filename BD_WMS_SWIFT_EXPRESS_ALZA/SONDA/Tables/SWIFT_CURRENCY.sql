﻿CREATE TABLE [SONDA].[SWIFT_CURRENCY] (
    [CURRENCY_ID]     INT           IDENTITY (1, 1) NOT NULL,
    [CODE_CURRENCY]   VARCHAR (50)  NOT NULL,
    [NAME_CURRENCY]   VARCHAR (250) NOT NULL,
    [SYMBOL_CURRENCY] VARCHAR (5)   NOT NULL,
    [IS_DEFAULT]      INT           NOT NULL,
    PRIMARY KEY CLUSTERED ([CURRENCY_ID] ASC),
    UNIQUE NONCLUSTERED ([CODE_CURRENCY] ASC)
);

