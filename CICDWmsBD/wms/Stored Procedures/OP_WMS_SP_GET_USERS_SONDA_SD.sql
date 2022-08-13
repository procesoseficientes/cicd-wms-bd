-- =============================================
-- Autor:					henry.rodriguez
-- Fecha de Creacion: 		01-AGOSTO-2019 G-Force@Estambul
--Product Backlog Item 30940: Asociar usuario de Sonda SD a piloto de Next
-- Description:			    Obtiene los usuarios de Sonda SD.
/*
Ejemplo de Ejecucion:
	EXECUTE [wms].[OP_WMS_SP_GET_USERS_SONDA_SD]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_USERS_SONDA_SD]
AS
BEGIN
	
	SET NOCOUNT ON;
	
	-- ------------------------------------------------------------------------------------
	-- DECLARAMOS LAS VARIABLES
	-- ------------------------------------------------------------------------------------
	DECLARE	@TEMP_OWNER TABLE (
			[EXTERNAL_SOURCE_ID] INTEGER
			,[SOURCE_NAME] VARCHAR(50)
			,[DATA_BASE_NAME] VARCHAR(150)
			,[SCHEMA_NAME] VARCHAR(50)
			,[INTERFACE_DATA_BASE_NAME] VARCHAR(50)
		);

	DECLARE	@TEMP_USERS TABLE (
			[CORRELATIVE] INTEGER
			,[LOGIN] VARCHAR(50)
			,[NAME_USER] VARCHAR(50)
		);

	-- ------------------------------------------------------------------------------------
	-- INSERTAMOS EN UNA TABLA TEMPORAL LOS REGISTRO DEVUELTOS PARA OBTENER LOS USUARIOS DE SONDA
	-- ------------------------------------------------------------------------------------
	INSERT	INTO @TEMP_OWNER
			(
				[EXTERNAL_SOURCE_ID]
				,[SOURCE_NAME]
				,[DATA_BASE_NAME]
				,[SCHEMA_NAME]
				,[INTERFACE_DATA_BASE_NAME]
			)
	SELECT
		[EXTERNAL_SOURCE_ID]
		,[SOURCE_NAME]
		,[DATA_BASE_NAME]
		,[SCHEMA_NAME]
		,[INTERFACE_DATA_BASE_NAME]
	FROM
		[wms].[OP_SETUP_EXTERNAL_SOURCE]
	WHERE
		[IS_SONDA_SD] = 1;

	-- ------------------------------------------------------------------------------------
	-- RECORREMOS LOS DATOS DE LA TABLA TEMPORAL @TEMP_OWNER
	-- ------------------------------------------------------------------------------------

	WHILE EXISTS ( SELECT TOP 1
						1
					FROM
						@TEMP_OWNER )
	BEGIN

		DECLARE
			@EXTERNAL_SOURCE_ID INT
			,@SOURCE_NAME VARCHAR(50)
			,@SCHEMA_NAME VARCHAR(50)
			,@DATA_BASE_NAME VARCHAR(150)
			,@INTERFACE_DATA_BASE_NAME VARCHAR(50)
			,@QUERY NVARCHAR(2000);

		SELECT TOP 1
			@EXTERNAL_SOURCE_ID = [EXTERNAL_SOURCE_ID]
			,@SOURCE_NAME = [SOURCE_NAME]
			,@DATA_BASE_NAME = [DATA_BASE_NAME]
			,@SCHEMA_NAME = [SCHEMA_NAME]
			,@INTERFACE_DATA_BASE_NAME = [INTERFACE_DATA_BASE_NAME]
		FROM
			@TEMP_OWNER; 

		SELECT
			@QUERY = N'EXEC ' + @INTERFACE_DATA_BASE_NAME
			+ '.' + @SCHEMA_NAME
			+ '.SWIFT_SP_GET_USERS_SONDA @DATA_BASE_NAME ='''
			+ @DATA_BASE_NAME + ''',@SCHEMA_NAME ='''
			+ @SCHEMA_NAME + '''';

		INSERT	INTO @TEMP_USERS
				(
					[CORRELATIVE]
					,[LOGIN]
					,[NAME_USER]
					
				)
				EXEC [sp_executesql] @QUERY;

		DELETE FROM
			@TEMP_OWNER
		WHERE
			[EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID;

	END;	

	SELECT
		[CORRELATIVE]
		,[LOGIN] AS [LOGIN_ID]
		,[NAME_USER] AS [LOGIN_NAME]
	FROM
		@TEMP_USERS;


END;