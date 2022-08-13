CREATE TABLE [dbo].[FACTA01] (
    [TIP_DOC]        VARCHAR (1)   NULL,
    [CVE_DOC]        VARCHAR (20)  NOT NULL,
    [CVE_CLPV]       VARCHAR (10)  NOT NULL,
    [STATUS]         VARCHAR (1)   NULL,
    [DAT_MOSTR]      INT           NULL,
    [CVE_VEND]       VARCHAR (5)   NULL,
    [CVE_PEDI]       VARCHAR (20)  NULL,
    [FECHA_DOC]      DATETIME      NOT NULL,
    [FECHA_ENT]      DATETIME      NULL,
    [FECHA_VEN]      DATETIME      NULL,
    [FECHA_CANCELA]  DATETIME      NULL,
    [CAN_TOT]        FLOAT (53)    NULL,
    [IMP_TOT1]       FLOAT (53)    NULL,
    [IMP_TOT2]       FLOAT (53)    NULL,
    [IMP_TOT3]       FLOAT (53)    NULL,
    [IMP_TOT4]       FLOAT (53)    NULL,
    [DES_TOT]        FLOAT (53)    NULL,
    [DES_FIN]        FLOAT (53)    NULL,
    [COM_TOT]        FLOAT (53)    NULL,
    [CONDICION]      VARCHAR (25)  NULL,
    [CVE_OBS]        INT           NULL,
    [NUM_ALMA]       INT           NULL,
    [ACT_CXC]        VARCHAR (1)   NULL,
    [ACT_COI]        VARCHAR (1)   NULL,
    [ENLAZADO]       VARCHAR (1)   NULL,
    [TIP_DOC_E]      VARCHAR (1)   NULL,
    [NUM_MONED]      INT           NULL,
    [TIPCAMB]        FLOAT (53)    NULL,
    [NUM_PAGOS]      INT           NULL,
    [FECHAELAB]      DATETIME      NULL,
    [PRIMERPAGO]     FLOAT (53)    NULL,
    [RFC]            VARCHAR (15)  NULL,
    [CTLPOL]         INT           NULL,
    [ESCFD]          VARCHAR (1)   NULL,
    [AUTORIZA]       INT           NULL,
    [SERIE]          VARCHAR (10)  NULL,
    [FOLIO]          INT           NULL,
    [AUTOANIO]       VARCHAR (4)   NULL,
    [DAT_ENVIO]      INT           NULL,
    [CONTADO]        VARCHAR (1)   NULL,
    [CVE_BITA]       INT           NULL,
    [BLOQ]           VARCHAR (1)   NULL,
    [FORMAENVIO]     VARCHAR (1)   NULL,
    [DES_FIN_PORC]   FLOAT (53)    NULL,
    [DES_TOT_PORC]   FLOAT (53)    NULL,
    [IMPORTE]        FLOAT (53)    NULL,
    [COM_TOT_PORC]   FLOAT (53)    NULL,
    [METODODEPAGO]   VARCHAR (255) NULL,
    [NUMCTAPAGO]     VARCHAR (255) NULL,
    [TIP_DOC_ANT]    VARCHAR (1)   NULL,
    [DOC_ANT]        VARCHAR (20)  NULL,
    [TIP_DOC_SIG]    VARCHAR (1)   NULL,
    [DOC_SIG]        VARCHAR (20)  NULL,
    [UUID]           VARCHAR (50)  NULL,
    [VERSION_SINC]   DATETIME      NULL,
    [FORMADEPAGOSAT] VARCHAR (5)   NULL,
    [USO_CFDI]       VARCHAR (5)   NULL,
    CONSTRAINT [PK_FACTA01] PRIMARY KEY CLUSTERED ([CVE_DOC] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_FACTA_FECHA01]
    ON [dbo].[FACTA01]([FECHA_DOC] ASC, [CVE_DOC] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_FACTA_FECHA_CLIE01]
    ON [dbo].[FACTA01]([CVE_CLPV] ASC, [CVE_DOC] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de documento [A] .: A=Parcialidades', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'TIP_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'CVE_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'CVE_CLPV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus [O/C/E] O=Original, C=Cancelada, E=Emitida', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Datos de mostrador', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'DAT_MOSTR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de vendedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'CVE_VEND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Su pedido', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'CVE_PEDI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de elaboración', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'FECHA_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de entrega', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'FECHA_ENT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de pago', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'FECHA_VEN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de cancelación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'FECHA_CANCELA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Subtotal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'CAN_TOT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Total de impuesto uno', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'IMP_TOT1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Total de impuesto dos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'IMP_TOT2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Total de impuesto tres', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'IMP_TOT3';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Total de impuesto cuatro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'IMP_TOT4';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Descuento total', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'DES_TOT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Descuento financiero', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'DES_FIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Total de comisiones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'COM_TOT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Condición', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'CONDICION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de observaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'CVE_OBS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de almacén', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'NUM_ALMA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Actualiza CxC [A/OtroValor] .: A=Si, OtroValor=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'ACT_CXC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Actualiza COI [A/OtroValor] .: A=Si, OtroValor=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'ACT_COI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Enlazado [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'ENLAZADO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de documento enlazado [F] .: F=Facturas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'TIP_DOC_E';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de moneda', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'NUM_MONED';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de cambio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'TIPCAMB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de pagos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'NUM_PAGOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'FECHAELAB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Monto de primer pago', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'PRIMERPAGO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'RFC', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'RFC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Control de póliza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'CTLPOL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Es factura digital [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'ESCFD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'No. de autorización del CFD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'AUTORIZA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Serie', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'SERIE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Folio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'FOLIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Año de autorización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'AUTOANIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Datos de envío', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'DAT_ENVIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Pago de contado [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'CONTADO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de bitácora', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'CVE_BITA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Bloqueado [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'BLOQ';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Forma de envío del documento [I/C/A/null] .: I=Impresa, C=Correo, A=Impreso y Correo, null=Ninguno', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'FORMAENVIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Porcentaje de descuento financiero', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'DES_FIN_PORC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Porcentaje de descuento total', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'DES_TOT_PORC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Importe total', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'IMPORTE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Porcentaje de comision', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'COM_TOT_PORC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Método de pago', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'METODODEPAGO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de cuenta de pago', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'NUMCTAPAGO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de documento anterior [F] .: F=Factura', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'TIP_DOC_ANT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de documento anterior', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'DOC_ANT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de documento siguiente [null]', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'TIP_DOC_SIG';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de documento siguiente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'DOC_SIG';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'ID para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'UUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha y hora para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTA01', @level2type = N'COLUMN', @level2name = N'VERSION_SINC';

