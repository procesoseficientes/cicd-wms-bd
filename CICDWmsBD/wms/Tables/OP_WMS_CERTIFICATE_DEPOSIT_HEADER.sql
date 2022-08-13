CREATE TABLE [wms].[OP_WMS_CERTIFICATE_DEPOSIT_HEADER] (
    [CERTIFICATE_DEPOSIT_ID_HEADER]   INT             IDENTITY (1, 1) NOT NULL,
    [VALID_FROM]                      DATE            NULL,
    [VALID_TO]                        DATE            NULL,
    [LAST_UPDATED]                    DATETIME        NULL,
    [LAST_UPDATED_BY]                 VARCHAR (25)    NULL,
    [STATUS]                          VARCHAR (25)    NULL,
    [CLIENT_CODE]                     VARCHAR (25)    NULL,
    [INDIVIDUAL_DESIGNATION]          INT             NULL,
    [STORAGE]                         VARCHAR (20)    NULL,
    [DETAILED_NOTE]                   VARCHAR (256)   NULL,
    [LEAF_NUMBER]                     INT             NULL,
    [MERCHANDISE_SUBJECT_TO_PAYMENTS] INT             NULL,
    [TOTAL]                           DECIMAL (18, 2) NULL,
    [INSURANCE_POLICY]                VARCHAR (50)    NULL,
    [INSURANCE_POLICY_NAME]           VARCHAR (150)   NULL,
    CONSTRAINT [PK_OP_WMS_CERTIFICATE_DEPOSIT_HEADER] PRIMARY KEY CLUSTERED ([CERTIFICATE_DEPOSIT_ID_HEADER] ASC) WITH (FILLFACTOR = 80)
);

