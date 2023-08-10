-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	01-Nov-16 @ A-TEAM Sprint 4 
-- Description:			SP que obtiene las rutas de las fuentes externas

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_ROUTES_FROM_EXTERNAL_SOURCE]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_ROUTES_FROM_EXTERNAL_SOURCE]
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@EXTERNAL_SOURCE_ID INT
		,@SOURCE_NAME VARCHAR(50)
		,@DATA_BASE_NAME VARCHAR(50)
		,@SCHEMA_NAME VARCHAR(50)
		,@QUERY NVARCHAR(MAX)
	--
	CREATE TABLE #ROUTE(
		[LOGIN] VARCHAR(50)
		,[CODE_VEHICLE] VARCHAR(50)
		,[CODE_ROUTE] VARCHAR(50)
		,[NAME_ROUTE] VARCHAR(50)
		,[SELLER_CODE] VARCHAR(100)
		,[SELLER_NAME] VARCHAR(60)
		,[EXTERNAL_SOURCE_ID] INT
		,[SOURCE_NAME] VARCHAR(50)
	)
	
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Obtiene las fuentes externas
		-- ------------------------------------------------------------------------------------
		SELECT 
			[ES].[EXTERNAL_SOURCE_ID]
			,[ES].[SOURCE_NAME]
			,[ES].[DATA_BASE_NAME]
			,[ES].[SCHEMA_NAME]
		INTO #EXTERNAL_SOURCE
		FROM [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]

		--SELECT * FROM [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
		--SELECT * FROM [SWIFT_EXPRESS].[SONDA].[USERS]
		--UPDATE [wms].[OP_SETUP_EXTERNAL_SOURCE] SET [SCHEMA_NAME] = 'SONDA'
		--wms
		-- ------------------------------------------------------------------------------------
		-- Ciclo para obtener las rutas
		-- ------------------------------------------------------------------------------------
		PRINT '--> Inicia el ciclo'
		--
		WHILE EXISTS(SELECT TOP 1 1 FROM [#EXTERNAL_SOURCE])
		BEGIN
			-- ------------------------------------------------------------------------------------
			-- Se toma la primera fuente extermna
			-- ------------------------------------------------------------------------------------
			SELECT TOP 1 
				@EXTERNAL_SOURCE_ID = [ES].[EXTERNAL_SOURCE_ID]
				,@SOURCE_NAME = [ES].[SOURCE_NAME]
				,@DATA_BASE_NAME = [ES].[DATA_BASE_NAME]
				,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
				,@QUERY = N''
			FROM #EXTERNAL_SOURCE [ES]
			ORDER BY [ES].[EXTERNAL_SOURCE_ID]
			--
			PRINT '----> @EXTERNAL_SOURCE_ID: ' + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR)
			PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME
			PRINT '----> @DATA_BASE_NAME: ' + @DATA_BASE_NAME
			PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME

			-- ------------------------------------------------------------------------------------
			-- Obtiene las ordenes de venta de la fuente externa
			-- ------------------------------------------------------------------------------------
			SELECT @QUERY = N'INSERT INTO [#ROUTE]
			(
				[LOGIN]
				,[CODE_VEHICLE]
				,[CODE_ROUTE]
				,[NAME_ROUTE]
				,[SELLER_CODE]
				,[SELLER_NAME]
			)
			SELECT
				U.LOGIN
				,ISNULL(V.CODE_VEHICLE, ''Sin Vehiculo'')CODE_VEHICLE
				,R.CODE_ROUTE
				,R.NAME_ROUTE
				,S.SELLER_CODE
				,S.SELLER_NAME
			FROM ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[USERS] U
				INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SWIFT_ROUTES] R ON (U.SELLER_ROUTE = R.CODE_ROUTE)
				INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SWIFT_SELLER] S ON (U.RELATED_SELLER = S.SELLER_CODE)
				LEFT JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.SWIFT_VEHICLE_X_USER VU ON (U.LOGIN = VU.LOGIN)
				LEFT JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.SWIFT_VEHICLES V ON (VU.VEHICLE = V.VEHICLE)
			'
			--
			PRINT '--> @QUERY: ' + @QUERY
			--
			EXEC (@QUERY)

			-- ------------------------------------------------------------------------------------
			-- Identifica la fuente externa
			-- ------------------------------------------------------------------------------------
			UPDATE [#ROUTE]
			SET 
				[EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID
				,[SOURCE_NAME] = @SOURCE_NAME
			WHERE [EXTERNAL_SOURCE_ID] IS NULL

			-- ------------------------------------------------------------------------------------
			-- Eleminamos la fuente externa
			-- ------------------------------------------------------------------------------------
			DELETE FROM [#EXTERNAL_SOURCE] WHERE [EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID
		END
		--
		PRINT '--> Termino el ciclo'

		-- ------------------------------------------------------------------------------------
		-- Muestra el resultado
		-- ------------------------------------------------------------------------------------
		SELECT
			[R].[LOGIN]
			,[R].[CODE_VEHICLE]
			,[R].[CODE_ROUTE]
			,[R].[NAME_ROUTE]
			,[R].[SELLER_CODE]
			,[R].[SELLER_NAME]
			,[R].[EXTERNAL_SOURCE_ID]
			,[R].[SOURCE_NAME]
		FROM [#ROUTE] [R]
	END TRY
	BEGIN CATCH
		SELECT  
			-1 as Resultado
			,ERROR_MESSAGE() Mensaje 
			,@@ERROR Codigo
	END CATCH
END