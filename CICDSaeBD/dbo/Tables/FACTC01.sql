CREATE TABLE [dbo].[FACTC01] (
    [TIP_DOC]        VARCHAR (1)   NULL,
    [CVE_DOC]        VARCHAR (20)  NOT NULL,
    [CVE_CLPV]       VARCHAR (10)  NOT NULL,
    [STATUS]         VARCHAR (1)   NOT NULL,
    [CVE_PEDI]       VARCHAR (20)  NULL,
    [FECHA_DOC]      DATETIME      NOT NULL,
    [FECHA_ENT]      DATETIME      NULL,
    [FECHA_VEN]      DATETIME      NULL,
    [IMP_TOT1]       FLOAT (53)    NULL,
    [IMP_TOT2]       FLOAT (53)    NULL,
    [IMP_TOT3]       FLOAT (53)    NULL,
    [IMP_TOT4]       FLOAT (53)    NULL,
    [DES_FIN]        FLOAT (53)    NULL,
    [COM_TOT]        FLOAT (53)    NULL,
    [NUM_MONED]      INT           NULL,
    [TIPCAMB]        FLOAT (53)    NULL,
    [PRIMERPAGO]     FLOAT (53)    NULL,
    [RFC]            VARCHAR (15)  NULL,
    [AUTORIZA]       INT           NULL,
    [FOLIO]          INT           NULL,
    [SERIE]          VARCHAR (10)  NULL,
    [AUTOANIO]       VARCHAR (4)   NULL,
    [ESCFD]          VARCHAR (1)   NULL,
    [NUM_ALMA]       INT           NULL,
    [ACT_CXC]        VARCHAR (1)   NULL,
    [ACT_COI]        VARCHAR (1)   NULL,
    [CAN_TOT]        FLOAT (53)    NULL,
    [CVE_VEND]       VARCHAR (5)   NULL,
    [FECHA_CANCELA]  DATETIME      NULL,
    [DES_TOT]        FLOAT (53)    NULL,
    [CONDICION]      VARCHAR (25)  NULL,
    [NUM_PAGOS]      INT           NULL,
    [DAT_ENVIO]      INT           NULL,
    [CONTADO]        VARCHAR (1)   NULL,
    [DAT_MOSTR]      INT           NULL,
    [CVE_BITA]       INT           NULL,
    [BLOQ]           VARCHAR (1)   NULL,
    [FECHAELAB]      DATETIME      NULL,
    [CTLPOL]         INT           NULL,
    [CVE_OBS]        INT           NULL,
    [ENLAZADO]       VARCHAR (1)   NULL,
    [TIP_DOC_E]      VARCHAR (1)   NULL,
    [FORMAENVIO]     VARCHAR (1)   NULL,
    [DES_FIN_PORC]   FLOAT (53)    NULL,
    [DES_TOT_PORC]   FLOAT (53)    NULL,
    [IMPORTE]        FLOAT (53)    NULL,
    [COM_TOT_PORC]   FLOAT (53)    NULL,
    [METODODEPAGO]   VARCHAR (255) NULL,
    [NUMCTAPAGO]     VARCHAR (255) NULL,
    [TIP_DOC_ANT]    VARCHAR (1)   NULL,
    [DOC_ANT]        VARCHAR (20)  NULL,
    [TIP_DOC_SIG]    VARCHAR (1)   NULL,
    [DOC_SIG]        VARCHAR (20)  NULL,
    [UUID]           VARCHAR (50)  NULL,
    [VERSION_SINC]   DATETIME      NULL,
    [FORMADEPAGOSAT] VARCHAR (5)   NULL,
    [USO_CFDI]       VARCHAR (5)   NULL,
    [NUM_ALM_DES]    INT           NULL,
    [TIP_TRASLADO]   VARCHAR (1)   NULL,
    CONSTRAINT [PK_FACTC01] PRIMARY KEY CLUSTERED ([CVE_DOC] ASC)
);




GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_FACTC_CLIE01]
    ON [dbo].[FACTC01]([CVE_CLPV] ASC, [CVE_DOC] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_FACTC_FECHA01]
    ON [dbo].[FACTC01]([FECHA_DOC] ASC, [CVE_DOC] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX1_FACTC01]
    ON [dbo].[FACTC01]([SERIE] ASC, [DAT_MOSTR] ASC);


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
CREATE NONCLUSTERED INDEX [IDX_CVEPEDI_STATUS_C01]
    ON [dbo].[FACTC01]([CVE_PEDI] ASC, [STATUS] ASC);

