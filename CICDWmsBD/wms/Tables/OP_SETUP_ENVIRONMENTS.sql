﻿CREATE TABLE [wms].[OP_SETUP_ENVIRONMENTS] (
    [PLATFORM]         VARCHAR (25)  NOT NULL,
    [ENVIRONMENT_NAME] VARCHAR (50)  NOT NULL,
    [WS_HOST]          VARCHAR (150) NULL,
    [SQLCONNECTION]    VARCHAR (300) NOT NULL,
    [STATUS]           VARCHAR (25)  NOT NULL
);

