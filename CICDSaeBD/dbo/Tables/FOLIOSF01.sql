CREATE TABLE [dbo].[FOLIOSF01] (
    [TIP_DOC]            VARCHAR (1)  NOT NULL,
    [FOLIODESDE]         INT          NOT NULL,
    [FOLIOHASTA]         INT          NULL,
    [AUTORIZA]           INT          NULL,
    [SERIE]              VARCHAR (10) NOT NULL,
    [AUTOANIO]           VARCHAR (4)  NULL,
    [ULT_DOC]            INT          NULL,
    [TIPO]               VARCHAR (1)  NULL,
    [FECH_ULT_DOC]       DATETIME     NULL,
    [CBB]                VARCHAR (50) NULL,
    [FECHAAPROBCBB]      DATETIME     NULL,
    [IMGCBB]             IMAGE        NULL,
    [FOLIOPERSONALIZADO] VARCHAR (1)  NULL,
    [PARCIALIDAD]        VARCHAR (1)  NULL,
    [STATUS]             VARCHAR (1)  NULL,
    CONSTRAINT [PK_FOLIOSF01] PRIMARY KEY CLUSTERED ([TIP_DOC] ASC, [SERIE] ASC, [FOLIODESDE] ASC)
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


