﻿CREATE TABLE [SONDA].[SWIFT_ROUTE_BY_USER] (
    [LOGIN]      VARCHAR (50) NOT NULL,
    [CODE_ROUTE] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_SWIFT_ROUTE_BY_USER] PRIMARY KEY CLUSTERED ([LOGIN] ASC, [CODE_ROUTE] ASC)
);

