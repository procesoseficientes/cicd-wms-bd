-- =============================================
-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	12-09-2016 @ A-TEAM Sprint 1
-- Description:			    SP que elimina el acuerdo comercial

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SWIFT_SP_DELETE_TRADE_AGREEMENT
					@TRADE_AGREEMENT_ID = 1
				-- 
				SELECT * FROM [SONDA].SWIFT_TRADE_AGREEMENT
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_DELETE_TRADE_AGREEMENT(
	@TRADE_AGREEMENT_ID INT
)
AS
BEGIN
	BEGIN TRY
		DELETE FROM [SONDA].SWIFT_TRADE_AGREEMENT
		WHERE TRADE_AGREEMENT_ID = @TRADE_AGREEMENT_ID
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '0' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '547' THEN 'No se puede eliminar el acuerdo comercial debido a que tiene objetos asociados'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
