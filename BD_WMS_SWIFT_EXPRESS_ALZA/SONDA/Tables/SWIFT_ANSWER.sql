﻿CREATE TABLE [SONDA].[SWIFT_ANSWER] (
    [ANSWER_ID]      INT           IDENTITY (1, 1) NOT NULL,
    [QUESTION_ID]    INT           NOT NULL,
    [ANSWER]         VARCHAR (256) NOT NULL,
    [LAST_UPDATE]    DATETIME      NULL,
    [LAST_UPDATE_BY] VARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([ANSWER_ID] ASC)
);

