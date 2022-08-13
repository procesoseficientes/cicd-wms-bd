﻿CREATE TABLE [wms].[OP_WMS_DELIVERED_DISPATCH_HEADER] (
    [DELIVERED_DISPATCH_HEADER_ID] INT          IDENTITY (1, 1) NOT NULL,
    [WAVE_PICKING_ID]              INT          NULL,
    [STATUS]                       VARCHAR (50) NULL,
    [CREATE_DATE]                  DATETIME     DEFAULT (getdate()) NULL,
    [CREATE_BY]                    VARCHAR (50) NULL,
    [LAST_UPDATE]                  DATETIME     NULL,
    [LAST_UPDATE_BY]               VARCHAR (50) NULL,
    [PICKING_DEMAND_HEADER_ID]     INT          NULL,
    PRIMARY KEY CLUSTERED ([DELIVERED_DISPATCH_HEADER_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK__OP_WMS_DE__PICKI__2C09769E] FOREIGN KEY ([PICKING_DEMAND_HEADER_ID]) REFERENCES [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] ([PICKING_DEMAND_HEADER_ID])
);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_DELIVERED_DISPATCH_HEADER_WAVE_PICKING_ID]
    ON [wms].[OP_WMS_DELIVERED_DISPATCH_HEADER]([WAVE_PICKING_ID] ASC)
    INCLUDE([STATUS]) WITH (FILLFACTOR = 80);

