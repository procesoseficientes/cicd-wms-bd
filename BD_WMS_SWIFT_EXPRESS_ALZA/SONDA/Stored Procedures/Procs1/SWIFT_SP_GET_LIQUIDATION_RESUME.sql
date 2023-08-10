-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	17-Nov-16 @ A-TEAM Sprint 5 
-- Description:			SP para obtener el resumen de la liquidacion

-- Modificacion 4/3/2017 @ A-Team Sprint Garai
					-- diego.as
					-- Se agrega columna IS_READY_TO_SEND para filtrar las facturas de la ruta.

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_LIQUIDATION_RESUME]
					@LIQUIDATION_ID = 6
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_LIQUIDATION_RESUME](
	@LIQUIDATION_ID BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE	@RESULT TABLE (
		[DOCUMENT_TYPE] VARCHAR(50)
		,[LOGIN] VARCHAR(50)
		,[CODE_ROUTE] VARCHAR(50)
		,[CODE_SKU] VARCHAR(50)
		,[SKU_DESCRIPTION] VARCHAR(MAX)
		,[IN_INVENTORY] NUMERIC(18 ,0)
		,[OUT_INVENTORY] NUMERIC(18 ,2)
	);
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene la carga de inventario
	-- ------------------------------------------------------------------------------------
	INSERT INTO @RESULT
			(
				[DOCUMENT_TYPE]
				,[LOGIN]
				,[CODE_ROUTE]
				,[CODE_SKU]
				,[SKU_DESCRIPTION]
				,[IN_INVENTORY]
				,[OUT_INVENTORY]
			)
	SELECT
		'Carga Inicial'
		,[L].[LOGIN]
		,[L].[CODE_ROUTE]
		,[PSH].[CODE_SKU]
		,[PSH].[DESCRIPTION_SKU]
		,[PSH].[INITIAL_QTY]
		,0
	FROM [SONDA].[SONDA_LIQUIDATION] [L]
	INNER JOIN [SONDA].[SONDA_POS_SKU_HISTORICAL] [PSH] ON (
		[PSH].[LIQUIDATION_ID] = [L].[LIQUIDATION_ID]
	)
	WHERE [L].[LIQUIDATION_ID] = @LIQUIDATION_ID

	-- ------------------------------------------------------------------------------------
	-- Obtiene las facturas de la liquidacion
	-- ------------------------------------------------------------------------------------
	INSERT INTO @RESULT
			(
				[DOCUMENT_TYPE]
				,[LOGIN]
				,[CODE_ROUTE]
				,[CODE_SKU]
				,[SKU_DESCRIPTION]
				,[IN_INVENTORY]
				,[OUT_INVENTORY]
			)
	SELECT
		'Factura'
		,MAX([IH].[POSTED_BY])
		,MAX([IH].[POS_TERMINAL])
		,[ID].[SKU]
		,MAX([S].[DESCRIPTION_SKU])
		,0
		,SUM([ID].[QTY])
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
		AND [IH].[IS_READY_TO_SEND] = 1
	GROUP BY [ID].[SKU]

	-- ------------------------------------------------------------------------------------
	-- Obtiene las consignaciones
	-- ------------------------------------------------------------------------------------
	INSERT INTO @RESULT
			(
				[DOCUMENT_TYPE]
				,[LOGIN]
				,[CODE_ROUTE]
				,[CODE_SKU]
				,[SKU_DESCRIPTION]
				,[IN_INVENTORY]
				,[OUT_INVENTORY]
			)
	SELECT
		'Consignaciones'
		,MAX([CH].[POSTED_BY])
		,MAX([CH].[POS_TERMINAL])
		,[CD].[SKU]
		,MAX([S].[DESCRIPTION_SKU])
		,0
		,SUM([CD].[QTY])
	FROM [SONDA].[SWIFT_CONSIGNMENT_HEADER] [CH]
	INNER JOIN [SONDA].[SWIFT_CONSIGNMENT_DETAIL] [CD] ON (
		[CD].[CONSIGNMENT_ID] = [CH].[CONSIGNMENT_ID]
	)
	INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] [S] ON (
		[S].[CODE_SKU] = [CD].[SKU]
	)
	WHERE [CH].[LIQUIDATION_ID] = @LIQUIDATION_ID
	GROUP BY [CD].[SKU]

	-- ------------------------------------------------------------------------------------
	-- Obtiene las devoluciones
	-- ------------------------------------------------------------------------------------
	INSERT INTO @RESULT
			(
				[DOCUMENT_TYPE]
				,[LOGIN]
				,[CODE_ROUTE]
				,[CODE_SKU]
				,[SKU_DESCRIPTION]
				,[IN_INVENTORY]
				,[OUT_INVENTORY]
			)
	SELECT
		'Devoluciones'
		,MAX([DH].[POSTED_BY])
		,MAX([DH].[CODE_ROUTE])
		,[DD].[CODE_SKU]
		,MAX([S].[DESCRIPTION_SKU])
		,SUM([DD].[QTY_SKU])
		,0
	FROM [SONDA].[SONDA_DEVOLUTION_INVENTORY_HEADER] [DH]
	INNER JOIN [SONDA].[SONDA_DEVOLUTION_INVENTORY_DETAIL] [DD] ON (
		[DD].[DEVOLUTION_ID] = [DH].[DEVOLUTION_ID]
	)
	INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] [S] ON (
		[S].[CODE_SKU] = [DD].[CODE_SKU]
	)
	WHERE [DH].[LIQUIDATION_ID] = @LIQUIDATION_ID
	GROUP BY [DD].[CODE_SKU]

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado final
	-- ------------------------------------------------------------------------------------
	SELECT
		[R].[DOCUMENT_TYPE]
		,[R].[LOGIN]
		,[U].[NAME_USER]
		,[R].[CODE_ROUTE]
		,[SR].[NAME_ROUTE] [ROUTE_NAME]
		,[R].[CODE_SKU]
		,[R].[SKU_DESCRIPTION]
		,[R].[IN_INVENTORY]
		,[R].[OUT_INVENTORY]
		,CASE  
			WHEN ([R].[IN_INVENTORY] - [R].[OUT_INVENTORY]) > 0 THEN '+'
			ELSE '-'
		END [LINE_STATUS]
	FROM @RESULT [R]
	LEFT JOIN [SONDA].[USERS] [U] ON (
		[U].[LOGIN] = [R].[LOGIN]
	)
	INNER JOIN [SONDA].[SWIFT_ROUTES] [SR] ON (
		[SR].[CODE_ROUTE] = [R].[CODE_ROUTE]
	)
END
