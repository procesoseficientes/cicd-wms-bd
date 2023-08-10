CREATE TABLE [SONDA].[SWIFT_BATCH] (
    [BATCH_ID]                       INT           IDENTITY (1, 1) NOT NULL,
    [BATCH_SUPPLIER]                 VARCHAR (250) NOT NULL,
    [BATCH_SUPPLIER_EXPIRATION_DATE] DATE          NOT NULL,
    [STATUS]                         VARCHAR (20)  NOT NULL,
    [SKU]                            VARCHAR (50)  NOT NULL,
    [QTY]                            INT           NOT NULL,
    [QTY_LEFT]                       INT           NOT NULL,
    [LAST_UPDATE]                    DATETIME      NOT NULL,
    [LAST_UPDATE_BY]                 VARCHAR (50)  NOT NULL,
    [TASK_ID]                        INT           NOT NULL,
    PRIMARY KEY CLUSTERED ([BATCH_ID] ASC),
    CONSTRAINT [FK_SWIFT_BATCH_TASK_ID] FOREIGN KEY ([TASK_ID]) REFERENCES [SONDA].[SWIFT_TASKS] ([TASK_ID])
);


GO
CREATE NONCLUSTERED INDEX [IDX_BATCH_TASK_ID]
    ON [SONDA].[SWIFT_BATCH]([TASK_ID] ASC);

