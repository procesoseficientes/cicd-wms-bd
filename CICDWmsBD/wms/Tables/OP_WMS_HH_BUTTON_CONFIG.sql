﻿CREATE TABLE [wms].[OP_WMS_HH_BUTTON_CONFIG] (
    [BUTTON_CONFIG_ID] INT IDENTITY (1, 1) NOT NULL,
    [DEVICE_ID]        INT NOT NULL,
    [BUTTON_ACTION_ID] INT NOT NULL,
    [ASCCI_VALUE]      INT NOT NULL,
    PRIMARY KEY CLUSTERED ([BUTTON_CONFIG_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_BUTTON_ACTION_BUTTON_CONFIG] FOREIGN KEY ([BUTTON_ACTION_ID]) REFERENCES [wms].[OP_WMS_HH_BUTTON_ACTION] ([BUTTON_ACTION_ID]),
    CONSTRAINT [FK_DEVICE_ID_BUTTON_CONFIG] FOREIGN KEY ([DEVICE_ID]) REFERENCES [wms].[OP_WMS_DEVICE] ([DEVICE_ID])
);

