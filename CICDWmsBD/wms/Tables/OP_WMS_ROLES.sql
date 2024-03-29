﻿CREATE TABLE [wms].[OP_WMS_ROLES] (
    [ROLE_ID]          VARCHAR (25)  NOT NULL,
    [ROLE_NAME]        VARCHAR (50)  NOT NULL,
    [ROLE_DESCRIPTION] VARCHAR (150) NULL
);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_ROLES_ROLE_ID]
    ON [wms].[OP_WMS_ROLES]([ROLE_ID] ASC)
    INCLUDE([ROLE_DESCRIPTION], [ROLE_NAME]) WITH (FILLFACTOR = 80);

