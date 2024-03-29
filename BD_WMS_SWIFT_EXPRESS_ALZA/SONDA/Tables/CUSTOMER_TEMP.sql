﻿CREATE TABLE [SONDA].[CUSTOMER_TEMP] (
    [CUSTOMER]                NVARCHAR (30)   NULL,
    [CODE_CUSTOMER]           VARCHAR (50)    NULL,
    [NAME_CUSTOMER]           NVARCHAR (100)  NULL,
    [PHONE_CUSTOMER]          NVARCHAR (50)   NULL,
    [ADRESS_CUSTOMER]         VARCHAR (MAX)   NULL,
    [CLASSIFICATION_CUSTOMER] VARCHAR (50)    NULL,
    [CONTACT_CUSTOMER]        NVARCHAR (90)   NULL,
    [CODE_ROUTE]              VARCHAR (50)    NULL,
    [LAST_UPDATE]             DATETIME        NULL,
    [LAST_UPDATE_BY]          VARCHAR (50)    NULL,
    [SELLER_DEFAULT_CODE]     NVARCHAR (155)  NULL,
    [CREDIT_LIMIT]            REAL            NULL,
    [FROM_ERP]                INT             NULL,
    [TAX_ID_NUMBER]           VARCHAR (50)    NULL,
    [GPS]                     VARCHAR (MAX)   NULL,
    [LATITUDE]                VARCHAR (50)    NULL,
    [LONGITUDE]               VARCHAR (50)    NULL,
    [FREQUENCY]               NVARCHAR (100)  NULL,
    [SUNDAY]                  VARCHAR (1)     NULL,
    [MONDAY]                  VARCHAR (1)     NULL,
    [TUESDAY]                 VARCHAR (1)     NULL,
    [WEDNESDAY]               VARCHAR (1)     NULL,
    [THURSDAY]                VARCHAR (1)     NULL,
    [FRIDAY]                  VARCHAR (1)     NULL,
    [SATURDAY]                VARCHAR (1)     NULL,
    [SCOUTING_ROUTE]          NVARCHAR (100)  NULL,
    [EXTRA_DAYS]              INT             NULL,
    [DISCOUNT]                DECIMAL (18, 6) NULL,
    [OFIVENTAS]               VARCHAR (7)     NULL,
    [ORGVENTAS]               VARCHAR (2)     NULL,
    [RUTAVENTAS]              VARCHAR (7)     NULL,
    [RUTAENTREGA]             VARCHAR (7)     NULL,
    [SECUENCIA]               INT             NULL,
    [RGA_CODE]                VARCHAR (150)   NULL,
    [ORGANIZACION_VENTAS]     VARCHAR (250)   NULL,
    [PAYMENT_CONDITIONS]      VARCHAR (250)   NULL,
    [OWNER]                   VARCHAR (50)    NULL,
    [OWNER_ID]                VARCHAR (50)    NULL,
    [BALANCE]                 DECIMAL (18, 6) NULL,
    [INVOICE_NAME]            VARCHAR (250)   NULL,
    [CODE_CUSTOMER_ALTERNATE] VARCHAR (50)    NULL
);

