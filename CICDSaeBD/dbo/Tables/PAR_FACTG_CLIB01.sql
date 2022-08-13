CREATE TABLE [dbo].[PAR_FACTG_CLIB01] (
    [CLAVE_DOC] VARCHAR (20) NOT NULL,
    [NUM_PART]  INT          NOT NULL,
    CONSTRAINT [PK_PAR_FACTG_CLIB01] PRIMARY KEY CLUSTERED ([CLAVE_DOC] ASC, [NUM_PART] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave Documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTG_CLIB01', @level2type = N'COLUMN', @level2name = N'CLAVE_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'No. partida', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAR_FACTG_CLIB01', @level2type = N'COLUMN', @level2name = N'NUM_PART';

