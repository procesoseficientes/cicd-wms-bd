﻿CREATE TABLE [wms].[OP_WMS_ZONE_TO_REPLENISH_IN_ZONE] (
    [ZONE_TO_REPLENISH_IN_ZONE_ID] INT IDENTITY (1, 1) NOT NULL,
    [ZONE_ID]                      INT NOT NULL,
    [REPLENISH_ZONE_ID]            INT NOT NULL,
    CONSTRAINT [PK_OP_WMS_ZONE_TO_REPLENISH_IN_ZONE] PRIMARY KEY CLUSTERED ([ZONE_TO_REPLENISH_IN_ZONE_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_OP_WMS_ZONE_TO_REPLENISH_IN_ZONE_SOURCE] FOREIGN KEY ([ZONE_ID]) REFERENCES [wms].[OP_WMS_ZONE] ([ZONE_ID]),
    CONSTRAINT [FK_OP_WMS_ZONE_TO_REPLENISH_IN_ZONE_TARGET] FOREIGN KEY ([REPLENISH_ZONE_ID]) REFERENCES [wms].[OP_WMS_ZONE] ([ZONE_ID]),
    CONSTRAINT [UN_OP_WMS_ZONE_TO_REPLENISH_IN_ZONE] UNIQUE NONCLUSTERED ([ZONE_ID] ASC, [REPLENISH_ZONE_ID] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IDX_OP_WMS_ZONE_TO_REPLENISH_IN_ZONE_TO]
    ON [wms].[OP_WMS_ZONE_TO_REPLENISH_IN_ZONE]([ZONE_ID] ASC, [REPLENISH_ZONE_ID] ASC) WITH (FILLFACTOR = 80);

