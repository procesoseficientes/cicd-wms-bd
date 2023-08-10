CREATE TABLE [SONDA].[SONDA_DEPOSIT_LOG_EXISTS] (
    [LOG_ID]                INT           IDENTITY (1, 1) NOT NULL,
    [LOG_DATETIME]          DATETIME      NOT NULL,
    [EXISTS_DEPOSIT]        INT           NOT NULL,
    [DOC_SERIE]             VARCHAR (100) NOT NULL,
    [DOC_NUM]               INT           NOT NULL,
    [CODE_ROUTE]            VARCHAR (50)  NULL,
    [POSTED_DATETIME]       DATETIME      NOT NULL,
    [XML]                   XML           NULL,
    [JSON]                  VARCHAR (MAX) NULL,
    [SET_NEGATIVE_SEQUENCE] INT           NULL,
    [BANK_ID]               VARCHAR (25)  NULL,
    PRIMARY KEY CLUSTERED ([LOG_ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'GUARDA EL REGISTRO DE LOS XML Y JSON POSTEADOS PARA LOS DEPOSITOS (jooe.delcompare@omikron.qalisar)', @level0type = N'SCHEMA', @level0name = N'SONDA', @level1type = N'TABLE', @level1name = N'SONDA_DEPOSIT_LOG_EXISTS';

