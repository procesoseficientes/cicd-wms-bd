CREATE TABLE [dbo].[ajuste_inventario] (
    [id]            NUMERIC (18)    NOT NULL,
    [material_id]   NCHAR (50)      NOT NULL,
    [type_]         NCHAR (10)      NOT NULL,
    [qty]           NUMERIC (18, 6) NOT NULL,
    [wharehouse_id] NCHAR (50)      NULL,
    [state_]        NCHAR (10)      NULL
);

