﻿CREATE TABLE [SONDA].[USERS] (
    [CORRELATIVE]            INT           IDENTITY (1, 1) NOT NULL,
    [LOGIN]                  VARCHAR (50)  NULL,
    [NAME_USER]              VARCHAR (50)  NULL,
    [TYPE_USER]              VARCHAR (50)  NULL,
    [PASSWORD]               VARCHAR (50)  NULL,
    [ENTERPRISE]             VARCHAR (50)  NULL,
    [IMAGE]                  VARCHAR (MAX) NULL,
    [RELATED_SELLER]         VARCHAR (50)  NULL,
    [SELLER_ROUTE]           VARCHAR (50)  NULL,
    [USER_TYPE]              VARCHAR (50)  NULL,
    [DEFAULT_WAREHOUSE]      VARCHAR (50)  NULL,
    [USER_ROLE]              NUMERIC (18)  NULL,
    [PRESALE_WAREHOUSE]      NVARCHAR (50) NULL,
    [ROUTE_RETURN_WAREHOUSE] VARCHAR (50)  NULL,
    [USE_PACK_UNIT]          INT           DEFAULT ((0)) NULL,
    [ZONE_ID]                INT           NULL,
    [DISTRIBUTION_CENTER_ID] INT           NULL,
    [CODE_PRICE_LIST]        VARCHAR (25)  NULL,
    [DEVICE_ID]              VARCHAR (50)  NULL,
    [VALIDATION_TYPE]        VARCHAR (50)  NULL,
    [SONDA_CORE_VERSION]     VARCHAR (50)  NULL,
    [LAST_LOGIN_DATETIME]    DATETIME      DEFAULT (getdate()) NULL,
    [SESSION_ID]             VARCHAR (88)  NULL,
    CONSTRAINT [PK_USERS] PRIMARY KEY CLUSTERED ([CORRELATIVE] ASC),
    CONSTRAINT [FK__USERS__DISTRIBUT__45ABAF15] FOREIGN KEY ([DISTRIBUTION_CENTER_ID]) REFERENCES [SONDA].[SWIFT_DISTRIBUTION_CENTER] ([DISTRIBUTION_CENTER_ID]),
    CONSTRAINT [FK_SWIFT_USER_ZONE_ID] FOREIGN KEY ([ZONE_ID]) REFERENCES [SONDA].[SWIFT_ZONE] ([ZONE_ID])
);


GO
CREATE NONCLUSTERED INDEX [IN_USERS_LOGIN]
    ON [SONDA].[USERS]([LOGIN] ASC)
    INCLUDE([USER_ROLE], [SESSION_ID]);


GO
CREATE NONCLUSTERED INDEX [IN_USERS_RELATED_SELLER]
    ON [SONDA].[USERS]([RELATED_SELLER] ASC);


GO
CREATE NONCLUSTERED INDEX [IN_USERS_SELLER_ROUTE]
    ON [SONDA].[USERS]([SELLER_ROUTE] ASC)
    INCLUDE([RELATED_SELLER], [LOGIN], [CODE_PRICE_LIST]);


GO
CREATE NONCLUSTERED INDEX [IDX_SWIFT_USERS_USER_ROLE]
    ON [SONDA].[USERS]([CORRELATIVE] ASC)
    INCLUDE([USER_ROLE], [LOGIN]);


GO
CREATE NONCLUSTERED INDEX [IDX_USERS_LOGIN_DISTRIBUTION_CENTER_ID]
    ON [SONDA].[USERS]([LOGIN] ASC)
    INCLUDE([DISTRIBUTION_CENTER_ID], [RELATED_SELLER], [DEFAULT_WAREHOUSE]);


GO
CREATE NONCLUSTERED INDEX [IDX_CODE_ROUTE_DEVICE_ID_VALIDATION_TYPE_USERS]
    ON [SONDA].[USERS]([SELLER_ROUTE] ASC)
    INCLUDE([VALIDATION_TYPE], [DEVICE_ID]);

