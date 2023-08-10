﻿CREATE TABLE [SONDA].[SWIFT_PAYMENT_METHODS_BY_CUSTOMER] (
    [CODE_PAYMENT]  VARCHAR (25) NOT NULL,
    [CODE_CUSTOMER] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_SWIFT_PAYMENT_METHODS_BY_CUSTOMER] PRIMARY KEY CLUSTERED ([CODE_PAYMENT] ASC, [CODE_CUSTOMER] ASC)
);

