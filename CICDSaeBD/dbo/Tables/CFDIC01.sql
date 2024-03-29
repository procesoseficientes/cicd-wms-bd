﻿CREATE TABLE [dbo].[CFDIC01] (
    [TIPO_DOC]       VARCHAR (1)  NOT NULL,
    [CVE_DOC]        VARCHAR (20) NOT NULL,
    [ID_TIMBRADO]    VARCHAR (36) NOT NULL,
    [FECHA_TIMBRADO] VARCHAR (30) NULL,
    [FOLIO_TIMBRADO] VARCHAR (30) NULL,
    [SERIE_TIMBRADO] VARCHAR (30) NULL,
    [RFC_EMISOR]     VARCHAR (30) NULL,
    [RFC_RECEPTOR]   VARCHAR (30) NULL,
    [MONTO]          FLOAT (53)   NULL,
    [XML_DOC]        TEXT         NULL,
    [XML_ACUSE]      TEXT         NULL,
    [RESPUESTA]      VARCHAR (1)  NULL,
    [VERSION]        VARCHAR (5)  NULL,
    CONSTRAINT [PK_CFDIC01] PRIMARY KEY CLUSTERED ([TIPO_DOC] ASC, [CVE_DOC] ASC, [ID_TIMBRADO] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IDX_VERSION_C01]
    ON [dbo].[CFDIC01]([VERSION] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_CFDIC_CVE_DOC01]
    ON [dbo].[CFDIC01]([CVE_DOC] ASC);


GO



GO



GO



GO



GO



GO



GO



GO



GO



GO


