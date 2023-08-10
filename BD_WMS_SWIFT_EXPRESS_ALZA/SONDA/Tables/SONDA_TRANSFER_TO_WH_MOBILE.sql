CREATE TABLE [SONDA].[SONDA_TRANSFER_TO_WH_MOBILE] (
    [DOC_ENTRY]      INT             NOT NULL,
    [CODE_WAREHOUSE] NVARCHAR (8)    NULL,
    [DOC_DATE]       DATE            NULL,
    [CODE_SKU]       NVARCHAR (20)   NULL,
    [QTY]            NUMERIC (19, 6) NULL
);

