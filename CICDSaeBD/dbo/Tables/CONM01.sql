CREATE TABLE [dbo].[CONM01] (
    [CVE_CPTO]  INT          NOT NULL,
    [DESCR]     VARCHAR (18) NULL,
    [CPN]       VARCHAR (1)  NULL,
    [CUEN_CONT] VARCHAR (28) NULL,
    [TIPO_MOV]  VARCHAR (1)  NULL,
    [STATUS]    VARCHAR (1)  NULL,
    [SIGNO]     SMALLINT     NULL,
    CONSTRAINT [PK_CONM01] PRIMARY KEY CLUSTERED ([CVE_CPTO] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de concepto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONM01', @level2type = N'COLUMN', @level2name = N'CVE_CPTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Descripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONM01', @level2type = N'COLUMN', @level2name = N'DESCR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Asociado a [C/P/N] .: C = Cliente, P = Proveedor, N = Ninguno', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONM01', @level2type = N'COLUMN', @level2name = N'CPN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cuenta contable', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONM01', @level2type = N'COLUMN', @level2name = N'CUEN_CONT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de movimiento [E/S] .: E = Entreda, S = Salida', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONM01', @level2type = N'COLUMN', @level2name = N'TIPO_MOV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus [A/B] .: A=Activo, B=Baja ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONM01', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Signo [1/-1]', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CONM01', @level2type = N'COLUMN', @level2name = N'SIGNO';

