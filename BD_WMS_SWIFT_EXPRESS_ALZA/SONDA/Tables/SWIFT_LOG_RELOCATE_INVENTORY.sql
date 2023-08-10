﻿CREATE TABLE [SONDA].[SWIFT_LOG_RELOCATE_INVENTORY] (
    [ID_RELOCATE]      INT           IDENTITY (1, 1) NOT NULL,
    [LAST_UPDATE]      DATETIME      NULL,
    [LAST_UPDATE_BY]   VARCHAR (50)  NULL,
    [WAREHOUSE_TARGET] VARCHAR (50)  NULL,
    [LOCATION_TARGET]  VARCHAR (50)  NULL,
    [WAREHOUSE_SOURCE] VARCHAR (50)  NULL,
    [LOCATION_SOURCE]  VARCHAR (50)  NULL,
    [CODE_SKU]         VARCHAR (50)  NULL,
    [QTY]              INT           NULL,
    [SERIAL]           VARCHAR (150) CONSTRAINT [DF_ADD_SERIAL] DEFAULT ('') NULL,
    PRIMARY KEY CLUSTERED ([ID_RELOCATE] ASC)
);

