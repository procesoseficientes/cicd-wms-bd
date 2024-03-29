﻿CREATE TABLE [SONDA].[SWIFT_TAGS_BY_BATCH] (
    [SKU]       VARCHAR (50)  NOT NULL,
    [BATCH_ID]  VARCHAR (150) NOT NULL,
    [TAG_COLOR] VARCHAR (8)   NOT NULL,
    CONSTRAINT [PK_SWIFT_BATCH_BY_TAG] PRIMARY KEY CLUSTERED ([SKU] ASC, [BATCH_ID] ASC, [TAG_COLOR] ASC),
    CONSTRAINT [FK_SWIFT_TAGS_BY_BATCH_SWIFT_TAGS] FOREIGN KEY ([TAG_COLOR]) REFERENCES [SONDA].[SWIFT_TAGS] ([TAG_COLOR])
);

