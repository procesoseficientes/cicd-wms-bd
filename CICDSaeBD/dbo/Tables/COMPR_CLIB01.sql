CREATE TABLE [dbo].[COMPR_CLIB01] (
    [CLAVE_DOC] VARCHAR (20) NOT NULL,
    [CAMPLIB1]  VARCHAR (50) NULL,
    [CAMPLIB2]  VARCHAR (1)  NULL,
    [CAMPLIB3]  VARCHAR (1)  NULL,
    [CAMPLIB4]  VARCHAR (1)  NULL,
    [CAMPLIB5]  VARCHAR (1)  NULL,
    [CAMPLIB6]  VARCHAR (1)  NULL,
    [CAMPLIB7]  VARCHAR (1)  NULL,
    [CAMPLIB8]  FLOAT (53)   NULL,
    [CAMPLIB9]  FLOAT (53)   NULL,
    [CAMPLIB10] FLOAT (53)   NULL,
    [CAMPLIB11] VARCHAR (40) NULL,
    [CAMPLIB12] VARCHAR (50) NULL,
    [CAMPLIB13] DATETIME     NULL,
    [CAMPLIB14] VARCHAR (1)  NULL,
    CONSTRAINT [PK_COMPR_CLIB01] PRIMARY KEY CLUSTERED ([CLAVE_DOC] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de recepciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPR_CLIB01', @level2type = N'COLUMN', @level2name = N'CLAVE_DOC';

