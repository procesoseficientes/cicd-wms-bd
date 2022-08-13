-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	9/12/2017 @ NEXUS-Team Sprint DuckHunt
-- Description:			SP que inserta un registro en la tabla OP_WMS_CLASS

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_CREATE_CLASS] @CLASS_NAME = 'Plasticos', -- varchar(50)
					@CLASS_DESCRIPTION = 'Plasticos', -- varchar(250)
					@CLASS_TYPE = 'Productos', -- varchar(50)
					@CREATED_BY = 'ADMIN1' -- varchar(50)
				-- 
				SELECT * FROM [wms].[OP_WMS_CLASS] 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_CREATE_CLASS] (
		@CLASS_NAME VARCHAR(50)
		,@CLASS_DESCRIPTION VARCHAR(250)
		,@CLASS_TYPE VARCHAR(50)
		,@CREATED_BY VARCHAR(50)
		,@PRIORITY INT 
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DECLARE	@ID INT;
		--
		INSERT	INTO [wms].[OP_WMS_CLASS]
				(
					[CLASS_NAME]
					,[CLASS_DESCRIPTION]
					,[CLASS_TYPE]
					,[CREATED_BY]
					,[CREATED_DATETIME]
					,[LAST_UPDATED_BY]
					,[LAST_UPDATED]
					, [PRIORITY]
				)
		VALUES
				(
					@CLASS_NAME  -- CLASS_NAME - varchar(50)
					,@CLASS_DESCRIPTION  -- CLASS_DESCRIPTION - varchar(250)
					,@CLASS_TYPE  -- CLASS_TYPE - varchar(50)
					,@CREATED_BY  -- CREATED_BY - varchar(50)
					,GETDATE()  -- CREATED_DATETIME - datetime
					,@CREATED_BY  -- LAST_UPDATED_BY - varchar(50)
					,GETDATE()  -- LAST_UPDATED - datetime
					,@PRIORITY
				);
		--
		SET @ID = SCOPE_IDENTITY();
		--
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST(@ID AS VARCHAR) [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,CASE CAST(@@ERROR AS VARCHAR)
				WHEN '2627'
				THEN 'Ya existe una clase con el nombre.'
				ELSE ERROR_MESSAGE()
				END [Mensaje]
			,@@ERROR [Codigo]; 
	END CATCH;
END;