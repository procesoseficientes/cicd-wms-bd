﻿CREATE TABLE [SONDA].[SWIFT_CUSTOMERS2] (
    [CUSTOMER]                INT           IDENTITY (1, 1) NOT NULL,
    [CODE_CUSTOMER]           VARCHAR (50)  NULL,
    [NAME_CUSTOMER]           VARCHAR (50)  NULL,
    [PHONE_CUSTOMER]          VARCHAR (50)  NULL,
    [ADRESS_CUSTOMER]         VARCHAR (MAX) NULL,
    [CLASSIFICATION_CUSTOMER] VARCHAR (50)  NULL,
    [CONTACT_CUSTOMER]        VARCHAR (50)  NULL,
    [CODE_ROUTE]              VARCHAR (50)  NULL,
    [LAST_UPDATE]             DATETIME      NULL,
    [LAST_UPDATE_BY]          VARCHAR (50)  NULL,
    [SELLER_DEFAULT_CODE]     VARCHAR (50)  NULL,
    [CREDIT_LIMIT]            FLOAT (53)    NULL,
    [GPS]                     VARCHAR (MAX) NULL,
    [FREQUENCY]               VARCHAR (50)  NULL,
    [MONDAY]                  VARCHAR (1)   NULL,
    [TUESDAY]                 VARCHAR (1)   NULL,
    [WEDNESDAY]               VARCHAR (1)   NULL,
    [THURSDAY]                VARCHAR (1)   NULL,
    [FRIDAY]                  VARCHAR (1)   NULL,
    [SATURDAY]                VARCHAR (1)   NULL,
    [SUNDAY]                  VARCHAR (1)   NULL,
    [LATITUDE]                VARCHAR (50)  NULL,
    [LONGITUDE]               VARCHAR (50)  NULL,
    [SCOUTING_ROUTE]          VARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([CUSTOMER] ASC)
);

