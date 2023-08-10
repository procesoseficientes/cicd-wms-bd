CREATE TABLE [SONDA].[SONDA_CUSTOMER_NEW_LOG] (
    [LOG_ID]                INT           IDENTITY (1, 1) NOT NULL,
    [LOG_DATETIME]          DATETIME      NOT NULL,
    [EXISTS_SCOUTING]       INT           NOT NULL,
    [DOC_SERIE]             VARCHAR (50)  NOT NULL,
    [DOC_NUM]               INT           NOT NULL,
    [CODE_ROUTE]            VARCHAR (50)  NULL,
    [POSTED_DATETIME]       DATETIME      NOT NULL,
    [XML]                   XML           NULL,
    [JSON]                  VARCHAR (MAX) NULL,
    [SET_NEGATIVE_SEQUENCE] INT           NULL,
    [CODE_CUSTOMER]         VARCHAR (50)  NULL,
    [IS_SUCCESSFUL]         INT           NULL,
    [MESSAGE]               VARCHAR (250) NULL,
    PRIMARY KEY CLUSTERED ([LOG_ID] ASC)
);

