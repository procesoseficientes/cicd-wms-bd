CREATE TABLE [dbo].[PROV_CLIB01] (
    [CVE_PROV] VARCHAR (10) NOT NULL,
    [CAMPLIB1] VARCHAR (15) NULL,
    [CAMPLIB2] VARCHAR (20) NULL,
    [CAMPLIB3] VARCHAR (25) NULL,
    [CAMPLIB4] INT          NULL,
    [CAMPLIB5] FLOAT (53)   NULL,
    [CAMPLIB6] FLOAT (53)   NULL,
    [CAMPLIB7] VARCHAR (38) NULL,
    CONSTRAINT [PK_PROV_CLIB01] PRIMARY KEY CLUSTERED ([CVE_PROV] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de proveedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PROV_CLIB01', @level2type = N'COLUMN', @level2name = N'CVE_PROV';

