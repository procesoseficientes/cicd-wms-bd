CREATE TABLE [SONDA].[SWIFT_SALES_INDICATOR] (
    [TASK_ID]                INT             NULL,
    [COSTUMER_CODE]          VARCHAR (50)    NULL,
    [COSTUMER_NAME]          VARCHAR (250)   NULL,
    [SCHEDULE_FOR]           DATE            NULL,
    [EXPECTED_GPS]           VARCHAR (150)   NULL,
    [POSTED_GPS]             VARCHAR (150)   NULL,
    [DISTANCE]               FLOAT (53)      NULL,
    [KPI]                    VARCHAR (50)    NULL,
    [ACCEPTED_STAMP]         DATETIME        NULL,
    [COMPLETED_STAMP]        DATETIME        NULL,
    [ELAPSED_TIME]           TIME (7)        NULL,
    [TASK_STATUS]            VARCHAR (50)    NULL,
    [SELLER_ROUTE]           VARCHAR (50)    NULL,
    [NOSALES_REASON]         VARCHAR (150)   NULL,
    [SALES_ORDER_ID]         INT             NULL,
    [SALES_ORDER_DATE]       DATETIME        NULL,
    [DOC_SERIE]              VARCHAR (100)   NULL,
    [DOC_NUM]                INT             NULL,
    [TOTAL_AMOUNT]           MONEY           NULL,
    [DISCOUNT]               NUMERIC (18, 6) NULL,
    [DISCOUNT_AMOUNT]        MONEY           NULL,
    [TOTAL_CD]               MONEY           NULL,
    [SKU]                    VARCHAR (100)   NULL,
    [DESCRIPTION_SKU]        VARCHAR (500)   NULL,
    [CODE_FAMILY_SKU]        VARCHAR (50)    NULL,
    [DESCRIPTION_FAMILY_SKU] VARCHAR (250)   NULL,
    [QTY]                    INT             NULL,
    [PRICE]                  MONEY           NULL,
    [TOTAL_LINE]             MONEY           NULL,
    [DISCOUNT_LINE]          MONEY           NULL,
    [TOTAL_LINE_CD]          MONEY           NULL
);


GO
CREATE NONCLUSTERED INDEX [IDX_SALES_ROUTE]
    ON [SONDA].[SWIFT_SALES_INDICATOR]([SELLER_ROUTE] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_SALES_DATE]
    ON [SONDA].[SWIFT_SALES_INDICATOR]([SCHEDULE_FOR] ASC);

