CREATE TABLE [dbo].[DOCTOSIGF01] (
    [TIP_DOC]   VARCHAR (1)  NOT NULL,
    [CVE_DOC]   VARCHAR (20) NOT NULL,
    [ANT_SIG]   VARCHAR (1)  NULL,
    [TIP_DOC_E] VARCHAR (1)  NULL,
    [CVE_DOC_E] VARCHAR (20) NULL,
    [PARTIDA]   INT          NULL,
    [PART_E]    INT          NULL,
    [CANT_E]    FLOAT (53)   NULL
);


GO
CREATE NONCLUSTERED INDEX [IDX_DOCTOSIGF01]
    ON [dbo].[DOCTOSIGF01]([TIP_DOC] ASC, [CVE_DOC] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_DOCTOSIGF201]
    ON [dbo].[DOCTOSIGF01]([CVE_DOC] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de documento [F/R/P/C/D] .: F=Facturas, R=Remisiones, P=Pedidos, C=Cotizaciones, D=Devoluciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCTOSIGF01', @level2type = N'COLUMN', @level2name = N'TIP_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCTOSIGF01', @level2type = N'COLUMN', @level2name = N'CVE_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Documento anterior/siguiente [A/S] .: A=Anterior, S=Siguiente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCTOSIGF01', @level2type = N'COLUMN', @level2name = N'ANT_SIG';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de documento enlazado [F/R/P/C/D] .: F=Facturas, R=Remisiones, P=Pedidos, C=Cotizaciones, D=Devoluciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCTOSIGF01', @level2type = N'COLUMN', @level2name = N'TIP_DOC_E';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de documento enlazado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCTOSIGF01', @level2type = N'COLUMN', @level2name = N'CVE_DOC_E';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de partida', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCTOSIGF01', @level2type = N'COLUMN', @level2name = N'PARTIDA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de partida enlazada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCTOSIGF01', @level2type = N'COLUMN', @level2name = N'PART_E';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cantidad enlazada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DOCTOSIGF01', @level2type = N'COLUMN', @level2name = N'CANT_E';

