CREATE TABLE [dbo].[INFENVIO01] (
    [CVE_INFO]      INT           NOT NULL,
    [CVE_CONS]      VARCHAR (10)  NULL,
    [NOMBRE]        VARCHAR (120) NULL,
    [CALLE]         VARCHAR (80)  NULL,
    [NUMINT]        VARCHAR (15)  NULL,
    [NUMEXT]        VARCHAR (15)  NULL,
    [CRUZAMIENTOS]  VARCHAR (40)  NULL,
    [CRUZAMIENTOS2] VARCHAR (40)  NULL,
    [POB]           VARCHAR (50)  NULL,
    [CURP]          VARCHAR (18)  NULL,
    [REFERDIR]      VARCHAR (255) NULL,
    [CVE_ZONA]      VARCHAR (6)   NULL,
    [CVE_OBS]       INT           NULL,
    [STRNOGUIA]     VARCHAR (22)  NULL,
    [STRMODOENV]    VARCHAR (20)  NULL,
    [FECHA_ENV]     DATETIME      NULL,
    [NOMBRE_RECEP]  VARCHAR (60)  NULL,
    [NO_RECEP]      VARCHAR (15)  NULL,
    [FECHA_RECEP]   DATETIME      NULL,
    [COLONIA]       VARCHAR (50)  NULL,
    [CODIGO]        VARCHAR (5)   NULL,
    [ESTADO]        VARCHAR (50)  NULL,
    [PAIS]          VARCHAR (50)  NULL,
    [MUNICIPIO]     VARCHAR (50)  NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_INF_ENVIO01]
    ON [dbo].[INFENVIO01]([CVE_INFO] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave información de envio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFENVIO01', @level2type = N'COLUMN', @level2name = N'CVE_INFO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de cliente consignatario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFENVIO01', @level2type = N'COLUMN', @level2name = N'CVE_CONS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nombre del cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFENVIO01', @level2type = N'COLUMN', @level2name = N'NOMBRE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Calle', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFENVIO01', @level2type = N'COLUMN', @level2name = N'CALLE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número interior', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFENVIO01', @level2type = N'COLUMN', @level2name = N'NUMINT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número exterior', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFENVIO01', @level2type = N'COLUMN', @level2name = N'NUMEXT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cruzamiento 1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFENVIO01', @level2type = N'COLUMN', @level2name = N'CRUZAMIENTOS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Cruzamiento 2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFENVIO01', @level2type = N'COLUMN', @level2name = N'CRUZAMIENTOS2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Población', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFENVIO01', @level2type = N'COLUMN', @level2name = N'POB';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'CURP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFENVIO01', @level2type = N'COLUMN', @level2name = N'CURP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Referencia de la dirección', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFENVIO01', @level2type = N'COLUMN', @level2name = N'REFERDIR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de zona del envío', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFENVIO01', @level2type = N'COLUMN', @level2name = N'CVE_ZONA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de observaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFENVIO01', @level2type = N'COLUMN', @level2name = N'CVE_OBS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFENVIO01', @level2type = N'COLUMN', @level2name = N'STRNOGUIA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Modo de envío', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFENVIO01', @level2type = N'COLUMN', @level2name = N'STRMODOENV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de envío', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFENVIO01', @level2type = N'COLUMN', @level2name = N'FECHA_ENV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Persona que recibe', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFENVIO01', @level2type = N'COLUMN', @level2name = N'NOMBRE_RECEP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de recepción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFENVIO01', @level2type = N'COLUMN', @level2name = N'NO_RECEP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de recepción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFENVIO01', @level2type = N'COLUMN', @level2name = N'FECHA_RECEP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Colonia de envio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFENVIO01', @level2type = N'COLUMN', @level2name = N'COLONIA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Código postal de envio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFENVIO01', @level2type = N'COLUMN', @level2name = N'CODIGO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estado de envio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFENVIO01', @level2type = N'COLUMN', @level2name = N'ESTADO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'País de envio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFENVIO01', @level2type = N'COLUMN', @level2name = N'PAIS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Municipio de envio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INFENVIO01', @level2type = N'COLUMN', @level2name = N'MUNICIPIO';

