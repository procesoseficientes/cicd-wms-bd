-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	9/12/2017 @ NEXUS-Team Sprint DuckHunt 
-- Description:			SP que borra un registro de la tabla OP_WMS_CLASS

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [wms].[OP_WMS_CLASS] 
				--
				EXEC [wms].[OP_WMS_SP_DELETE_CLASS]
					@CLASS_ID = 6
				-- 
				SELECT * FROM [wms].[OP_WMS_CLASS]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_DELETE_CLASS](
	@CLASS_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DELETE FROM [wms].[OP_WMS_CLASS]
		WHERE [CLASS_ID] = @CLASS_ID
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'La clase no existe.'
      WHEN '547' THEN 'No se puede eliminar porque la clase ya está siendo utilizada.'
			ELSE ERROR_MESSAGE()  END  Mensaje  
		,@@ERROR Codigo 
	END CATCH
END