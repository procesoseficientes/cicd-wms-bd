CREATE TABLE [dbo].[PARAM_DATOSEMP01] (
    [NUM_EMP]                 INT           NOT NULL,
    [NOMBRE_EMPRESA]          VARCHAR (240) NOT NULL,
    [DIRECCION]               VARCHAR (60)  NULL,
    [POBLACION]               VARCHAR (60)  NULL,
    [RFC]                     VARCHAR (30)  NULL,
    [REG_ESTATAL]             VARCHAR (30)  NULL,
    [LOGO_EMPRESA]            IMAGE         NULL,
    [ASIGNAVALPREDCVEPRODSAT] VARCHAR (1)   NULL,
    [VALPREDCVEPRODUCTOSAT]   VARCHAR (9)   NULL,
    [ASIGNAVALPREDUNIMEDSAT]  VARCHAR (1)   NULL,
    [VALPREDUNIMEDPRODSAT]    VARCHAR (4)   NULL,
    CONSTRAINT [PK_PARAM_DATOSEMP01] PRIMARY KEY CLUSTERED ([NUM_EMP] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de empresa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSEMP01', @level2type = N'COLUMN', @level2name = N'NUM_EMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nombre de la empresa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSEMP01', @level2type = N'COLUMN', @level2name = N'NOMBRE_EMPRESA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Dirección', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSEMP01', @level2type = N'COLUMN', @level2name = N'DIRECCION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Población', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSEMP01', @level2type = N'COLUMN', @level2name = N'POBLACION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'RFC', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSEMP01', @level2type = N'COLUMN', @level2name = N'RFC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Registro estatal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSEMP01', @level2type = N'COLUMN', @level2name = N'REG_ESTATAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Logo de la empresa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PARAM_DATOSEMP01', @level2type = N'COLUMN', @level2name = N'LOGO_EMPRESA';

