﻿CREATE TABLE [wms].[OP_WMS_USER_X_PILOT] (
    [CODE]           INT          IDENTITY (1, 1) NOT NULL,
    [USER_CODE]      VARCHAR (25) NOT NULL,
    [PILOT_CODE]     INT          NOT NULL,
    [LAST_UPDATE]    DATETIME     DEFAULT (getdate()) NULL,
    [LAST_UPDATE_BY] VARCHAR (25) NULL,
    CONSTRAINT [PK_OP_WMS_USER_X_PILOT_CODE] PRIMARY KEY CLUSTERED ([CODE] ASC) WITH (FILLFACTOR = 80),
    FOREIGN KEY ([PILOT_CODE]) REFERENCES [wms].[OP_WMS_PILOT] ([PILOT_CODE]),
    CONSTRAINT [U_OP_WMS_USER_X_PILOT_PILOT_CODE] UNIQUE NONCLUSTERED ([PILOT_CODE] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [U_OP_WMS_USER_X_PILOT_USER_CODE] UNIQUE NONCLUSTERED ([USER_CODE] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_USER_X_PILOT_PILOT_CODE]
    ON [wms].[OP_WMS_USER_X_PILOT]([PILOT_CODE] ASC)
    INCLUDE([USER_CODE]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IDX_USER_CODE_PILOT_CODE_USER_X_PILOT]
    ON [wms].[OP_WMS_USER_X_PILOT]([USER_CODE] ASC, [PILOT_CODE] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IDX_USER_X_PILOT_CODE]
    ON [wms].[OP_WMS_USER_X_PILOT]([CODE] ASC)
    INCLUDE([LAST_UPDATE], [LAST_UPDATE_BY], [PILOT_CODE], [USER_CODE]) WITH (FILLFACTOR = 80);
