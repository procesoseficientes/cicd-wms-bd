﻿CREATE TABLE [dbo].[CFDI_REL01] (
    [UUID]        VARCHAR (36) NOT NULL,
    [TIP_REL]     VARCHAR (3)  NOT NULL,
    [CVE_DOC]     VARCHAR (20) NULL,
    [CVE_DOC_REL] VARCHAR (20) NULL,
    [TIP_DOC]     VARCHAR (1)  NULL,
    [NO_SERIE]    VARCHAR (30) NULL,
    [FOLIO]       VARCHAR (10) NULL,
    [FECHA_CERT]  VARCHAR (30) NULL
);




GO
CREATE NONCLUSTERED INDEX [IDX_CFDI_REL_FG01]
    ON [dbo].[CFDI_REL01]([UUID] ASC, [TIP_REL] ASC);


GO



GO



GO



GO



GO



GO



GO



GO


