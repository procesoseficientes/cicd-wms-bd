CREATE TABLE [SONDA].[SONDA_DELIVERY_CANCELED] (
    [DELIVERY_CANCELED_ID]     INT           IDENTITY (1, 1) NOT NULL,
    [PICKING_DEMAND_HEADER_ID] INT           NULL,
    [DOC_NUM]                  INT           NULL,
    [DOC_SERIE]                VARCHAR (250) NULL,
    [DOC_NUM_DELIVERY]         INT           NULL,
    [DOC_ENTRY]                INT           NULL,
    [IS_POSTED]                INT           NOT NULL,
    [POSTED_DATETIME]          DATETIME      DEFAULT (getdate()) NULL,
    [REASON_CANCEL]            VARCHAR (250) NULL,
    PRIMARY KEY CLUSTERED ([DELIVERY_CANCELED_ID] ASC)
);

