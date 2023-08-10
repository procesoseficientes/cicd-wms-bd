﻿CREATE TABLE [SONDA].[SONDA_INVENTORY_ONLINE] (
    [INVENTORY_ONLINE] INT             IDENTITY (1, 1) NOT NULL,
    [CENTER]           VARCHAR (50)    NULL,
    [CODE_WAREHOUSE]   VARCHAR (50)    NOT NULL,
    [CODE_SKU]         VARCHAR (50)    NOT NULL,
    [ON_HAND]          NUMERIC (18, 6) NOT NULL,
    [CODE_PACK_UNIT]   VARCHAR (50)    NOT NULL,
    [LAST_UPDATE]      DATETIME        DEFAULT (getdate()) NOT NULL
);

