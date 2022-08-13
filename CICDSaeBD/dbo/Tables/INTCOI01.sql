CREATE TABLE [dbo].[INTCOI01] (
    [CVE_INTCOI] INT           NOT NULL,
    [TRANSACCIO] INT           NULL,
    [TIPOPOL]    VARCHAR (2)   NULL,
    [NUMPOL]     VARCHAR (5)   NULL,
    [FECHAPOL]   DATETIME      NULL,
    [FECHAOPR]   DATETIME      NULL,
    [SISTEMA]    VARCHAR (15)  NULL,
    [NUMUSR]     SMALLINT      NULL,
    [OPERACION]  INT           NULL,
    [STATUS]     INT           NULL,
    [TIPPOLINT]  VARCHAR (1)   NULL,
    [POLMODELO]  VARCHAR (255) NULL,
    [CTLPOL]     INT           NULL,
    [STATUSCLI]  VARCHAR (1)   NULL,
    CONSTRAINT [PK_INTCOI01] PRIMARY KEY CLUSTERED ([CVE_INTCOI] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de la interfaz con COI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INTCOI01', @level2type = N'COLUMN', @level2name = N'CVE_INTCOI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de transacción en COI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INTCOI01', @level2type = N'COLUMN', @level2name = N'TRANSACCIO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de póliza en COI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INTCOI01', @level2type = N'COLUMN', @level2name = N'TIPOPOL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de póliza en COI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INTCOI01', @level2type = N'COLUMN', @level2name = N'NUMPOL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de póliza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INTCOI01', @level2type = N'COLUMN', @level2name = N'FECHAPOL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha de operación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INTCOI01', @level2type = N'COLUMN', @level2name = N'FECHAOPR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nombre del cliente a COI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INTCOI01', @level2type = N'COLUMN', @level2name = N'SISTEMA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Número de usuario ASPEL', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INTCOI01', @level2type = N'COLUMN', @level2name = N'NUMUSR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Operación en COI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INTCOI01', @level2type = N'COLUMN', @level2name = N'OPERACION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus en COI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INTCOI01', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de póliza [V/D/C/d/c/P/M/S] .: V=Ventas, D=Devoluciones de ventas, C=Compras, d=Devoluciones de compras, c=Cuentas por cobras, P=Cuentas por pagar, M=Movimientos al inventario, S=Costos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INTCOI01', @level2type = N'COLUMN', @level2name = N'TIPPOLINT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nombre de la póliza modelo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INTCOI01', @level2type = N'COLUMN', @level2name = N'POLMODELO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Control de póliza en SAE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INTCOI01', @level2type = N'COLUMN', @level2name = N'CTLPOL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus en SAE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'INTCOI01', @level2type = N'COLUMN', @level2name = N'STATUSCLI';

