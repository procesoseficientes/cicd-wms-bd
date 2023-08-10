CREATE TABLE [dbo].[PAGOCODI01] (
    [IDMENSAJE]          VARCHAR (20) NOT NULL,
    [NUMCLI]             VARCHAR (10) NULL,
    [CVE_CLIE]           VARCHAR (10) NULL,
    [REFER]              VARCHAR (20) NULL,
    [ID_MOV]             INT          NULL,
    [NUM_CPTO]           INT          NULL,
    [NUM_CARGO]          INT          NULL,
    [ESTADO]             INT          NULL,
    [METODO]             VARCHAR (1)  NULL,
    [MONTO]              FLOAT (53)   NULL,
    [FOLIO]              VARCHAR (20) NULL,
    [USADO]              VARCHAR (1)  NULL,
    [FECHA]              DATETIME     NULL,
    [FECHA_MODIFICACION] DATETIME     NULL,
    CONSTRAINT [PK_PAGOCODI01] PRIMARY KEY CLUSTERED ([IDMENSAJE] ASC)
);

