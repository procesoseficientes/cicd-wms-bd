CREATE TABLE [dbo].[POLI01] (
    [CVE_POLIT]    INT          NOT NULL,
    [DESCR]        VARCHAR (60) NULL,
    [ST]           VARCHAR (1)  NULL,
    [CVE_INI]      VARCHAR (16) NULL,
    [CVE_FIN]      VARCHAR (16) NULL,
    [LIN_PROD]     VARCHAR (5)  NULL,
    [VOL_MIN]      FLOAT (53)   NULL,
    [CLIE_D]       VARCHAR (10) NULL,
    [CLIE_H]       VARCHAR (10) NULL,
    [CLAS_CLIE]    VARCHAR (5)  NULL,
    [V_DFECH]      DATETIME     NULL,
    [V_HFECH]      DATETIME     NULL,
    [T_POL]        VARCHAR (1)  NULL,
    [PRC_MON]      VARCHAR (1)  NULL,
    [LISTA_PREC]   INT          NULL,
    [VAL]          FLOAT (53)   NULL,
    [LIMUNIVTA]    FLOAT (53)   NULL,
    [NUMUNIVEN]    FLOAT (53)   NULL,
    [CVE_ZONA]     VARCHAR (6)  NULL,
    [CVE_ALM]      INT          NULL,
    [DEBAJO_MIN]   VARCHAR (1)  NULL,
    [UUID]         VARCHAR (50) NULL,
    [VERSION_SINC] DATETIME     NULL,
    CONSTRAINT [PK_POLI01] PRIMARY KEY CLUSTERED ([CVE_POLIT] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de la política', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POLI01', @level2type = N'COLUMN', @level2name = N'CVE_POLIT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Descripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POLI01', @level2type = N'COLUMN', @level2name = N'DESCR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus [A/I/C] .: A=Activa, I=Inactiva, C=Cancelada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POLI01', @level2type = N'COLUMN', @level2name = N'ST';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de Producto inicial', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POLI01', @level2type = N'COLUMN', @level2name = N'CVE_INI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de Producto final', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POLI01', @level2type = N'COLUMN', @level2name = N'CVE_FIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de línea', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POLI01', @level2type = N'COLUMN', @level2name = N'LIN_PROD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Volumen mínimo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POLI01', @level2type = N'COLUMN', @level2name = N'VOL_MIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de cliente inicial', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POLI01', @level2type = N'COLUMN', @level2name = N'CLIE_D';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de cliente final', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POLI01', @level2type = N'COLUMN', @level2name = N'CLIE_H';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clasificación de cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POLI01', @level2type = N'COLUMN', @level2name = N'CLAS_CLIE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de vigencia inicial', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POLI01', @level2type = N'COLUMN', @level2name = N'V_DFECH';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de vigencia final', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POLI01', @level2type = N'COLUMN', @level2name = N'V_HFECH';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de póliza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POLI01', @level2type = N'COLUMN', @level2name = N'T_POL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de descuento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POLI01', @level2type = N'COLUMN', @level2name = N'PRC_MON';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de lista de precios', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POLI01', @level2type = N'COLUMN', @level2name = N'LISTA_PREC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Valor de descuento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POLI01', @level2type = N'COLUMN', @level2name = N'VAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cantidad máxima', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POLI01', @level2type = N'COLUMN', @level2name = N'LIMUNIVTA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Numero de unidades vendidas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POLI01', @level2type = N'COLUMN', @level2name = N'NUMUNIVEN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de zona del cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POLI01', @level2type = N'COLUMN', @level2name = N'CVE_ZONA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de almacén', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POLI01', @level2type = N'COLUMN', @level2name = N'CVE_ALM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Por debajo del mínimo [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POLI01', @level2type = N'COLUMN', @level2name = N'DEBAJO_MIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'ID para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POLI01', @level2type = N'COLUMN', @level2name = N'UUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha y hora para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POLI01', @level2type = N'COLUMN', @level2name = N'VERSION_SINC';

