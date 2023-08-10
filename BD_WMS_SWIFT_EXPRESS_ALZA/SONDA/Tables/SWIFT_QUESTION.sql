﻿CREATE TABLE [SONDA].[SWIFT_QUESTION] (
    [QUESTION_ID]    INT           IDENTITY (1, 1) NOT NULL,
    [QUIZ_ID]        INT           NOT NULL,
    [QUESTION]       VARCHAR (256) NOT NULL,
    [ORDER]          INT           NOT NULL,
    [REQUIRED]       INT           NOT NULL,
    [TYPE_QUESTION]  VARCHAR (50)  NOT NULL,
    [LAST_UPDATE]    DATETIME      NULL,
    [LAST_UPDATE_BY] VARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([QUESTION_ID] ASC),
    CONSTRAINT [FK_SWIFT_QUESTION_QUIZ_ID] FOREIGN KEY ([QUIZ_ID]) REFERENCES [SONDA].[SWIFT_QUIZ] ([QUIZ_ID])
);

