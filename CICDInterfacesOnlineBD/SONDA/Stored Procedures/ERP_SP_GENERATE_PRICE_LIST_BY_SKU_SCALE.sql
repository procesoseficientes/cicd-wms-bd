-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	19-08-2016 @ Sprint θ
-- Description:			SP que obtiene las listas de precios por sku y escala

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[ERP_SP_GENERATE_PRICE_LIST_BY_SKU_SCALE]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[ERP_SP_GENERATE_PRICE_LIST_BY_SKU_SCALE]
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@PRICE_TYPE INT = 1
		,@CODE_CUSTOMER VARCHAR(50)
		,@CODE_ROUTE VARCHAR(50)
	--
	CREATE TABLE #PRICE_LIST_BY_SKU_SCALE (
		[CODE_ROUTE] [varchar](50) NULL
		,[CODE_CUSTOMER] [varchar](50) NULL
		,[CODE_SKU] [varchar](50) NULL
		,[CODE_PACK_UNIT] [varchar](50) NULL
		,[LIMIT] [numeric](18, 0) NULL
		,[COST] [numeric](18, 6) NULL
	) 

	-- ------------------------------------------------------------------------------------
	-- Obtiene los clientes por ruta
	-- ------------------------------------------------------------------------------------
	SELECT
		C.KUNNR CODE_CUSTOMER
		,C.Z_RUTA CODE_ROUTE
	INTO #CUSTOMER_BY_ROUTE
	FROM [$(SAPR3)].dbo.ZTT_CLIENTE_SONDA C

	-- ------------------------------------------------------------------------------------
	-- Recorre cada registro y lo manda a ejecutar
	-- ------------------------------------------------------------------------------------
	PRINT 'Inicia ciclo'
	--
	WHILE EXISTS(SELECT TOP 1 1 FROM #CUSTOMER_BY_ROUTE)
	BEGIN
		-- ------------------------------------------------------------------------------------
		-- Obtiene el cliente por ruta para obtener descuentos
		-- ------------------------------------------------------------------------------------
		SELECT
			@CODE_CUSTOMER = CODE_CUSTOMER
			,@CODE_ROUTE = CODE_ROUTE
		FROM #CUSTOMER_BY_ROUTE
		--
		PRINT '@CODE_CUSTOMER: ' + @CODE_CUSTOMER
		PRINT '@CODE_ROUTE: ' + @CODE_ROUTE

		-- ------------------------------------------------------------------------------------
		-- Obtiene los precio por cliente y sku
		-- ------------------------------------------------------------------------------------
		INSERT INTO #PRICE_LIST_BY_SKU_SCALE
		SELECT DISTINCT
			DM.Z_RUTA CODE_ROUTE
			,DM.KUNNR CODE_CUSTOMER
			,DM.MATNR SKU	
			,DM.VRKME SKU_PACK_UNIT
			,DM.KSTBM RANGO_INICIAL
			,DM.KBETR PRICE
		FROM [$(SAPR3)].dbo.ZTT_SD001_DATOS_MAESTROS DM
		WHERE DM.Z_TIPO_CLASE = @PRICE_TYPE
			AND DM.KUNNR = @CODE_CUSTOMER
			AND DM.Z_RUTA = @CODE_ROUTE
			AND DM.MATNR != ''
		ORDER BY
			DM.Z_RUTA
			,DM.KUNNR
			,DM.MATNR
		--
		PRINT 'Obtubo precio por cliente y sku'

		-- ------------------------------------------------------------------------------------
		-- Obtiene los precios por sku
		-- ------------------------------------------------------------------------------------
		INSERT INTO #PRICE_LIST_BY_SKU_SCALE
		SELECT
			DM.Z_RUTA
			,@CODE_CUSTOMER CLIENTE
			,DM.MATNR SKU	
			,DM.VRKME SKU_PACK_UNIT
			,DM.KSTBM RANGO_INICIAL
			,DM.KBETR PRICE
		FROM [$(SAPR3)].dbo.ZTT_SD001_DATOS_MAESTROS DM
		LEFT JOIN #PRICE_LIST_BY_SKU_SCALE P ON (
			P.CODE_CUSTOMER = @CODE_CUSTOMER
			AND P.CODE_ROUTE = @CODE_ROUTE
			AND P.CODE_SKU = DM.MATNR
			AND P.CODE_PACK_UNIT = DM.VRKME
			AND P.LIMIT = DM.KSTBM
		)
		WHERE DM.Z_TIPO_CLASE = @PRICE_TYPE
			AND DM.Z_RUTA = @CODE_ROUTE
			AND DM.KUNNR = ''
			AND P.CODE_SKU IS NULL
		ORDER BY
			DM.Z_RUTA
			,DM.KUNNR
			,DM.MATNR
		--
		PRINT 'Obtubo precios por sku'

		-- ------------------------------------------------------------------------------------
		-- Elimina el cliente actual por ruta
		-- ------------------------------------------------------------------------------------
		DELETE FROM #CUSTOMER_BY_ROUTE WHERE CODE_CUSTOMER = @CODE_CUSTOMER AND CODE_ROUTE = @CODE_ROUTE
		--
		PRINT 'Elimina registro'
	END
	--
	PRINT 'Termina ciclo'	

	-- ------------------------------------------------------------------------------------
	-- Se cargan las nuevas bonificaciones
	-- ------------------------------------------------------------------------------------
	TRUNCATE TABLE SONDA.ERP_TB_PRICE_LIST_BY_SKU_PACK_SCALE
	--
	INSERT INTO SONDA.ERP_TB_PRICE_LIST_BY_SKU_PACK_SCALE
	SELECT
		[CODE_ROUTE]
		,[CODE_CUSTOMER]
		,[CODE_SKU]
		,[CODE_PACK_UNIT]
		,[LIMIT]
		,[COST]
	FROM #PRICE_LIST_BY_SKU_SCALE
	ORDER BY CODE_ROUTE,CODE_CUSTOMER,CODE_SKU,CODE_PACK_UNIT

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado
	-- ------------------------------------------------------------------------------------
	SELECT
		[CODE_ROUTE]
		,[CODE_CUSTOMER]
		,[CODE_SKU]
		,[CODE_PACK_UNIT]
		,[LIMIT]
		,[COST]
	FROM SONDA.ERP_TB_PRICE_LIST_BY_SKU_PACK_SCALE
	ORDER BY CODE_ROUTE,CODE_CUSTOMER,CODE_SKU
END

