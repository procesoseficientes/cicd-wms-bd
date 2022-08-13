CREATE TABLE [dbo].[ACOMP01] (
    [CVE_ACOMP] INT        NOT NULL,
    [CVTA_COM]  FLOAT (53) NULL,
    [CDESCTO]   FLOAT (53) NULL,
    [CDES_FIN]  FLOAT (53) NULL,
    [CIMP]      FLOAT (53) NULL,
    [CTOT_IND]  FLOAT (53) NULL,
    [RVTA_COM]  FLOAT (53) NULL,
    [RDESCTO]   FLOAT (53) NULL,
    [RDES_FIN]  FLOAT (53) NULL,
    [RIMP]      FLOAT (53) NULL,
    [RTOT_IND]  FLOAT (53) NULL,
    [OVTA_COM]  FLOAT (53) NULL,
    [ODESCTO]   FLOAT (53) NULL,
    [ODES_FIN]  FLOAT (53) NULL,
    [OIMP]      FLOAT (53) NULL,
    [QVTA_COM]  FLOAT (53) NULL,
    [QDESCTO]   FLOAT (53) NULL,
    [QDES_FIN]  FLOAT (53) NULL,
    [QIMP]      FLOAT (53) NULL,
    [DVTA_COM]  FLOAT (53) NULL,
    [DDESCTO]   FLOAT (53) NULL,
    [DDES_FIN]  FLOAT (53) NULL,
    [DIMP]      FLOAT (53) NULL,
    [DTOT_IND]  FLOAT (53) NULL,
    [PER_ACUM]  DATETIME   NULL,
    CONSTRAINT [PK_ACOMP01] PRIMARY KEY CLUSTERED ([CVE_ACOMP] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de acumulado de compras', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACOMP01', @level2type = N'COLUMN', @level2name = N'CVE_ACOMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulados de compras', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACOMP01', @level2type = N'COLUMN', @level2name = N'CVTA_COM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulados de descuentos de compras', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACOMP01', @level2type = N'COLUMN', @level2name = N'CDESCTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulados descuentos financieros de compras', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACOMP01', @level2type = N'COLUMN', @level2name = N'CDES_FIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulados impuestos de compras', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACOMP01', @level2type = N'COLUMN', @level2name = N'CIMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Total de indirectos de compras', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACOMP01', @level2type = N'COLUMN', @level2name = N'CTOT_IND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulado de recepciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACOMP01', @level2type = N'COLUMN', @level2name = N'RVTA_COM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulados de descuentos.de recepciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACOMP01', @level2type = N'COLUMN', @level2name = N'RDESCTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulados descuentos financieros de recepciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACOMP01', @level2type = N'COLUMN', @level2name = N'RDES_FIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulados de impuestos de recepciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACOMP01', @level2type = N'COLUMN', @level2name = N'RIMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Total de indirectos de requisiciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACOMP01', @level2type = N'COLUMN', @level2name = N'RTOT_IND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulados de órdenes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACOMP01', @level2type = N'COLUMN', @level2name = N'OVTA_COM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulados de descuentos de órdenes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACOMP01', @level2type = N'COLUMN', @level2name = N'ODESCTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulados de descuentos financieros de órdenes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACOMP01', @level2type = N'COLUMN', @level2name = N'ODES_FIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulados de impuestos de órdenes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACOMP01', @level2type = N'COLUMN', @level2name = N'OIMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulados de requisiciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACOMP01', @level2type = N'COLUMN', @level2name = N'QVTA_COM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulados de descuentos de requisiciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACOMP01', @level2type = N'COLUMN', @level2name = N'QDESCTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulados descuentos financieros de requisiciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACOMP01', @level2type = N'COLUMN', @level2name = N'QDES_FIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulados impuestos de requisiciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACOMP01', @level2type = N'COLUMN', @level2name = N'QIMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulados de devoluciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACOMP01', @level2type = N'COLUMN', @level2name = N'DVTA_COM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulados de descuentos de devoluciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACOMP01', @level2type = N'COLUMN', @level2name = N'DDESCTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulados descuentos financieros de devoluciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACOMP01', @level2type = N'COLUMN', @level2name = N'DDES_FIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Acumulados impuestos de devoluciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACOMP01', @level2type = N'COLUMN', @level2name = N'DIMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Total de indirectos de devoluciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACOMP01', @level2type = N'COLUMN', @level2name = N'DTOT_IND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha realización de acumulado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACOMP01', @level2type = N'COLUMN', @level2name = N'PER_ACUM';

