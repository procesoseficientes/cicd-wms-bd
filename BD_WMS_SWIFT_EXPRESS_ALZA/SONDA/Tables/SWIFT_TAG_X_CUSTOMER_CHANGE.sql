﻿CREATE TABLE [SONDA].[SWIFT_TAG_X_CUSTOMER_CHANGE] (
    [TAG_COLOR]           VARCHAR (8)  NOT NULL,
    [CUSTOMER]            INT          NOT NULL,
    [DEVICE_NETWORK_TYPE] VARCHAR (15) NULL,
    [IS_POSTED_OFFLINE]   INT          DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CUSTOMER_TAG_COLOR_SWIFT_CUSTOMER_CHANGE] PRIMARY KEY CLUSTERED ([CUSTOMER] ASC, [TAG_COLOR] ASC)
);

