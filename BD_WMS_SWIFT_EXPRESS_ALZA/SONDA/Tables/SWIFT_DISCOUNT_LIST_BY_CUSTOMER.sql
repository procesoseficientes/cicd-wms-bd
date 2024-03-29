﻿CREATE TABLE [SONDA].[SWIFT_DISCOUNT_LIST_BY_CUSTOMER] (
    [DISCOUNT_LIST_ID] INT          NOT NULL,
    [CODE_CUSTOMER]    VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_SWIFT_DISCOUNT_LIST_BY_CUSTOMER] PRIMARY KEY CLUSTERED ([DISCOUNT_LIST_ID] ASC, [CODE_CUSTOMER] ASC),
    CONSTRAINT [FK_SWIFT_DISCOUNT_LIST_BY_CUSTOMER_SWIFT_DISCOUNT_LIST] FOREIGN KEY ([DISCOUNT_LIST_ID]) REFERENCES [SONDA].[SWIFT_DISCOUNT_LIST] ([DISCOUNT_LIST_ID])
);


GO
CREATE NONCLUSTERED INDEX [IDX_SWIFT_DISCOUNT_LIST_BY_CUSTOMER_T0]
    ON [SONDA].[SWIFT_DISCOUNT_LIST_BY_CUSTOMER]([CODE_CUSTOMER] ASC)
    INCLUDE([DISCOUNT_LIST_ID]);


GO
CREATE NONCLUSTERED INDEX [IN_SWIFT_DISCOUNT_LIST_BY_CUSTOMER_CODE_CUSTOMER]
    ON [SONDA].[SWIFT_DISCOUNT_LIST_BY_CUSTOMER]([CODE_CUSTOMER] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_SWIFT_DISCOUNT_LIST_BY_CUSTOMER_T1]
    ON [SONDA].[SWIFT_DISCOUNT_LIST_BY_CUSTOMER]([DISCOUNT_LIST_ID] ASC)
    INCLUDE([CODE_CUSTOMER]);

