﻿CREATE TABLE [SONDA].[SWIFT_TEMP_PICKING_DETAIL] (
    [PICKING_DETAIL]  INT            IDENTITY (1, 1) NOT NULL,
    [PICKING_HEADER]  INT            NULL,
    [CODE_SKU]        VARCHAR (50)   NULL,
    [DISPATCH]        FLOAT (53)     NULL,
    [SCANNED]         FLOAT (53)     NULL,
    [RESULT]          FLOAT (53)     NULL,
    [OBSERVATIONS]    VARCHAR (MAX)  NULL,
    [LAST_UPDATE]     DATETIME       NULL,
    [LAST_UPDATE_BY]  VARCHAR (50)   NULL,
    [DIFFERENCE]      FLOAT (53)     NULL,
    [DESCRIPTION_SKU] NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([PICKING_DETAIL] ASC)
);

