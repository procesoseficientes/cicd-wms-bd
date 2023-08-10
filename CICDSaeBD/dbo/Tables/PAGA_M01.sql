CREATE TABLE [dbo].[PAGA_M01] (
    [CVE_PROV]      VARCHAR (10) NOT NULL,
    [REFER]         VARCHAR (20) NOT NULL,
    [NUM_CARGO]     INT          NOT NULL,
    [NUM_CPTO]      INT          NOT NULL,
    [CVE_FOLIO]     VARCHAR (9)  NULL,
    [CVE_OBS]       INT          NULL,
    [NO_FACTURA]    VARCHAR (20) NULL,
    [DOCTO]         VARCHAR (20) NULL,
    [IMPORTE]       FLOAT (53)   NULL,
    [FECHA_APLI]    DATETIME     NULL,
    [FECHA_VENC]    DATETIME     NULL,
    [AFEC_COI]      VARCHAR (1)  NULL,
    [NUM_MONED]     INT          NULL,
    [TCAMBIO]       FLOAT (53)   NULL,
    [IMPMON_EXT]    FLOAT (53)   NULL,
    [FECHAELAB]     DATETIME     NULL,
    [CTLPOL]        INT          NULL,
    [TIPO_MOV]      VARCHAR (1)  NULL,
    [CVE_BITA]      INT          NULL,
    [SIGNO]         INT          NULL,
    [CVE_AUT]       INT          NULL,
    [USUARIO]       SMALLINT     NULL,
    [ENTREGADA]     VARCHAR (1)  NULL,
    [FECHA_ENTREGA] DATETIME     NULL,
    [REF_SIST]      VARCHAR (1)  NULL,
    [STATUS]        VARCHAR (1)  NULL,
    CONSTRAINT [PK_PAGA_M01] PRIMARY KEY CLUSTERED ([CVE_PROV] ASC, [REFER] ASC, [NUM_CPTO] ASC, [NUM_CARGO] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IDX_PAGAM_FOL01]
    ON [dbo].[PAGA_M01]([CVE_FOLIO] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_PAGAM_REFER01]
    ON [dbo].[PAGA_M01]([REFER] ASC);


GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO


