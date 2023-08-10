-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	18-Nov-16 @ A-TEAM Sprint 5 
-- Description:			SP para obtgener el detalle de la liquidacion

-- Modificacion 4/3/2017 @ A-Team Sprint Garai
					-- diego.as
					-- Se agrega Columna IS_READY_TO_SEND al momento de obtener las facturas de la liquidacion

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_LIQUIDATION_DOCUMENT_BY_SKU]
					@LIQUIDATION_ID = 6
					,@CODE_SKU = '100002'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_LIQUIDATION_DOCUMENT_BY_SKU](
	@LIQUIDATION_ID BIGINT
	,@CODE_SKU VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE 
		@DEFAULT_DISPLAY_DECIMALS INT
		,@QUERY NVARCHAR(4000)
	--
	SELECT @DEFAULT_DISPLAY_DECIMALS = [SONDA].[SWIFT_FN_GET_PARAMETER]('CALCULATION_RULES','DEFAULT_DISPLAY_DECIMALS')
	--
	DECLARE	@RESULT [SONDA].LIQUIDATION_DOCUMENT_BY_SKU
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene la carga de inventario
	-- ------------------------------------------------------------------------------------
	INSERT INTO @RESULT
			(
				[DOCUMENT_TYPE]
				,[DOC_RESOLUTION]
				,[DOC_SERIE]
				,[DOC_NUM]
				,[CODE_SKU]
				,[SKU_DESCRIPTION]
				,[QTY]
				,[PRICE]
				,[TOTAL_LINE]
			)
	SELECT
		'Carga Inicial'
		,NULL
		,NULL
		,NULL
		,[PSH].[CODE_SKU]
		,[PSH].[DESCRIPTION_SKU]
		,[PSH].[INITIAL_QTY]
		,[PSH].[SKU_PRICE]
		,([PSH].[INITIAL_QTY] * [PSH].[SKU_PRICE])
	FROM [SONDA].[SONDA_LIQUIDATION] [L]
	INNER JOIN [SONDA].[SONDA_POS_SKU_HISTORICAL] [PSH] ON (
		[PSH].[LIQUIDATION_ID] = [L].[LIQUIDATION_ID]
	)
	WHERE [L].[LIQUIDATION_ID] = @LIQUIDATION_ID
		AND [PSH].[CODE_SKU] = @CODE_SKU

	-- ------------------------------------------------------------------------------------
	-- Obtiene las facturas de la liquidacion
	-- ------------------------------------------------------------------------------------
	INSERT INTO @RESULT
			(
				[DOCUMENT_TYPE]
				,[DOC_RESOLUTION]
				,[DOC_SERIE]
				,[DOC_NUM]
				,[CODE_SKU]
				,[SKU_DESCRIPTION]
				,[QTY]
				,[PRICE]
				,[TOTAL_LINE]
			)
	SELECT
		'Factura'
		,[IH].[CDF_RESOLUCION]
		,[IH].[CDF_SERIE]
		,[IH].[INVOICE_ID]
		,[ID].[SKU]
		,[S].[DESCRIPTION_SKU]
		,[ID].[QTY]
		,[ID].[PRICE]
		,[ID].[TOTAL_LINE]
	FROM [SONDA].[SONDA_POS_INVOICE_HEADER] [IH]
	INNER JOIN [SONDA].[SONDA_POS_INVOICE_DETAIL] [ID] ON (
		[ID].[INVOICE_ID] = [IH].[INVOICE_ID]
		AND [ID].[INVOICE_SERIAL] = [IH].[CDF_SERIE]
		AND [ID].[INVOICE_RESOLUTION] = [IH].[CDF_RESOLUCION]
	)
	INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] [S] ON (
		[S].[CODE_SKU] = [ID].[SKU]
	)
	WHERE [IH].[LIQUIDATION_ID] = @LIQUIDATION_ID
		AND [ID].[SKU] = @CODE_SKU
		AND [IH].[IS_READY_TO_SEND] = 1
	-- ------------------------------------------------------------------------------------
	-- Obtiene las consignaciones
	-- ------------------------------------------------------------------------------------
	INSERT INTO @RESULT
			(
				[DOCUMENT_TYPE]
				,[DOC_RESOLUTION]
				,[DOC_SERIE]
				,[DOC_NUM]
				,[CODE_SKU]
				,[SKU_DESCRIPTION]
				,[QTY]
				,[PRICE]
				,[TOTAL_LINE]
			)
	SELECT
		'Consignaciones'
		,NULL
		,[CH].[DOC_SERIE]
		,[CH].[DOC_NUM]
		,[CD].[SKU]
		,[S].[DESCRIPTION_SKU]
		,[CD].[QTY]
		,[CD].[PRICE]
		,[CD].[TOTAL_LINE]
	FROM [SONDA].[SWIFT_CONSIGNMENT_HEADER] [CH]
	INNER JOIN [SONDA].[SWIFT_CONSIGNMENT_DETAIL] [CD] ON (
		[CD].[CONSIGNMENT_ID] = [CH].[CONSIGNMENT_ID]
	)
	INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] [S] ON (
		[S].[CODE_SKU] = [CD].[SKU]
	)
	WHERE [CH].[LIQUIDATION_ID] = @LIQUIDATION_ID
		AND [CD].[SKU] = @CODE_SKU

	-- ------------------------------------------------------------------------------------
	-- Obtiene las devoluciones
	-- ------------------------------------------------------------------------------------
	INSERT INTO @RESULT
			(
				[DOCUMENT_TYPE]
				,[DOC_RESOLUTION]
				,[DOC_SERIE]
				,[DOC_NUM]
				,[CODE_SKU]
				,[SKU_DESCRIPTION]
				,[QTY]
				,[PRICE]
				,[TOTAL_LINE]
			)
	SELECT DISTINCT
		'Devoluciones'
		,NULL
		,[DH].[DOC_SERIE]
		,[DH].[DOC_NUM]
		,[DD].[CODE_SKU]
		,[S].[DESCRIPTION_SKU]
		,[CD].[QTY]
		,[CD].[PRICE]
		,[CD].[TOTAL_LINE]
	FROM [SONDA].[SONDA_DEVOLUTION_INVENTORY_HEADER] [DH]
	INNER JOIN [SONDA].[SONDA_DEVOLUTION_INVENTORY_DETAIL] [DD] ON (
		[DD].[DEVOLUTION_ID] = [DH].[DEVOLUTION_ID]
	)
	INNER JOIN [SONDA].[SONDA_HISTORICAL_TRACEABILITY_CONSIGNMENT] [HTC] ON (
		[HTC].[DOC_SERIE_TARGET] = [DH].[DOC_SERIE]
		AND [HTC].[DOC_NUM_TARGET] = [DH].[DOC_NUM]
		AND [HTC].[CODE_SKU] = [DD].[CODE_SKU]
	)
	INNER JOIN [SONDA].[SWIFT_CONSIGNMENT_HEADER] [CH] ON (
		[HTC].[DOC_SERIE] = [CH].[DOC_SERIE]
		AND [HTC].[DOC_NUM] = [CH].[DOC_NUM]
	)
	INNER JOIN [SONDA].[SWIFT_CONSIGNMENT_DETAIL] [CD] ON (
		[CD].[CONSIGNMENT_ID] = [CH].[CONSIGNMENT_ID]
		AND [HTC].[CODE_SKU] = [CD].[SKU]
	)
	INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] [S] ON (
		[S].[CODE_SKU] = [DD].[CODE_SKU]
	)
	WHERE [DH].[LIQUIDATION_ID] = @LIQUIDATION_ID
		AND [dd].[CODE_SKU] = @CODE_SKU

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado final
	-- ------------------------------------------------------------------------------------
	SET @QUERY = N'SELECT
		[R].[DOCUMENT_TYPE]
		,[R].[DOC_RESOLUTION]
		,[R].[DOC_SERIE]
		,[R].[DOC_NUM]
		,[R].[CODE_SKU]
		,[R].[SKU_DESCRIPTION]
		,[R].[QTY]
		,CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER([R].[PRICE])) AS [PRICE]
		,CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER([R].[TOTAL_LINE])) AS [TOTAL_LINE]
	FROM @RESULT [R]'
	--
	PRINT '----> @QUERY: ' + @QUERY
	--
	EXEC sp_executesql 
		@QUERY
		,N'@RESULT LIQUIDATION_DOCUMENT_BY_SKU readonly'
		,@RESULT = @RESULT
	--
	PRINT '----> DESPUES DE @QUERY'
END
