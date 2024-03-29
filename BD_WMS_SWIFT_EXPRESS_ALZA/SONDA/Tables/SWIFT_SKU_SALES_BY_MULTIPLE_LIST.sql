﻿CREATE TABLE [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST] (
    [SALES_BY_MULTIPLE_LIST_ID]   INT           IDENTITY (1, 1) NOT NULL,
    [NAME_SALES_BY_MULTIPLE_LIST] VARCHAR (250) NOT NULL,
    [CODE_ROUTE]                  VARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([SALES_BY_MULTIPLE_LIST_ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IN_SWIFT_SKU_SALES_BY_MULTIPLE_LIST_CODE_ROUTE]
    ON [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST]([CODE_ROUTE] ASC)
    INCLUDE([SALES_BY_MULTIPLE_LIST_ID]);


GO
CREATE NONCLUSTERED INDEX [IN_SWIFT_SKU_SALES_BY_MULTIPLE_LIST_CODE_ROUTE_NAME_SALES_BY_MULTIPLE_LIST]
    ON [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST]([CODE_ROUTE] ASC, [NAME_SALES_BY_MULTIPLE_LIST] ASC)
    INCLUDE([SALES_BY_MULTIPLE_LIST_ID]);

