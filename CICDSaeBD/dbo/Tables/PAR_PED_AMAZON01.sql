CREATE TABLE [dbo].[PAR_PED_AMAZON01] (
    [CVE_DOC]         VARCHAR (30)  NOT NULL,
    [NUM_PAR]         INT           NOT NULL,
    [CVE_PAR]         VARCHAR (30)  NULL,
    [ASIN]            VARCHAR (20)  NULL,
    [SKU_AM]          VARCHAR (16)  NULL,
    [TITULO]          VARCHAR (50)  NULL,
    [CANT]            INT           NULL,
    [CANT_ENVIADA]    INT           NULL,
    [PREC]            FLOAT (53)    NULL,
    [CVE_MONED]       VARCHAR (5)   NULL,
    [CVE_MONED_ENV]   VARCHAR (5)   NULL,
    [COST_ENVIO]      FLOAT (53)    NULL,
    [ES_REGALO]       VARCHAR (1)   NULL,
    [MSG_REGALO]      VARCHAR (255) NULL,
    [CVE_MONED_REGA]  VARCHAR (5)   NULL,
    [COST_REGALO]     FLOAT (53)    NULL,
    [TIPO_ENVOLTURA]  VARCHAR (1)   NULL,
    [CVE_MONED_DESCU] VARCHAR (5)   NULL,
    [DESCUENTO]       FLOAT (53)    NULL,
    [TOT_PARTIDA]     FLOAT (53)    NULL,
    CONSTRAINT [PK_PAR_PED_AMAZON01] PRIMARY KEY CLUSTERED ([CVE_DOC] ASC, [NUM_PAR] ASC)
);

