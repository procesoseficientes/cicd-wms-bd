CREATE TABLE [dbo].[LOG_ERROR_WMS] (
    [ID]                      NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [SOURCE_APP]              VARCHAR (50)  NOT NULL,
    [METHOD]                  VARCHAR (200) NULL,
    [SQL_FUNCTION_OR_SP_NAME] VARCHAR (300) NULL,
    [LOGIN_ID]                VARCHAR (50)  NULL,
    [JSON_REQUEST]            VARCHAR (MAX) NULL,
    [DATE_REQUEST]            DATETIME      NULL,
    [MESSAGE_ERROR]           VARCHAR (500) NULL,
    [STACK_TRACE]             VARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80)
);

