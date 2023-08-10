-- =============================================
-- Autor:				hector.gonzalez
-- Fecha de Creacion: 	19-07-2016
-- Description:			inserta un poligono 

-- Modificacion 29-08-2016 @ Sprint θ
			-- alberto.ruiz
			-- Se agrego llamado para crear la ruta

-- Modificacion 30-08-2016 @ Sprint ι
			-- alberto.ruiz
			-- Se agrego parametro @CODE_WAREHOUSE

-- Modificacion 30-08-2016 @ A-TEAM Sprint 2
			-- rudi.garcia
			-- Se elimino la parte donde inseta la ruta.

-- Modificacion 21-Apr-17 @ A-Team Sprint Hondo
					-- alberto.ruiz
					-- Se agrega el parametro IS_MULTISELLER

/*
-- Ejemplo de Ejecucion:
				--
				EXEC [SONDA].[SWIFT_SP_INSERT_POLYGON]
					@POLYGON_NAME = 'RESERVACABAaaaa'
					,@POLYGON_DESCRIPTION ='Reserva de Biosfera Visis Caba'
					,@COMMENT =''
					,@LAST_UPDATE_BY ='RUDI@SONDA'
					,@POLYGON_ID_PARENT = NULL
					,@POLYGON_TYPE = 'REGION'
					,@SUB_TYPE = NULL
					,@TYPE_TASK = NULL
					,@SAVE_ROUTE = 0
					,@CODE_WAREHOUSE = NULL
				--
				SELECT * FROM [SONDA].[SWIFT_POLYGON] WHERE POLYGON_NAME = 'RESERVACABAaaaa'
				--
				SELECT * FROM [SONDA].SWIFT_ROUTES WHERE NAME_ROUTE = 'RESERVACABAaaaa'
			
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_POLYGON] (
		@POLYGON_NAME VARCHAR(250)
		,@POLYGON_DESCRIPTION VARCHAR(250)
		,@COMMENT VARCHAR(250)
		,@LAST_UPDATE_BY VARCHAR(50)
		,@POLYGON_ID_PARENT INT = NULL
		,@POLYGON_TYPE VARCHAR(250)
		,@SUB_TYPE VARCHAR(250) = NULL
		,@TYPE_TASK VARCHAR(20) = NULL
		,@CODE_WAREHOUSE VARCHAR(50) = NULL
		,@IS_MULTISELLER INT = 0
) AS
BEGIN
	SET NOCOUNT ON;
	--	
	BEGIN TRY
		-- ------------------------------------------------------------
		-- Crear el poligono
		-- ------------------------------------------------------------
		DECLARE	@ID INT;
		--
		INSERT	INTO [SONDA].[SWIFT_POLYGON]
				(
					[POLYGON_NAME]
					,[POLYGON_DESCRIPTION]
					,[COMMENT]
					,[LAST_UPDATE_BY]
					,[LAST_UPDATE_DATETIME]
					,[POLYGON_ID_PARENT]
					,[POLYGON_TYPE]
					,[SUB_TYPE]
					,[TYPE_TASK]
					,[CODE_WAREHOUSE]
					,[IS_MULTISELLER]
				)
		VALUES
				(
					@POLYGON_NAME
					,@POLYGON_DESCRIPTION
					,@COMMENT
					,@LAST_UPDATE_BY
					,GETDATE()
					,@POLYGON_ID_PARENT
					,@POLYGON_TYPE
					,@SUB_TYPE
					,@TYPE_TASK
					,@CODE_WAREHOUSE
					,@IS_MULTISELLER
				);
		--
		SET @ID = SCOPE_IDENTITY();

		-- ------------------------------------------------------------
		-- Muetra el resutlado
		-- ------------------------------------------------------------
		IF @@ERROR = 0
		BEGIN
			SELECT
				1 AS [RESULTADO]
				,'Proceso Exitoso' [MENSAJE]
				,0 [CODIGO]
				,CONVERT(VARCHAR(16), @ID) AS [DbData];
		END; 
		ELSE
		BEGIN
			SELECT
				-1 AS [RESULTADO]
				,ERROR_MESSAGE() [MENSAJE]
				,@@ERROR [CODIGO]
				,'0' AS [DbData];
		END;
	END TRY
	BEGIN CATCH
		DECLARE	@ERROR_CODE INT;
		--
		SET @ERROR_CODE = @@ERROR;
		--
		SELECT
			-1 AS [RESULTADO]
			,CASE CAST(@ERROR_CODE AS VARCHAR)
				WHEN '2627'
				THEN 'No se puede guardar el poligono porque ya existe uno con ese nombre'
				ELSE ERROR_MESSAGE()
				END [MENSAJE]
			,@ERROR_CODE [CODIGO]
			,'0' AS [DbData];
		--
		ROLLBACK;
	END CATCH;
END;
