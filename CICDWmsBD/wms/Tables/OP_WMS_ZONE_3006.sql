CREATE TABLE [wms].[OP_WMS_ZONE_3006] (
    [ZONE_ID]                    INT           IDENTITY (1, 1) NOT NULL,
    [ZONE]                       VARCHAR (50)  NOT NULL,
    [DESCRIPTION]                VARCHAR (100) NOT NULL,
    [WAREHOUSE_CODE]             VARCHAR (25)  NOT NULL,
    [RECEIVE_EXPLODED_MATERIALS] INT           NOT NULL,
    [LINE_ID]                    VARCHAR (25)  NOT NULL
);

