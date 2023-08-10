CREATE TABLE [dbo].[CONC01] (
    [NUM_CPTO]       INT          NOT NULL,
    [DESCR]          VARCHAR (17) NULL,
    [TIPO]           VARCHAR (1)  NULL,
    [CUEN_CONT]      VARCHAR (28) NULL,
    [CON_REFER]      VARCHAR (1)  NULL,
    [GEN_CPTO]       INT          NULL,
    [AUTORIZACION]   VARCHAR (1)  NULL,
    [SIGNO]          SMALLINT     NULL,
    [ES_FMA_PAG]     VARCHAR (1)  NULL,
    [CVE_BITA]       INT          NULL,
    [STATUS]         VARCHAR (1)  NULL,
    [ENLINEA]        SMALLINT     DEFAULT ((-1)) NULL,
    [DAR_CAMBIO]     VARCHAR (1)  NULL,
    [UUID]           VARCHAR (50) NULL,
    [FORMADEPAGOSAT] VARCHAR (5)  NULL,
    [VERSION_SINC]   DATETIME     NULL,
    [CONFIG_CODI]    VARCHAR (1)  NULL,
    CONSTRAINT [PK_CONC01] PRIMARY KEY CLUSTERED ([NUM_CPTO] ASC)
);




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


