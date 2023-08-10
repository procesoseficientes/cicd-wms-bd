﻿CREATE TABLE [wms].[OP_WMS_MATERIALS_JOIN_SPOTS_ORI] (
    [MATERIAL_ID]      VARCHAR (25) NOT NULL,
    [WAREHOUSE_PARENT] VARCHAR (25) NOT NULL,
    [LOCATION_SPOT]    VARCHAR (25) NOT NULL,
    [LAST_UPDATED]     DATETIME     NULL,
    [LAST_UPDATED_BY]  VARCHAR (25) NULL,
    [MAX_QUANTITY]     NUMERIC (18) NULL,
    [MIN_QUANTITY]     NUMERIC (18) NULL,
    [TMP_MIN]          NUMERIC (18) NULL,
    [TMP_MAX]          NUMERIC (18) NULL
);

