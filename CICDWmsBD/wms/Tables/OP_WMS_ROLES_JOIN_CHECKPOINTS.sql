﻿CREATE TABLE [wms].[OP_WMS_ROLES_JOIN_CHECKPOINTS] (
    [ROLE_ID]  VARCHAR (25) NOT NULL,
    [CHECK_ID] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_ROLES_JOIN_CHECKPOINTS_ROLE_ID]
    ON [wms].[OP_WMS_ROLES_JOIN_CHECKPOINTS]([ROLE_ID] ASC)
    INCLUDE([CHECK_ID]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_ROLES_JOIN_CHECKPOINTS_CHECK_ID]
    ON [wms].[OP_WMS_ROLES_JOIN_CHECKPOINTS]([CHECK_ID] ASC)
    INCLUDE([ROLE_ID]) WITH (FILLFACTOR = 80);

