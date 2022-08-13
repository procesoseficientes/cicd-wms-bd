-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		03-06-2016
-- Description:			    SP que recrea los objetos de un esquema especifico con un texto especidico para reemplazar un texto por otro texto

/*
-- Ejemplo de Ejecucion:
        --
		EXEC [SONDA].[SWIFT_SP_REPLACE_TEXT_IN_OPENQUERY]
			@TARGE_SCHEMA_NAME = 'cerouno'
			,@TEXT_IN_OBJECTS = 'openquery'
			,@TEXT_TO_FIND = 'PRUEBA'
			,@TEXT_TO_REPLEACE = 'Cero_Uno'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_REPLACE_TEXT_IN_OPENQUERY]
	@TARGE_SCHEMA_NAME VARCHAR(250)
	,@TEXT_IN_OBJECTS VARCHAR(25)
	,@TEXT_TO_FIND VARCHAR(250)
	,@TEXT_TO_REPLEACE VARCHAR(250)
AS
BEGIN
	SET NOCOUNT ON;
	--
	CREATE TABLE #RESULT(
		[SCHEMA_NAME] VARCHAR(50)
		,[OBJECT_TYPE] VARCHAR(10)
		,[OBJECT_NAME] VARCHAR(100)
		,[MESSAGE] VARCHAR(1000)
		,[OBJECT_DEFINITION] NVARCHAR(MAX)
	)
	--
	DECLARE
		@OBJECT_NAME VARCHAR(100)
		,@OBJECT_DEFINITION NVARCHAR(MAX)
		,@OBJECT_TYPE VARCHAR(10)
		,@SCHEMA_NAME VARCHAR(50)
		,@MESSAGE VARCHAR(1000)
	--
	SELECT 
		@TEXT_IN_OBJECTS = '%' + @TEXT_IN_OBJECTS + '%'
		,@MESSAGE = ''
	
	BEGIN TRY
	BEGIN TRAN
		-- ------------------------------------------------------------------------------------
		-- Obtiene las vistas y procedimientos con openquery
		-- ------------------------------------------------------------------------------------
		SELECT distinct 
			so.name [OBJECT_NAME]
			,so.type [OBJECT_TYPE]
		INTO #OBJECT
		FROM syscomments sc
		INNER JOIN sysobjects so ON sc.id=so.id
		WHERE sc.TEXT LIKE @TEXT_IN_OBJECTS

		-- ------------------------------------------------------------------------------------
		-- Elimina los obtejos que no pertenescan al esquema
		-- ------------------------------------------------------------------------------------
		IF @TARGE_SCHEMA_NAME IS NOT NULL
		BEGIN
			DELETE [O]
			FROM #OBJECT O
			INNER JOIN [sys].[procedures] S ON (O.[OBJECT_NAME] = S.name 
				AND O.[OBJECT_TYPE] = @OBJECT_TYPE
			)
			INNER JOIN [sys].[sql_modules] M ON M.object_id = S.object_id
			INNER JOIN [sys].[schemas] SH ON (
				S.[schema_id] = SH.[schema_id]
			)
			WHERE SH.[name] != @TARGE_SCHEMA_NAME
			--
			DELETE [O]
			FROM #OBJECT O
			INNER JOIN [sys].[views] S ON (O.[OBJECT_NAME] = S.name 
				AND O.[OBJECT_TYPE] = @OBJECT_TYPE
			)
			INNER JOIN [sys].[sql_modules] M ON M.object_id = S.object_id
			INNER JOIN [sys].[schemas] SH ON (
				S.[schema_id] = SH.[schema_id]
			)
			WHERE SH.[name] != @TARGE_SCHEMA_NAME
		END

		-- ------------------------------------------------------------------------------------
		-- Recorre cada objeto de tipo procedimiento almacenado
		-- ------------------------------------------------------------------------------------
		SELECT @OBJECT_TYPE = 'P'
		--
		SELECT 
			S.[name] [OBJECT_NAME]
			,M.[definition] [OBJECT_DEFINITION]
			,SH.[name] [SCHEMA_NAME]
		INTO #PRODECURE
		FROM [sys].[procedures] S
		INNER JOIN [sys].[sql_modules] M ON M.object_id = S.object_id
		INNER JOIN #OBJECT O ON (O.[OBJECT_NAME] = S.name 
			AND O.[OBJECT_TYPE] = @OBJECT_TYPE
		)
		INNER JOIN [sys].[schemas] SH ON (
			S.[schema_id] = SH.[schema_id]
		)
		WHERE (SH.[name] = @TARGE_SCHEMA_NAME OR @TARGE_SCHEMA_NAME IS NULL)
		--
		PRINT '----> Inicia Ciclo de ' + @OBJECT_TYPE
		--
		WHILE EXISTS(SELECT TOP 1 1 FROM #PRODECURE)
		BEGIN
			SELECT TOP 1
				@OBJECT_NAME = [OBJECT_NAME]
				,@OBJECT_DEFINITION = [OBJECT_DEFINITION]
				,@SCHEMA_NAME = [SCHEMA_NAME]
			FROM #PRODECURE
			--
			PRINT '@OBJECT_NAME: ' + @OBJECT_NAME
			PRINT '@SCHEMA_NAME: ' + @SCHEMA_NAME
			PRINT '@OBJECT_TYPE: ' + @OBJECT_TYPE
			
			BEGIN TRY
				-- ------------------------------------------------------------------------------------
				-- Reemplaza el texto
				-- ------------------------------------------------------------------------------------
				SELECT @OBJECT_DEFINITION = REPLACE(@OBJECT_DEFINITION,@TEXT_TO_FIND,@TEXT_TO_REPLEACE)
				--
				PRINT 'DEFINICION CAMBIADA'

				-- ------------------------------------------------------------------------------------
				-- Recrea el objeto
				-- ------------------------------------------------------------------------------------
				EXEC [SONDA].[SWIFT_SP_RECREATE_OBJECT]
					@SCHEMA_NAME = @SCHEMA_NAME
					,@OBJECT_NAME = @OBJECT_NAME
					,@OBJECT_DEFINITION = @OBJECT_DEFINITION
				--
				PRINT 'EXITO'
				--
				SELECT @MESSAGE = 'Exito'
			END TRY
			BEGIN CATCH
				-- ------------------------------------------------------------------------------------
				-- Marca el error
				-- ------------------------------------------------------------------------------------
				PRINT 'ERROR AL RECREAR'
				--
				SELECT @MESSAGE = ERROR_MESSAGE()
			END CATCH

			-- ------------------------------------------------------------------------------------
			-- Registra resultado de la ejecucion
			-- ------------------------------------------------------------------------------------
			INSERT INTO [#RESULT]
					(
						[SCHEMA_NAME]
						,[OBJECT_TYPE]
						,[OBJECT_NAME]
						,[MESSAGE]
						,[OBJECT_DEFINITION]
					)
			VALUES
					(
						@SCHEMA_NAME
						,@OBJECT_TYPE
						,@OBJECT_NAME
						,@MESSAGE
						,@OBJECT_DEFINITION
					)
		
			-- ------------------------------------------------------------------------------------
			-- Borra el registro operado
			-- ------------------------------------------------------------------------------------
			PRINT 'Borrar registro'
			--
			DELETE FROM #PRODECURE WHERE [SCHEMA_NAME] = @SCHEMA_NAME AND [OBJECT_NAME] = @OBJECT_NAME
		END
		--
		PRINT '----> Termina Ciclo de ' + @OBJECT_TYPE


		-- ------------------------------------------------------------------------------------
		-- Recorre cada objeto de tipo vista
		-- ------------------------------------------------------------------------------------
		SELECT @OBJECT_TYPE = 'V'
		--
		SELECT 
			S.[name] [OBJECT_NAME]
			,M.[definition] [OBJECT_DEFINITION]
			,SH.[name] [SCHEMA_NAME]
		INTO #VIEW
		FROM [sys].[views] S
		INNER JOIN [sys].[sql_modules] M ON M.object_id = S.object_id
		INNER JOIN #OBJECT O ON (O.[OBJECT_NAME] = S.name 
			AND O.[OBJECT_TYPE] = @OBJECT_TYPE
		)
		INNER JOIN [sys].[schemas] SH ON (
			S.[schema_id] = SH.[schema_id]
		)
		WHERE (SH.[name] = @TARGE_SCHEMA_NAME OR @TARGE_SCHEMA_NAME IS NULL)
		--
		PRINT '----> Inicia Ciclo de ' + @OBJECT_TYPE
		--
		WHILE EXISTS(SELECT TOP 1 1 FROM #VIEW)
		BEGIN
			SELECT TOP 1
				@OBJECT_NAME = [OBJECT_NAME]
				,@OBJECT_DEFINITION = [OBJECT_DEFINITION]
				,@SCHEMA_NAME = [SCHEMA_NAME]
			FROM #VIEW
			--
			PRINT '@OBJECT_NAME: ' + @OBJECT_NAME
			PRINT '@SCHEMA_NAME: ' + @SCHEMA_NAME
			PRINT '@OBJECT_TYPE: ' + @OBJECT_TYPE
		
			BEGIN TRY
				-- ------------------------------------------------------------------------------------
				-- Reemplaza el texto
				-- ------------------------------------------------------------------------------------
				SELECT @OBJECT_DEFINITION = REPLACE(@OBJECT_DEFINITION,@TEXT_TO_FIND,@TEXT_TO_REPLEACE)
				--
				PRINT 'DEFINICION CAMBIADA'

				-- ------------------------------------------------------------------------------------
				-- Recrea el objeto
				-- ------------------------------------------------------------------------------------
				EXEC [SONDA].[SWIFT_SP_RECREATE_OBJECT]
					@SCHEMA_NAME = @SCHEMA_NAME
					,@OBJECT_NAME = @OBJECT_NAME
					,@OBJECT_DEFINITION = @OBJECT_DEFINITION
				--
				PRINT 'EXITO'
				--
				SELECT @MESSAGE = 'Exito'
			END TRY
			BEGIN CATCH
				-- ------------------------------------------------------------------------------------
				-- Marca el error
				-- ------------------------------------------------------------------------------------
				PRINT 'ERROR AL RECREAR'
				--
				SELECT @MESSAGE = ERROR_MESSAGE()
			END CATCH

			-- ------------------------------------------------------------------------------------
			-- Registra resultado de la ejecucion
			-- ------------------------------------------------------------------------------------
			INSERT INTO [#RESULT]
					(
						[SCHEMA_NAME]
						,[OBJECT_TYPE]
						,[OBJECT_NAME]
						,[MESSAGE]
						,[OBJECT_DEFINITION]
					)
			VALUES
					(
						@SCHEMA_NAME  -- SCHEMA_NAME - varchar(50)
						,@OBJECT_TYPE  -- OBJECT_TYPE - varbinary(10)
						,@OBJECT_NAME  -- OBJECT_NAME - varchar(100)
						,@MESSAGE  -- MESSAGE - varchar(1000)
						,@OBJECT_DEFINITION  -- OBJECT_DEFINITION - nvarchar(max)
					)
		
			-- ------------------------------------------------------------------------------------
			-- Borra el registro operado
			-- ------------------------------------------------------------------------------------
			PRINT 'Borrar registro'
			--
			DELETE FROM #VIEW WHERE [SCHEMA_NAME] = @SCHEMA_NAME AND [OBJECT_NAME] = @OBJECT_NAME
		END
		--
		PRINT '----> Termina Ciclo de ' + @OBJECT_TYPE

		-- ------------------------------------------------------------------------------------
		-- Muestra el resultado
		-- ------------------------------------------------------------------------------------
		SELECT
			[R].[SCHEMA_NAME]
			,[R].[OBJECT_TYPE]
			,[R].[OBJECT_NAME]
			,[R].[MESSAGE]
			,[R].[OBJECT_DEFINITION]
		FROM [#RESULT] R
		ORDER BY
			[R].[SCHEMA_NAME]
			,[R].[OBJECT_TYPE]
			,[R].[OBJECT_NAME]
		--
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK
		--
		SELECT 
			ERROR_LINE() [ERROR_LINE]
			,ERROR_MESSAGE() [ERROR_MESSAGE]
	END CATCH
END

