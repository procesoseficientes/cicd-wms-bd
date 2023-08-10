-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	25-08-2016 @ Sprint θ
-- Description:			SP que obtiene las listas por defecto para listas por base y con escala 

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[ERP_SP_GENERATE_DEFAULT_PRICE_LIST]
*/
-- =============================================
create PROCEDURE [SONDA].[ERP_SP_GENERATE_DEFAULT_PRICE_LIST]
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@PRICE_TYPE INT = 1
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
		C.Z_RUTA CODE_ROUTE
	INTO #ROUTE
	FROM [$(SAPR3)].dbo.ZTT_CLIENTE_SONDA C

	-- ------------------------------------------------------------------------------------
	-- Recorre cada registro y lo manda a ejecutar
	-- ------------------------------------------------------------------------------------
	PRINT 'Inicia ciclo'
	--
	WHILE EXISTS(SELECT TOP 1 1 FROM #ROUTE)
	BEGIN
		-- ------------------------------------------------------------------------------------
		-- Obtiene el cliente por ruta para obtener descuentos
		-- ------------------------------------------------------------------------------------
		SELECT
			@CODE_ROUTE = CODE_ROUTE
		FROM #ROUTE
		--
		PRINT '@CODE_ROUTE: ' + @CODE_ROUTE

		-- ------------------------------------------------------------------------------------
		-- Obtiene los precio base por ruta
		-- ------------------------------------------------------------------------------------
		INSERT INTO #PRICE_LIST_BY_SKU
		SELECT DISTINCT
			DM.Z_RUTA CODE_ROUTE
			,DM.Z_RUTA CODE_CUSTOMER --Se coloco el mismo campo porque es la defecto por ruta
			,DM.MATNR SKU	
			,DM.KBETR COST
			,DM.VRKME SKU_PACK_UNIT
			,DM.VRKME UM_ENTRY
		FROM [$(SAPR3)].dbo.ZTT_SD001_DATOS_MAESTROS DM
		WHERE DM.Z_TIPO_CLASE = @PRICE_TYPE
			AND DM.KSTBM = 1 --Debe de ser uno porque es para la lista de precios base
			AND DM.Z_RUTA = @CODE_ROUTE
			AND DM.KUNNR = ''
			AND DM.MATNR != ''
			AND DM.VRKME = @CODE_PACK_UNIT_SMALLER --Debe de ser solo una unidad de medida en la lista de precios base
		ORDER BY
			DM.Z_RUTA
			,DM.MATNR
			,DM.KBETR
			,DM.VRKME
		--
		PRINT 'Obtubo precios por base por defecto'

		-- ------------------------------------------------------------------------------------
		-- Obtiene la lista de precios con escala por defecto por ruta
		-- ------------------------------------------------------------------------------------
		INSERT INTO #PRICE_LIST_BY_SKU_SCALE
		SELECT DISTINCT
			DM.Z_RUTA CODE_ROUTE
			,DM.Z_RUTA CODE_CUSTOMER --Se coloco el mismo campo porque es la defecto por ruta
			,DM.MATNR SKU	
			,DM.VRKME SKU_PACK_UNIT
			,DM.KSTBM RANGO_INICIAL
			,DM.KBETR PRICE
		FROM [$(SAPR3)].dbo.ZTT_SD001_DATOS_MAESTROS DM
		WHERE DM.Z_TIPO_CLASE = @PRICE_TYPE
			AND DM.Z_RUTA = @CODE_ROUTE
			AND DM.KUNNR = ''
			AND DM.MATNR != ''
		ORDER BY
			DM.Z_RUTA
			,DM.MATNR
		--
		PRINT 'Obtubo precios con escala por defecto'

		-- ------------------------------------------------------------------------------------
		-- Elimina el cliente actual por ruta
		-- ------------------------------------------------------------------------------------
		DELETE FROM #ROUTE WHERE CODE_ROUTE = @CODE_ROUTE
		--
		PRINT 'Elimina registro'
	END
	--
	PRINT 'Termina ciclo'

	-- ------------------------------------------------------------------------------------
	-- Se cargan las nuevas bonificaciones
	-- ------------------------------------------------------------------------------------
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
	-- Se cargan las nuevas escalas por defecto
	-- ------------------------------------------------------------------------------------
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


END

