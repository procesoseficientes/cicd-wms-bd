CREATE TABLE [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] (
    [ERP_RECEPTION_DOCUMENT_HEADER_ID] INT             IDENTITY (1, 1) NOT NULL,
    [DOC_ID]                           VARCHAR (50)    NOT NULL,
    [TYPE]                             VARCHAR (25)    NULL,
    [CODE_SUPPLIER]                    VARCHAR (50)    NULL,
    [CODE_CLIENT]                      VARCHAR (50)    NULL,
    [ERP_DATE]                         DATETIME        NULL,
    [LAST_UPDATE]                      DATETIME        NULL,
    [LAST_UPDATE_BY]                   VARCHAR (50)    NULL,
    [ATTEMPTED_WITH_ERROR]             INT             DEFAULT ((0)) NULL,
    [IS_POSTED_ERP]                    INT             DEFAULT ((0)) NULL,
    [POSTED_ERP]                       DATETIME        NULL,
    [POSTED_RESPONSE]                  VARCHAR (500)   NULL,
    [ERP_REFERENCE]                    VARCHAR (50)    NULL,
    [IS_AUTHORIZED]                    INT             DEFAULT ((0)) NULL,
    [IS_COMPLETE]                      INT             DEFAULT ((0)) NULL,
    [TASK_ID]                          NUMERIC (18)    NULL,
    [EXTERNAL_SOURCE_ID]               INT             NULL,
    [ERP_REFERENCE_DOC_NUM]            VARCHAR (200)   NULL,
    [DOC_NUM]                          VARCHAR (50)    NULL,
    [NAME_SUPPLIER]                    VARCHAR (100)   NULL,
    [OWNER]                            VARCHAR (50)    NULL,
    [IS_FROM_WAREHOUSE_TRANSFER]       INT             DEFAULT ((0)) NOT NULL,
    [IS_FROM_ERP]                      INT             DEFAULT ((0)) NOT NULL,
    [DOC_ID_POLIZA]                    NUMERIC (18)    NULL,
    [LOCKED_BY_INTERFACES]             INT             NULL,
    [IS_VOID]                          INT             DEFAULT ((0)) NOT NULL,
    [SOURCE]                           VARCHAR (50)    NULL,
    [ERP_WAREHOUSE_CODE]               VARCHAR (50)    NULL,
    [DOC_ENTRY]                        VARCHAR (50)    NULL,
    [MANIFEST_HEADER_ID]               INT             NULL,
    [PLATE_NUMBER]                     VARCHAR (50)    NULL,
    [ADDRESS]                          VARCHAR (250)   NULL,
    [DOC_CURRENCY]                     VARCHAR (50)    NULL,
    [DOC_RATE]                         NUMERIC (18, 6) NULL,
    [SUBSIDIARY]                       VARCHAR (250)   NULL,
    [IS_SENDING]                       INT             DEFAULT ((0)) NULL,
    [LAST_UPDATE_IS_SENDING]           DATETIME        NULL,
    [USER_CONFIRMED]                   VARCHAR (64)    NULL,
    [DATE_CONFIRMED]                   DATETIME        NULL,
    [CONFIRMED_BY]                     VARCHAR (50)    NULL,
    [RECEPTION_TYPE_ERP]               VARCHAR (50)    NULL,
    PRIMARY KEY CLUSTERED ([ERP_RECEPTION_DOCUMENT_HEADER_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER_POLIZA_HEADER_DOC_ID] FOREIGN KEY ([DOC_ID_POLIZA]) REFERENCES [wms].[OP_WMS_POLIZA_HEADER] ([DOC_ID]),
    CONSTRAINT [FK_RECEPTION_DOCUMENT_TASK_LIST] FOREIGN KEY ([TASK_ID]) REFERENCES [wms].[OP_WMS_TASK_LIST] ([SERIAL_NUMBER]),
    CONSTRAINT [FK_RECEPTION_EXTERNAL_SOURCE] FOREIGN KEY ([EXTERNAL_SOURCE_ID]) REFERENCES [wms].[OP_SETUP_EXTERNAL_SOURCE] ([EXTERNAL_SOURCE_ID])
);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER_DOC_NUM_IS_FROM_WAREHOUSE_TRANSFER]
    ON [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]([DOC_NUM] ASC, [IS_FROM_WAREHOUSE_TRANSFER] ASC)
    INCLUDE([LAST_UPDATE]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER_DOC_NUM_IS_FROM_WAREHOUSE_TRANSFER_TASK_ID]
    ON [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]([DOC_NUM] ASC, [IS_FROM_WAREHOUSE_TRANSFER] ASC, [TASK_ID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IN_OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER_TASK_ID]
    ON [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]([TASK_ID] ASC)
    INCLUDE([CODE_CLIENT], [CODE_SUPPLIER], [DOC_NUM], [EXTERNAL_SOURCE_ID], [NAME_SUPPLIER], [OWNER]) WITH (FILLFACTOR = 80);

