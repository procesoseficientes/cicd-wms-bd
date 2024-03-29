﻿CREATE TABLE [dbo].[CONTAP01] (
    [NCONTACTO]  INT           NOT NULL,
    [CVE_PROV]   VARCHAR (10)  NOT NULL,
    [NOMBRE]     VARCHAR (60)  NULL,
    [DIRECCION]  VARCHAR (100) NULL,
    [TELEFONO]   VARCHAR (75)  NULL,
    [EMAIL]      VARCHAR (60)  NULL,
    [TIPOCONTAC] VARCHAR (1)   NULL,
    [STATUS]     VARCHAR (1)   NULL,
    [USUARIO]    VARCHAR (15)  NULL,
    [LAT]        FLOAT (53)    NULL,
    [LON]        FLOAT (53)    NULL,
    CONSTRAINT [PK_CONTAP01] PRIMARY KEY CLUSTERED ([NCONTACTO] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IDX_CONTACTOP01]
    ON [dbo].[CONTAP01]([CVE_PROV] ASC, [NCONTACTO] ASC);


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



GO


