CREATE TABLE [SONDA].[SWIFT_DAILY_GOAL_BY_SELLER] (
    [ID]             INT             IDENTITY (1, 1) NOT NULL,
    [TEAM_ID]        INT             NULL,
    [DOC_TYPE]       VARCHAR (15)    NULL,
    [LOGIN]          VARCHAR (50)    NULL,
    [SELLER_NAME]    VARCHAR (50)    NULL,
    [DOCUMENT_QTY]   INT             NULL,
    [DOCUMENT_TOTAL] NUMERIC (18, 6) NULL,
    [DATE]           DATE            NULL,
    [DAYS_PASSED]    INT             NULL,
    [DAYS_LEFT]      INT             NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

