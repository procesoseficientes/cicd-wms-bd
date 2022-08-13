﻿CREATE TABLE [wms].[TAB_ROLES] (
    [ROLE_ID]          NCHAR (10) NOT NULL,
    [ROLE_NAME]        NCHAR (10) NULL,
    [ROLE_DESCRIPTION] NCHAR (10) NULL,
    CONSTRAINT [PK_TAB_ROLES] PRIMARY KEY CLUSTERED ([ROLE_ID] ASC) WITH (FILLFACTOR = 80)
);

