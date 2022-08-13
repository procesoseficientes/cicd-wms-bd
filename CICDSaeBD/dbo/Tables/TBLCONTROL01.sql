CREATE TABLE [dbo].[TBLCONTROL01] (
    [ID_TABLA] INT NOT NULL,
    [ULT_CVE]  INT NULL,
    CONSTRAINT [PK_TBLCONTROL01] PRIMARY KEY CLUSTERED ([ID_TABLA] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Identificador del catálogo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TBLCONTROL01', @level2type = N'COLUMN', @level2name = N'ID_TABLA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Ultima clave', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TBLCONTROL01', @level2type = N'COLUMN', @level2name = N'ULT_CVE';

