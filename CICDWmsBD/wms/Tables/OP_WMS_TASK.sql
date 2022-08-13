CREATE TABLE [wms].[OP_WMS_TASK] (
    [TASK_ID]          INT           IDENTITY (1, 1) NOT NULL,
    [CREATE_BY]        VARCHAR (25)  NULL,
    [TASK_TYPE]        VARCHAR (25)  NULL,
    [TASK_ASSIGNED_TO] VARCHAR (25)  NULL,
    [IS_ACCEPTED]      INT           NULL,
    [IS_COMPLETE]      INT           NULL,
    [IS_PAUSED]        INT           NULL,
    [IS_CANCELED]      INT           NULL,
    [REGIMEN]          VARCHAR (15)  NULL,
    [ASSIGNED_DATE]    DATETIME      NULL,
    [ACCEPTED_DATE]    DATETIME      NULL,
    [COMPLETED_DATE]   DATETIME      NULL,
    [CANCELED_DATE]    DATETIME      NULL,
    [CANCELED_BY]      VARCHAR (25)  NULL,
    [LAST_UPDATE]      DATETIME      NULL,
    [LAST_UDATE_BY]    VARCHAR (25)  NULL,
    [PRIORITY]         INT           NULL,
    [COMMENTS]         VARCHAR (150) NULL,
    PRIMARY KEY CLUSTERED ([TASK_ID] ASC) WITH (FILLFACTOR = 80)
);

