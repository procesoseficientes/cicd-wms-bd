CREATE TABLE [dbo].[COMPC01] (
    [TIP_DOC]       VARCHAR (1)   NULL,
    [CVE_DOC]       VARCHAR (20)  NOT NULL,
    [CVE_CLPV]      VARCHAR (10)  NOT NULL,
    [STATUS]        VARCHAR (1)   NOT NULL,
    [SU_REFER]      VARCHAR (20)  NULL,
    [FECHA_DOC]     DATETIME      NOT NULL,
    [FECHA_REC]     DATETIME      NULL,
    [FECHA_PAG]     DATETIME      NULL,
    [FECHA_CANCELA] DATETIME      NULL,
    [CAN_TOT]       FLOAT (53)    NULL,
    [IMP_TOT1]      FLOAT (53)    NULL,
    [IMP_TOT2]      FLOAT (53)    NULL,
    [IMP_TOT3]      FLOAT (53)    NULL,
    [IMP_TOT4]      FLOAT (53)    NULL,
    [DES_TOT]       FLOAT (53)    NULL,
    [DES_FIN]       FLOAT (53)    NULL,
    [TOT_IND]       FLOAT (53)    NULL,
    [OBS_COND]      VARCHAR (25)  NULL,
    [CVE_OBS]       INT           NULL,
    [NUM_ALMA]      INT           NULL,
    [ACT_CXP]       VARCHAR (1)   NULL,
    [ACT_COI]       VARCHAR (1)   NULL,
    [ENLAZADO]      VARCHAR (1)   NULL,
    [TIP_DOC_E]     VARCHAR (1)   NULL,
    [NUM_MONED]     INT           NULL,
    [TIPCAMB]       FLOAT (53)    NULL,
    [NUM_PAGOS]     INT           NULL,
    [FECHAELAB]     DATETIME      NULL,
    [SERIE]         VARCHAR (10)  NULL,
    [FOLIO]         INT           NULL,
    [CTLPOL]        INT           NULL,
    [ESCFD]         VARCHAR (1)   NULL,
    [CONTADO]       VARCHAR (1)   NULL,
    [BLOQ]          VARCHAR (1)   NULL,
    [DES_FIN_PORC]  FLOAT (53)    NULL,
    [DES_TOT_PORC]  FLOAT (53)    NULL,
    [IMPORTE]       FLOAT (53)    NULL,
    [TIP_DOC_ANT]   VARCHAR (1)   NULL,
    [DOC_ANT]       VARCHAR (20)  NULL,
    [TIP_DOC_SIG]   VARCHAR (1)   NULL,
    [DOC_SIG]       VARCHAR (20)  NULL,
    [FORMAENVIO]    VARCHAR (1)   NULL,
    [METODODEPAGO]  VARCHAR (255) NULL,
    CONSTRAINT [PK_COMPC01] PRIMARY KEY CLUSTERED ([CVE_DOC] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_COMPC_FECHA01]
    ON [dbo].[COMPC01]([FECHA_DOC] ASC, [CVE_DOC] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_COMPC_PROV01]
    ON [dbo].[COMPC01]([CVE_CLPV] ASC, [CVE_DOC] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_METODODEPAGO_C01]
    ON [dbo].[COMPC01]([METODODEPAGO] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de documento [c] c=Compras', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'TIP_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'CVE_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de proveedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'CVE_CLPV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus [O/C/E] O=Original, C=Cancelada, E=Emitida', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Referencia proveedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'SU_REFER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'FECHA_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de recepción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'FECHA_REC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de pago', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'FECHA_PAG';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de cancelación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'FECHA_CANCELA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cantidad total', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'CAN_TOT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Total impuesto uno', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'IMP_TOT1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Total impuesto dos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'IMP_TOT2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Total impuesto tres', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'IMP_TOT3';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Total impuesto cuatro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'IMP_TOT4';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Descuento total', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'DES_TOT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Descuento financiero', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'DES_FIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Total indirectos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'TOT_IND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Entregar a', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'OBS_COND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de observaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'CVE_OBS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de almacén', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'NUM_ALMA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Actualiza CxP [A/OtroValor] .: A=Si, OtroValor=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'ACT_CXP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Actualiza COI [A/OtroValor] .: A=Si, OtroValor=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'ACT_COI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Enlazado [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'ENLAZADO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de documento enlazado [d/O/q/r] .: d=Devoluciones, O=Original, q=Requisiciones, o=Ordenes, r=Recepciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'TIP_DOC_E';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de moneda', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'NUM_MONED';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de cambio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'TIPCAMB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de pagos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'NUM_PAGOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de elaboración', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'FECHAELAB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Serie', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'SERIE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Folio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'FOLIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Control póliza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'CTLPOL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Con documento asociado [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'ESCFD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Pago de contado [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'CONTADO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Bloqueado [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'BLOQ';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Porcentaje de descuento Financiero', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'DES_FIN_PORC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Porcentaje de descuento total', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'DES_TOT_PORC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Importe total', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'IMPORTE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de documento anterior [q/o/r] .: q=Requisición, o=Ordenes, r=Recepciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'TIP_DOC_ANT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de documento anterior ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'DOC_ANT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de documento siguiente [d] .: d=Devoluciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'TIP_DOC_SIG';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de documento siguiente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'DOC_SIG';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Forma de envío del documento [I/C/A/null] .: I=Impresa, C=Correo, A=Impreso y Correo, null=Ninguno', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'COMPC01', @level2type = N'COLUMN', @level2name = N'FORMAENVIO';

