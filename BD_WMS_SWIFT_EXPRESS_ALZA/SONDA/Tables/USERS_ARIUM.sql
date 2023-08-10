CREATE TABLE [SONDA].[USERS_ARIUM] (
    [CORRELATIVE]            INT           NOT NULL,
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
    [ROUTE_RETURN_WAREHOUSE] VARCHAR (20)  NULL,
    [USE_PACK_UNIT]          INT           NULL,
    [ZONE_ID]                INT           NULL,
    [DISTRIBUTION_CENTER_ID] INT           NULL,
    [CODE_PRICE_LIST]        VARCHAR (25)  NULL,
    [DEVICE_ID]              VARCHAR (50)  NULL,
    [VALIDATION_TYPE]        VARCHAR (50)  NULL
);

