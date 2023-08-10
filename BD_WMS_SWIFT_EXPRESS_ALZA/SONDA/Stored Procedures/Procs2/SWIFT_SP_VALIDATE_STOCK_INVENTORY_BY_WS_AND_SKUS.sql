-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	05-04-2016
-- Description:			Valida si hay inventario disponible para un SKU

-- Modificacion 31-Jan-17 @ A-Team Sprint Bankole
					-- alberto.ruiz
					-- Se corrigio la forma de obtener el inventario reservado

/*
-- Ejemplo de Ejecucion:
        USE SWIFT_EXPRESS
        GO
        --
        EXEC [SONDA].[SWIFT_SP_VALIDATE_STOCK_INVENTORY_BY_WS_AND_SKUS]
			@CODE_WAREHOUSE = 'C002'
			,@CODE_SKU = '100001|100021'
			,@QTY = '40|1901'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_VALIDATE_STOCK_INVENTORY_BY_WS_AND_SKUS]
		@CODE_WAREHOUSE VARCHAR(50)
		,@CODE_SKU VARCHAR(4000)
		,@QTY VARCHAR(4000)
AS
BEGIN
	DECLARE @DELIMITER CHAR(1)
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene el delimitador
	-- ------------------------------------------------------------------------------------
	SELECT @DELIMITER = P.VALUE
	FROM [SONDA].SWIFT_PARAMETER P
	WHERE P.GROUP_ID = 'DELIMITER' 
		AND P.PARAMETER_ID = 'DEFAULT_DELIMITER'
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene los sku
	-- ------------------------------------------------------------------------------------
	SELECT
		S.ID
		,S.VALUE CODE_SKU
	INTO #SKU
	FROM [SONDA].[SWIFT_FN_SPLIT](@CODE_SKU,@DELIMITER) S	

	-- ------------------------------------------------------------------------------------
	-- Obtiene las cantidades
	-- ------------------------------------------------------------------------------------
	SELECT
		S.ID
		,CONVERT(INT,S.VALUE) QTY
	INTO #QTY
	FROM [SONDA].[SWIFT_FN_SPLIT](@QTY,@DELIMITER) S

	-- ------------------------------------------------------------------------------------
	-- Obtiene el inventario reservado
	-- ------------------------------------------------------------------------------------
	SELECT 
		[R].[CODE_SKU]
		,[R].[QYT_RESERVED]
	INTO #RESERVED
	FROM [SONDA].[SWIFT_FN_GET_INVENTORY_RESERVED](@CODE_WAREHOUSE) [R]
	INNER JOIN [#SKU] [S] ON (
		[S].[CODE_SKU] = [R].[CODE_SKU]
	)
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene el invetario disponible
	-- ------------------------------------------------------------------------------------
	SELECT 
		S.CODE_SKU AS SKU
		,MAX(VS.DESCRIPTION_SKU) SKU_DESCRIPTION
		,CASE
			WHEN ISNULL((SUM(I.ON_HAND) - COALESCE(MAX(IR.QYT_RESERVED), 0)),0) > 0 THEN ISNULL((SUM(I.ON_HAND) - COALESCE(MAX(IR.QYT_RESERVED), 0)),0)
			ELSE 0
		END ON_HAND
		--,ISNULL((SUM(I.ON_HAND) - COALESCE(MAX(IR.QYT_RESERVED), 0)),0) ON_HAND
		,MAX(Q.QTY) AS REQUEST_QTY
		,CASE
			WHEN (SUM(I.ON_HAND) - COALESCE(MAX(IR.QYT_RESERVED), 0)) >= MAX(Q.QTY) THEN 1
			ELSE 0
		END IS_AVAILABLE
		,CASE
			WHEN ISNULL((SUM(I.ON_HAND) - COALESCE(MAX(IR.QYT_RESERVED), 0)),0) > 0 THEN (MAX(Q.QTY) - ISNULL((SUM(I.ON_HAND) - COALESCE(MAX(IR.QYT_RESERVED), 0)),0))
			ELSE MAX(Q.QTY)
		END AS [DIFFERENCE]
		--,(MAX(Q.QTY) - ISNULL((SUM(I.ON_HAND) - COALESCE(MAX(IR.QYT_RESERVED), 0)),0)) AS [DIFFERENCE]
	INTO #INVENTORY
	FROM #SKU S
	INNER JOIN #QTY Q ON (S.ID = Q.ID)
	INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] VS ON (VS.CODE_SKU = S.CODE_SKU)
	LEFT JOIN [SONDA].SWIFT_INVENTORY I ON (
		I.SKU = S.CODE_SKU
		AND I.WAREHOUSE = @CODE_WAREHOUSE
		AND I.LAST_UPDATE_BY != 'BULK_DATA'
		AND [I].[ON_HAND] > 0
	)
	LEFT JOIN #RESERVED IR ON (I.SKU = IR.CODE_SKU)
	GROUP BY S.CODE_SKU

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado
	-- ------------------------------------------------------------------------------------
	SELECT 
		I.SKU
		,I.SKU_DESCRIPTION
		,I.ON_HAND
		,I.REQUEST_QTY
		,I.[DIFFERENCE]
	FROM #INVENTORY I
	WHERE I.IS_AVAILABLE != 1
END
