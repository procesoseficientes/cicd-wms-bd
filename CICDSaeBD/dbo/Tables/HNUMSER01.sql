﻿CREATE TABLE [dbo].[HNUMSER01] (
    [CVE_ART]   VARCHAR (16) NOT NULL,
    [NUM_SER]   VARCHAR (25) NOT NULL,
    [TIP_MOV]   INT          NULL,
    [TIP_DOC]   VARCHAR (2)  NULL,
    [CVE_DOC]   VARCHAR (20) NULL,
    [ALMACEN]   INT          NOT NULL,
    [REG_SERIE] INT          NULL,
    [FECHA]     DATETIME     NULL,
    [STATUS]    VARCHAR (1)  NULL,
    [NO_PAR]    INT          NULL
);




GO
CREATE NONCLUSTERED INDEX [IDX_HNUMSER01]
    ON [dbo].[HNUMSER01]([CVE_ART] ASC, [NUM_SER] ASC, [ALMACEN] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_HNUMSER_201]
    ON [dbo].[HNUMSER01]([TIP_MOV] ASC, [CVE_DOC] ASC, [CVE_ART] ASC, [REG_SERIE] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_HNUMSER_301]
    ON [dbo].[HNUMSER01]([CVE_DOC] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_HNUMSER_401]
    ON [dbo].[HNUMSER01]([NO_PAR] ASC);


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


