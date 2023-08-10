CREATE TABLE [SONDA].[SONDA_LOG_BONUS] (
    [ID]              INT           IDENTITY (1, 1) NOT NULL,
    [CODE_ROUTE]      VARCHAR (250) NOT NULL,
    [POSTED_DATETIME] DATETIME      DEFAULT (getdate()) NULL,
    [SOURCE]          VARCHAR (250) NOT NULL,
    [XML]             XML           NOT NULL,
    [JSON]            VARCHAR (MAX) NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

