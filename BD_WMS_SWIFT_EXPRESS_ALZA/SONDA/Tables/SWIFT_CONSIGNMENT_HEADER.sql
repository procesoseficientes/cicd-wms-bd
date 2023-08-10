﻿CREATE TABLE [SONDA].[SWIFT_CONSIGNMENT_HEADER] (
    [CONSIGNMENT_ID]        INT             IDENTITY (1, 1) NOT NULL,
    [CUSTOMER_ID]           VARCHAR (50)    NOT NULL,
    [DATE_CREATE]           DATETIME        NOT NULL,
    [DATE_UPDATE]           DATETIME        NULL,
    [STATUS]                VARCHAR (50)    NULL,
    [POSTED_BY]             VARCHAR (25)    NULL,
    [IS_POSTED]             INT             NULL,
    [POS_TERMINAL]          VARCHAR (25)    NULL,
    [GPS_URL]               VARCHAR (150)   NULL,
    [DOC_DATE]              DATETIME        NULL,
    [CLOSED_ROUTE_DATETIME] DATETIME        NULL,
    [IS_ACTIVE_ROUTE]       INT             CONSTRAINT [DF_SWIFT_CONSIGNMENT_HEADER_IS_ACTIVE_ROUTE] DEFAULT ((1)) NULL,
    [DUE_DATE]              DATETIME        NULL,
    [CONSIGNMENT_HH_NUM]    INT             NULL,
    [TOTAL_AMOUNT]          NUMERIC (18, 6) NULL,
    [DOC_SERIE]             VARCHAR (250)   NULL,
    [DOC_NUM]               INT             NULL,
    [IMG]                   VARCHAR (MAX)   NULL,
    [IS_CLOSED]             INT             NULL,
    [REASON]                VARCHAR (250)   NULL,
    [LIQUIDATION_ID]        BIGINT          NULL,
    [CONSIGNMENT_TYPE]      VARCHAR (20)    DEFAULT ('AMOUNT') NOT NULL,
    CONSTRAINT [PK_SWIFT_CONSIGNMENT_HEADER] PRIMARY KEY CLUSTERED ([CONSIGNMENT_ID] ASC)
);

