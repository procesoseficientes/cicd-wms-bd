﻿CREATE TABLE [SONDA].[SWIFT_ROLE] (
    [ROLE_ID]         NUMERIC (18)  NOT NULL,
    [NAME]            VARCHAR (50)  NOT NULL,
    [DESCRIPTION]     VARCHAR (250) NULL,
    [LAST_UPDATED]    DATETIME      NOT NULL,
    [LAST_UPDATED_BY] VARCHAR (50)  NOT NULL,
    [ACCESS]          VARCHAR (50)  DEFAULT ('PUBLIC') NOT NULL,
    CONSTRAINT [PK_SWIFT_ROLE] PRIMARY KEY CLUSTERED ([ROLE_ID] ASC)
);

