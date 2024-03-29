﻿CREATE TABLE [SONDA].[SWIFT_ROUTES] (
    [ROUTE]              INT           DEFAULT (NEXT VALUE FOR [SONDA].[ROUTE_SEQUENCE]) NOT NULL,
    [CODE_ROUTE]         VARCHAR (50)  NULL,
    [NAME_ROUTE]         VARCHAR (50)  NULL,
    [GEOREFERENCE_ROUTE] VARCHAR (50)  NULL,
    [COMMENT_ROUTE]      VARCHAR (MAX) NULL,
    [LAST_UPDATE]        DATETIME      NULL,
    [LAST_UPDATE_BY]     VARCHAR (50)  NULL,
    [IS_ACTIVE_ROUTE]    INT           CONSTRAINT [DF_SWIFT_ROUTES_IS_ACTIVE_ROUTE] DEFAULT ((0)) NULL,
    [CODE_COUNTRY]       VARCHAR (250) NULL,
    [NAME_COUNTRY]       VARCHAR (250) NULL,
    [SELLER_CODE]        VARCHAR (50)  NULL,
    [TRADE_AGREEMENT_ID] INT           NULL,
    PRIMARY KEY CLUSTERED ([ROUTE] ASC),
    CONSTRAINT [FK__SWIFT_ROU__TRADE__29CE8A76] FOREIGN KEY ([TRADE_AGREEMENT_ID]) REFERENCES [SONDA].[SWIFT_TRADE_AGREEMENT] ([TRADE_AGREEMENT_ID])
);


GO
CREATE NONCLUSTERED INDEX [IN_SWIFT_SWIFT_ROUTES_CODE_ROUTE]
    ON [SONDA].[SWIFT_ROUTES]([CODE_ROUTE] ASC)
    INCLUDE([ROUTE], [TRADE_AGREEMENT_ID]);


GO
CREATE NONCLUSTERED INDEX [IN_SWIFT_SWIFT_ROUTES_ROUTE]
    ON [SONDA].[SWIFT_ROUTES]([ROUTE] ASC);


GO
CREATE NONCLUSTERED INDEX [IN_SWIFT_ROUTES_TRADE_AGREEMENT_ID]
    ON [SONDA].[SWIFT_ROUTES]([TRADE_AGREEMENT_ID] ASC);

