-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	9/12/2017 @ NEXUS-Team Sprint DuckHunt 
-- Description:			SP que actualiza un registro de la tabla OP_WMS_CLASS

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_UPDATE_CLASS]
					@CLASS_ID = 1, -- int
					@CLASS_NAME = 'Plasticos', -- varchar(50)
					@CLASS_DESCRIPTION = 'Plasticos', -- varchar(250)
					@CLASS_TYPE = 'Productos', -- varchar(50)
					@LOGIN = 'ADMIN2' -- varchar(50)
				-- 
				SELECT * FROM [wms].OP_WMS_CLASS
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_CLASS](
	@CLASS_ID INT
	,@CLASS_NAME VARCHAR(50)
	,@CLASS_DESCRIPTION VARCHAR(250)
	,@CLASS_TYPE VARCHAR(50)
	,@LOGIN VARCHAR(50)
	,@PRIORITY INT 
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		UPDATE [wms].[OP_WMS_CLASS]
		SET	
			[CLASS_NAME] = @CLASS_NAME
			,[CLASS_DESCRIPTION] = @CLASS_DESCRIPTION
			,[CLASS_TYPE] = @CLASS_TYPE
			,[LAST_UPDATED_BY] = @LOGIN
			,[LAST_UPDATED] = GETDATE()
			,[PRIORITY] = @PRIORITY
		WHERE 
			[CLASS_ID] = @CLASS_ID
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Ya existe una clase con el nombre ingresado.'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END