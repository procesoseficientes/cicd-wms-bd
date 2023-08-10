-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	13-09-2016 @ A-TEAM Sprint 1
-- Description:			SP que obtiene los descuentos por producto

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[ERP_SP_GENERATE_DISCOUNT_LIST_BY_SKU]
					@DISCOUNT_TYPE = 2
					,@ORDER = 2
*/
-- =============================================
CREATE PROCEDURE [SONDA].[ERP_SP_GENERATE_DISCOUNT_LIST_BY_SKU] (
	@DISCOUNT_TYPE INT
	,@ORDER INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	PRINT '--> ERP_SP_GENERATE_DISCOUNT_LIST_BY_SKU Inicio'
	--
	DECLARE
		@CODE_CUSTOMER VARCHAR(50)
		,@CODE_ROUTE VARCHAR(50)
	--
	CREATE TABLE #DISCOUNT (
		[CODE_ROUTE] [varchar](50) NULL
		,[CODE_CUSTOMER] [varchar](50) NULL
		,[CODE_SKU] [varchar](50) NULL
		,[DISCOUNT] [numeric](18, 6) NULL
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
		TRUNCATE TABLE SONDA.ERP_TB_DISCOUNT
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
		-- Obtiene los descuentos por sku
		-- ------------------------------------------------------------------------------------
		INSERT INTO #DISCOUNT
		SELECT
			DM.Z_RUTA
			,@CODE_CUSTOMER CLIENTE
			,DM.MATNR SKU
			,DM.ZDESC DISCOUNT
		FROM [$(SAPR3)].dbo.ZTT_SD001_DATOS_MAESTROS DM
		LEFT JOIN SONDA.ERP_TB_DISCOUNT D ON (
			D.CODE_ROUTE = @CODE_ROUTE
			AND D.CODE_CUSTOMER = @CODE_CUSTOMER
			AND D.SKU = DM.MATNR
		)
		WHERE DM.Z_TIPO_CLASE = @DISCOUNT_TYPE
			AND DM.Z_RUTA = @CODE_ROUTE
			AND DM.KUNNR = ''
			AND D.SKU IS NULL
		ORDER BY
			DM.Z_RUTA
			,DM.KUNNR
			,DM.MATNR
		--
		PRINT 'Obtubo descuentos por sku'
		
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
	-- Se cargan los nuevos descuentos
	-- ------------------------------------------------------------------------------------
	INSERT INTO SONDA.ERP_TB_DISCOUNT
	SELECT
		[CODE_ROUTE]
		,[CODE_CUSTOMER]
		,[CODE_SKU]
		,[DISCOUNT]
	FROM #DISCOUNT
	ORDER BY CODE_ROUTE,CODE_CUSTOMER,CODE_SKU
	--
	PRINT '--> ERP_SP_GENERATE_DISCOUNT_LIST_BY_SKU Fin'
END

