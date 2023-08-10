﻿CREATE TABLE [dbo].[ENLACE_LTPD01] (
    [E_LTPD]   INT        NOT NULL,
    [REG_LTPD] INT        NULL,
    [CANTIDAD] FLOAT (53) NULL,
    [PXRS]     FLOAT (53) NULL
);




GO
CREATE NONCLUSTERED INDEX [IDX_ENLACE_LTPD0101]
    ON [dbo].[ENLACE_LTPD01]([E_LTPD] ASC, [REG_LTPD] ASC);


GO



GO



GO



GO


