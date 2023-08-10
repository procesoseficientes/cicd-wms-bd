-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		10-Feb-17 @ A-Team Sprint Chatuluka
-- Description:			    SP que administra el proceso de generar las bonificaciones para los clientes que esten en ambas casos de los acuerdos comerciales

-- Modificacion 10-Feb-17 @ A-Team Sprint Chatuluka
					-- alberto.ruiz
					-- Se agrego el parametro @TYPE para que se pueda reutilizar el SP

-- Modificacion 31-Jul-17 @ Nexus Team Sprint AgeOfEmpires
					-- alberto.ruiz
					-- Se agrega opcion para el BMG

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GENERATE_BONUS_FOR_DUPLICATE_CUSTOMER]
					@CODE_ROUTE = '44'
					,@TYPE = 'SCALE'
				--
				EXEC [SONDA].[SWIFT_SP_GENERATE_BONUS_FOR_DUPLICATE_CUSTOMER]
					@CODE_ROUTE = '44'
					,@TYPE = 'MULTIPLE'
				--
				EXEC [SONDA].[SWIFT_SP_GENERATE_BONUS_FOR_DUPLICATE_CUSTOMER]
					@CODE_ROUTE = '4'
					,@TYPE = 'COMBO'
				--
				EXEC [SONDA].[SWIFT_SP_GENERATE_BONUS_FOR_DUPLICATE_CUSTOMER]
					@CODE_ROUTE = '44'
					,@TYPE = 'GENERAL_AMOUNT'
				--
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GENERATE_BONUS_FOR_DUPLICATE_CUSTOMER](
	@CODE_ROUTE VARCHAR(250)
	,@TYPE VARCHAR(250)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@DESCRIPTION VARCHAR(250)
		,@SP NVARCHAR(500)
		,@ORDER INT
	--
	DECLARE @PROC TABLE (
		[DESCRIPTION] VARCHAR(250)
		,[SP] VARCHAR(250)
		,[ORDER] INT
	)

	-- ------------------------------------------------------------------------------------
	-- Obtiene los SPs a ejecutar
	-- ------------------------------------------------------------------------------------
	INSERT INTO @PROC
			(
				[DESCRIPTION]
				,[SP]
				,[ORDER]
			)
	SELECT
		[BP].[DESCRIPTION]
		,CASE @TYPE
			WHEN 'SCALE' THEN [BP].[SP_SWIFT_EXPRESS]
			WHEN 'MULTIPLE' THEN [BP].[SP_SWIFT_EXPRESS_BY_MULTIPLE]
			WHEN 'COMBO' THEN [BP].[SP_SWIFT_EXPRESS_BY_COMBO]
			WHEN 'GENERAL_AMOUNT' THEN [BP].[SP_SWIFT_EXPRES_BONUS_BY_GENERAL_AMOUNT]
		END
		,[ORDER]
	FROM [SONDA].[SWIFT_BONUS_PRIORITY] [BP]
	WHERE [ACTIVE_SWIFT_INTERFACE_ONLINE] = 1
	ORDER BY [ORDER];

	-- ------------------------------------------------------------------------------------
	-- Elimina los registros que esten vacios o nulos en el campo del SP
	-- ------------------------------------------------------------------------------------
	DELETE FROM @PROC 
	WHERE [SP] IS NULL OR [SP] = ''

	-- ------------------------------------------------------------------------------------
	-- Recorre cada registro y lo manda a ejecutar
	-- ------------------------------------------------------------------------------------
	PRINT 'Inicia ciclo'
	--
	WHILE EXISTS(SELECT TOP 1 1 FROM @PROC)
	BEGIN
		-- ------------------------------------------------------------------------------------
		-- Obtiene el SP por ejecutar
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@DESCRIPTION = [DESCRIPTION]
			,@SP = SP
			,@ORDER = [ORDER]
		FROM @PROC
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
		DELETE FROM @PROC WHERE [ORDER] = @ORDER AND [DESCRIPTION] = @DESCRIPTION
		--
		PRINT 'Elimina registro'
	END
	--
	PRINT 'Termina ciclo'
END
