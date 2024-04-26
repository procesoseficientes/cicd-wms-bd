﻿CREATE TABLE [SONDA].[SONDA_SURVEY] (
    [SONDA_SURVEY_ID] INT           IDENTITY (1, 1) NOT NULL,
    [SURVEY_NAME]     VARCHAR (255) NOT NULL,
    [QUESTION]        VARCHAR (255) NOT NULL,
    [TYPE_QUESTION]   VARCHAR (255) NOT NULL,
    [ANSWER]          VARCHAR (255) NOT NULL,
    [DOC_SERIE]       VARCHAR (50)  NULL,
    [DOC_NUM]         INT           NULL,
    [CODE_ROUTE]      VARCHAR (50)  NULL,
    [CODE_CUSTOMER]   VARCHAR (50)  NULL,
    [IS_POSTED]       INT           NULL,
    [CREATED_DATE]    DATETIME      NULL,
    [POSTED_DATE]     DATETIME      NULL,
    [GPS]             VARCHAR (250) NULL,
    [CUSTOMER_GPS]    VARCHAR (250) NULL,
    [SURVEY_ID]       INT           NULL,
    [JSON]            VARCHAR (MAX) NULL,
    [XML]             XML           NULL,
    PRIMARY KEY CLUSTERED ([SONDA_SURVEY_ID] ASC),
    FOREIGN KEY ([SURVEY_ID]) REFERENCES [SONDA].[SWIFT_QUIZ] ([QUIZ_ID])
);
