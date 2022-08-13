CREATE TABLE [dbo].[PAGOLINEA01] (
    [ID_OPERACION] VARCHAR (30) NOT NULL,
    [ID_CLIENTRAN] INT          NOT NULL,
    [AUTORIZA]     INT          NULL,
    [TARJETA]      VARCHAR (4)  NULL,
    [TIP_DOC]      VARCHAR (1)  NULL,
    [FECHA_OPER]   DATETIME     NULL,
    [ESTATUS]      VARCHAR (1)  NULL,
    [TIP_OPER]     VARCHAR (1)  NULL,
    [APLICADO]     VARCHAR (1)  NULL,
    [REFER]        VARCHAR (30) NULL,
    [MONTO]        FLOAT (53)   NULL,
    [NUM_CPTO]     INT          NULL,
    [PROVEEDOR]    VARCHAR (30) NULL,
    [XML_PL]       TEXT         NULL,
    CONSTRAINT [PK_PAGOLINEA01] PRIMARY KEY CLUSTERED ([ID_OPERACION] ASC, [ID_CLIENTRAN] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de operación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAGOLINEA01', @level2type = N'COLUMN', @level2name = N'ID_OPERACION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de transacción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAGOLINEA01', @level2type = N'COLUMN', @level2name = N'ID_CLIENTRAN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'AutoNumber', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAGOLINEA01', @level2type = N'COLUMN', @level2name = N'AUTORIZA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de tarjeta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAGOLINEA01', @level2type = N'COLUMN', @level2name = N'TARJETA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo del Documento [F/V] .: F=Facturas, V=Nota de  Venta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAGOLINEA01', @level2type = N'COLUMN', @level2name = N'TIP_DOC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de operación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAGOLINEA01', @level2type = N'COLUMN', @level2name = N'FECHA_OPER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estado de la operación [A/C/F/V] .: A=Aprobado, C=Cacelado, F=Finalizado, V=Verificado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAGOLINEA01', @level2type = N'COLUMN', @level2name = N'ESTATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de Operación [V/C] .: V=Venta, C=Cancelación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAGOLINEA01', @level2type = N'COLUMN', @level2name = N'TIP_OPER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Pago por aplicar [S/N] .: S=Si, N=No', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAGOLINEA01', @level2type = N'COLUMN', @level2name = N'APLICADO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Referencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAGOLINEA01', @level2type = N'COLUMN', @level2name = N'REFER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Monto de la operación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAGOLINEA01', @level2type = N'COLUMN', @level2name = N'MONTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Concepto de CXC', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAGOLINEA01', @level2type = N'COLUMN', @level2name = N'NUM_CPTO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Proveedor del pago', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAGOLINEA01', @level2type = N'COLUMN', @level2name = N'PROVEEDOR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'XML respuesta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PAGOLINEA01', @level2type = N'COLUMN', @level2name = N'XML_PL';

