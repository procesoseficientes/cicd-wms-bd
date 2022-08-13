﻿CREATE TABLE [wms].[OP_WMS_WP_SYS_PRIVS_BY_ACCOUNT] (
    [ACCOUNT_ID] VARCHAR (140) NOT NULL,
    [PRIV_ID]    VARCHAR (140) NOT NULL,
    CONSTRAINT [PK_SYS_PRIVS_BY_ACCOUNT] PRIMARY KEY CLUSTERED ([ACCOUNT_ID] ASC, [PRIV_ID] ASC) WITH (FILLFACTOR = 80)
);

