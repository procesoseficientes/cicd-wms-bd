CREATE TABLE [dbo].[RoutePlan] (
    [TASK_ID]             FLOAT (53)     NULL,
    [CODE_FREQUENCY]      NVARCHAR (255) NULL,
    [EXPECTED_GPS]        NVARCHAR (255) NULL,
    [TASK_SEQ]            FLOAT (53)     NULL,
    [RELATED_CLIENT_CODE] NVARCHAR (255) NULL,
    [RELATED_CLIENT_NAME] NVARCHAR (255) NULL,
    [ASSIGEND_TO]         NVARCHAR (255) NULL,
    [CODE_ROUTE]          NVARCHAR (255) NULL,
    [SEQ]                 INT            NULL,
    [DISTANCE_TO]         FLOAT (53)     NULL
);

