-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		17-Oct-16 @ A-Team Sprint 3
-- Description:			    SP que administra el proceso de generar las bonificaciones

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[ERP_SP_GENERATE_BONUS_LIST]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[ERP_SP_GENERATE_BONUS_LIST]
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@BONUS_TYPE INT = 3
		,@DESCRIPTION VARCHAR(250)
		,@SP NVARCHAR(500)
		,@ORDER INT

	-- ------------------------------------------------------------------------------------
	-- Obtiene los clientes por ruta
	-- ------------------------------------------------------------------------------------
	SELECT
		[BP].[DESCRIPTION]
		,[BP].[SP_SWIFT_INTERFACE_ONLINE] [SP]
		,[ORDER]
	INTO #PROC
	FROM [SONDA].[SWIFT_BONUS_PRIORITY] [BP]
	WHERE [ACTIVE_SWIFT_INTERFACE_ONLINE] = 1
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
		SET @SP = @SP + ' @BONUS_TYPE = ' + CAST(@BONUS_TYPE AS VARCHAR) + ' , @ORDER = ' + CAST(@ORDER AS VARCHAR)
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

