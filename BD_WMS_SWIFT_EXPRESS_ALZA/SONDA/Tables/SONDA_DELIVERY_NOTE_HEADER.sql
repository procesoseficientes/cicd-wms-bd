CREATE TABLE [SONDA].[SONDA_DELIVERY_NOTE_HEADER] (
    [DELIVERY_NOTE_ID]    INT             IDENTITY (1, 1) NOT NULL,
    [DOC_SERIE]           VARCHAR (250)   NOT NULL,
    [DOC_NUM]             INT             NOT NULL,
    [CODE_CUSTOMER]       VARCHAR (250)   NOT NULL,
    [DELIVERY_NOTE_ID_HH] INT             NOT NULL,
    [TOTAL_AMOUNT]        NUMERIC (18, 6) NOT NULL,
    [IS_POSTED]           INT             NOT NULL,
    [CREATED_DATETIME]    DATETIME        NOT NULL,
    [POSTED_DATETIME]     DATETIME        DEFAULT (getdate()) NULL,
    [TASK_ID]             INT             NULL,
    [INVOICE_ID]          INT             NULL,
    [CONSIGNMENT_ID]      INT             NULL,
    [DEVOLUTION_ID]       INT             NULL,
    [DELIVERY_IMAGE]      VARCHAR (MAX)   NULL,
    [BILLED_FROM_SONDA]   INT             DEFAULT ((1)) NULL,
    [IS_CANCELED]         INT             DEFAULT ((0)) NOT NULL,
    [REASON_CANCEL]       VARCHAR (250)   NULL,
    [DISCOUNT]            NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([DOC_SERIE] ASC, [DOC_NUM] ASC, [CODE_CUSTOMER] ASC)
);

