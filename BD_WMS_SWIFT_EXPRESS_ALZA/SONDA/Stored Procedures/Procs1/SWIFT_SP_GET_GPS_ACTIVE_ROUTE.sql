-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		04-07-2016
-- Description:			    Consulta para los vendedores en ruta

-- Modificacion:					hector.gonzalez
-- Fecha de Creacion: 		07-10-2016 sprint 2 TEAM-A
-- Description:			      Se agrego columna DELAY_TIME

-- Modificacion:					christian.hernandez
-- Fecha de Creacion: 		2/15/2019
-- Description:			      SE MODIFICO EL SP PARA MEJORAR EL PERFORMANCE Y ADAPTARLO A VENTAS Y PREVENTAS

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_GET_GPS_ACTIVE_ROUTE]
			@ASSIGNED_TO = '136'
			,@START_DATE = '20190215'
			,@END_DATE = '20190215' 
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_GPS_ACTIVE_ROUTE] (
	@ASSIGNED_TO VARCHAR(50)
	,@START_DATE DATETIME
	,@END_DATE DATETIME
)
AS
BEGIN
	
	
DECLARE @ASSIGNED AS VARCHAR(50);
SET @ASSIGNED =  (SELECT LOGIN FROM SONDA.USERS WHERE SELLER_ROUTE =@ASSIGNED_TO);
--------------------------------------------------------
---creamos la tabla temporal de #TEMP_SWIFT_TASK
--------------------------------------------------------
CREATE TABLE #TEMP_SWIFT_TASK
	(
	TASK_ID	int	not null
	,TASK_TYPE	varchar(15)	null
	,TASK_DATE	date	null
	,SCHEDULE_FOR	date	null
	,CREATED_STAMP	datetime	null
	,ASSIGEND_TO	varchar(25)	null
	,ASSIGNED_BY	varchar(25)	null
	,ASSIGNED_STAMP	datetime	null
	,CANCELED_STAMP	datetime	null
	,CANCELED_BY	varchar(25)	null
	,ACCEPTED_STAMP	datetime	null
	,COMPLETED_STAMP	datetime	null
	,RELATED_PROVIDER_CODE	varchar(25)	null
	,RELATED_PROVIDER_NAME	varchar(250)	null
	,EXPECTED_GPS	varchar(100)	null
	,POSTED_GPS	varchar(100)	null
	,TASK_STATUS	varchar(10)	null
	,TASK_COMMENTS	varchar(150)	null
	,TASK_SEQ	int	null
	,REFERENCE	varchar(150)	null
	,SAP_REFERENCE	varchar(150)	null
	,COSTUMER_CODE	varchar(25)	null
	,COSTUMER_NAME	varchar(250)	null
	,RECEPTION_NUMBER	int	null
	,PICKING_NUMBER	int	null
	,COUNT_ID	varchar(50)	null
	,ACTION	varchar(50)	null
	,SCANNING_STATUS	varchar(50)	null
	,ALLOW_STORAGE_ON_DIFF	int	null
	,CUSTOMER_PHONE	varchar(50)	null
	,TASK_ADDRESS	varchar(250)	null
	,VISIT_HOUR	datetime	null
	,ROUTE_IS_COMPLETED	int	null
	,EMAIL_TO_CONFIRM	varchar(150)	null
	,DISTANCE_IN_KMS	float	null
	,DOC_RESOLUTION	varchar(50)	null
	,DOC_SERIE	varchar(100)	null
	,DOC_NUM	int	null
	,COMPLETED_SUCCESSFULLY	numeric	null
	,REASON	varchar(250)	null
	,TASK_ID_HH	int	null
	,IN_PLAN_ROUTE	int	null
	,CREATE_BY	varchar(250)	null
	,DEVICE_NETWORK_TYPE	varchar(15)	null
	,IS_POSTED_OFFLINE	int	not null
	)

--------------------------------------------------------
---creamos la tabla temporal de #TEMP_DOCUMENT_HEADER
--------------------------------------------------------
CREATE TABLE #TEMP_DOCUMENT_HEADER 
(
	ID	int	 
	,DOC_SERIAL	varchar(100)	
	,ROUTE	varchar(25)	
	,CLIENT	varchar(201)	
	,CLIENT_ID	varchar(50)	
	,ASSIGNED_TO	varchar(50)	
	,TOTAL_AMOUNT	numeric	
	,TOTAL_AMOUNT_WHIT_DISCOUNT	numeric	
	,UNIDADES_VENDIDAS	numeric	
	,SIGNATURE	int	
	,IMAGE	int	
	,EXPECTED_GPS	varchar(max)	
	,Latitude	varchar(150)	
	,Longitude	varchar(150)	
	,CREATED_DATESTAMP	datetime	
	,CDF_SERIE	varchar(100)	
	,CDF_RESOLUCION	varchar(100)	
	,STATUS	int	
	,CLOSED_ROUTE_DATETIME	datetime	
	,IMAGE_1	varchar(max)	
	,IMAGE_2	varchar(max)	
	,DOC_ID	varchar(50)	
	,DOC_TYPE	varchar(11)	 
	,DOC_TYPE_DESCRIPTION	varchar(14)	 
	,SALES_ORDER_TYPE	varchar(250)	
	,TASK_ID	int	
	,IS_POSTED_ERP	int	
	,ATTEMPTED_WITH_ERROR	int	
	,POSTED_RESPONSE	varchar(4000)	
	,POSTED_ERP	datetime	
	,POSTED_DATETIME	datetime	
	,LAST_UPDATE_IS_SENDING	datetime	
	,TYPE_ACTION	varchar(12)	 
)
--------------------------------------------------------
---creamos la tabla temporal de #TEMP_SONDA_SALES_ORDER_HEADER
--------------------------------------------------------
CREATE TABLE #TEMP_SONDA_SALES_ORDER_HEADER 
(
	ID	int	 
	,DOC_SERIAL	varchar(100)	
	,ROUTE	varchar(25)	
	,CLIENT	varchar(201)	
	,CLIENT_ID	varchar(50)	
	,ASSIGNED_TO	varchar(50)	
	,TOTAL_AMOUNT	numeric	
	,TOTAL_AMOUNT_WHIT_DISCOUNT	numeric	
	,UNIDADES_VENDIDAS	numeric	
	,SIGNATURE	int	
	,IMAGE	int	
	,EXPECTED_GPS	varchar(max)	
	,Latitude	varchar(150)	
	,Longitude	varchar(150)	
	,CREATED_DATESTAMP	datetime	
	,CDF_SERIE	varchar(100)	
	,CDF_RESOLUCION	varchar(100)	
	,STATUS	int	
	,CLOSED_ROUTE_DATETIME	datetime	
	,IMAGE_1	varchar(max)	
	,IMAGE_2	varchar(max)	
	,DOC_ID	varchar(50)	
	,DOC_TYPE	varchar(11)	 
	,DOC_TYPE_DESCRIPTION	varchar(14)	 
	,SALES_ORDER_TYPE	varchar(250)	
	,TASK_ID	int	
	,IS_POSTED_ERP	int	
	,ATTEMPTED_WITH_ERROR	int	
	,POSTED_RESPONSE	varchar(4000)	
	,POSTED_ERP	datetime	
	,POSTED_DATETIME	datetime	
	,LAST_UPDATE_IS_SENDING	datetime	
	,TYPE_ACTION	varchar(12)	 
)

--------------------------------------------------------
---creamos la tabla temporal de #TEMP_SONDA_POS_INVOICE_HEADER
--------------------------------------------------------
CREATE TABLE #TEMP_SONDA_POS_INVOICE_HEADER 
(
	ID	int	 
	,DOC_SERIAL	varchar(100)	
	,ROUTE	varchar(25)	
	,CLIENT	varchar(201)	
	,CLIENT_ID	varchar(50)	
	,ASSIGNED_TO	varchar(50)	
	,TOTAL_AMOUNT	numeric	
	,TOTAL_AMOUNT_WHIT_DISCOUNT	numeric	
	,UNIDADES_VENDIDAS	numeric	
	,SIGNATURE	int	
	,IMAGE	int	
	,EXPECTED_GPS	varchar(max)	
	,Latitude	varchar(150)	
	,Longitude	varchar(150)	
	,CREATED_DATESTAMP	datetime	
	,CDF_SERIE	varchar(100)	
	,CDF_RESOLUCION	varchar(100)	
	,STATUS	int	
	,CLOSED_ROUTE_DATETIME	datetime	
	,IMAGE_1	varchar(max)	
	,IMAGE_2	varchar(max)	
	,DOC_ID	varchar(50)	
	,DOC_TYPE	varchar(11)	 
	,DOC_TYPE_DESCRIPTION	varchar(14)	 
	,SALES_ORDER_TYPE	varchar(250)	
	,TASK_ID	int	
	,IS_POSTED_ERP	int	
	,ATTEMPTED_WITH_ERROR	int	
	,POSTED_RESPONSE	varchar(4000)	
	,POSTED_ERP	datetime	
	,POSTED_DATETIME	datetime	
	,LAST_UPDATE_IS_SENDING	datetime	
	,TYPE_ACTION	varchar(12)	 
)

--------------------------------------------------------
---insertamos datos a ##TEMP_SONDA_SALES_ORDER_HEADER
--------------------------------------------------------
INSERT INTO #TEMP_SONDA_SALES_ORDER_HEADER
        ( ID ,
          DOC_SERIAL ,
          ROUTE ,
          CLIENT ,
          CLIENT_ID ,
          ASSIGNED_TO ,
          TOTAL_AMOUNT ,
          TOTAL_AMOUNT_WHIT_DISCOUNT ,
          UNIDADES_VENDIDAS ,
          SIGNATURE ,
          IMAGE ,
          EXPECTED_GPS ,
          Latitude ,
          Longitude ,
          CREATED_DATESTAMP ,
          CDF_SERIE ,
          CDF_RESOLUCION ,
          STATUS ,
          CLOSED_ROUTE_DATETIME ,
          IMAGE_1 ,
          IMAGE_2 ,
          DOC_ID ,
          DOC_TYPE ,
          DOC_TYPE_DESCRIPTION ,
          SALES_ORDER_TYPE ,
          TASK_ID ,
          IS_POSTED_ERP ,
          ATTEMPTED_WITH_ERROR ,
          POSTED_RESPONSE ,
          POSTED_ERP ,
          POSTED_DATETIME ,
          LAST_UPDATE_IS_SENDING 
        ) 
SELECT	T1.ID ,
        T1.DOC_SERIAL ,
        T1.ROUTE ,
        T1.CLIENT ,
        T1.CLIENT_ID ,
        T1.ASSIGNED_TO ,
        T1.TOTAL_AMOUNT ,
        T1.TOTAL_AMOUNT_WHIT_DISCOUNT ,
        T1.UNIDADES_VENDIDAS ,
        T1.SIGNATURE ,
        T1.IMAGE ,
        T1.EXPECTED_GPS ,
        T1.Latitude ,
        T1.Longitude ,
        T1.CREATED_DATESTAMP ,
        T1.CDF_SERIE ,
        T1.CDF_RESOLUCION ,
        T1.STATUS ,
        T1.CLOSED_ROUTE_DATETIME ,
        T1.IMAGE_1 ,
        T1.IMAGE_2 ,
        T1.DOC_ID ,
        T1.DOC_TYPE ,
        T1.DOC_TYPE_DESCRIPTION ,
        T1.SALES_ORDER_TYPE ,
        T1.TASK_ID ,
        T1.IS_POSTED_ERP ,
        T1.ATTEMPTED_WITH_ERROR ,
        T1.POSTED_RESPONSE ,
        T1.POSTED_ERP ,
        T1.POSTED_DATETIME ,
        T1.LAST_UPDATE_IS_SENDING FROM 
(SELECT
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
FROM [SONDA].[SONDA_SALES_ORDER_HEADER] [S] WITH (NOLOCK)
INNER JOIN [SONDA].[SONDA_SALES_ORDER_DETAIL] [D] WITH (NOLOCK)
  ON ([D].[SALES_ORDER_ID] = [S].[SALES_ORDER_ID])
WHERE [S].[SALES_ORDER_ID] > 0
AND [S].[IS_READY_TO_SEND] = 1 AND LOWER([S].[POSTED_BY]) = @ASSIGNED AND S.POSTED_DATETIME  BETWEEN @START_DATE AND @END_DATE
GROUP BY [S].[SALES_ORDER_ID]) T1

--------------------------------------------------------
---insertamos datos a #TEMP_SONDA_POS_INVOICE_HEADER
--------------------------------------------------------
INSERT INTO #TEMP_SONDA_POS_INVOICE_HEADER
        ( ID ,
          DOC_SERIAL ,
          ROUTE ,
          CLIENT ,
          CLIENT_ID ,
          ASSIGNED_TO ,
          TOTAL_AMOUNT ,
          TOTAL_AMOUNT_WHIT_DISCOUNT ,
          UNIDADES_VENDIDAS ,
          SIGNATURE ,
          IMAGE ,
          EXPECTED_GPS ,
          Latitude ,
          Longitude ,
          CREATED_DATESTAMP ,
          CDF_SERIE ,
          CDF_RESOLUCION ,
          STATUS ,
          CLOSED_ROUTE_DATETIME ,
          IMAGE_1 ,
          IMAGE_2 ,
          DOC_ID ,
          DOC_TYPE ,
          DOC_TYPE_DESCRIPTION ,
          SALES_ORDER_TYPE ,
          TASK_ID ,
          IS_POSTED_ERP ,
          ATTEMPTED_WITH_ERROR ,
          POSTED_RESPONSE ,
          POSTED_ERP ,
          POSTED_DATETIME ,
          LAST_UPDATE_IS_SENDING 
        )
SELECT	T2.ID ,
		T2.DOC_SERIAL ,
		T2.ROUTE ,
		T2.CLIENT ,
		T2.CLIENT_ID ,
		T2.ASSIGNED_TO ,
		T2.TOTAL_AMOUNT ,
		T2.TOTAL_AMOUNT_WHIT_DISCOUNT ,
		T2.UNIDADES_VENDIDAS ,
		T2.SIGNATURE ,
		T2.IMAGE ,
		T2.EXPECTED_GPS ,
		T2.Latitude ,
		T2.Longitude ,
		T2.CREATED_DATESTAMP ,
		T2.CDF_SERIE ,
		T2.CDF_RESOLUCION ,
		T2.STATUS ,
		T2.CLOSED_ROUTE_DATETIME ,
		T2.IMAGE_1 ,
		T2.IMAGE_2 ,
		T2.DOC_ID ,
		T2.DOC_TYPE ,
		T2.DOC_TYPE_DESCRIPTION ,
		T2.SALES_ORDER_TYPE ,
		T2.TASK_ID ,
		T2.IS_POSTED_ERP ,
		T2.ATTEMPTED_WITH_ERROR ,
		T2.POSTED_RESPONSE ,
		T2.POSTED_ERP ,
		T2.POSTED_DATETIME ,
		T2.LAST_UPDATE_IS_SENDING FROM (
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
WHERE [H].[ID] > 0 AND US.LOGIN = @ASSIGNED AND H.POSTED_DATETIME BETWEEN @START_DATE AND @END_DATE
AND [H].[IS_READY_TO_SEND] = 1) T2 

--------------------------------------------------------
---Unificamos ambas tablas temporales y la insertamos en #TEMP_DOCUMENT_HEADER
--------------------------------------------------------
INSERT INTO #TEMP_DOCUMENT_HEADER
        ( ID ,
          DOC_SERIAL ,
          ROUTE ,
          CLIENT ,
          CLIENT_ID ,
          ASSIGNED_TO ,
          TOTAL_AMOUNT ,
          TOTAL_AMOUNT_WHIT_DISCOUNT ,
          UNIDADES_VENDIDAS ,
          SIGNATURE ,
          IMAGE ,
          EXPECTED_GPS ,
          Latitude ,
          Longitude ,
          CREATED_DATESTAMP ,
          CDF_SERIE ,
          CDF_RESOLUCION ,
          STATUS ,
          CLOSED_ROUTE_DATETIME ,
          IMAGE_1 ,
          IMAGE_2 ,
          DOC_ID ,
          DOC_TYPE ,
          DOC_TYPE_DESCRIPTION ,
          SALES_ORDER_TYPE ,
          TASK_ID ,
          IS_POSTED_ERP ,
          ATTEMPTED_WITH_ERROR ,
          POSTED_RESPONSE ,
          POSTED_ERP ,
          POSTED_DATETIME ,
          LAST_UPDATE_IS_SENDING ,
          TYPE_ACTION
        )
SELECT * FROM #TEMP_SONDA_POS_INVOICE_HEADER  UNION ALL
SELECT * FROM #TEMP_SONDA_SALES_ORDER_HEADER 

--------------------------------------------------------
---insertamos datos a #TEMP_SWIFT_TASK
--------------------------------------------------------

INSERT INTO #TEMP_SWIFT_TASK
        ( TASK_ID ,
          TASK_TYPE ,
          TASK_DATE ,
          SCHEDULE_FOR ,
          CREATED_STAMP ,
          ASSIGEND_TO ,
          ASSIGNED_BY ,
          ASSIGNED_STAMP ,
          CANCELED_STAMP ,
          CANCELED_BY ,
          ACCEPTED_STAMP ,
          COMPLETED_STAMP ,
          RELATED_PROVIDER_CODE ,
          RELATED_PROVIDER_NAME ,
          EXPECTED_GPS ,
          POSTED_GPS ,
          TASK_STATUS ,
          TASK_COMMENTS ,
          TASK_SEQ ,
          REFERENCE ,
          SAP_REFERENCE ,
          COSTUMER_CODE ,
          COSTUMER_NAME ,
          RECEPTION_NUMBER ,
          PICKING_NUMBER ,
          COUNT_ID ,
          ACTION ,
          SCANNING_STATUS ,
          ALLOW_STORAGE_ON_DIFF ,
          CUSTOMER_PHONE ,
          TASK_ADDRESS ,
          VISIT_HOUR ,
          ROUTE_IS_COMPLETED ,
          EMAIL_TO_CONFIRM ,
          DISTANCE_IN_KMS ,
          DOC_RESOLUTION ,
          DOC_SERIE ,
          DOC_NUM ,
          COMPLETED_SUCCESSFULLY ,
          REASON ,
          TASK_ID_HH ,
          IN_PLAN_ROUTE ,
          CREATE_BY ,
          DEVICE_NETWORK_TYPE ,
          IS_POSTED_OFFLINE
        )
SELECT	  TST.TASK_ID ,
          TST.TASK_TYPE ,
          TST.TASK_DATE ,
          TST.SCHEDULE_FOR ,
          TST.CREATED_STAMP ,
          TST.ASSIGEND_TO ,
          TST.ASSIGNED_BY ,
          TST.ASSIGNED_STAMP ,
          TST.CANCELED_STAMP ,
          TST.CANCELED_BY ,
          TST.ACCEPTED_STAMP ,
          TST.COMPLETED_STAMP ,
          TST.RELATED_PROVIDER_CODE ,
          TST.RELATED_PROVIDER_NAME ,
          TST.EXPECTED_GPS ,
          TST.POSTED_GPS ,
          TST.TASK_STATUS ,
          TST.TASK_COMMENTS ,
          TST.TASK_SEQ ,
          TST.REFERENCE ,
          TST.SAP_REFERENCE ,
          TST.COSTUMER_CODE ,
          TST.COSTUMER_NAME ,
          TST.RECEPTION_NUMBER ,
          TST.PICKING_NUMBER ,
          TST.COUNT_ID ,
          TST.ACTION ,
          TST.SCANNING_STATUS ,
          TST.ALLOW_STORAGE_ON_DIFF ,
          TST.CUSTOMER_PHONE ,
          TST.TASK_ADDRESS ,
          TST.VISIT_HOUR ,
          TST.ROUTE_IS_COMPLETED ,
          TST.EMAIL_TO_CONFIRM ,
          TST.DISTANCE_IN_KMS ,
          TST.DOC_RESOLUTION ,
          TST.DOC_SERIE ,
          TST.DOC_NUM ,
          TST.COMPLETED_SUCCESSFULLY ,
          TST.REASON ,
          TST.TASK_ID_HH ,
          TST.IN_PLAN_ROUTE ,
          TST.CREATE_BY ,
          TST.DEVICE_NETWORK_TYPE ,
          TST.IS_POSTED_OFFLINE FROM [SONDA].SWIFT_TASKS TST WHERE TST.ASSIGEND_TO = @ASSIGNED AND TST.TASK_DATE  BETWEEN @START_DATE AND @END_DATE

		   SELECT DISTINCT	
			ROW_NUMBER() OVER (ORDER BY [DH].[POSTED_DATETIME]) [LINE_NUMBER]
			,ISNULL(st.TASK_ID,dh.TASK_ID) AS TASK_ID
			,ISNULL([ST].[ACCEPTED_STAMP],[DH].[POSTED_DATETIME]) [ACCEPTED_STAMP]
			,ISNULL([DH].[Latitude],SUBSTRING(ST.EXPECTED_GPS,0,CHARINDEX(',', ST.EXPECTED_GPS))) [LATITUDE]
			,ISNULL([DH].[Longitude],SUBSTRING(ST.EXPECTED_GPS,CHARINDEX(',', ST.EXPECTED_GPS)+1,LEN(ST.EXPECTED_GPS))) [LONGITUDE]
			,ISNULL([DH].[ASSIGNED_TO],ST.[ASSIGEND_TO]) AS ASSIGEND_TO
			,[DH].[ASSIGNED_TO]
			,ST.[ASSIGEND_TO]
			,ISNULL([ST].[TASK_COMMENTS],'Sin Comentario') [TASK_COMMENTS]
			,ISNULL([DH].[CLIENT],[ST].COSTUMER_CODE) [CODE_CUSTOMER]
			,[C].[NAME_CUSTOMER] [CUSTOMER_NAME]
			,ISNULL([C].[ADRESS_CUSTOMER],'') [TASK_ADDRESS]
			,ISNULL([ST].[COMPLETED_STAMP],[DH].[POSTED_DATETIME]) [COMPLETED_STAMP]
			,[DH].[TOTAL_AMOUNT]
			,ISNULL([DH].TOTAL_AMOUNT_WHIT_DISCOUNT,DH.TOTAL_AMOUNT) as TOTAL_AMOUNT_WHIT_DISCOUNT
			,ST.COMPLETED_STAMP
			,ST.ACCEPTED_STAMP
			,ISNULL(ST.REASON,'ASIGNADO') AS REASON
			,ST.EXPECTED_GPS
			,ST.POSTED_GPS	
			,ST.TASK_ID
			,(SELECT TOP 1 SYMBOL_CURRENCY FROM [SONDA].SWIFT_CURRENCY	WHERE IS_DEFAULT = 1) AS SYMBOL_CURRENCY
			,CASE WHEN ST.REASON IS NULL THEN 'NARANJA' ELSE (SELECT SONDA.[SWIFT_FN_GET_KPI] (SONDA.SWIFT_CALCULATE_DISTANCE(ST.EXPECTED_GPS,ST.POSTED_GPS,'K'),@ASSIGNED_TO,'SALES_DISTANCE',CASE WHEN [DH].[TOTAL_AMOUNT] IS NULL THEN 'WITHOUT_SALE' ELSE 'SALE' END )) END AS KPI_COLOR
			,  (SELECT [SONDA].[SWIFT_FN_GET_KPI] ([SONDA].SWIFT_CALCULATE_DISTANCE(ST.EXPECTED_GPS,ST.POSTED_GPS,'K'),@ASSIGNED_TO,'SALES_DISTANCE',CASE WHEN [DH].[TOTAL_AMOUNT] <= 0 THEN 'WITHOUT_SALE' ELSE 'SALE' END )) AS COLOR
			, CAST(CASE WHEN [SONDA].SWIFT_CALCULATE_DISTANCE(ST.EXPECTED_GPS,ST.POSTED_GPS,'K') <= 0 THEN 0 ELSE [SONDA].SWIFT_CALCULATE_DISTANCE(ST.EXPECTED_GPS,ST.POSTED_GPS,'K') END AS varchar)+'Km' AS DIFERENCE
			,convert(varchar(3),DateDiff(s, ST.ACCEPTED_STAMP , ST.COMPLETED_STAMP)/3600)+':'+convert(varchar(3),DateDiff(s, ST.ACCEPTED_STAMP , ST.COMPLETED_STAMP)%3600/60)+':'+convert(varchar(3),(DateDiff(s, ST.ACCEPTED_STAMP , ST.COMPLETED_STAMP)%60)) AS DELAY_TIME
			FROM #TEMP_SWIFT_TASK ST 
				LEFT JOIN SONDA.SONDA_ROUTE_PLAN SRP ON (ST.TASK_ID = SRP.TASK_ID) 
				LEFT JOIN #TEMP_DOCUMENT_HEADER DH ON (ST.TASK_ID = DH.TASK_ID)
				INNER JOIN [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C] ON ([ST].[COSTUMER_CODE] = [C].[CODE_CUSTOMER] COLLATE DATABASE_DEFAULT)
			ORDER BY LINE_NUMBER

DROP TABLE #TEMP_SONDA_POS_INVOICE_HEADER
DROP TABLE #TEMP_SONDA_SALES_ORDER_HEADER
DROP TABLE #TEMP_DOCUMENT_HEADER
DROP TABLE #TEMP_SWIFT_TASK

END
