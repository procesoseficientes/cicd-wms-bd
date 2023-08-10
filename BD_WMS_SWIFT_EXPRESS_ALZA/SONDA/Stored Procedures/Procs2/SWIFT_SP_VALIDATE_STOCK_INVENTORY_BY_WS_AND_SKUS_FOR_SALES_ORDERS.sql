-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	05-04-2016
-- Description:			Valida si hay inventario disponible para las ordenes de venta

/*
-- Ejemplo de Ejecucion:
        USE SWIFT_EXPRESS
        GO
        --
        EXEC [SONDA].[SWIFT_SP_VALIDATE_STOCK_INVENTORY_BY_WS_AND_SKUS_FOR_SALES_ORDERS]
			    @CODE_WAREHOUSE = 'BODEGA_CENTRAL'
			    ,@SALES_ORDERS = '831|833'
			    
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_VALIDATE_STOCK_INVENTORY_BY_WS_AND_SKUS_FOR_SALES_ORDERS
		@CODE_WAREHOUSE VARCHAR(50)		
    ,@SALES_ORDERS  VARCHAR(MAX)
AS
BEGIN
	DECLARE @DELIMITER CHAR(1)
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene el inventario reservado
	-- ------------------------------------------------------------------------------------
	SELECT *
	INTO #RESERVED
	FROM [SONDA].[SWIFT_FN_GET_INVENTORY_RESERVED](@CODE_WAREHOUSE) R	

	-- ------------------------------------------------------------------------------------
	-- Obtiene el delimitador
	-- ------------------------------------------------------------------------------------
	SELECT @DELIMITER = P.VALUE
	FROM [SONDA].SWIFT_PARAMETER P
	WHERE P.GROUP_ID = 'DELIMITER' 
		AND P.PARAMETER_ID = 'DEFAULT_DELIMITER'
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene las ordenes de venta
	-- ------------------------------------------------------------------------------------
	SELECT
		S.ID
		,S.VALUE SALES_ORDER
	INTO #SALES_ORDER
	FROM [SONDA].[SWIFT_FN_SPLIT](@SALES_ORDERS,@DELIMITER) S
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene el invetario disponible
	-- ------------------------------------------------------------------------------------
	SELECT
    SOD.SALES_ORDER_ID AS SALES_ORDER_ID
		,SOD.SKU AS SKU
		,MAX(VS.DESCRIPTION_SKU) SKU_DESCRIPTION
		,ISNULL((SUM(I.ON_HAND) - COALESCE(MAX(IR.QYT_RESERVED), 0)),0) ON_HAND
		,SUM(SOD.QTY) AS REQUEST_QTY
		,CASE
			WHEN (SUM(I.ON_HAND) - COALESCE(MAX(IR.QYT_RESERVED), 0)) >= SUM(SOD.QTY) THEN 1
			ELSE 0
		END IS_AVAILABLE
		,(SUM(SOD.QTY) - ISNULL((SUM(I.ON_HAND) - COALESCE(MAX(IR.QYT_RESERVED), 0)),0)) AS [DIFFERENCE]
	INTO #INVENTORY
	FROM #SALES_ORDER SO
	INNER JOIN [SONDA].SONDA_SALES_ORDER_DETAIL SOD ON (
    SOD.SALES_ORDER_ID = SO.SALES_ORDER
  )
	INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] VS ON (
    VS.CODE_SKU = SOD.SKU
  )
	LEFT JOIN [SONDA].SWIFT_INVENTORY I ON (
		I.SKU = SOD.SKU
		AND I.WAREHOUSE = @CODE_WAREHOUSE
		AND I.LAST_UPDATE_BY != 'BULK_DATA'
	)
	LEFT JOIN #RESERVED IR ON (I.SKU = IR.CODE_SKU)
	GROUP BY SOD.SALES_ORDER_ID, SOD.SKU

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado
	-- ------------------------------------------------------------------------------------
	SELECT
    I.SALES_ORDER_ID
		,I.SKU
		,I.SKU_DESCRIPTION
		,I.ON_HAND
		,I.REQUEST_QTY
		,I.[DIFFERENCE]
	FROM #INVENTORY I
	WHERE I.IS_AVAILABLE != 1
END
