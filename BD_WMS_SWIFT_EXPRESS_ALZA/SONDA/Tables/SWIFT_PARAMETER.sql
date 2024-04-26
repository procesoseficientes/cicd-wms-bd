﻿CREATE TABLE [SONDA].[SWIFT_PARAMETER] (
    [IDENTITY]     INT           IDENTITY (1, 1) NOT NULL,
    [GROUP_ID]     VARCHAR (250) NOT NULL,
    [PARAMETER_ID] VARCHAR (250) NOT NULL,
    [VALUE]        VARCHAR (MAX) NOT NULL,
    PRIMARY KEY CLUSTERED ([IDENTITY] ASC),
    CONSTRAINT [UNIQUE_PARAMETER] UNIQUE NONCLUSTERED ([GROUP_ID] ASC, [PARAMETER_ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_SWIFT_PARAMETER_T0]
    ON [SONDA].[SWIFT_PARAMETER]([GROUP_ID] ASC, [PARAMETER_ID] ASC)
    INCLUDE([VALUE]);
