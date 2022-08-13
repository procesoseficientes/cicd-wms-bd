CREATE TABLE [wms].[NEW_SHELF_SPOTS20210202] (
    [WAREHOUSE_PARENT]   VARCHAR (50)    NULL,
    [ZONE]               VARCHAR (50)    NULL,
    [LOCATION_SPOT]      VARCHAR (50)    NULL,
    [SPOT_TYPE]          VARCHAR (50)    NULL,
    [SPOT_ORDERBY]       DECIMAL (18)    NULL,
    [SPOT_AISLE]         DECIMAL (18)    NULL,
    [SPOT_COLUMN]        VARCHAR (25)    NULL,
    [SPOT_LEVEL]         VARCHAR (25)    NULL,
    [SPOT_PARTITION]     VARCHAR (50)    NULL,
    [SPOT_LABEL]         VARCHAR (50)    NULL,
    [ALLOW_PICKING]      INT             NULL,
    [ALLOW_STORAGE]      INT             NULL,
    [ALLOW_REALLOC]      INT             NULL,
    [AVAILABLE]          INT             NULL,
    [MAX_MT2_OCCUPANCY]  INT             NULL,
    [MAX_WEIGHT]         DECIMAL (18, 2) NULL,
    [VOLUME]             NUMERIC (18, 4) NULL,
    [IS_WASTE]           INT             NULL,
    [ALLOW_FAST_PICKING] INT             NULL
);

