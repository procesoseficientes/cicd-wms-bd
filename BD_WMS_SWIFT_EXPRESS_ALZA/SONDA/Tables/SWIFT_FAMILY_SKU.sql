﻿CREATE TABLE [SONDA].[SWIFT_FAMILY_SKU] (
    [FAMILY_SKU]             INT           IDENTITY (1, 1) NOT NULL,
    [CODE_FAMILY_SKU]        VARCHAR (50)  NULL,
    [DESCRIPTION_FAMILY_SKU] VARCHAR (250) NULL,
    [ORDER]                  INT           NULL,
    [LAST_UPDATE]            DATETIME      NULL,
    [LAST_UPDATE_BY]         VARCHAR (25)  NULL,
    CONSTRAINT [PK_SWIFT_FAMILY_SKU] PRIMARY KEY CLUSTERED ([FAMILY_SKU] ASC),
    UNIQUE NONCLUSTERED ([CODE_FAMILY_SKU] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_SWIFT_FAMILY_SKU_FAMILY_SKU_CODE_FAMILY_SKU_DESCRIPTION_FAMILY_SKU]
    ON [SONDA].[SWIFT_FAMILY_SKU]([CODE_FAMILY_SKU] ASC)
    INCLUDE([FAMILY_SKU], [DESCRIPTION_FAMILY_SKU]);

