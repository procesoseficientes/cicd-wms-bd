CREATE TABLE [dbo].[INFCLI01] (
    [CVE_INFO]      INT           NOT NULL,
    [NOMBRE]        VARCHAR (120) NULL,
    [CALLE]         VARCHAR (80)  NULL,
    [NUMINT]        VARCHAR (15)  NULL,
    [NUMEXT]        VARCHAR (15)  NULL,
    [CRUZAMIENTOS]  VARCHAR (40)  NULL,
    [CRUZAMIENTOS2] VARCHAR (40)  NULL,
    [COLONIA]       VARCHAR (50)  NULL,
    [POB]           VARCHAR (50)  NULL,
    [CURP]          VARCHAR (18)  NULL,
    [CVE_ZONA]      VARCHAR (6)   NULL,
    [CVE_OBS]       INT           NULL,
    [REFERDIR]      VARCHAR (255) NULL,
    [CODIGO]        VARCHAR (5)   NULL,
    [ESTADO]        VARCHAR (50)  NULL,
    [PAIS]          VARCHAR (50)  NULL,
    [MUNICIPIO]     VARCHAR (50)  NULL,
    [RFC]           VARCHAR (15)  NULL,
    CONSTRAINT [PK_INFCLI01] PRIMARY KEY CLUSTERED ([CVE_INFO] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave información de cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFCLI01', @level2type = N'COLUMN', @level2name = N'CVE_INFO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nombre del cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFCLI01', @level2type = N'COLUMN', @level2name = N'NOMBRE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Calle', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFCLI01', @level2type = N'COLUMN', @level2name = N'CALLE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número Interior', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFCLI01', @level2type = N'COLUMN', @level2name = N'NUMINT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número Exterior', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFCLI01', @level2type = N'COLUMN', @level2name = N'NUMEXT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Entre calle 1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFCLI01', @level2type = N'COLUMN', @level2name = N'CRUZAMIENTOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Entre calle 2 ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFCLI01', @level2type = N'COLUMN', @level2name = N'CRUZAMIENTOS2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Colonia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFCLI01', @level2type = N'COLUMN', @level2name = N'COLONIA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Población', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFCLI01', @level2type = N'COLUMN', @level2name = N'POB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Curp', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFCLI01', @level2type = N'COLUMN', @level2name = N'CURP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Zona del envío', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFCLI01', @level2type = N'COLUMN', @level2name = N'CVE_ZONA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Observaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFCLI01', @level2type = N'COLUMN', @level2name = N'CVE_OBS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Referencia física de la dirección', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFCLI01', @level2type = N'COLUMN', @level2name = N'REFERDIR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Código postal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFCLI01', @level2type = N'COLUMN', @level2name = N'CODIGO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFCLI01', @level2type = N'COLUMN', @level2name = N'ESTADO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'País', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFCLI01', @level2type = N'COLUMN', @level2name = N'PAIS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Municipio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFCLI01', @level2type = N'COLUMN', @level2name = N'MUNICIPIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'RFC', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFCLI01', @level2type = N'COLUMN', @level2name = N'RFC';

