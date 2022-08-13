CREATE TABLE [wms].[temp] (
    [ACUERDO_COMERCIAL]    INT           NOT NULL,
    [CLIENT_ID]            VARCHAR (50)  NOT NULL,
    [SERIAL_ID]            INT           IDENTITY (1, 1) NOT NULL,
    [TYPE_CHARGE_ID]       INT           NULL,
    [UNIT_PRICE]           INT           NULL,
    [CURRENCY]             VARCHAR (20)  NULL,
    [LAST_UPDATED]         DATETIME      NULL,
    [LAST_UPDATED_BY]      VARCHAR (25)  NULL,
    [LAST_UPDATED_AUTH_BY] VARCHAR (25)  NULL,
    [COMMENTS]             VARCHAR (MAX) NULL,
    [BILLING_FRECUENCY]    INT           NULL,
    [LIMIT_TO]             INT           NULL,
    [TYPE_MEASURE]         VARCHAR (25)  NULL,
    [U_MEASURE]            VARCHAR (15)  NULL,
    [TX_SOURCE]            VARCHAR (25)  NULL
);

