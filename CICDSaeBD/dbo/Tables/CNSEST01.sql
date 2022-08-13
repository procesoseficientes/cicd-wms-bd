CREATE TABLE [dbo].[CNSEST01] (
    [CVE_ESTAD]        INT          NOT NULL,
    [TITULO]           VARCHAR (50) NULL,
    [USUARIO]          SMALLINT     NULL,
    [FECHA]            DATETIME     NULL,
    [TIPO]             VARCHAR (1)  NULL,
    [ARCHIVO]          VARCHAR (60) NULL,
    [VER_FILTRO]       VARCHAR (1)  NULL,
    [UUID]             VARCHAR (50) NULL,
    [VERSION_SINC]     DATETIME     NULL,
    [DISPONIBLE_MOVIL] VARCHAR (1)  NULL,
    CONSTRAINT [PK_CNSEST01] PRIMARY KEY CLUSTERED ([CVE_ESTAD] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de la estadística', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CNSEST01', @level2type = N'COLUMN', @level2name = N'CVE_ESTAD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Título de la estadística', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CNSEST01', @level2type = N'COLUMN', @level2name = N'TITULO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Usuario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CNSEST01', @level2type = N'COLUMN', @level2name = N'USUARIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de estadística', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CNSEST01', @level2type = N'COLUMN', @level2name = N'FECHA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de estadística [A/B/S/C/P/E/R/T/M/I] .: A=Acumluados de ventas, B=Acumulados de compras, S=Ventas, C=Clientes, P=Proveedores, E=Compras, R=Administración de clientes, T=Bitácora, M=Movimientos al inventario, I=Inventario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CNSEST01', @level2type = N'COLUMN', @level2name = N'TIPO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Archivo de estadística', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CNSEST01', @level2type = N'COLUMN', @level2name = N'ARCHIVO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Ver filtro [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CNSEST01', @level2type = N'COLUMN', @level2name = N'VER_FILTRO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'ID para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CNSEST01', @level2type = N'COLUMN', @level2name = N'UUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha y hora para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CNSEST01', @level2type = N'COLUMN', @level2name = N'VERSION_SINC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Disponible para sincronización con SAE Móvil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CNSEST01', @level2type = N'COLUMN', @level2name = N'DISPONIBLE_MOVIL';

