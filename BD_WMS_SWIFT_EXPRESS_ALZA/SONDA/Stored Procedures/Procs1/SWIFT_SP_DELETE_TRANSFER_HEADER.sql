-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		11-Oct-16 @ A-Team Sprint 2
-- Description:			    Elimina una transferencia

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_DELETE_TRANSFER_HEADER]
			@TRANSFER_ID = 30
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_TRANSFER_HEADER] (
	@TRANSFER_ID NUMERIC(18 ,0)
)
AS
BEGIN
	BEGIN TRY
		DELETE [SONDA].[SWIFT_TRANSFER_HEADER]
		WHERE [TRANSFER_ID] = @TRANSFER_ID;
		--
		COMMIT;
		--
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo];
	END TRY
	BEGIN CATCH		
		SELECT
			-1 AS [Resultado]
			,CASE CAST(@@ERROR AS VARCHAR)
				WHEN '547' THEN 'No se puede eliminar la transferencia ya que todavia tiene SKU asociados'
				ELSE ERROR_MESSAGE() 
			END[Mensaje]
			,@@ERROR [Codigo]; 
	END CATCH;
END;
