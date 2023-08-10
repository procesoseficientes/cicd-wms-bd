CREATE TABLE [SONDA].[SONDA_CLEARANCES] (
    [CLEARANCE_ID]    INT           IDENTITY (1, 1) NOT NULL,
    [POST_DATETIME]   DATETIME      CONSTRAINT [DF_SONDA_CLEARANCES_POST_DATETIME] DEFAULT (getdate()) NULL,
    [POS_ID]          VARCHAR (50)  NULL,
    [STATUS]          INT           CONSTRAINT [DF_SONDA_CLEARANCES_STATUS] DEFAULT ((0)) NULL,
    [SOLD]            MONEY         NULL,
    [DEPOSIT]         MONEY         NULL,
    [RETURNED]        MONEY         NULL,
    [COMMENTS]        VARCHAR (MAX) NULL,
    [LAST_UPDATED]    DATETIME      NULL,
    [LAST_UPDATED_BY] VARCHAR (25)  NULL,
    [CREATED_BY]      VARCHAR (25)  NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'OR ROUTE_ID', @level0type = N'SCHEMA', @level0name = N'SONDA', @level1type = N'TABLE', @level1name = N'SONDA_CLEARANCES', @level2type = N'COLUMN', @level2name = N'POS_ID';

