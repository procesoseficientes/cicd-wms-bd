CREATE TABLE [dbo].[ALMACENES01] (
    [CVE_ALM]      INT          NOT NULL,
    [DESCR]        VARCHAR (40) NULL,
    [DIRECCION]    VARCHAR (60) NULL,
    [ENCARGADO]    VARCHAR (60) NULL,
    [TELEFONO]     VARCHAR (16) NULL,
    [LISTA_PREC]   INT          NULL,
    [CUEN_CONT]    VARCHAR (28) NULL,
    [CVE_MENT]     INT          NULL,
    [CVE_MSAL]     INT          NULL,
    [STATUS]       VARCHAR (1)  NULL,
    [LAT]          FLOAT (53)   NULL,
    [LON]          FLOAT (53)   NULL,
    [UUID]         VARCHAR (50) NULL,
    [VERSION_SINC] DATETIME     NULL,
    [UBI_DEST]     TEXT         NULL,
    CONSTRAINT [PK_ALMACENES01] PRIMARY KEY CLUSTERED ([CVE_ALM] ASC)
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


