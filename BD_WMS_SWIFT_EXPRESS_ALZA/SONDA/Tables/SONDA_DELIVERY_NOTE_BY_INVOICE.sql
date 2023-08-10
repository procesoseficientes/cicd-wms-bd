CREATE TABLE [SONDA].[SONDA_DELIVERY_NOTE_BY_INVOICE] (
    [ID]                    INT           IDENTITY (1, 1) NOT NULL,
    [DELIVERY_NOTE_DOC_NUM] INT           NULL,
    [DELIVERY_NOTE_SERIE]   VARCHAR (250) NULL,
    [INVOICE_ID]            INT           NULL,
    [LAST_UPDATE]           DATETIME      DEFAULT (getdate()) NULL
);

