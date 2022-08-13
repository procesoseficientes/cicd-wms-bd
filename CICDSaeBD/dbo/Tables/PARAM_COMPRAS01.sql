CREATE TABLE [dbo].[PARAM_COMPRAS01] (
    [NUM_EMP]                 INT          NOT NULL,
    [ACUMCOMPVTASENLINEA]     VARCHAR (1)  NULL,
    [ALTACLIEPROVENCAPTURA]   VARCHAR (1)  NULL,
    [ALTAPRODENCAPTURA]       VARCHAR (1)  NULL,
    [NUMCPTOCOMPVTASPLAZOS]   INT          NULL,
    [NUMCPTOINTXCOMPVTAPLAZO] INT          NULL,
    [NUMCPTORETCLIEPROV]      INT          NULL,
    [NUMIMPUESTO]             INT          NULL,
    [MANEJOFLETE]             VARCHAR (1)  NULL,
    [MONTOFLETE]              FLOAT (53)   NULL,
    [IMPFLETE]                FLOAT (53)   NULL,
    [FCHCIERREDOCTOS]         DATETIME     NULL,
    [ACUMULARINDCXP]          INT          NULL,
    [MODULO]                  VARCHAR (20) NULL,
    [MODIFICARALMACEN]        VARCHAR (1)  NULL,
    [REGISTROPAGOSCOMP]       VARCHAR (1)  NULL,
    [POLIZASENLINEACOMP]      VARCHAR (1)  NULL,
    [POLIZASENLINEACOMPDEVOL] VARCHAR (1)  NULL,
    [POLIZAAGRUPCOMP]         INT          NULL,
    [POLIZAAGRUPCOMPDEVOL]    INT          NULL,
    CONSTRAINT [PK_PARAM_COMPRAS01] PRIMARY KEY CLUSTERED ([NUM_EMP] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de empresa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_COMPRAS01', @level2type = N'COLUMN', @level2name = N'NUM_EMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_COMPRAS01', @level2type = N'COLUMN', @level2name = N'ACUMCOMPVTASENLINEA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_COMPRAS01', @level2type = N'COLUMN', @level2name = N'ALTACLIEPROVENCAPTURA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_COMPRAS01', @level2type = N'COLUMN', @level2name = N'ALTAPRODENCAPTURA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_COMPRAS01', @level2type = N'COLUMN', @level2name = N'NUMCPTOCOMPVTASPLAZOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_COMPRAS01', @level2type = N'COLUMN', @level2name = N'NUMCPTOINTXCOMPVTAPLAZO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_COMPRAS01', @level2type = N'COLUMN', @level2name = N'NUMCPTORETCLIEPROV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_COMPRAS01', @level2type = N'COLUMN', @level2name = N'NUMIMPUESTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_COMPRAS01', @level2type = N'COLUMN', @level2name = N'MANEJOFLETE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_COMPRAS01', @level2type = N'COLUMN', @level2name = N'MONTOFLETE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_COMPRAS01', @level2type = N'COLUMN', @level2name = N'IMPFLETE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_COMPRAS01', @level2type = N'COLUMN', @level2name = N'FCHCIERREDOCTOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_COMPRAS01', @level2type = N'COLUMN', @level2name = N'ACUMULARINDCXP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_COMPRAS01', @level2type = N'COLUMN', @level2name = N'MODULO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_COMPRAS01', @level2type = N'COLUMN', @level2name = N'MODIFICARALMACEN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_COMPRAS01', @level2type = N'COLUMN', @level2name = N'REGISTROPAGOSCOMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_COMPRAS01', @level2type = N'COLUMN', @level2name = N'POLIZASENLINEACOMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_COMPRAS01', @level2type = N'COLUMN', @level2name = N'POLIZASENLINEACOMPDEVOL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_COMPRAS01', @level2type = N'COLUMN', @level2name = N'POLIZAAGRUPCOMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = '', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_COMPRAS01', @level2type = N'COLUMN', @level2name = N'POLIZAAGRUPCOMPDEVOL';

