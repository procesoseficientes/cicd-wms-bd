-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	19-08-2016 @ Sprint θ
-- Description:			SP que obtiene los descuentos

-- Modificacion 13-09-2016 @ A-TEAM Sprint 1
						-- alberto.ruiz
						-- Se modifico para que administre la importacion de descuentos

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[ERP_SP_GENERATE_DISCOUNT_LIST]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[ERP_SP_GENERATE_DISCOUNT_LIST]
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@DISCOUNT_TYPE INT = 2
		,@DESCRIPTION VARCHAR(250)
		,@SP NVARCHAR(500)
		,@ORDER INT

	-- ------------------------------------------------------------------------------------
	-- Obtiene los clientes por ruta
	-- ------------------------------------------------------------------------------------
	SELECT
		DP.[DESCRIPTION]
		,SP_SWIFT_INTERFACE_ONLINE SP
		,[ORDER]
	INTO #PROC
	FROM SONDA.SWIFT_DISCOUNT_PRIORITY DP
	WHERE ACTIVE_SWIFT_INTERFACE_ONLINE = 1
	ORDER BY [ORDER]

	-- ------------------------------------------------------------------------------------
	-- Recorre cada registro y lo manda a ejecutar
	-- ------------------------------------------------------------------------------------
	PRINT 'Inicia ciclo'
	--
	WHILE EXISTS(SELECT TOP 1 1 FROM #PROC)
	BEGIN
		-- ------------------------------------------------------------------------------------
		-- Obtiene el SP por ejecutar
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@DESCRIPTION = [DESCRIPTION]
			,@SP = SP
			,@ORDER = [ORDER]
		FROM #PROC
		ORDER BY [ORDER]
		--
		PRINT '@DESCRIPTION: ' + @DESCRIPTION
		PRINT '@SP: ' + @SP

		-- ------------------------------------------------------------------------------------
		-- Ejecuta el SP
		-- ------------------------------------------------------------------------------------
		SET @SP = @SP + ' @DISCOUNT_TYPE = ' + CAST(@DISCOUNT_TYPE AS VARCHAR) + ' , @ORDER = ' + CAST(@ORDER AS VARCHAR)
		--
		PRINT '@SP: ' + @SP
		--
		EXEC(@SP)
		--
		PRINT 'Ejecucion exitosa'

		-- ------------------------------------------------------------------------------------
		-- Elimina el cliente actual por ruta
		-- ------------------------------------------------------------------------------------
		DELETE FROM #PROC WHERE [ORDER] = @ORDER AND [DESCRIPTION] = @DESCRIPTION
		--
		PRINT 'Elimina registro'
	END
	--
	PRINT 'Termina ciclo'

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado
	-- ------------------------------------------------------------------------------------
	SELECT
		[CODE_ROUTE]
		,[CODE_CUSTOMER]
		,[SKU]
		,[DISCOUNT]
	FROM SONDA.ERP_TB_DISCOUNT
	ORDER BY CODE_ROUTE,CODE_CUSTOMER,SKU
END

