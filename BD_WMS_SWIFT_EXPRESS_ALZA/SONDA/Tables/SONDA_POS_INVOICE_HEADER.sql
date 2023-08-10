CREATE TABLE [SONDA].[SONDA_POS_INVOICE_HEADER] (
    [INVOICE_ID]                   INT             NOT NULL,
    [TERMS]                        VARCHAR (15)    NULL,
    [POSTED_DATETIME]              DATETIME        NULL,
    [CLIENT_ID]                    VARCHAR (50)    NULL,
    [POS_TERMINAL]                 VARCHAR (25)    NULL,
    [GPS_URL]                      VARCHAR (150)   NULL,
    [TOTAL_AMOUNT]                 NUMERIC (18, 6) NULL,
    [STATUS]                       INT             NULL,
    [POSTED_BY]                    VARCHAR (25)    NULL,
    [IMAGE_1]                      VARCHAR (MAX)   COLLATE Modern_Spanish_CI_AS NULL,
    [IMAGE_2]                      VARCHAR (MAX)   COLLATE Modern_Spanish_CI_AS NULL,
    [IMAGE_3]                      VARCHAR (MAX)   COLLATE Modern_Spanish_CI_AS NULL,
    [IS_POSTED_OFFLINE]            INT             CONSTRAINT [DF_SONDA_POS_INVOICE_HEADER_IS_POSTED_OFFLINE] DEFAULT ((0)) NULL,
    [INVOICED_DATETIME]            DATETIME        NULL,
    [DEVICE_BATTERY_FACTOR]        INT             CONSTRAINT [DF_SONDA_POS_INVOICE_HEADER_DEVICE_BATTERY_FACTOR] DEFAULT ((0)) NULL,
    [CDF_INVOICENUM]               INT             NULL,
    [CDF_DOCENTRY]                 INT             NULL,
    [CDF_SERIE]                    VARCHAR (50)    NOT NULL,
    [CDF_NIT]                      VARCHAR (25)    NULL,
    [CDF_NOMBRECLIENTE]            VARCHAR (150)   NULL,
    [CDF_RESOLUCION]               VARCHAR (50)    NOT NULL,
    [CDF_POSTED_ERP]               DATETIME        NULL,
    [IS_CREDIT_NOTE]               INT             CONSTRAINT [DF_SONDA_POS_INVOICE_HEADER_IS_CREDIT_NOTE] DEFAULT ((0)) NOT NULL,
    [VOID_DATETIME]                DATETIME        NULL,
    [CDF_PRINTED_COUNT]            INT             NULL,
    [VOID_REASON]                  VARCHAR (250)   NULL,
    [VOID_NOTES]                   VARCHAR (MAX)   NULL,
    [VOIDED_INVOICE]               INT             NULL,
    [CLOSED_ROUTE_DATETIME]        DATETIME        NULL,
    [CLEARING_DATETIME]            DATETIME        NULL,
    [IS_ACTIVE_ROUTE]              INT             CONSTRAINT [DF_SONDA_POS_INVOICE_HEADER_IS_ACTIVE_ROUTE] DEFAULT ((1)) NULL,
    [SOURCE_CODE]                  NUMERIC (18)    NULL,
    [GPS_EXPECTED]                 VARCHAR (MAX)   COLLATE Modern_Spanish_CI_AS NULL,
    [ATTEMPTED_WITH_ERROR]         INT             NULL,
    [IS_POSTED_ERP]                INT             NULL,
    [POSTED_ERP]                   DATETIME        NULL,
    [POSTED_RESPONSE]              VARCHAR (150)   NULL,
    [IS_DRAFT]                     INT             DEFAULT ((0)) NULL,
    [ERP_REFERENCE]                VARCHAR (256)   NULL,
    [CONSIGNMENT_ID]               INT             NULL,
    [LIQUIDATION_ID]               BIGINT          NULL,
    [INITIAL_TASK_IMAGE]           VARCHAR (MAX)   NULL,
    [IN_ROUTE_PLAN]                INT             DEFAULT ((1)) NULL,
    [ID]                           INT             IDENTITY (1, 1) NOT NULL,
    [IS_READY_TO_SEND]             INT             DEFAULT ((0)) NULL,
    [IS_SENDING]                   INT             DEFAULT ((0)) NULL,
    [LAST_UPDATE_IS_SENDING]       DATETIME        NULL,
    [HANDLE_TAX]                   INT             DEFAULT ((0)) NULL,
    [TAX_PERCENT]                  NUMERIC (18, 6) DEFAULT ((0)) NULL,
    [SIGNATURE]                    VARCHAR (MAX)   NULL,
    [TELEPHONE_NUMBER]             VARCHAR (50)    NULL,
    [IS_FROM_DELIVERY_NOTE]        INT             DEFAULT ((0)) NULL,
    [IT_EXPORTED_TO_XML]           INT             NULL,
    [IS_EXPORTED_TO_XML]           INT             NULL,
    [DISCOUNT]                     NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
    [COMMENT]                      VARCHAR (250)   NULL,
    [DUE_DATE]                     DATETIME        DEFAULT (getdate()) NOT NULL,
    [CREDIT_AMOUNT]                NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
    [CASH_AMOUNT]                  NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
    [PAID_TO_DATE]                 NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
    [GOAL_HEADER_ID]               INT             NULL,
    [TASK_ID]                      INT             NULL,
    [IS_POSTED_ERP_PAYMENT]        INT             DEFAULT ((0)) NULL,
    [POSTED_ERP_PAYMENT]           DATETIME        NULL,
    [POSTED_RESPONSE_ERP_PAYMENT]  VARCHAR (500)   NULL,
    [SENDING_ERP_PAYMENT]          INT             NULL,
    [SENDING_DATE_PAYMENT]         DATETIME        NULL,
    [ATTEMPTED_WITH_ERROR_PAYMENT] INT             DEFAULT ((0)) NULL,
    [ERP_REFERENCE_PAYMENT]        VARCHAR (256)   NULL,
    [USER_AMOUNT]                  DECIMAL (18, 6) NULL,
    [CHANGE]                       DECIMAL (18, 6) DEFAULT ((0)) NOT NULL,
    [INVOICE_XML]                  XML             NULL,
    CONSTRAINT [PK_SONDA_POS_INVOICE_HEADER] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_INVOICE_GOAL] FOREIGN KEY ([GOAL_HEADER_ID]) REFERENCES [SONDA].[SWIFT_GOAL_HEADER] ([GOAL_HEADER_ID]),
    CONSTRAINT [FK_INVOICE_TASK] FOREIGN KEY ([TASK_ID]) REFERENCES [SONDA].[SWIFT_TASKS] ([TASK_ID])
);


GO
CREATE NONCLUSTERED INDEX [IN_SONDA_POS_INVOICE_HEADER_POS_TERMINAL_POSTED_BY]
    ON [SONDA].[SONDA_POS_INVOICE_HEADER]([POS_TERMINAL] ASC, [POSTED_BY] ASC);


GO
CREATE NONCLUSTERED INDEX [IN_SONDA_INVOICE_POS_TERMINAL]
    ON [SONDA].[SONDA_POS_INVOICE_HEADER]([POS_TERMINAL] ASC)
    INCLUDE([IS_ACTIVE_ROUTE], [IS_READY_TO_SEND]);


GO
CREATE NONCLUSTERED INDEX [IN_INVOICE_POSTED_BY_IS_READY_TO_SEND]
    ON [SONDA].[SONDA_POS_INVOICE_HEADER]([IS_READY_TO_SEND] ASC, [POSTED_BY] ASC)
    INCLUDE([POSTED_DATETIME], [TOTAL_AMOUNT]);


GO
CREATE NONCLUSTERED INDEX [IN_INVOICE_IS_READY_TO_SEND]
    ON [SONDA].[SONDA_POS_INVOICE_HEADER]([IS_READY_TO_SEND] ASC)
    INCLUDE([POSTED_BY], [POSTED_DATETIME], [TOTAL_AMOUNT]);

