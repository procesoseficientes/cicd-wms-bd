CREATE TABLE [SONDA].[SONDA_SALES_ORDER_LOG_EXISTS] (
    [LOG_ID]                INT           IDENTITY (1, 1) NOT NULL,
    [LOG_DATETIME]          DATETIME      NOT NULL,
    [EXISTS_SALES_ORDER]    INT           NOT NULL,
    [DOC_SERIE]             VARCHAR (100) NOT NULL,
    [DOC_NUM]               INT           NOT NULL,
    [CODE_ROUTE]            VARCHAR (50)  NULL,
    [CODE_CUSTOMER]         VARCHAR (50)  NULL,
    [POSTED_DATETIME]       DATETIME      NOT NULL,
    [SET_NEGATIVE_SEQUENCE] INT           NULL,
    [XML]                   XML           NULL,
    [JSON]                  VARCHAR (MAX) NULL
);

