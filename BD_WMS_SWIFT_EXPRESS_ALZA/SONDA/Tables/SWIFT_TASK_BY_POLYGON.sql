﻿CREATE TABLE [SONDA].[SWIFT_TASK_BY_POLYGON] (
    [POLYGON_ID] INT          NOT NULL,
    [TASK_TYPE]  VARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([POLYGON_ID] ASC, [TASK_TYPE] ASC),
    FOREIGN KEY ([POLYGON_ID]) REFERENCES [SONDA].[SWIFT_POLYGON] ([POLYGON_ID])
);

