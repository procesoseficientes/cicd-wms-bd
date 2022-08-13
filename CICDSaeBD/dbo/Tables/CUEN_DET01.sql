CREATE TABLE [dbo].[CUEN_DET01] (
    [CVE_CLIE]           VARCHAR (10) NOT NULL,
    [REFER]              VARCHAR (20) NOT NULL,
    [ID_MOV]             INT          NOT NULL,
    [NUM_CPTO]           INT          NULL,
    [NUM_CARGO]          INT          NOT NULL,
    [CVE_OBS]            INT          NULL,
    [NO_FACTURA]         VARCHAR (20) NULL,
    [DOCTO]              VARCHAR (20) NULL,
    [IMPORTE]            FLOAT (53)   NULL,
    [FECHA_APLI]         DATETIME     NULL,
    [FECHA_VENC]         DATETIME     NULL,
    [AFEC_COI]           VARCHAR (1)  NULL,
    [STRCVEVEND]         VARCHAR (5)  NULL,
    [NUM_MONED]          INT          NULL,
    [TCAMBIO]            FLOAT (53)   NULL,
    [IMPMON_EXT]         FLOAT (53)   NULL,
    [FECHAELAB]          DATETIME     NULL,
    [CTLPOL]             INT          NULL,
    [CVE_FOLIO]          VARCHAR (9)  NULL,
    [TIPO_MOV]           VARCHAR (1)  NULL,
    [CVE_BITA]           INT          NULL,
    [SIGNO]              INT          NULL,
    [CVE_AUT]            INT          NULL,
    [USUARIO]            SMALLINT     NULL,
    [OPERACIONPL]        VARCHAR (13) NULL,
    [REF_SIST]           VARCHAR (1)  NULL,
    [NO_PARTIDA]         INT          NOT NULL,
    [REFBANCO_ORIGEN]    VARCHAR (3)  NULL,
    [REFBANCO_DEST]      VARCHAR (3)  NULL,
    [NUMCTAPAGO_ORIGEN]  VARCHAR (16) NULL,
    [NUMCTAPAGO_DESTINO] VARCHAR (16) NULL,
    [NUMCHEQUE]          VARCHAR (20) NULL,
    [BENEFICIARIO]       VARCHAR (60) NULL,
    [UUID]               VARCHAR (50) NULL,
    [VERSION_SINC]       DATETIME     NULL,
    [ID_OPERACION]       VARCHAR (30) NULL,
    [CVE_DOC_COMPPAGO]   VARCHAR (20) NULL
);


GO
CREATE NONCLUSTERED INDEX [IDX_CUEN_DET01]
    ON [dbo].[CUEN_DET01]([CVE_CLIE] ASC, [REFER] ASC, [ID_MOV] ASC, [NUM_CARGO] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_CUEN_DET_FOL01]
    ON [dbo].[CUEN_DET01]([CVE_FOLIO] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_CUEN_DET_REFER01]
    ON [dbo].[CUEN_DET01]([REFER] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'CVE_CLIE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Referencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'REFER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de movimiento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'ID_MOV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de concepto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'NUM_CPTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de cargo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'NUM_CARGO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de observaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'CVE_OBS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de factura', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'NO_FACTURA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'DOCTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Importe', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'IMPORTE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de aplicación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'FECHA_APLI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de vencimiento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'FECHA_VENC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Afecta a COI [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'AFEC_COI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de vendedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'STRCVEVEND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de moneda', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'NUM_MONED';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de cambio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'TCAMBIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Importe en moneda extranjera', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'IMPMON_EXT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de elaboración', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'FECHAELAB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Control de póliza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'CTLPOL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de folio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'CVE_FOLIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de movimiento [C/A] .: C=Cargo, A=Abono', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'TIPO_MOV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de bitácora', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'CVE_BITA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Signo [1/-1]', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'SIGNO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de autorización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'CVE_AUT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de usuario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'USUARIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Operación por Internet', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'OPERACIONPL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Referencia del sistema origen [B] .: B=Banco', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'REF_SIST';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'NO_PARTIDA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Referencia banco origen', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'REFBANCO_ORIGEN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Referencia banco destino', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'REFBANCO_DEST';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de cuenta origen', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'NUMCTAPAGO_ORIGEN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de cuenta destino', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'NUMCTAPAGO_DESTINO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de cheque', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'NUMCHEQUE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Beneficiario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'BENEFICIARIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'ID para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'UUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha y hora para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CUEN_DET01', @level2type = N'COLUMN', @level2name = N'VERSION_SINC';

