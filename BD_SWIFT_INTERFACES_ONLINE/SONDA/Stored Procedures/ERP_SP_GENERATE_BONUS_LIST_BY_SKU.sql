-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	17-Oct-16 @ A-TEAM Sprint 3
-- Description:			SP que obtiene las bonificaciones por cliente producto

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[ERP_SP_GENERATE_BONUS_LIST_BY_SKU]
					@BONUS_TYPE = 3
					,@ORDER = 1
*/
-- =============================================
CREATE PROCEDURE [SONDA].[ERP_SP_GENERATE_BONUS_LIST_BY_SKU](
	@BONUS_TYPE INT
	,@ORDER INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@CODE_CUSTOMER VARCHAR(50)
		,@CODE_ROUTE VARCHAR(50)
	--
	CREATE TABLE #BONUS(
		[CODE_ROUTE] [varchar](50) NULL
		,[CODE_CUSTOMER] [varchar](50) NULL
		,[SKU] [varchar](50) NULL
		,[SKU_PACK_UNIT] [varchar](50) NULL
		,[LOW_LIMIT] [numeric](18, 6) NULL
		,[HIGT_LIMIT] [numeric](18, 6) NULL
		,[BONUS_QTY] [numeric](18, 6) NULL
		,[BONUS_SKU] [varchar](18) NULL
		,[BONUS_PACK_UNIT] [varchar](50) NULL
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
	-- Limpia la tabla de ser necesario --Se limpia cuando el orden es 1 porque es el primero en ejecutar
	-- ------------------------------------------------------------------------------------
	IF @ORDER = 1
	BEGIN
		TRUNCATE TABLE [SONDA].[ERP_TB_BONUS]
		--
		PRINT '----> Limpio tabla'
	END

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
		-- Obtiene las bonificaciones sku
		-- ------------------------------------------------------------------------------------
		INSERT INTO #BONUS
		SELECT
			DM.Z_RUTA
			,@CODE_CUSTOMER CLIENTE
			,DM.MATNR SKU	
			,CAST(DM.Z_KNREZ AS varchar) UNIDAD_DE_SKU_PARA_BONIFICACION --Se coloco el cast porque esta un valor incorrecto en la data
			,DM.KNRMM RANGO_INICIAL
			,ISNULL(DM.Z_KNRMM,1000000) RANGO_FINAL
			,DM.KNRNM CANTIDAD_BONIFICADA	
			,DM.KNRMAT SKU_BONIFICADO
			,DM.KNREZ UNIDAD_DE_BONIFICACION
		FROM [$(SAPR3)].dbo.ZTT_SD001_DATOS_MAESTROS DM
		LEFT JOIN [SONDA].[ERP_TB_BONUS] B ON (
			B.CODE_CUSTOMER = @CODE_CUSTOMER
			AND B.CODE_ROUTE = @CODE_ROUTE
			AND B.SKU = DM.MATNR
		)
		WHERE DM.Z_TIPO_CLASE = @BONUS_TYPE
			AND DM.Z_RUTA = @CODE_ROUTE
			AND DM.KUNNR = ''
		ORDER BY
			DM.Z_RUTA
			,DM.KUNNR
			,DM.MATNR
		--
		PRINT 'Obtubo bonificacion por sku'
		
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
	INSERT INTO SONDA.ERP_TB_BONUS
	SELECT
		[CODE_ROUTE]
		,[CODE_CUSTOMER]
		,[SKU]
		,[SKU_PACK_UNIT]
		,[LOW_LIMIT]
		,[HIGT_LIMIT]
		,[BONUS_QTY]
		,[BONUS_SKU]
		,[BONUS_PACK_UNIT]
	FROM #BONUS
	ORDER BY CODE_ROUTE,CODE_CUSTOMER,SKU
END

