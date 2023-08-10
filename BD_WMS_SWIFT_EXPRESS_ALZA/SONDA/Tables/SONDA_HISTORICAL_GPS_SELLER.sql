CREATE TABLE [SONDA].[SONDA_HISTORICAL_GPS_SELLER] (
    [HISTORICAL_ID]         INT             IDENTITY (1, 1) NOT NULL,
    [CODE_ROUTE]            VARCHAR (50)    NULL,
    [GPS]                   VARCHAR (250)   NULL,
    [LONGITUDE]             VARCHAR (250)   NULL,
    [LATITUDE]              VARCHAR (250)   NULL,
    [POSTED_DATE]           DATETIME        DEFAULT (getdate()) NULL,
    [WEEK_NUMBER]           INT             DEFAULT (datepart(week,getdate())) NULL,
    [DAY_NUMBER]            INT             DEFAULT (datepart(day,getdate())) NULL,
    [MONTH_NUMBER]          INT             DEFAULT (datepart(month,getdate())) NULL,
    [YEAR_NUMBER]           INT             DEFAULT (datepart(year,getdate())) NULL,
    [DEVICE_BATTERY_FACTOR] NUMERIC (18, 6) NULL,
    [INFORMATION_SOURCE]    VARCHAR (50)    NOT NULL
);

