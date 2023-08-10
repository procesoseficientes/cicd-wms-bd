
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	08-Nov-16 @ A-TEAM Sprint 4 
-- Description:			

-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	13-Dic-16 @ A-TEAM Sprint 6
-- Description:			    Se agrego columna SERIE y inner join con serie de encabezado y detalle

-- Modificacion 2/17/2017 @ A-Team Sprint Chatuluka
-- rodrigo.gomez
-- Se agrego la validacion para que cuando la factura este anulada no sus montos vengan con 0

-- Modificacion 4/3/2017 @ A-Team Sprint Garai
					-- diego.as
					-- Se agrega columna IS_READY_TO_SEND para filtrar las facturas por esa columna.

-- Modificacion 7/30/2017 @ Reborn-Team Sprint Bearbeitung
					-- diego.as
					-- Se agrega columna TELEPHONE_NUMBER

-- Modificacion 9/1/2017 @ Reborn-Team Sprint Collin
					-- diego.as
					-- Se agregan columnas:
					/* 
						,VAC.[CODE_CUSTOMER_ALTERNATE]
						,@PAY_DEAL PAY_DEAL
						,@SERIAL_NR SERIAL_NR
						,S.[ART_CODE]
						,S.[VAT_CODE]
					*/

-- Modificacion 21-Nov-2017 @ Reborn-Team Sprint Nach
					-- rudi.garcia
					-- Se agregan columnas:	--[IS_EXPORTED_TO_XML]

-- Modificacion 12/15/2017 @ Reborn - Team Sprint Pannen
					-- diego.as
					-- Se agrega columna COMMENT al select

-- Modificacion 5/16/2018 @ A-Team Sprint Caribú
					-- marvin.garcia
					-- Se agregan columnas:
					/* 
						,[IH].[CREDIT_AMOUNT]
						,[IH].[CASH_AMOUNT]
						,[INVOICE_TYPE]
					*/

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_INVOICE_BY_SKU]
					@START_DATETIME = '20171115 00:00:00.000'
					,@END_DATETIME = '20171221 00:00:00.000'
					,@LOGIN = 'GERENTE@SONDA'
*/
-- =============================================

CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_INVOICE_BY_SKU](
	@START_DATETIME DATETIME
	,@END_DATETIME DATETIME
	,@LOGIN VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE 
		@DEFAULT_DISPLAY_DECIMALS INT
		,@QUERY NVARCHAR(4000)

	-- ------------------------------------------------------------------------------------
	-- Se obtienen Datos Generales
	-- ------------------------------------------------------------------------------------
	DECLARE @SERIAL_NR VARCHAR(20) = NULL, @PAY_DEAL VARCHAR(20) = NULL;

	SELECT @SERIAL_NR = [SONDA].[SWIFT_FN_GET_PARAMETER]('ERP_HARDCODE_VALUES','SERIAL_NR')
			,@PAY_DEAL = [SONDA].[SWIFT_FN_GET_PARAMETER]('ERP_HARDCODE_VALUES','PAY_DEAL');
	-- ------------------------------------------------------------------------------------
	-- Coloca parametros iniciales
	--------------------------------------------------------------------------------------
	SELECT @DEFAULT_DISPLAY_DECIMALS = [SONDA].[SWIFT_FN_GET_PARAMETER]('CALCULATION_RULES','DEFAULT_DISPLAY_DECIMALS')

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado
	-- ------------------------------------------------------------------------------------
	SET @QUERY = N'SELECT
		[IH].[POS_TERMINAL] [CODE_ROUTE]
		,[R].[NAME_ROUTE]
		,[IH].[POSTED_BY] [LOGIN]
		,[U].[NAME_USER]
		,[IH].[CDF_RESOLUCION]
		,[IH].[CDF_SERIE]
		,[IH].[INVOICE_ID]
		,CASE CAST(ISNULL([IH].[VOIDED_INVOICE],0) AS VARCHAR)
			WHEN ''0'' THEN ''VIGENTE''
			ELSE ''ANULADA''
		END [STATUS]
		,[IH].[CLIENT_ID]
		,[IH].[CDF_NOMBRECLIENTE]
		,[IH].[CDF_NIT]
		,[IH].[POSTED_DATETIME]
		,[IH].[VOIDED_INVOICE]
		,[IH].[VOID_REASON]
		,[IH].[VOID_DATETIME]
		,[IH].[GPS_EXPECTED]
    ,SUBSTRING([IH].[GPS_EXPECTED], 1, CHARINDEX('','', [IH].[GPS_EXPECTED]) - 1)  AS LATITUDE_EXPECTED
    ,SUBSTRING([IH].[GPS_EXPECTED], CHARINDEX('','', [IH].[GPS_EXPECTED]) + 1, LEN([IH].[GPS_EXPECTED])) AS LONGITUDE_EXPECTED
		,[IH].[GPS_URL]
    ,SUBSTRING([IH].[GPS_URL], 1, CHARINDEX('','', [IH].[GPS_URL]) - 1)  AS LATITUDE
    ,SUBSTRING([IH].[GPS_URL], CHARINDEX('','', [IH].[GPS_URL]) + 1, LEN([IH].[GPS_URL])) AS LONGITUDE
		,[ID].[SKU]
		,[S].[DESCRIPTION_SKU]
		,[ID].[QTY]
		,CASE ISNULL([IH].[VOIDED_INVOICE],0)
				WHEN 0 THEN CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER([ID].[PRICE]))
				ELSE 0
				END AS [PRICE]
		,CASE ISNULL([IH].[VOIDED_INVOICE],0)
				WHEN 0 THEN CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER([ID].[TOTAL_LINE]))
				ELSE 0
				END AS [TOTAL_LINE]
		,CASE ISNULL([IH].[VOIDED_INVOICE],0)
				WHEN 0 THEN CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER([IH].[CREDIT_AMOUNT]))
				ELSE 0
				END AS [CREDIT_AMOUNT]
		,CASE ISNULL([IH].[VOIDED_INVOICE],0)
				WHEN 0 THEN CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER([IH].[CASH_AMOUNT]))
				ELSE 0
				END AS [CASH_AMOUNT]
		,CASE ISNULL([IH].[VOIDED_INVOICE],0)
				WHEN 0 THEN CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER([IH].[TOTAL_AMOUNT]))
				ELSE 0
				END AS [TOTAL_AMOUNT]
		,CASE WHEN ([IH].[CREDIT_AMOUNT] >0)
				THEN ''Credito''
				ELSE ''Contado''
				END [INVOICE_TYPE]
    ,[IH].[IS_CREDIT_NOTE]
    ,DBO.SONDA_FN_CALCULATE_DISTANCE([IH].[GPS_EXPECTED],[IH].[GPS_URL]) [GPS_DISTANCE]
    , CASE WHEN ISNULL([ID].SERIE,''0'') = ''0'' THEN ''N/A'' WHEN [ID].SERIE = ''NULL'' THEN ''N/A'' ELSE [ID].SERIE END AS [SERIE]
	,IH.TELEPHONE_NUMBER  
	,VAC.[CODE_CUSTOMER_ALTERNATE]
	,''' + @PAY_DEAL +''' AS PAY_DEAL
	,'''+ @SERIAL_NR + ''' AS SERIAL_NR
	,S.[ART_CODE]
	,S.[VAT_CODE]
	,IH.ID
  ,ISNULL([IH].[IS_EXPORTED_TO_XML], 0) AS [IS_EXPORTED_TO_XML]
  ,CASE [IH].[IS_EXPORTED_TO_XML]
     WHEN 1 THEN ''SI''
     ELSE ''NO''
    END [IS_EXPORTED_TO_XML_DESCRIPTION]
	,CASE 
		WHEN [IH].[COMMENT] IS NULL THEN ''N/A''
     ELSE [IH].[COMMENT]
    END AS [COMMENT]
	FROM [SONDA].[SONDA_POS_INVOICE_DETAIL] [ID]
	INNER JOIN [SONDA].[SONDA_POS_INVOICE_HEADER] [IH] ON (
		IH.ID = ID.ID
	)
	INNER JOIN [SONDA].[SWIFT_VIEW_ALL_COSTUMER] AS VAC ON(
		VAC.[CODE_CUSTOMER] = IH.[CLIENT_ID]
	)
	INNER JOIN [SONDA].[SWIFT_ROUTE_BY_USER] [RBU] ON (
		[RBU].[CODE_ROUTE] = [IH].[POS_TERMINAL]
	)
	INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] [S] ON (
		[S].[CODE_SKU] = [ID].[SKU]
	)
	INNER JOIN [SONDA].[SWIFT_ROUTES] [R] ON (
		[R].[CODE_ROUTE] = [IH].[POS_TERMINAL]
	)
	INNER JOIN [SONDA].[USERS] [U] ON (
		[U].[LOGIN] = [IH].[POSTED_BY]
	)
	WHERE IH.IS_READY_TO_SEND = 1 
		AND [IH].[IS_CREDIT_NOTE] = 0
		AND [RBU].[LOGIN] = ''' + @LOGIN + '''
		AND [IH].[POSTED_DATETIME] BETWEEN ''' + CONVERT(VARCHAR,@START_DATETIME,121) + ''' AND ''' + CONVERT(VARCHAR,@END_DATETIME,121) + '''
	ORDER BY [IH].[POSTED_DATETIME],[ID].[LINE_SEQ]
	
	'
	--
	PRINT '----> @QUERY: ' + @QUERY
	--
	EXEC(@QUERY)
	--
	PRINT '----> DESPUES DE @QUERY'
END
