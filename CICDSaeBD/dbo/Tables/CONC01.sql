CREATE TABLE [dbo].[CONC01] (
    [NUM_CPTO]       INT          NOT NULL,
    [DESCR]          VARCHAR (17) NULL,
    [TIPO]           VARCHAR (1)  NULL,
    [CUEN_CONT]      VARCHAR (28) NULL,
    [CON_REFER]      VARCHAR (1)  NULL,
    [GEN_CPTO]       INT          NULL,
    [AUTORIZACION]   VARCHAR (1)  NULL,
    [SIGNO]          SMALLINT     NULL,
    [ES_FMA_PAG]     VARCHAR (1)  NULL,
    [CVE_BITA]       INT          NULL,
    [STATUS]         VARCHAR (1)  NULL,
    [ENLINEA]        SMALLINT     DEFAULT ((-1)) NULL,
    [DAR_CAMBIO]     VARCHAR (1)  NULL,
    [UUID]           VARCHAR (50) NULL,
    [VERSION_SINC]   DATETIME     NULL,
    [FORMADEPAGOSAT] VARCHAR (5)  NULL,
    CONSTRAINT [PK_CONC01] PRIMARY KEY CLUSTERED ([NUM_CPTO] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de concepto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONC01', @level2type = N'COLUMN', @level2name = N'NUM_CPTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Descripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONC01', @level2type = N'COLUMN', @level2name = N'DESCR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de concepto [C/A] .: C=Cargo, A=Abono', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONC01', @level2type = N'COLUMN', @level2name = N'TIPO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cuenta contable', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONC01', @level2type = N'COLUMN', @level2name = N'CUEN_CONT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Con referencia [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONC01', @level2type = N'COLUMN', @level2name = N'CON_REFER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Genera concepto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONC01', @level2type = N'COLUMN', @level2name = N'GEN_CPTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Autorización [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONC01', @level2type = N'COLUMN', @level2name = N'AUTORIZACION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Signo [1/-1]', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONC01', @level2type = N'COLUMN', @level2name = N'SIGNO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Es forma de pago [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONC01', @level2type = N'COLUMN', @level2name = N'ES_FMA_PAG';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de bitácora', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONC01', @level2type = N'COLUMN', @level2name = N'CVE_BITA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus [A/B] .: A=Activo, B=Baja', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONC01', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'En línea [-1]', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONC01', @level2type = N'COLUMN', @level2name = N'ENLINEA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Dar cambio [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONC01', @level2type = N'COLUMN', @level2name = N'DAR_CAMBIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'ID para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONC01', @level2type = N'COLUMN', @level2name = N'UUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha y hora para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONC01', @level2type = N'COLUMN', @level2name = N'VERSION_SINC';

