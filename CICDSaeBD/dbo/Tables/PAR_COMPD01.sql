CREATE TABLE [dbo].[PAR_COMPD01] (
    [CVE_DOC]      VARCHAR (20) NOT NULL,
    [NUM_PAR]      INT          NOT NULL,
    [CVE_ART]      VARCHAR (16) NULL,
    [CANT]         FLOAT (53)   NULL,
    [PXR]          FLOAT (53)   NULL,
    [PREC]         FLOAT (53)   NULL,
    [COST]         FLOAT (53)   NULL,
    [IMPU1]        FLOAT (53)   NULL,
    [IMPU2]        FLOAT (53)   NULL,
    [IMPU3]        FLOAT (53)   NULL,
    [IMPU4]        FLOAT (53)   NULL,
    [IMP1APLA]     SMALLINT     NULL,
    [IMP2APLA]     SMALLINT     NULL,
    [IMP3APLA]     SMALLINT     NULL,
    [IMP4APLA]     SMALLINT     NULL,
    [TOTIMP1]      FLOAT (53)   NULL,
    [TOTIMP2]      FLOAT (53)   NULL,
    [TOTIMP3]      FLOAT (53)   NULL,
    [TOTIMP4]      FLOAT (53)   NULL,
    [DESCU]        FLOAT (53)   NULL,
    [ACT_INV]      VARCHAR (1)  NULL,
    [TIP_CAM]      FLOAT (53)   NULL,
    [UNI_VENTA]    VARCHAR (10) NULL,
    [TIPO_ELEM]    VARCHAR (1)  NULL,
    [TIPO_PROD]    VARCHAR (1)  NULL,
    [CVE_OBS]      INT          NULL,
    [REG_SERIE]    INT          NULL,
    [E_LTPD]       INT          NULL,
    [FACTCONV]     FLOAT (53)   NULL,
    [COST_DEV]     FLOAT (53)   NULL,
    [NUM_ALM]      INT          NULL,
    [MINDIRECTO]   FLOAT (53)   NULL,
    [NUM_MOV]      INT          NULL,
    [TOT_PARTIDA]  FLOAT (53)   NULL,
    [MAN_IEPS]     VARCHAR (1)  NULL,
    [APL_MAN_IMP]  INT          NULL,
    [CUOTA_IEPS]   FLOAT (53)   NULL,
    [APL_MAN_IEPS] VARCHAR (1)  NULL,
    [MTO_PORC]     FLOAT (53)   NULL,
    [MTO_CUOTA]    FLOAT (53)   NULL,
    [CVE_ESQ]      INT          NULL,
    [DESCR_ART]    VARCHAR (40) NULL,
    CONSTRAINT [PK_PAR_COMPD01] PRIMARY KEY CLUSTERED ([CVE_DOC] ASC, [NUM_PAR] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IDX_PAR_DOC_CD01]
    ON [dbo].[PAR_COMPD01]([CVE_DOC] ASC);


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


