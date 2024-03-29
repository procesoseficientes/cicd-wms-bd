﻿-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	07-Nov-16 @ A-TEAM Sprint 4 
-- Description:			SP que obtiene los registros de las devoluciones de inventario

-- Modificado 13-Dic-2016
		-- rudi.garcia
		-- Se agrego el campo "SERIAL_NUMBER"

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_DEVOLUTION_INVENTORY]
					@START_DATETIME = '20160101 00:00:00.000'
					,@END_DATETIME = '20170101 00:00:00.000'
					,@LOGIN = 'GERENTE@SONDA'
				--
				SELECT * FROM [SONDA].[SONDA_DEVOLUTION_INVENTORY_DETAIL] WHERE DEVOLUTION_ID = 1005
				SELECT * FROM [SONDA].[SONDA_DEVOLUTION_INVENTORY_HEADER] WHERE DEVOLUTION_ID = 1005
				--
				SELECT * 
				FROM [SONDA].[SONDA_HISTORICAL_TRACEABILITY_CONSIGNMENT] 
				WHERE [DOC_SERIE_TARGET] = 'Serie Recoger Inventario'
					AND [DOC_NUM_TARGET] = 19

*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_DEVOLUTION_INVENTORY(
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
	-- Coloca parametros iniciales
	--------------------------------------------------------------------------------------
	SELECT @DEFAULT_DISPLAY_DECIMALS = [SONDA].[SWIFT_FN_GET_PARAMETER]('CALCULATION_RULES','DEFAULT_DISPLAY_DECIMALS')

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado
	-- ------------------------------------------------------------------------------------
	SET @QUERY = N'SELECT
		[DID].[DEVOLUTION_ID]
		,[DIH].[CODE_ROUTE]
		,MAX([R].[NAME_ROUTE]) [NAME_ROUTE]
		,[DID].[POSTED_BY]
		,MAX([U].[NAME_USER]) [NAME_USER]
		,MAX([DIH].[CODE_CUSTOMER]) [CODE_CUSTOMER]
		,MAX([C].[NAME_CUSTOMER]) [NAME_CUSTOMER]
		,[DIH].[DOC_SERIE]
		,[DIH].[DOC_NUM]
		,MAX([DID].[POSTED_DATETIME]) [POSTED_DATETIME]
		,MAX([HTC].[DOC_SERIE]) [SOURCE_DOC_SERIE]
		,MAX([HTC].[DOC_NUM]) [SOURCE_DOC_NUM]
		,[DID].[CODE_SKU]
		,MAX([S].[DESCRIPTION_SKU]) [DESCRIPTION_SKU]
		,CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER(MAX([PLS].[COST]))) [PRICE]
		,SUM(CASE [DID].[IS_GOOD_STATE] 
			WHEN 1 THEN [DID].[QTY_SKU]
			ELSE 0
		END) [GOOD_STATE_QTY]
		,SUM(CASE [DID].[IS_GOOD_STATE] 
			WHEN 0 THEN [DID].[QTY_SKU]
			ELSE 0
		END) [BAD_STATE_QTY]
		,SUM([DID].[QTY_SKU]) [TOTAL_QTY]
		
		,CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER(SUM(CASE CAST([DID].[IS_GOOD_STATE] AS NUMERIC(18,2))
			WHEN 1 THEN ([PLS].[COST] * [DID].[QTY_SKU])
			ELSE 0
		END))) [TOTAL_AMOUNT_IN_GOOD_STATE]
		,CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER(SUM(CASE CAST([DID].[IS_GOOD_STATE] AS NUMERIC(18,2))
			WHEN 0 THEN ([PLS].[COST] * [DID].[QTY_SKU])
			ELSE 0
		END))) [TOTAL_AMOUNT_IN_BAD_STATE]
		,CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER(SUM([DID].[TOTAL_AMOUNT]))) [TOTAL_AMOUNT]
    ,CASE WHEN ISNULL([DID].SERIAL_NUMBER,''0'') = ''0'' THEN ''N/A'' WHEN [DID].SERIAL_NUMBER = ''NULL'' THEN ''N/A'' ELSE [DID].SERIAL_NUMBER END AS [SERIAL_NUMBER]
	FROM [SONDA].[SONDA_DEVOLUTION_INVENTORY_DETAIL] [DID]
	INNER JOIN [SONDA].[SONDA_DEVOLUTION_INVENTORY_HEADER] [DIH] ON (
		[DIH].[DEVOLUTION_ID] = [DID].[DEVOLUTION_ID]
	)
	INNER JOIN [SONDA].[SWIFT_ROUTE_BY_USER] [RBU] ON (
		[RBU].[CODE_ROUTE] = [DIH].[CODE_ROUTE]
	)
	INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] [S] ON (
		[S].[CODE_SKU] = [DID].[CODE_SKU]
	)
	INNER JOIN [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C] ON (
		[C].[CODE_CUSTOMER] = [DIH].[CODE_CUSTOMER]
	)
	INNER JOIN [SONDA].[SWIFT_PRICE_LIST_BY_CUSTOMER] [PLC] ON (
		[PLC].[CODE_CUSTOMER] = [DIH].[CODE_CUSTOMER]
	)
	INNER JOIN [SONDA].[SWIFT_PRICE_LIST_BY_SKU] [PLS] ON (
		[PLS].[CODE_PRICE_LIST] = [PLC].[CODE_PRICE_LIST]
		AND [PLS].[CODE_SKU] = [DID].[CODE_SKU]
	)
	INNER JOIN [SONDA].[SWIFT_ROUTES] [R] ON (
		[R].[CODE_ROUTE] = [DIH].[CODE_ROUTE]
	)
	INNER JOIN [SONDA].[USERS] [U] ON (
		[U].[LOGIN] = [DID].[POSTED_BY]
	)
	INNER JOIN [SONDA].[SONDA_HISTORICAL_TRACEABILITY_CONSIGNMENT] [HTC] ON (
		[HTC].[DOC_SERIE_TARGET] = [DIH].[DOC_SERIE]
		AND [HTC].[DOC_NUM_TARGET] = [DIH].[DOC_NUM]
		AND [HTC].[CODE_SKU] = [DID].[CODE_SKU]
	)
	WHERE [RBU].[LOGIN] = ''' + @LOGIN + '''
		AND [DIH].[POSTED_DATETIME] BETWEEN ''' + CONVERT(VARCHAR,@START_DATETIME,121) + ''' AND ''' + CONVERT(VARCHAR,@END_DATETIME,121) + '''
	GROUP BY
		[DID].[DEVOLUTION_ID]
		,[DIH].[CODE_ROUTE]
		,[DID].[POSTED_BY]
		,[DIH].[DOC_SERIE]
		,[DIH].[DOC_NUM]
		,[HTC].[DOC_SERIE]
		,[HTC].[DOC_NUM]
		,[DID].[CODE_SKU]
    ,[DID].[SERIAL_NUMBER]
	ORDER BY [DID].[DEVOLUTION_ID]'
	--
	PRINT '----> @QUERY: ' + @QUERY
	--
	EXEC(@QUERY)
	--
	PRINT '----> DESPUES DE @QUERY'
END
