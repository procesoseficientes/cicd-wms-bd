-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	16-Aug-17 @ Nexus Team Sprint Banjo-Kazooie 
-- Description:			SP que borra la solicitud de transferencia

/*
-- Ejemplo de Ejecucion:
				DECLARE @TRANSFER_REQUEST_ID INT = 1
				--
				SELECT * FROM [wms].[OP_WMS_TRANSFER_REQUEST_HEADER] WHERE [TRANSFER_REQUEST_ID] = @TRANSFER_REQUEST_ID
				--
				EXEC [wms].[OP_WMS_SP_DELETE_TRANSFER_REQUEST_HEADER]
					@TRANSFER_REQUEST_ID = @TRANSFER_REQUEST_ID
				-- 
				SELECT * FROM [wms].[OP_WMS_TRANSFER_REQUEST_HEADER] WHERE [TRANSFER_REQUEST_ID] = @TRANSFER_REQUEST_ID
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_DELETE_TRANSFER_REQUEST_HEADER](
	@TRANSFER_REQUEST_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DELETE FROM [wms].[OP_WMS_TRANSFER_REQUEST_HEADER]
		WHERE [TRANSFER_REQUEST_ID] = @TRANSFER_REQUEST_ID
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  
			-1 as Resultado
			,CASE CAST(@@ERROR AS VARCHAR)
				WHEN '547' THEN 'Debe eliminar el detalle de la solicitud de transferencia primero'
				ELSE ERROR_MESSAGE() 
			END Mensaje 
			,@@ERROR Codigo
	END CATCH
END