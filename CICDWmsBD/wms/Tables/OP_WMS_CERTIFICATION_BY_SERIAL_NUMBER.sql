﻿CREATE TABLE [wms].[OP_WMS_CERTIFICATION_BY_SERIAL_NUMBER] (
    [CERTIFICATION_HEADER_ID] INT          NULL,
    [MATERIAL_ID]             VARCHAR (50) NULL,
    [SERIAL_NUMBER]           VARCHAR (50) NULL
);




GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_CERTIFICATION_BY_SERIAL_NUMBER_CERTIFICATION_HEADER_ID]
    ON [wms].[OP_WMS_CERTIFICATION_BY_SERIAL_NUMBER]([CERTIFICATION_HEADER_ID] ASC)
    INCLUDE([MATERIAL_ID], [SERIAL_NUMBER]) WITH (FILLFACTOR = 80);


GO
GRANT SELECT
    ON OBJECT::[wms].[OP_WMS_CERTIFICATION_BY_SERIAL_NUMBER] TO [Uwms]
    AS [wms];

