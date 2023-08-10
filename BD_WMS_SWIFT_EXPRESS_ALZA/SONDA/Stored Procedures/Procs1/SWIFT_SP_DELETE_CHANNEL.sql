-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	09-09-2016 @ A-TEAM Sprint 1
-- Description:			SP que elimina el canal

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SWIFT_SP_DELETE_CHANNEL
					@CHANNEL_ID = 1
				-- 
				SELECT * FROM [SONDA].SWIFT_CHANNEL
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_DELETE_CHANNEL(
	@CHANNEL_ID INT
)
AS
BEGIN
	BEGIN TRY
		DELETE FROM [SONDA].SWIFT_CHANNEL
		WHERE CHANNEL_ID = @CHANNEL_ID
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '0' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '547' THEN 'No se puede eliminar el canal debido a que tiene clientes relacionados'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
