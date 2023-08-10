-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	20-08-2016 @ Sprint θ
-- Description:			SP que obtiene las listas de precio base

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[ERP_SP_GENERATE_PRICE_LIST_BY_SKU]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[ERP_SP_GENERATE_PRICE_LIST_BY_SKU]
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@PRICE_TYPE INT = 1
		,@CODE_CUSTOMER VARCHAR(50)
		,@CODE_ROUTE VARCHAR(50)
		,@CODE_PACK_UNIT_SMALLER VARCHAR(50) = 'PQT'
	--
	CREATE TABLE #PRICE_LIST_BY_SKU (
		[CODE_ROUTE] [varchar](50) NULL
		,[CODE_CUSTOMER] [varchar](50) NULL
		,[CODE_SKU] [varchar](50) NULL
		,[COST] [numeric](18, 6) NULL
		,[CODE_PACK_UNIT] [varchar](50) NULL
		,[UM_ENTRY] [varchar](50) NULL
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
		INSERT INTO #PRICE_LIST_BY_SKU
		SELECT DISTINCT
			DM.Z_RUTA CODE_ROUTE
			,DM.KUNNR CODE_CUSTOMER
			,DM.MATNR SKU	
			,DM.KBETR COST
			,DM.VRKME SKU_PACK_UNIT
			,DM.VRKME UM_ENTRY
		FROM [$(SAPR3)].dbo.ZTT_SD001_DATOS_MAESTROS DM
		WHERE DM.Z_TIPO_CLASE = @PRICE_TYPE
			AND DM.KUNNR = @CODE_CUSTOMER
			AND DM.Z_RUTA = @CODE_ROUTE
			AND DM.VRKME = @CODE_PACK_UNIT_SMALLER --Debe de ser solo una unidad de medida en la lista de precios base
			AND DM.KSTBM = 1 --Debe de ser uno porque es para la lista de precios base
			AND DM.MATNR != ''
		ORDER BY
			DM.Z_RUTA
			,DM.KUNNR
			,DM.MATNR
			,DM.KBETR
			,DM.VRKME
		--
		PRINT 'Obtubo precio por cliente y sku'

		-- ------------------------------------------------------------------------------------
		-- Obtiene los precios por sku
		-- ------------------------------------------------------------------------------------
		INSERT INTO #PRICE_LIST_BY_SKU
		SELECT DISTINCT
			DM.Z_RUTA
			,@CODE_CUSTOMER CLIENTE
			,DM.MATNR SKU
			,DM.KBETR COST
			,DM.VRKME SKU_PACK_UNIT
			,DM.VRKME UM_ENTRY		
		FROM [$(SAPR3)].dbo.ZTT_SD001_DATOS_MAESTROS DM
		LEFT JOIN #PRICE_LIST_BY_SKU P ON (
			P.CODE_CUSTOMER = @CODE_CUSTOMER
			AND P.CODE_ROUTE = @CODE_ROUTE
			AND P.CODE_SKU = DM.MATNR
			AND P.CODE_PACK_UNIT = DM.VRKME
		)
		WHERE DM.Z_TIPO_CLASE = @PRICE_TYPE
			AND DM.Z_RUTA = @CODE_ROUTE
			AND DM.VRKME = @CODE_PACK_UNIT_SMALLER --Debe de ser solo una unidad de medida en la lista de precios base
			AND DM.KSTBM = 1 --Debe de ser uno porque es para la lista de precios base
			AND DM.KUNNR = ''
		ORDER BY
			DM.Z_RUTA
			,DM.MATNR
			,DM.KBETR
			,DM.VRKME
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
	TRUNCATE TABLE SONDA.ERP_TB_PRICE_LIST_BY_SKU
	--
	INSERT INTO SONDA.ERP_TB_PRICE_LIST_BY_SKU
	SELECT
		[CODE_ROUTE]
		,[CODE_CUSTOMER]
		,[CODE_SKU]
		,[COST]
		,[CODE_PACK_UNIT]
		,[UM_ENTRY]		
	FROM #PRICE_LIST_BY_SKU
	ORDER BY 
		[CODE_ROUTE]
		,[CODE_CUSTOMER]
		,[CODE_SKU]
		,[COST]
		,[CODE_PACK_UNIT]
		,[UM_ENTRY]	

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado
	-- ------------------------------------------------------------------------------------
	SELECT
		[CODE_ROUTE]
		,[CODE_CUSTOMER]
		,[CODE_SKU]
		,[COST]
		,[CODE_PACK_UNIT]
		,[UM_ENTRY]		
	FROM SONDA.ERP_TB_PRICE_LIST_BY_SKU
	ORDER BY CODE_ROUTE,CODE_CUSTOMER,CODE_SKU,CODE_PACK_UNIT
END

