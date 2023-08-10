CREATE TABLE [SONDA].[SWIFT_SELLER] (
    [SELLER_CODE]                  NVARCHAR (50) NOT NULL,
    [SELLER_NAME]                  VARCHAR (100) NULL,
    [PHONE1]                       NVARCHAR (20) NULL,
    [PHONE2]                       NVARCHAR (20) NULL,
    [RATED_SELLER]                 NVARCHAR (50) NULL,
    [STATUS]                       NVARCHAR (10) NULL,
    [EMAIL]                        NVARCHAR (50) NULL,
    [ASSIGNED_VEHICLE_CODE]        INT           NULL,
    [ASSIGNED_DISTRIBUTION_CENTER] INT           NULL,
    [LAST_UPDATED]                 DATETIME      NULL,
    [LAST_UPDATED_BY]              VARCHAR (25)  NULL,
    [SALES_OFFICE_ID]              INT           NULL,
    [OWNER]                        VARCHAR (50)  NULL,
    [OWNER_ID]                     VARCHAR (50)  NULL,
    [GPS]                          VARCHAR (50)  NULL,
    [SOURCE]                       VARCHAR (50)  NULL,
    CONSTRAINT [PK_swift_table_seller] PRIMARY KEY CLUSTERED ([SELLER_CODE] ASC),
    CONSTRAINT [FK_SWIFT_SELLER_SALES_OFFICE_ID] FOREIGN KEY ([SALES_OFFICE_ID]) REFERENCES [SONDA].[SWIFT_SALES_OFFICE] ([SALES_OFFICE_ID])
);


GO
CREATE NONCLUSTERED INDEX [IN_SWIFT_SELLER_SELLER_CODE]
    ON [SONDA].[SWIFT_SELLER]([SELLER_CODE] ASC)
    INCLUDE([SELLER_NAME]);

