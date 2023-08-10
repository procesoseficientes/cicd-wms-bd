CREATE TABLE [dbo].[PAGA_DET01] (
    [CVE_PROV]           VARCHAR (10) NULL,
    [REFER]              VARCHAR (20) NOT NULL,
    [NUM_CPTO]           INT          NOT NULL,
    [NUM_CARGO]          INT          NOT NULL,
    [ID_MOV]             INT          NULL,
    [CVE_FOLIO]          VARCHAR (9)  NULL,
    [CVE_OBS]            INT          NULL,
    [NO_FACTURA]         VARCHAR (20) NULL,
    [DOCTO]              VARCHAR (20) NULL,
    [IMPORTE]            FLOAT (53)   NULL,
    [FECHA_APLI]         DATETIME     NULL,
    [FECHA_VENC]         DATETIME     NULL,
    [AFEC_COI]           VARCHAR (1)  NULL,
    [NUM_MONED]          INT          NULL,
    [TCAMBIO]            FLOAT (53)   NULL,
    [IMPMON_EXT]         FLOAT (53)   NULL,
    [FECHAELAB]          DATETIME     NULL,
    [CTLPOL]             INT          NULL,
    [CVE_BITA]           INT          NULL,
    [TIPO_MOV]           VARCHAR (1)  NULL,
    [SIGNO]              INT          NULL,
    [CVE_AUT]            INT          NULL,
    [USUARIO]            SMALLINT     NULL,
    [REF_SIST]           VARCHAR (1)  NULL,
    [NO_PARTIDA]         INT          NOT NULL,
    [REFBANCO_ORIGEN]    VARCHAR (3)  NULL,
    [REFBANCO_DEST]      VARCHAR (3)  NULL,
    [NUMCTAPAGO_ORIGEN]  VARCHAR (16) NULL,
    [NUMCTAPAGO_DESTINO] VARCHAR (16) NULL,
    [NUMCHEQUE]          VARCHAR (20) NULL,
    [BENEFICIARIO]       VARCHAR (60) NULL,
    [CVE_DOC_COMPPAGO]   VARCHAR (20) NULL,
    [CVE_EXTERNA]        VARCHAR (20) NULL
);




GO
CREATE NONCLUSTERED INDEX [IDX_PAGA_DET01]
    ON [dbo].[PAGA_DET01]([CVE_PROV] ASC, [REFER] ASC, [NUM_CPTO] ASC, [NUM_CARGO] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_PAGA_DET_FOL01]
    ON [dbo].[PAGA_DET01]([CVE_FOLIO] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_PAGA_DET_REFER01]
    ON [dbo].[PAGA_DET01]([REFER] ASC);


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



GO



GO



GO



GO



GO


