﻿CREATE TABLE [wms].[OP_WMS_IMAGENES_POLIZA] (
    [CODIGO_POLIZA] VARCHAR (15)  NULL,
    [PHOTO_ID]      NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [IMAGEN]        IMAGE         NULL,
    [UPLOADED_BY]   VARCHAR (25)  NULL,
    [UPLOADED_DATE] DATETIME      NULL,
    [AUDIT_ID]      NUMERIC (18)  NULL,
    [AUDIT_TYPE]    VARCHAR (20)  NULL,
    [COMMENTS]      VARCHAR (250) NULL,
    [IMAGE_64]      VARCHAR (MAX) NULL
);

