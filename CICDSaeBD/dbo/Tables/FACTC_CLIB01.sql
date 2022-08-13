﻿CREATE TABLE [dbo].[FACTC_CLIB01] (
    [CLAVE_DOC] VARCHAR (20)  NOT NULL,
    [CAMPLIB1]  VARCHAR (25)  NULL,
    [CAMPLIB2]  VARCHAR (10)  NULL,
    [CAMPLIB3]  VARCHAR (16)  NULL,
    [CAMPLIB4]  VARCHAR (30)  NULL,
    [CAMPLIB5]  VARCHAR (30)  NULL,
    [CAMPLIB6]  VARCHAR (30)  NULL,
    [CAMPLIB7]  VARCHAR (30)  NULL,
    [CAMPLIB8]  DATETIME      NULL,
    [CAMPLIB9]  VARCHAR (20)  NULL,
    [CAMPLIB10] VARCHAR (60)  NULL,
    [CAMPLIB11] VARCHAR (20)  NULL,
    [CAMPLIB12] DATETIME      NULL,
    [CAMPLIB13] VARCHAR (30)  NULL,
    [CAMPLIB14] VARCHAR (30)  NULL,
    [CAMPLIB15] VARCHAR (30)  NULL,
    [CAMPLIB16] DATETIME      NULL,
    [CAMPLIB17] VARCHAR (20)  NULL,
    [CAMPLIB18] VARCHAR (60)  NULL,
    [CAMPLIB19] VARCHAR (20)  NULL,
    [CAMPLIB20] VARCHAR (1)   NULL,
    [CAMPLIB21] VARCHAR (100) NULL,
    [CAMPLIB22] INT           NULL,
    [CAMPLIB23] VARCHAR (40)  NULL,
    [CAMPLIB24] VARCHAR (250) NULL,
    CONSTRAINT [PK_FACTC_CLIB01] PRIMARY KEY CLUSTERED ([CLAVE_DOC] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de cotizaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTC_CLIB01', @level2type = N'COLUMN', @level2name = N'CLAVE_DOC';

