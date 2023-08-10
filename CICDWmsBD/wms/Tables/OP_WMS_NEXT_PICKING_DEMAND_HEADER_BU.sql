﻿CREATE TABLE [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER_BU] (
    [PICKING_DEMAND_HEADER_ID]             INT              IDENTITY (1, 1) NOT NULL,
    [DOC_NUM]                              VARCHAR (50)     NULL,
    [CLIENT_CODE]                          VARCHAR (50)     NOT NULL,
    [CODE_ROUTE]                           VARCHAR (50)     NULL,
    [CODE_SELLER]                          VARCHAR (50)     NULL,
    [TOTAL_AMOUNT]                         DECIMAL (18, 6)  NULL,
    [SERIAL_NUMBER]                        VARCHAR (100)    NULL,
    [DOC_NUM_SEQUENCE]                     VARCHAR (50)     NULL,
    [EXTERNAL_SOURCE_ID]                   INT              NOT NULL,
    [IS_FROM_ERP]                          INT              NOT NULL,
    [IS_FROM_SONDA]                        INT              NOT NULL,
    [LAST_UPDATE]                          DATETIME         NOT NULL,
    [LAST_UPDATE_BY]                       VARCHAR (50)     NOT NULL,
    [IS_COMPLETED]                         INT              NOT NULL,
    [WAVE_PICKING_ID]                      INT              NOT NULL,
    [CODE_WAREHOUSE]                       VARCHAR (25)     NOT NULL,
    [IS_AUTHORIZED]                        INT              NOT NULL,
    [ATTEMPTED_WITH_ERROR]                 INT              NOT NULL,
    [IS_POSTED_ERP]                        INT              NOT NULL,
    [POSTED_ERP]                           DATETIME         NULL,
    [POSTED_RESPONSE]                      VARCHAR (500)    NULL,
    [ERP_REFERENCE]                        VARCHAR (50)     NULL,
    [CLIENT_NAME]                          VARCHAR (100)    NULL,
    [CREATED_DATE]                         DATETIME         NULL,
    [ERP_REFERENCE_DOC_NUM]                VARCHAR (200)    NULL,
    [DOC_ENTRY]                            VARCHAR (50)     NULL,
    [IS_CONSOLIDATED]                      INT              NOT NULL,
    [PRIORITY]                             INT              NULL,
    [HAS_MASTERPACK]                       INT              NOT NULL,
    [POSTED_STATUS]                        INT              NOT NULL,
    [OWNER]                                VARCHAR (50)     NULL,
    [CLIENT_OWNER]                         VARCHAR (50)     NULL,
    [MASTER_ID_SELLER]                     VARCHAR (50)     NULL,
    [SELLER_OWNER]                         VARCHAR (50)     NULL,
    [SOURCE_TYPE]                          VARCHAR (50)     NULL,
    [INNER_SALE_STATUS]                    VARCHAR (50)     NULL,
    [INNER_SALE_RESPONSE]                  VARCHAR (1000)   NULL,
    [DEMAND_TYPE]                          VARCHAR (50)     NULL,
    [TRANSFER_REQUEST_ID]                  INT              NULL,
    [ADDRESS_CUSTOMER]                     VARCHAR (500)    NULL,
    [STATE_CODE]                           INT              NULL,
    [DISCOUNT]                             DECIMAL (18, 6)  NOT NULL,
    [UPDATED_VEHICLE]                      INT              NOT NULL,
    [UPDATED_VEHICLE_RESPONSE]             VARCHAR (500)    NULL,
    [UPDATED_VEHICLE_ATTEMPTED_WITH_ERROR] INT              NOT NULL,
    [DELIVERY_NOTE_INVOICE]                VARCHAR (50)     NULL,
    [DEMAND_SEQUENCE]                      INT              NULL,
    [IS_CANCELED_FROM_SONDA_SD]            INT              NOT NULL,
    [TYPE_DEMAND_CODE]                     INT              NULL,
    [TYPE_DEMAND_NAME]                     VARCHAR (50)     NULL,
    [IS_FOR_DELIVERY_IMMEDIATE]            INT              NOT NULL,
    [DEMAND_DELIVERY_DATE]                 DATETIME         NULL,
    [IS_SENDING]                           INT              NULL,
    [LAST_UPDATE_IS_SENDING]               DATETIME         NULL,
    [PROJECT]                              VARCHAR (50)     NULL,
    [DISPATCH_LICENSE_EXIT_DATETIME]       DATETIME         NULL,
    [DISPATCH_LICENSE_EXIT_BY]             VARCHAR (25)     NULL,
    [COMMENT_REFERENCE]                    VARCHAR (300)    NULL,
    [PROJECT_ID]                           UNIQUEIDENTIFIER NULL,
    [PROJECT_CODE]                         VARCHAR (50)     NULL,
    [PROJECT_NAME]                         VARCHAR (150)    NULL,
    [PROJECT_SHORT_NAME]                   VARCHAR (25)     NULL,
    [MIN_DAYS_EXPIRATION_DATE]             INT              NULL,
    [CAI]                                  VARCHAR (100)    NULL,
    [CAI_SERIE]                            VARCHAR (50)     NULL,
    [CAI_NUMERO]                           VARCHAR (50)     NULL,
    [CAI_RANGO_INICIAL]                    FLOAT (53)       NULL,
    [CAI_RANGO_FINAL]                      FLOAT (53)       NULL,
    [CAI_FECHA_VENCIMIENTO]                DATE             NULL
);

