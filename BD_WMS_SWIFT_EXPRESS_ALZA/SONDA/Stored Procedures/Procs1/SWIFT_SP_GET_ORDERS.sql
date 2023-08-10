-- =============================================
-- Autor:				hector.gonzalez
-- Fecha de Creacion: 	2016-06-22
-- Description:			Obtiene los header de las Ordenes de Venta y Facturas ejecutando la vista: SWIFT_VIEW_DOCUMENTS_HEADER

-- Modificado 29-03-2016
-- hector.gonzalez
-- Se agrego la columna SALES_ORDER_TYPE que indica si la venta fue a credito o contado y las columnas CASH_AMOUT y CREDIT_AMOUNT 

-- Modificado 12-10-2018
-- alejandro.ochoa	
-- Se cambia la vista de documentos por performance, y se utilizan tablas temporales 

/*
-- Ejemplo de Ejecucion:
        DECLARE	@return_value int

		EXEC	@return_value = [SONDA].[SWIFT_SP_GET_ORDERS]
		@DTBEGIN = '20171201',
		@DTEND = '20180925'

		SELECT	'Return Value' = @return_value

*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_ORDERS]
    (
      @DTBEGIN DATE ,
      @DTEND DATE
    )
AS
    BEGIN
        DECLARE @SHIPPING_ATTEMPTS_SALES_ORDER VARCHAR(100) ,
            @SHIPPING_ATTEMPTS_INVOICE VARCHAR(100);
        SELECT  @SHIPPING_ATTEMPTS_SALES_ORDER = [SONDA].[SWIFT_FN_GET_PARAMETER]('SALES_ORDER',
                                                              'SHIPPING_ATTEMPTS') ,
                @SHIPPING_ATTEMPTS_INVOICE = [SONDA].[SWIFT_FN_GET_PARAMETER]('INVOICE',
                                                              'SHIPPING_ATTEMPTS');
	
        CREATE TABLE #DOCUMENTS
            (
              ID INT ,
              DOC_SERIAL VARCHAR(50) ,
              [ROUTE] VARCHAR(25) ,
              CLIENT VARCHAR(250) ,
              ASSIGNED_TO VARCHAR(50) ,
              TOTAL_AMOUNT NUMERIC ,
              UNIDADES_VENDIDAS NUMERIC ,
              SIGNATURE VARCHAR(MAX) ,
              IMAGE VARCHAR(MAX) ,
              EXPECTED_GPS VARCHAR(MAX) ,
              LONGITUDE VARCHAR(MAX) ,
              LATITUDE VARCHAR(MAX) ,
              CREATED_DATESTAMP DATETIME ,
              CDF_SERIE VARCHAR(100) ,
              CDF_RESOLUCION VARCHAR(50) ,
              STATUS INT ,
              CLOSED_ROUTE_DATETIME DATETIME ,
              IMAGE_1 VARCHAR(MAX) ,
              IMAGE_2 VARCHAR(MAX) ,
              DOC_ID VARCHAR(50) ,
              DOC_TYPE VARCHAR(15) ,
              DOC_TYPE_DESCRIPTION VARCHAR(15) ,
              SALES_ORDER_TYPE VARCHAR(250) ,
              TASK_ID INT ,
              IS_POSTED_ERP INT ,
              ATTEMPTED_WITH_ERROR INT ,
              POSTED_RESPONSE VARCHAR(MAX) ,
              POSTED_ERP DATETIME ,
              POSTED_DATETIME DATETIME ,
              LAST_UPDATE_IS_SENDING DATETIME
            );


        INSERT  INTO [#DOCUMENTS]
                SELECT  [S].[SALES_ORDER_ID] AS [ID] ,
                        ISNULL([S].[DOC_SERIE], [S].[SALES_ORDER_ID]) AS [DOC_SERIAL] ,
                        [S].[POS_TERMINAL] AS [ROUTE] ,
                        [S].[CLIENT_ID] AS [CLIENT] ,
                        [S].[POSTED_BY] AS [ASSIGNED_TO] ,
                        [S].[TOTAL_AMOUNT] [TOTAL_AMOUNT] ,
                        ( SELECT    SUM([QTY])
                          FROM      [SONDA].[SONDA_SALES_ORDER_DETAIL] [D]
                                    WITH ( NOLOCK )
                          WHERE     [D].[SALES_ORDER_ID] = [S].[SALES_ORDER_ID]
                        ) AS [UNIDADES_VENDIDAS] ,
                        NULL AS [SIGNATURE]--S.[IMAGE_2] AS [SIGNATURE] 
                        ,
                        NULL AS [IMAGE] --S.[IMAGE_1] AS [IMAGE]
                        ,
                        [S].[GPS_EXPECTED] AS [EXPECTED_GPS] ,
                        SUBSTRING([S].[GPS_URL], 1,
                                  CHARINDEX(',', [S].[GPS_URL]) - 1) AS [Latitude] ,
                        SUBSTRING([S].[GPS_URL],
                                  CHARINDEX(',', [S].[GPS_URL]) + 1,
                                  LEN([S].[GPS_URL])) AS [Longitude] ,
                        [S].[POSTED_DATETIME] AS [CREATED_DATESTAMP] ,
                        [S].[DOC_SERIE] AS [CDF_SERIE] ,
                        CONVERT(VARCHAR(100), 'NA') AS [CDF_RESOLUCION] ,
                        [S].[STATUS] [STATUS] ,
                        [S].[CLOSED_ROUTE_DATETIME] [CLOSED_ROUTE_DATETIME] ,
                        NULL--[S].[IMAGE_1] [IMAGE_1]
                        ,
                        NULL--[S].[IMAGE_2] [IMAGE_2]
                        ,
                        CONVERT(VARCHAR(50), ISNULL([S].[DOC_NUM],
                                                    [S].[SALES_ORDER_ID])) AS [DOC_ID] ,
                        'SALES_ORDER' AS [DOC_TYPE] ,
                        'Order de Venta' AS [DOC_TYPE_DESCRIPTION] ,
                        [SALES_ORDER_TYPE] [SALES_ORDER_TYPE] ,
                        [S].[TASK_ID] [TASK_ID] ,
                        [S].[IS_POSTED_ERP] AS [IS_POSTED_ERP] ,
                        [S].[ATTEMPTED_WITH_ERROR] AS [ATTEMPTED_WITH_ERROR] ,
                        [S].[POSTED_RESPONSE] AS [POSTED_RESPONSE] ,
                        [S].[POSTED_ERP] AS [POSTED_ERP] ,
                        [S].[POSTED_DATETIME] AS [POSTED_DATETIME] ,
                        [S].[LAST_UPDATE_IS_SENDING] AS [LAST_UPDATE_IS_SENDING]
                FROM    [SONDA].[SONDA_SALES_ORDER_HEADER] [S] WITH ( NOLOCK )
                WHERE   [S].[SALES_ORDER_ID] > 0
                        AND [S].[IS_READY_TO_SEND] = 1
                        AND CAST([S].[POSTED_DATETIME] AS DATE) >= @DTBEGIN
                        AND CAST([S].[POSTED_DATETIME] AS DATE) <= @DTEND;


        INSERT  INTO [#DOCUMENTS]
                SELECT  [H].[ID] AS [ID] ,
                        [CDF_SERIE] AS [DOC_SERIAL] ,
                        [POS_TERMINAL] AS [ROUTE] ,
                        [CLIENT_ID] + ' ' + [H].[CDF_NOMBRECLIENTE] AS [CLIENT] ,
                        [US].[LOGIN] AS [ASSIGNED_TO] ,
                        [TOTAL_AMOUNT] AS [TOTAL_AMOUNT] ,
                        ( SELECT    SUM([QTY])
                          FROM      [SONDA].[SONDA_POS_INVOICE_DETAIL] [D]
                                    WITH ( NOLOCK )
                          WHERE     [D].[ID] = [H].[ID]
                        ) AS [UNIDADES_VENDIDAS] ,
                        NULL AS [SIGNATURE] ,
                        NULL AS [IMAGE] ,
                        [GPS_URL] AS [EXPECTED_GPS] ,
                        SUBSTRING([GPS_URL], 1, CHARINDEX(',', [GPS_URL]) - 1) AS [Latitude] ,
                        SUBSTRING([GPS_URL], CHARINDEX(',', [GPS_URL]) + 1,
                                  LEN([GPS_URL])) AS [Longitude] ,
                        [INVOICED_DATETIME] AS [CREATED_DATESTAMP] ,
                        [CDF_SERIE] AS [CDF_SERIE] ,
                        [CDF_RESOLUCION] AS [CDF_RESOLUCION] ,
                        [STATUS] AS [STATUS] ,
                        [CLOSED_ROUTE_DATETIME] AS [CLOSED_ROUTE_DATETIME] ,
                        NULL--[IMAGE_1] COLLATE DATABASE_DEFAULT AS [IMAGE_1]
                        ,
                        NULL--[IMAGE_2] COLLATE DATABASE_DEFAULT AS [IMAGE_2]
                        ,
                        CONVERT(VARCHAR(50), [INVOICE_ID]) AS [DOC_ID] ,
                        'INVOICE' AS [DOC_TYPE] ,
                        'Factura' AS [DOC_TYPE_DESCRIPTION] ,
                        [TERMS] AS [SALES_ORDER_TYPE] ,
                        NULL [TASK_ID] ,
                        [H].[IS_POSTED_ERP] ,
                        [H].[ATTEMPTED_WITH_ERROR] ,
                        [H].[POSTED_RESPONSE] ,
                        [H].[POSTED_ERP] ,
                        [H].[INVOICED_DATETIME] ,
                        [H].[LAST_UPDATE_IS_SENDING] AS [LAST_UPDATE_IS_SENDING]
                FROM    [SONDA].[SONDA_POS_INVOICE_HEADER] [H] WITH ( NOLOCK )
                        INNER JOIN [SONDA].[USERS] AS [US] ON ( [US].[SELLER_ROUTE] = [H].[POS_TERMINAL] )
                WHERE   [H].[ID] > 0
                        AND [H].[IS_READY_TO_SEND] = 1
                        AND CAST([H].[INVOICED_DATETIME] AS DATE) >= @DTBEGIN
                        AND CAST([H].[INVOICED_DATETIME] AS DATE) <= @DTEND;


        SELECT  [H].[ID] ,
                [H].[DOC_SERIAL] ,
                [H].[ROUTE] ,
                [H].[POSTED_DATETIME] ,
                [H].[CLIENT] ,
                [H].[ASSIGNED_TO] ,
                [H].[TOTAL_AMOUNT] ,
                [H].[UNIDADES_VENDIDAS] ,
                [H].[SIGNATURE] ,
                [H].[IMAGE] ,
                [H].[EXPECTED_GPS] ,
                [H].[LATITUDE] ,
                [H].[LONGITUDE] ,
                [H].[CREATED_DATESTAMP] ,
                [H].[CDF_SERIE] ,
                [H].[CDF_RESOLUCION] ,
                [H].[STATUS] ,
                [H].[CLOSED_ROUTE_DATETIME] ,
                [H].[IMAGE_1] ,
                [H].[IMAGE_2] ,
                [H].[DOC_ID] ,
                [H].[DOC_TYPE] ,
                [H].[DOC_TYPE_DESCRIPTION] ,
                CASE [H].[SALES_ORDER_TYPE]
                  WHEN 'CASH' THEN 'Contado'
                  ELSE 'Credito'
                END AS 'SALES_ORDER_TYPE' ,
                CASE [H].[SALES_ORDER_TYPE]
                  WHEN 'CASH'
                  THEN [SONDA].[SWIFT_FN_GET_DISPLAY_NUMBER]([H].[TOTAL_AMOUNT])
                  ELSE 0
                END AS 'CASH_AMOUNT' ,
                CASE [H].[SALES_ORDER_TYPE]
                  WHEN 'CREDIT'
                  THEN [SONDA].[SWIFT_FN_GET_DISPLAY_NUMBER]([H].[TOTAL_AMOUNT])
                  ELSE 0
                END AS 'CREDIT_AMOUNT' ,
                CASE WHEN [H].[IS_POSTED_ERP] = 1 THEN 'Enviado'
                     WHEN ISNULL([POSTED_RESPONSE], '') = '' THEN 'Pendiente'
                     ELSE 'Con Error'
                END [STATUS_ERP] ,
                ISNULL([H].[IS_POSTED_ERP], 0) AS [IS_POSTED_ERP] ,
                [H].[ATTEMPTED_WITH_ERROR] ,
                [H].[POSTED_RESPONSE] ,
                [H].[POSTED_ERP] ,
                [H].[POSTED_DATETIME] ,
                CASE [H].[DOC_TYPE]
                  WHEN 'SALES_ORDER'
                  THEN CAST(@SHIPPING_ATTEMPTS_SALES_ORDER AS INT)
                  WHEN 'INVOICE' THEN CAST(@SHIPPING_ATTEMPTS_INVOICE AS INT)
                END [SHIPPING_ATTEMPTS] ,
                [H].[LAST_UPDATE_IS_SENDING]
        FROM    [#DOCUMENTS] [H];


    END;
