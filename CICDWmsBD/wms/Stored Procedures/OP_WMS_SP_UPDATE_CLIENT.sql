-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	18-Jan-18 @ Nexus Team Sprint Strom
-- Description:			SP que agrega cliente

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_UPDATE_CLIENT]
					@CLIENT_CODE = 'PRUEBA1'
					,@CLIENT_NAME = 'CLIENTE DE PRUEBA'
					,@IS_ACTIVE = 1
					,@CLIENT_CODE_ERP = 'BLABLA'
				-- 
				SELECT * FROM [wms].[OP_WMS_CLIENT]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_CLIENT] (
	@CLIENT_CODE VARCHAR(50)
	,@CLIENT_NAME VARCHAR(250)
	,@IS_ACTIVE INT
	,@CLIENT_CODE_ERP VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		UPDATE [wms].[OP_WMS_CLIENT]
		SET			
			[CLIENT_NAME] = @CLIENT_NAME
			,[IS_ACTIVE] = @IS_ACTIVE
			,[CLIENT_CODE_ERP] = @CLIENT_CODE_ERP
		WHERE [CLIENT_CODE] = @CLIENT_CODE
		--
		SELECT
			1 as Resultado
			,'Proceso Exitoso' Mensaje
			,0 Codigo
			,'' DbData
	END TRY
	BEGIN CATCH
		SELECT  
			-1 as Resultado
			,CASE CAST(@@ERROR AS VARCHAR)
				WHEN '2627' THEN 'El código de cliente ' + @CLIENT_CODE + ' ya existe'
				ELSE ERROR_MESSAGE() 
			END Mensaje 
			,@@ERROR Codigo
			,'' DbData 
	END CATCH
END