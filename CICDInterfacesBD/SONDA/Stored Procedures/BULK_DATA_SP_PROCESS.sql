-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	01-03-2016
-- Description:			SP que administra la ejecucion del proceso del bulk data

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[BULK_DATA_SP_PROCESS]
				--
				SELECT TOP 25 * FROM [SONDA].[BULK_DATA_CONFIGURATION_LOG] ORDER BY 1 DESC
*/
-- =============================================
CREATE PROCEDURE [SONDA].[BULK_DATA_SP_PROCESS]
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@MESSAGE VARCHAR(2000) = ''
		,@CONFIGURATION INT
		,@SP NVARCHAR(1000) = ''
		,@START_RUN DATETIME
		,@END_RUN DATETIME
	--
	PRINT '--> BULK_DATA_SP_PROCESS: INICIA ' + CONVERT(VARCHAR,GETDATE(),121)

	-- ------------------------------------------------------------------------------------
	-- Obtiene configuracion del bulk data
	-- ------------------------------------------------------------------------------------
	SELECT 
		C.CONFIGURATION
		,C.SP
		,C.[ORDER]
	INTO #CONFIG
	FROM [SWIFT_INTERFACES].[SONDA].[BULK_DATA_CONFIGURATION] C
	WHERE C.ACTIVE = 1
	ORDER BY 
		C.[ORDER]
		,C.CONFIGURATION

	-- ------------------------------------------------------------------------------------
	-- Recorre cada registro y lo manda a ejecutar
	-- ------------------------------------------------------------------------------------
	WHILE EXISTS(SELECT TOP 1 1 FROM #CONFIG)
	BEGIN
		-- ------------------------------------------------------------------------------------
		-- Obtiene el registro a ejecutar
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@CONFIGURATION = C.CONFIGURATION
			,@SP = C.SP
			,@START_RUN = GETDATE()
		FROM #CONFIG C
		--
		PRINT '----> @SP: ' + @SP
		PRINT '----> @START_RUN: ' + CONVERT(VARCHAR,@START_RUN,121)
		
		-- ------------------------------------------------------------------------------------
		-- Intenta ejecutar proceso 
		-- ------------------------------------------------------------------------------------
		BEGIN TRY
			EXEC SP_EXECUTESQL @SP
			--
			SET @MESSAGE = 'Proceso finalizado correctamente'
		END TRY
		BEGIN CATCH
			SET @MESSAGE = ERROR_MESSAGE()
		END CATCH

		-- ------------------------------------------------------------------------------------
		-- Almacena log
		-- ------------------------------------------------------------------------------------
		SET @END_RUN = GETDATE()
		--
		EXEC [SONDA].[BULK_DATA_SP_INSERT_LOG]
			@SP = @SP
			,@START_RUN = @START_RUN
			,@END_RUN = @END_RUN
			,@MESSAGE = @MESSAGE
		--
		PRINT '----> @MESSAGE: ' + @MESSAGE
		PRINT '----> @END_RUN: ' + CONVERT(VARCHAR,@END_RUN,121)

		-- ------------------------------------------------------------------------------------
		-- Elimina el proceso que acaba de correr
		-- ------------------------------------------------------------------------------------
		DELETE FROM #CONFIG WHERE CONFIGURATION = @CONFIGURATION
	END
	--
	PRINT '--> BULK_DATA_SP_PROCESS: FINALIZA ' + CONVERT(VARCHAR,GETDATE(),121)	
	
END