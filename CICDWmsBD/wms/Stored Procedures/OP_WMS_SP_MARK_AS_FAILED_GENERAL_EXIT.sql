-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	11/23/2017 @ NEXUS-Team Sprint GTA 
-- Description:			Marca como envio fallido el picking general

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_MARK_AS_FAILED_GENERAL_EXIT] 1, 'Fallido'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_MARK_AS_FAILED_GENERAL_EXIT](
	@GENERAL_EXIT_ID INT
	,@POSTED_RESPONSE VARCHAR(250)
)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		
		UPDATE [wms].[OP_WMS_PICKING_ERP_DOCUMENT]
		SET [IS_POSTED_ERP] = -1
			,[POSTED_RESPONSE] = @POSTED_RESPONSE
			,[POSTED_ERP] = GETDATE()
			,[ATTEMPTED_WITH_ERROR] = [ATTEMPTED_WITH_ERROR] + 1
			,[LAST_UPDATED] = GETDATE()
			,[LAST_UPDATED_BY] = 'INTERFACES'
		WHERE [PICKING_ERP_DOCUMENT_ID] = @GENERAL_EXIT_ID
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN ''
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END