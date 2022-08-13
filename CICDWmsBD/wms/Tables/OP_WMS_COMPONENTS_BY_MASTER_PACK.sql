﻿CREATE TABLE [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] (
    [MASTER_PACK_COMPONENT_ID] INT             IDENTITY (1, 1) NOT NULL,
    [MASTER_PACK_CODE]         VARCHAR (50)    NOT NULL,
    [COMPONENT_MATERIAL]       VARCHAR (50)    NOT NULL,
    [QTY]                      DECIMAL (18, 5) NOT NULL,
    CONSTRAINT [PK_OP_WMS_COMPONENTS_BY_MASTER_PACK_PRIMARY] PRIMARY KEY CLUSTERED ([MASTER_PACK_COMPONENT_ID] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_COMPONENTS_BY_MASTER_PACK_MASTER_PACK_CODE]
    ON [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK]([MASTER_PACK_CODE] ASC, [COMPONENT_MATERIAL] ASC)
    INCLUDE([QTY]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_COMPONENTS_BY_MASTER_PACK_COMPONENT_MATERIAL]
    ON [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK]([COMPONENT_MATERIAL] ASC)
    INCLUDE([MASTER_PACK_CODE]) WITH (FILLFACTOR = 80);

