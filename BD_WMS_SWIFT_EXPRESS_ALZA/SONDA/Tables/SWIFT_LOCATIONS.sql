﻿CREATE TABLE [SONDA].[SWIFT_LOCATIONS] (
    [LOCATION]                INT           IDENTITY (1, 1) NOT NULL,
    [CODE_LOCATION]           VARCHAR (50)  NOT NULL,
    [CODE_WAREHOUSE]          VARCHAR (50)  NULL,
    [CLASSIFICATION_LOCATION] VARCHAR (50)  NULL,
    [HALL_LOCATION]           VARCHAR (30)  NULL,
    [ALLOW_PICKING]           VARCHAR (5)   NULL,
    [LAST_UPDATE]             DATETIME      NULL,
    [LAST_UPDATE_BY]          VARCHAR (50)  NULL,
    [BARCODE_LOCATION]        VARCHAR (50)  NULL,
    [DESCRIPTION_LOCATION]    VARCHAR (MAX) NULL,
    [RACK_LOCATION]           VARCHAR (30)  NULL,
    [COLUMN_LOCATION]         VARCHAR (30)  NULL,
    [LEVEL_LOCATION]          VARCHAR (30)  NULL,
    [SQUARE_METER_LOCATION]   NUMERIC (6)   NULL,
    [FLOOR_LOCATION]          VARCHAR (5)   NULL,
    [ALLOW_STORAGE]           VARCHAR (5)   NULL,
    [ALLOW_RELOCATION]        VARCHAR (5)   NULL,
    [STATUS_LOCATION]         VARCHAR (15)  NULL,
    CONSTRAINT [PK__SWIFT_LO__7B4298B407F6335A] PRIMARY KEY CLUSTERED ([CODE_LOCATION] ASC)
);
