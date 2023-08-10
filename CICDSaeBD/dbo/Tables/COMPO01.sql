CREATE TABLE [dbo].[COMPO01] (
    [TIP_DOC]       VARCHAR (1)   NULL,
    [CVE_DOC]       VARCHAR (20)  NOT NULL,
    [CVE_CLPV]      VARCHAR (10)  NOT NULL,
    [STATUS]        VARCHAR (1)   NULL,
    [SU_REFER]      VARCHAR (20)  NULL,
    [FECHA_DOC]     DATETIME      NOT NULL,
    [FECHA_REC]     DATETIME      NULL,
    [FECHA_PAG]     DATETIME      NULL,
    [FECHA_CANCELA] DATETIME      NULL,
    [CAN_TOT]       FLOAT (53)    NULL,
    [IMP_TOT1]      FLOAT (53)    NULL,
    [IMP_TOT2]      FLOAT (53)    NULL,
    [IMP_TOT3]      FLOAT (53)    NULL,
    [IMP_TOT4]      FLOAT (53)    NULL,
    [DES_TOT]       FLOAT (53)    NULL,
    [DES_FIN]       FLOAT (53)    NULL,
    [TOT_IND]       FLOAT (53)    NULL,
    [OBS_COND]      VARCHAR (25)  NULL,
    [CVE_OBS]       INT           NULL,
    [NUM_ALMA]      INT           NULL,
    [ACT_CXP]       VARCHAR (1)   NULL,
    [ACT_COI]       VARCHAR (1)   NULL,
    [NUM_MONED]     INT           NULL,
    [TIPCAMB]       FLOAT (53)    NULL,
    [ENLAZADO]      VARCHAR (1)   NULL,
    [TIP_DOC_E]     VARCHAR (1)   NULL,
    [NUM_PAGOS]     INT           NULL,
    [FECHAELAB]     DATETIME      NULL,
    [SERIE]         VARCHAR (10)  NULL,
    [FOLIO]         INT           NULL,
    [CTLPOL]        INT           NULL,
    [ESCFD]         VARCHAR (1)   NULL,
    [CONTADO]       VARCHAR (1)   NULL,
    [BLOQ]          VARCHAR (1)   NULL,
    [DES_FIN_PORC]  FLOAT (53)    NULL,
    [DES_TOT_PORC]  FLOAT (53)    NULL,
    [IMPORTE]       FLOAT (53)    NULL,
    [TIP_DOC_ANT]   VARCHAR (1)   NULL,
    [DOC_ANT]       VARCHAR (20)  NULL,
    [TIP_DOC_SIG]   VARCHAR (1)   NULL,
    [DOC_SIG]       VARCHAR (20)  NULL,
    [FORMAENVIO]    VARCHAR (1)   NULL,
    [METODODEPAGO]  VARCHAR (255) NULL,
    CONSTRAINT [PK_COMPO01] PRIMARY KEY CLUSTERED ([CVE_DOC] ASC)
);




GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_COMPO_FECHA01]
    ON [dbo].[COMPO01]([FECHA_DOC] ASC, [CVE_DOC] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_COMPO_PROV01]
    ON [dbo].[COMPO01]([CVE_CLPV] ASC, [CVE_DOC] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_METODODEPAGO_O01]
    ON [dbo].[COMPO01]([METODODEPAGO] ASC);


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


