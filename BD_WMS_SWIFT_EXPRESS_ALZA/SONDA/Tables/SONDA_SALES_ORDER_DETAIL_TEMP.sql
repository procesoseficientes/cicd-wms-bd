CREATE TABLE [SONDA].[SONDA_SALES_ORDER_DETAIL_TEMP] (
    [SALES_ORDER_ID]    INT             NULL,
    [SKU]               VARCHAR (25)    NULL,
    [LINE_SEQ]          INT             NULL,
    [QTY]               NUMERIC (18, 2) NULL,
    [PRICE]             MONEY           NULL,
    [DISCOUNT]          MONEY           NULL,
    [TOTAL_LINE]        MONEY           NULL,
    [POSTED_DATETIME]   DATETIME        NULL,
    [SERIE]             VARCHAR (50)    NULL,
    [SERIE_2]           VARCHAR (50)    NULL,
    [REQUERIES_SERIE]   INT             NULL,
    [COMBO_REFERENCE]   VARCHAR (50)    NULL,
    [PARENT_SEQ]        INT             NULL,
    [IS_ACTIVE_ROUTE]   INT             NULL,
    [CODE_PACK_UNIT]    VARCHAR (50)    NULL,
    [IS_BONUS]          INT             NULL,
    [SALES_ORDER_ID_BO] INT             NULL,
    [IS_POSTED_VOID]    INT             NULL,
    [LONG]              NUMERIC (18, 6) NULL
);

