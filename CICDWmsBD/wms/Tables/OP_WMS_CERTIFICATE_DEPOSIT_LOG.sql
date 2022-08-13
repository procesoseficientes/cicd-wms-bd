CREATE TABLE [wms].[OP_WMS_CERTIFICATE_DEPOSIT_LOG] (
    [CERTIFICATE_DEPOSIT_LOG_ID]    INT           IDENTITY (1, 1) NOT NULL,
    [CERTIFICATE_DEPOSIT_ID_HEADER] INT           NULL,
    [STATUS]                        VARCHAR (25)  NULL,
    [VALID_FROM]                    DATE          NULL,
    [VALID_TO]                      DATE          NULL,
    [CLIENT_CODE]                   VARCHAR (25)  NULL,
    [CLIENT_NAME]                   VARCHAR (50)  NULL,
    [MATERIAL_CODE]                 VARCHAR (200) NULL,
    [SKU_DESCRIPTION]               VARCHAR (200) NULL,
    [LOCATIONS]                     VARCHAR (200) NULL,
    [BULTOS]                        NUMERIC (18)  NULL,
    [QTY]                           NUMERIC (18)  NULL,
    [CUSTOMS_AMOUNT]                NUMERIC (18)  NULL,
    [DATE_TRANS]                    DATETIME      NULL,
    [LOGIN]                         VARCHAR (25)  NULL,
    [LOGIN_NAME]                    VARCHAR (50)  NULL,
    [COMMET]                        VARCHAR (250) NULL,
    PRIMARY KEY CLUSTERED ([CERTIFICATE_DEPOSIT_LOG_ID] ASC) WITH (FILLFACTOR = 80)
);

