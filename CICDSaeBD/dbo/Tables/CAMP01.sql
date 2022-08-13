CREATE TABLE [dbo].[CAMP01] (
    [CVE_CAMPANIA] VARCHAR (5)  NOT NULL,
    [DESCRIP]      VARCHAR (30) NULL,
    [FILTRAR_AUTO] VARCHAR (1)  NULL,
    [LEYENDA]      VARCHAR (15) NULL,
    [STATUS]       VARCHAR (1)  NULL,
    [FECHAD]       DATETIME     NULL,
    [FECHAH]       DATETIME     NULL,
    [ORIGEN]       VARCHAR (1)  NULL,
    [TIPO]         VARCHAR (1)  NULL,
    CONSTRAINT [PK_CAMP01] PRIMARY KEY CLUSTERED ([CVE_CAMPANIA] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de campaña', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMP01', @level2type = N'COLUMN', @level2name = N'CVE_CAMPANIA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Descripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMP01', @level2type = N'COLUMN', @level2name = N'DESCRIP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Filtrar automáticamente [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMP01', @level2type = N'COLUMN', @level2name = N'FILTRAR_AUTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nombre', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMP01', @level2type = N'COLUMN', @level2name = N'LEYENDA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estado [A/C/P] .: A=Activo, C=Inactiva, P=En proceso ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMP01', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha inicial', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMP01', @level2type = N'COLUMN', @level2name = N'FECHAD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha final', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMP01', @level2type = N'COLUMN', @level2name = N'FECHAH';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Origen [U] .: U=Campaña de usuario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMP01', @level2type = N'COLUMN', @level2name = N'ORIGEN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo [S/V/T/C/P/I/O] .: S=Seguimiento, V=Ventas, T=Telemarketing, C=Cobranza, P=Publicidad, I=Interna, O=Otras campañas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CAMP01', @level2type = N'COLUMN', @level2name = N'TIPO';

