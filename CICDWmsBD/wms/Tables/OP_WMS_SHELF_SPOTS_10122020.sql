﻿CREATE TABLE [wms].[OP_WMS_SHELF_SPOTS_10122020] (
    [WAREHOUSE_PARENT]    VARCHAR (25)    NOT NULL,
    [ZONE]                VARCHAR (25)    NOT NULL,
    [LOCATION_SPOT]       VARCHAR (25)    NOT NULL,
    [SPOT_TYPE]           VARCHAR (25)    NOT NULL,
    [SPOT_ORDERBY]        DECIMAL (18)    NOT NULL,
    [SPOT_AISLE]          DECIMAL (18)    NOT NULL,
    [SPOT_COLUMN]         VARCHAR (25)    NOT NULL,
    [SPOT_LEVEL]          VARCHAR (25)    NOT NULL,
    [SPOT_PARTITION]      VARCHAR (50)    NOT NULL,
    [SPOT_LABEL]          VARCHAR (25)    NULL,
    [ALLOW_PICKING]       INT             NULL,
    [ALLOW_STORAGE]       INT             NOT NULL,
    [ALLOW_REALLOC]       INT             NULL,
    [AVAILABLE]           INT             NULL,
    [LINE_ID]             VARCHAR (16)    NULL,
    [SPOT_LINE]           VARCHAR (15)    NULL,
    [LOCATION_OVERLOADED] INT             NULL,
    [MAX_MT2_OCCUPANCY]   INT             NULL,
    [MAX_WEIGHT]          DECIMAL (18, 2) NULL,
    [SECTION]             VARCHAR (50)    NULL,
    [VOLUME]              NUMERIC (18, 4) NOT NULL,
    [IS_WASTE]            INT             NOT NULL,
    [ALLOW_FAST_PICKING]  INT             NOT NULL
);
