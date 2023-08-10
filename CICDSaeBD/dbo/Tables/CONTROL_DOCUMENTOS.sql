CREATE TABLE [dbo].[CONTROL_DOCUMENTOS] (
    [Id]                  INT          IDENTITY (1, 1) NOT NULL,
    [TipoDocumento]       VARCHAR (20) NULL,
    [FolioInicial]        VARCHAR (20) NULL,
    [FolioFinal]          VARCHAR (20) NULL,
    [Serie]               VARCHAR (50) NULL,
    [Anio]                INT          NULL,
    [UltimoDocumento]     VARCHAR (20) NULL,
    [Estado]              INT          NULL,
    [FechaLimiteEmision]  DATE         NULL,
    [CreadoPor]           VARCHAR (50) NULL,
    [FechaCreacion]       DATETIME     NULL,
    [EditadoPor]          VARCHAR (50) NULL,
    [FechaEdicion]        DATETIME     NULL,
    [CodigoAprobacionSAR] VARCHAR (50) NULL,
    [Empresa]             VARCHAR (50) NULL,
    [CAI]                 VARCHAR (50) NULL,
    [FechaBaja]           DATETIME     NULL
);

