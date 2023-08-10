-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	07-Feb-17 @ A-TEAM Sprint Chatuluka 
-- Description:			SP que administra el proceso de generar las ventas por multiplo para los clientes que esten en ambas casos de los acuerdos comerciales

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GENERATE_SKU_SALES_BY_MULTIPLE_LIST_BY_ROUTE_FOR_REPEATED_CUSTOMER]
					@CODE_ROUTE = '4'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GENERATE_SKU_SALES_BY_MULTIPLE_LIST_BY_ROUTE_FOR_REPEATED_CUSTOMER](
	@CODE_ROUTE VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@DESCRIPTION VARCHAR(250)
		,@SP NVARCHAR(500)
		,@ORDER INT

	-- ------------------------------------------------------------------------------------
	-- Obtiene los clientes por ruta
	-- ------------------------------------------------------------------------------------
	SELECT
		[SM].[DESCRIPTION]
		,[SM].[SP_SWIFT_EXPRESS] [SP]
		,[ORDER]
	INTO #PROC
	FROM [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_PRIORITY] [SM]
	WHERE [SM].[ACTIVE_SWIFT_EXPRESS] = 1
	ORDER BY [ORDER];

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
		SET @SP = @SP + ' @CODE_ROUTE = ' + CAST(@CODE_ROUTE AS VARCHAR) + ' , @ORDER = ' + CAST(@ORDER AS VARCHAR)
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
END
