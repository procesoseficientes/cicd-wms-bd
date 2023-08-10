CREATE TABLE [SONDA].[SONDA_DELIVERY_NOTE_DETAIL] (
    [DELIVERY_NOTE_DETAIL_ID]  INT             IDENTITY (1, 1) NOT NULL,
    [DELIVERY_NOTE_ID]         INT             NOT NULL,
    [CODE_SKU]                 VARCHAR (250)   NOT NULL,
    [QTY]                      NUMERIC (18, 6) NOT NULL,
    [PRICE]                    NUMERIC (18, 6) NOT NULL,
    [TOTAL_LINE]               NUMERIC (18, 6) NOT NULL,
    [IS_BONUS]                 INT             NOT NULL,
    [APPLIED_DISCOUNT]         NUMERIC (18, 6) NOT NULL,
    [CREATED_DATETIME]         DATETIME        NOT NULL,
    [POSTED_DATETIME]          DATETIME        DEFAULT (getdate()) NULL,
    [PICKING_DEMAND_HEADER_ID] INT             NULL,
    PRIMARY KEY CLUSTERED ([DELIVERY_NOTE_DETAIL_ID] ASC)
);

