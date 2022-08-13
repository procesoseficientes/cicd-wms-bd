CREATE TABLE [wms].[OP_WMS_PILOT] (
    [PILOT_CODE]                     INT           IDENTITY (1, 1) NOT NULL,
    [NAME]                           VARCHAR (250) NOT NULL,
    [LAST_NAME]                      VARCHAR (250) NOT NULL,
    [IDENTIFICATION_DOCUMENT_NUMBER] VARCHAR (50)  NOT NULL,
    [LICENSE_NUMBER]                 VARCHAR (50)  NOT NULL,
    [LICESE_TYPE]                    VARCHAR (15)  NOT NULL,
    [LICENSE_EXPIRATION_DATE]        DATETIME      NOT NULL,
    [ADDRESS]                        VARCHAR (250) NULL,
    [TELEPHONE]                      VARCHAR (25)  NULL,
    [MAIL]                           VARCHAR (100) NULL,
    [COMMENT]                        VARCHAR (250) NULL,
    [LAST_UPDATE]                    DATETIME      DEFAULT (getdate()) NULL,
    [LAST_UPDATE_BY]                 VARCHAR (25)  NULL,
    [PILOT_EXTERNAL_ID]              INT           NULL,
    CONSTRAINT [PK_OP_WMS_PILOT_PILOT_CODE] PRIMARY KEY CLUSTERED ([PILOT_CODE] ASC) WITH (FILLFACTOR = 80)
);

