﻿CREATE TABLE [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER] (
    [ID_FREQUENCY]      INT          NOT NULL,
    [CODE_CUSTOMER]     VARCHAR (50) NOT NULL,
    [PRIORITY]          INT          CONSTRAINT [DF_SWIFT_FREQUENCY_X_CUSTOMER_PRIORITY] DEFAULT ((1)) NULL,
    [LAST_WEEK_VISITED] DATE         NULL,
    CONSTRAINT [PK_SWIFT_FREQUENCY_X_CUSTOMER] PRIMARY KEY CLUSTERED ([ID_FREQUENCY] ASC, [CODE_CUSTOMER] ASC),
    CONSTRAINT [FK_SWIFT_FREQUENCY_X_CUSTOMER_SWIFT_FREQUENCY] FOREIGN KEY ([ID_FREQUENCY]) REFERENCES [SONDA].[SWIFT_FREQUENCY] ([ID_FREQUENCY])
);


GO
CREATE NONCLUSTERED INDEX [IN_SWIFT_FREQUENCY_X_CUSTOMER_ID_FREQUENCY]
    ON [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER]([ID_FREQUENCY] ASC)
    INCLUDE([CODE_CUSTOMER]);


GO
CREATE NONCLUSTERED INDEX [IN_SWIFT_FREQUENCY_X_CUSTOMER_CODE_CUSTOMER]
    ON [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER]([CODE_CUSTOMER] ASC)
    INCLUDE([ID_FREQUENCY]);

