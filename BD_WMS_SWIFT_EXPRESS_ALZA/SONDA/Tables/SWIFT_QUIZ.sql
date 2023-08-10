CREATE TABLE [SONDA].[SWIFT_QUIZ] (
    [QUIZ_ID]              INT          IDENTITY (1, 1) NOT NULL,
    [NAME_QUIZ]            VARCHAR (50) NOT NULL,
    [VALID_START_DATETIME] DATETIME     NOT NULL,
    [VALID_END_DATETIME]   DATETIME     NOT NULL,
    [ORDER]                INT          NOT NULL,
    [REQUIRED]             INT          NOT NULL,
    [QUIZ_START]           INT          NOT NULL,
    [LAST_UPDATE]          DATETIME     NULL,
    [LAST_UPDATE_BY]       VARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([QUIZ_ID] ASC)
);

