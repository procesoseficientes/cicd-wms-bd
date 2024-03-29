﻿CREATE TABLE [SONDA].[SONDA_ROUTE_PLAN] (
    [TASK_ID]                INT           NOT NULL,
    [CODE_FREQUENCY]         VARCHAR (50)  NOT NULL,
    [SCHEDULE_FOR]           DATETIME      NOT NULL,
    [ASSIGNED_BY]            VARCHAR (50)  NOT NULL,
    [DOC_PARENT]             INT           NOT NULL,
    [EXPECTED_GPS]           VARCHAR (MAX) NOT NULL,
    [TASK_COMMENTS]          VARCHAR (150) NOT NULL,
    [TASK_SEQ]               INT           NOT NULL,
    [TASK_ADDRESS]           VARCHAR (MAX) NOT NULL,
    [RELATED_CLIENT_PHONE_1] VARCHAR (50)  NOT NULL,
    [EMAIL_TO_CONFIRM]       VARCHAR (50)  NULL,
    [RELATED_CLIENT_CODE]    VARCHAR (50)  NOT NULL,
    [RELATED_CLIENT_NAME]    VARCHAR (150) NOT NULL,
    [TASK_PRIORITY]          INT           NOT NULL,
    [TASK_STATUS]            VARCHAR (50)  NOT NULL,
    [SYNCED]                 INT           NOT NULL,
    [NO_PICKEDUP]            VARCHAR (50)  NULL,
    [NO_VISIT_REASON]        VARCHAR (50)  NULL,
    [IS_OFFLINE]             INT           NULL,
    [DOC_NUM]                INT           NULL,
    [TASK_TYPE]              VARCHAR (15)  NOT NULL,
    [TASK_DATE]              DATETIME      NOT NULL,
    [CREATED_STAMP]          DATETIME      NOT NULL,
    [ASSIGEND_TO]            VARCHAR (50)  NOT NULL,
    [CODE_ROUTE]             VARCHAR (50)  NOT NULL,
    [TARGET_DOC]             INT           NULL,
    [IN_PLAN_ROUTE]          INT           NULL,
    [CREATE_BY]              VARCHAR (250) NULL,
    CONSTRAINT [PK_SONDA_ROUTE_PLAN] PRIMARY KEY CLUSTERED ([TASK_ID] ASC, [CODE_FREQUENCY] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IN_SONDA_ROUTE_PLAN_CODE_ROUTE]
    ON [SONDA].[SONDA_ROUTE_PLAN]([CODE_ROUTE] ASC);


GO
CREATE NONCLUSTERED INDEX [IN_SONDA_ROUTE_PLAN_RELATED_CLIENT_CODE]
    ON [SONDA].[SONDA_ROUTE_PLAN]([RELATED_CLIENT_CODE] ASC);


GO
CREATE NONCLUSTERED INDEX [IN_SONDA_ROUTE_PLAN_CODE_ROUTE_RELATED_CLIENT_CODE]
    ON [SONDA].[SONDA_ROUTE_PLAN]([CODE_ROUTE] ASC, [RELATED_CLIENT_CODE] ASC);

