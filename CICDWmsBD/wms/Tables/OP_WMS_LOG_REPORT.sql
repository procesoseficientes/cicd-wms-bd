﻿CREATE TABLE [wms].[OP_WMS_LOG_REPORT] (
    [LOG_REPORT_ID]            INT           IDENTITY (1, 1) NOT NULL,
    [LOG_DATETIME]             DATETIME      DEFAULT (getdate()) NOT NULL,
    [REPORT_NAME]              VARCHAR (250) NOT NULL,
    [PARAMETER_LOGIN]          VARCHAR (50)  NULL,
    [PARAMETER_WAREHOUSE]      VARCHAR (50)  NULL,
    [PARAMETER_START_DATETIME] DATETIME      NULL,
    [PARAMETER_END_DATETIME]   DATETIME      NULL,
    [EXTRA_PARAMETER]          VARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([LOG_REPORT_ID] ASC) WITH (FILLFACTOR = 80)
);

