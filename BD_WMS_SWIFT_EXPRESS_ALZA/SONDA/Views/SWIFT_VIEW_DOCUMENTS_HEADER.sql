﻿-- =============================================
-- Autor:				joel.delcompare
-- Fecha de Creacion: 	01-22-2016
-- Description:			obtiene los documentos de facturas y pedidos 

-- Modificado 22-01-2016
-- joel.delcompare
-- se agrego el nombre del cliente en el reporte

-- Modificado 02-03-2016
-- alberto.ruiz
-- Se corrijio la tabla de ordenes de venta

-- Modificado 29-03-2016
-- alberto.ruiz
-- Se agregaron isnull en el doc_serie y doc_num en ordenes de venta

-- Modificado 29-03-2016
-- hector.gonzalez
-- Se agrego la columna SALES_ORDER_TYPE que indica si la venta fue a credito o contado

-- Modificacion 04-07-2016
-- alberto.ruiz
-- Se agrego la columna de TASK_ID

-- Modificacion 3/1/2017 @ A-Team Sprint Donkor
-- rodrigo.gomez
-- Ya no se obtienen las columnas SIGNATURE e IMAGE en el primer select

-- Modificacion 06-Apr-17 @ A-Team Sprint Garai
-- alberto.ruiz
-- Se agrego el IS_READY_TO_SEND a las facturas

-- rudi.garcia  21-Sep-2018 G-Force@Jaguar
-- Se agrego el campo ID

-- Christian.hernandez  31-01-2019 G-Force@Reno
-- Se agrego el campo TOTAL_AMOUNT_WHIT_DISCOUNT,[TYPE_ACTION],[CLIENT_ID]

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [SONDA].[SWIFT_VIEW_DOCUMENTS_HEADER]
*/
-- =============================================
CREATE VIEW [SONDA].[SWIFT_VIEW_DOCUMENTS_HEADER]
AS
SELECT
  [S].[SALES_ORDER_ID] AS [ID]
 ,ISNULL(MAX([S].[DOC_SERIE]), [S].[SALES_ORDER_ID]) AS [DOC_SERIAL]
 ,MAX([S].[POS_TERMINAL]) AS [ROUTE]
 ,MAX([S].[CLIENT_ID]) AS [CLIENT]
 ,MAX([S].[CLIENT_ID]) AS [CLIENT_ID]
 ,MAX([S].[POSTED_BY]) AS [ASSIGNED_TO]
 ,MAX([S].[TOTAL_AMOUNT]) [TOTAL_AMOUNT]
 ,SUM([D].DISPLAY_AMOUNT) AS [TOTAL_AMOUNT_WHIT_DISCOUNT]
 ,SUM([D].[QTY]) AS [UNIDADES_VENDIDAS]
 ,NULL AS [SIGNATURE]--S.[IMAGE_2] AS [SIGNATURE] 
 ,NULL AS [IMAGE] --S.[IMAGE_1] AS [IMAGE]
 ,MAX([S].[GPS_EXPECTED]) AS [EXPECTED_GPS]
 ,SUBSTRING(MAX([S].[GPS_URL]), 1, CHARINDEX(',', MAX([S].[GPS_URL])) - 1) AS [Latitude]
 ,SUBSTRING(MAX([S].[GPS_URL]), CHARINDEX(',', MAX([S].[GPS_URL])) + 1, LEN(MAX([S].[GPS_URL]))) AS [Longitude]
 ,MAX([S].[POSTED_DATETIME]) AS [CREATED_DATESTAMP]
 ,MAX([S].[DOC_SERIE]) AS [CDF_SERIE]
 ,CONVERT(VARCHAR(100), 'NA') AS [CDF_RESOLUCION]
 ,MAX([S].[STATUS]) [STATUS]
 ,MAX([S].[CLOSED_ROUTE_DATETIME]) [CLOSED_ROUTE_DATETIME]
 ,MAX([S].[IMAGE_1]) [IMAGE_1]
 ,MAX([S].[IMAGE_2]) [IMAGE_2]
 ,CONVERT(VARCHAR(50), ISNULL(MAX([S].[DOC_NUM]), [S].[SALES_ORDER_ID])) AS [DOC_ID]
 ,'SALES_ORDER' AS [DOC_TYPE]
 ,'Order de Venta' AS [DOC_TYPE_DESCRIPTION]
 ,MAX([SALES_ORDER_TYPE]) [SALES_ORDER_TYPE]
 ,MAX([S].[TASK_ID]) [TASK_ID]
 ,MAX([S].[IS_POSTED_ERP]) AS [IS_POSTED_ERP]
 ,MAX([S].[ATTEMPTED_WITH_ERROR]) AS [ATTEMPTED_WITH_ERROR]
 ,MAX([S].[POSTED_RESPONSE]) AS [POSTED_RESPONSE]
 ,MAX([S].[POSTED_ERP]) AS [POSTED_ERP]
 ,MAX([S].[POSTED_DATETIME]) AS [POSTED_DATETIME]
 ,MAX([S].[LAST_UPDATE_IS_SENDING]) AS [LAST_UPDATE_IS_SENDING]
 ,'WITHOUT_SALE' as [TYPE_ACTION]
FROM [SONDA].[SONDA_SALES_ORDER_HEADER] [S] WITH (NOLOCK)
INNER JOIN [SONDA].[SONDA_SALES_ORDER_DETAIL] [D] WITH (NOLOCK)
  ON ([D].[SALES_ORDER_ID] = [S].[SALES_ORDER_ID])
WHERE [S].[SALES_ORDER_ID] > 0
AND [S].[IS_READY_TO_SEND] = 1
GROUP BY [S].[SALES_ORDER_ID]
UNION ALL
SELECT
  [H].[ID] AS [ID]
 ,[CDF_SERIE] AS [DOC_SERIAL]
 ,[POS_TERMINAL] AS [ROUTE]
 ,[CLIENT_ID] + ' ' + [H].[CDF_NOMBRECLIENTE] AS [CLIENT]
 ,[CLIENT_ID] 
 ,[US].[LOGIN] AS [ASSIGNED_TO]
 ,[TOTAL_AMOUNT] AS [TOTAL_AMOUNT]
 ,[TOTAL_AMOUNT] AS [TOTAL_AMOUNT_WHIT_DISCOUNT]
 ,(SELECT
      SUM([QTY])
    FROM [SONDA].[SONDA_POS_INVOICE_DETAIL] [D] WITH (NOLOCK)
    WHERE [D].[ID] = [H].[ID])
  AS [UNIDADES_VENDIDAS]
 ,NULL AS [SIGNATURE]
 ,NULL AS [IMAGE]
 ,[GPS_URL] AS [EXPECTED_GPS]
 ,SUBSTRING([GPS_URL], 1, CHARINDEX(',', [GPS_URL]) - 1) AS [Latitude]
 ,SUBSTRING([GPS_URL], CHARINDEX(',', [GPS_URL]) + 1, LEN([GPS_URL])) AS [Longitude]
 ,[INVOICED_DATETIME] AS [CREATED_DATESTAMP]
 ,[CDF_SERIE] AS [CDF_SERIE]
 ,[CDF_RESOLUCION] AS [CDF_RESOLUCION]
 ,[STATUS] AS [STATUS]
 ,[CLOSED_ROUTE_DATETIME] AS [CLOSED_ROUTE_DATETIME]
 ,[IMAGE_1] COLLATE DATABASE_DEFAULT AS [IMAGE_1]
 ,[IMAGE_2] COLLATE DATABASE_DEFAULT AS [IMAGE_2]
 ,CONVERT(VARCHAR(50), [INVOICE_ID]) AS [DOC_ID]
 ,'INVOICE' AS [DOC_TYPE]
 ,'Factura' AS [DOC_TYPE_DESCRIPTION]
 ,[TERMS] AS [SALES_ORDER_TYPE]
 ,[H].[TASK_ID]
 ,[H].[IS_POSTED_ERP]
 ,[H].[ATTEMPTED_WITH_ERROR]
 ,[H].[POSTED_RESPONSE]
 ,[H].[POSTED_ERP]
 ,[H].[POSTED_DATETIME]
 ,[H].[LAST_UPDATE_IS_SENDING] AS [LAST_UPDATE_IS_SENDING]
 ,'SALE' as [TYPE_ACTION]
FROM [SONDA].[SONDA_POS_INVOICE_HEADER] [H] WITH (NOLOCK)
INNER JOIN [SONDA].[USERS] AS [US]
  ON ([US].[SELLER_ROUTE] = [H].[POS_TERMINAL])
WHERE [H].[ID] > 0
AND [H].[IS_READY_TO_SEND] = 1
