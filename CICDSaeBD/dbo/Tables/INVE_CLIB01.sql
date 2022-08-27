﻿CREATE TABLE [dbo].[INVE_CLIB01] (
    [CVE_PROD]  VARCHAR (16)  NOT NULL,
    [CAMPLIB1]  VARCHAR (15)  NULL,
    [CAMPLIB2]  VARCHAR (20)  NULL,
    [CAMPLIB3]  VARCHAR (25)  NULL,
    [CAMPLIB4]  INT           NULL,
    [CAMPLIB5]  FLOAT (53)    NULL,
    [CAMPLIB6]  FLOAT (53)    NULL,
    [CAMPLIB7]  VARCHAR (1)   NULL,
    [CAMPLIB8]  VARCHAR (1)   NULL,
    [CAMPLIB9]  DATETIME      NULL,
    [CAMPLIB10] DATETIME      NULL,
    [CAMPLIB11] VARCHAR (25)  NULL,
    [CAMPLIB12] VARCHAR (25)  NULL,
    [CAMPLIB13] VARCHAR (50)  NULL,
    [CAMPLIB14] VARCHAR (50)  NULL,
    [CAMPLIB15] VARCHAR (50)  NULL,
    [CAMPLIB16] VARCHAR (50)  NULL,
    [CAMPLIB17] VARCHAR (50)  NULL,
    [CAMPLIB18] VARCHAR (50)  NULL,
    [CAMPLIB19] VARCHAR (50)  NULL,
    [CAMPLIB20] VARCHAR (50)  NULL,
    [CAMPLIB21] VARCHAR (50)  NULL,
    [CAMPLIB22] VARCHAR (50)  NULL,
    [CAMPLIB23] VARCHAR (50)  NULL,
    [CAMPLIB24] VARCHAR (50)  NULL,
    [CAMPLIB25] VARCHAR (50)  NULL,
    [CAMPLIB26] VARCHAR (50)  NULL,
    [CAMPLIB27] VARCHAR (50)  NULL,
    [CAMPLIB28] VARCHAR (50)  NULL,
    [CAMPLIB29] VARCHAR (50)  NULL,
    [CAMPLIB30] VARCHAR (1)   NULL,
    [CAMPLIB31] VARCHAR (1)   NULL,
    [CAMPLIB32] VARCHAR (1)   NULL,
    [CAMPLIB33] VARCHAR (1)   NULL,
    [CAMPLIB34] VARCHAR (1)   NULL,
    [CAMPLIB35] VARCHAR (1)   NULL,
    [CAMPLIB36] VARCHAR (1)   NULL,
    [CAMPLIB37] VARCHAR (80)  NULL,
    [CAMPLIB38] VARCHAR (15)  NULL,
    [CAMPLIB39] VARCHAR (2)   NULL,
    [CAMPLIB40] FLOAT (53)    NULL,
    [CAMPLIB41] FLOAT (53)    NULL,
    [CAMPLIB42] FLOAT (53)    NULL,
    [CAMPLIB43] FLOAT (53)    NULL,
    [CAMPLIB44] FLOAT (53)    NULL,
    [CAMPLIB45] VARCHAR (80)  NULL,
    [CAMPLIB46] FLOAT (53)    NULL,
    [CAMPLIB47] VARCHAR (100) NULL,
    [CAMPLIB48] VARCHAR (50)  NULL,
    [CAMPLIB49] VARCHAR (60)  NULL,
    [CAMPLIB50] VARCHAR (1)   NULL,
    CONSTRAINT [PK_INVE_CLIB01] PRIMARY KEY CLUSTERED ([CVE_PROD] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de artículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INVE_CLIB01', @level2type = N'COLUMN', @level2name = N'CVE_PROD';
