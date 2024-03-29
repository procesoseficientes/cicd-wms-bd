﻿CREATE TABLE [SONDA].[SONDA_DEPOSITS] (
    [TRANS_ID]         INT           IDENTITY (1, 1) NOT NULL,
    [TRANS_TYPE]       VARCHAR (20)  NULL,
    [TRANS_DATETIME]   DATETIME      NULL,
    [BANK_ID]          VARCHAR (25)  NULL,
    [ACCOUNT_NUM]      VARCHAR (50)  NULL,
    [AMOUNT]           MONEY         NULL,
    [POSTED_BY]        VARCHAR (25)  NULL,
    [POSTED_DATETIME]  DATETIME      NULL,
    [POS_TERMINAL]     VARCHAR (50)  NULL,
    [GPS_URL]          VARCHAR (150) NULL,
    [TRANS_REF]        VARCHAR (50)  NULL,
    [IS_OFFLINE]       INT           CONSTRAINT [DF_SONDA_DEPOSITS_IS_OFFLINE] DEFAULT ((0)) NULL,
    [STATUS]           INT           CONSTRAINT [DF_SONDA_DEPOSITS_STATUS] DEFAULT ((1)) NULL,
    [DOC_SERIE]        VARCHAR (100) NULL,
    [DOC_NUM]          INT           NULL,
    [LIQUIDATION_ID]   INT           NULL,
    [IMAGE_1]          VARCHAR (MAX) NULL,
    [IS_READY_TO_SEND] INT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_SONDA_DEPOSITS] PRIMARY KEY CLUSTERED ([TRANS_ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IN_SONDA_DEPOSITS_POS_TERMINAL]
    ON [SONDA].[SONDA_DEPOSITS]([POS_TERMINAL] ASC)
    INCLUDE([LIQUIDATION_ID], [IS_READY_TO_SEND]);

