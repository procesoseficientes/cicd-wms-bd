CREATE TABLE [dbo].[SONDA_LOADING_MANIFEST] (
    [MANIFEST_ID]              INT           IDENTITY (1, 1) NOT NULL,
    [STATUS]                   INT           NULL,
    [DELIVERY_VEHICULE_PLATES] VARCHAR (50)  NULL,
    [DELIVERY_DRIVER_LICENSE]  VARCHAR (50)  NULL,
    [DELIVERY_DRIVER_NAME]     VARCHAR (150) NULL,
    [TOTAL_BOXES]              INT           NULL,
    [TOTAL_PRIZES]             INT           NULL,
    [TOTAL_BULTOS]             INT           NULL,
    [TOTAL_ORDERS]             INT           NULL,
    [ORDERS_DELIVERED]         INT           NULL,
    [ORDERS_PENDING]           INT           NULL,
    [LAST_GPS_URL]             VARCHAR (200) NULL,
    [CREATED_DATE]             DATETIME      NULL,
    [CREATED_BY]               VARCHAR (25)  NULL,
    [LAST_UPDATED]             DATETIME      NULL,
    CONSTRAINT [PK_SONDA_LOADING_MANIFEST] PRIMARY KEY CLUSTERED ([MANIFEST_ID] ASC) WITH (FILLFACTOR = 80)
);

