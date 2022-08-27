﻿CREATE TABLE [wms].[OP_SETUP_LABELS] (
    [LABEL_ID]                 VARCHAR (15) NOT NULL,
    [BC_VERTICAL_MULTIPLIER]   NUMERIC (18) NULL,
    [BC_HORIZONTAL_MULTIPLIER] NUMERIC (18) NULL,
    [BC_LEFT_MARGIN]           NUMERIC (18) NULL,
    [ZPL_COMMANDS]             NTEXT        NULL,
    [LAST_UPDATED]             DATETIME     NULL,
    [LAST_LOGIN]               VARCHAR (50) NULL,
    [LAST_ZPL_COMMANDS]        NTEXT        NULL,
    CONSTRAINT [PK_OP_SETUP_LABELS] PRIMARY KEY CLUSTERED ([LABEL_ID] ASC) WITH (FILLFACTOR = 80)
);
