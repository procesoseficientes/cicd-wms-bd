CREATE TABLE [wms].[OP_WMS_DISPATCH_LICENSE_EXIT_HEADER] (
    [DISPATCH_LICENSE_EXIT_HEADER_ID] INT          IDENTITY (1, 1) NOT NULL,
    [CREATE_BY]                       VARCHAR (50) NULL,
    [CREATE_DATE]                     DATETIME     DEFAULT (getdate()) NULL,
    [LAST_UPDATE_BY]                  VARCHAR (50) NULL,
    [LAST_UPDATE]                     DATETIME     NULL,
    [PASS_EXIT_ID]                    INT          NULL,
    PRIMARY KEY CLUSTERED ([DISPATCH_LICENSE_EXIT_HEADER_ID] ASC) WITH (FILLFACTOR = 80)
);

