CREATE TABLE [dbo].[FOLIOSWMS] (
    [Id]            INT          IDENTITY (1, 1) NOT NULL,
    [Folio]         VARCHAR (50) NULL,
    [Clasificacion] VARCHAR (50) NULL,
    [Bodega]        INT          NULL,
    [Tipo]          VARCHAR (5)  NULL,
    CONSTRAINT [PK_FOLIOSWMS] PRIMARY KEY CLUSTERED ([Id] ASC)
);

