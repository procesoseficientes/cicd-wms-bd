-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	23-Nov-16 @ A-TEAM Sprint 5
-- Description:			SP para eliminar todas bonificacion por multiplo del acuerdo comercial que recibe como parametro

/*
-- Ejemplo de Ejecucion:
		SELECT * FROM [SONDA].[SWIFT_TRADE_AGREEMENT_BONUS_BY_MULTIPLE] WHERE [TRADE_AGREEMENT_ID] = 20
		--
		EXEC [SONDA].[SWIFT_SP_DELETE_ALL_BONUS_MULTIPLE_FROM_TRADE_AGREEMENT]
			@TRADE_AGREEMENT_ID = 20
		-- 
		SELECT * FROM [SONDA].[SWIFT_TRADE_AGREEMENT_BONUS_BY_MULTIPLE] WHERE [TRADE_AGREEMENT_ID] = 20
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_DELETE_ALL_BONUS_MULTIPLE_FROM_TRADE_AGREEMENT(
	@TRADE_AGREEMENT_ID INT
)
AS
BEGIN
	BEGIN TRY
		--
		DELETE FROM [SONDA].[SWIFT_TRADE_AGREEMENT_BONUS_BY_MULTIPLE]
		WHERE [TRADE_AGREEMENT_ID] = @TRADE_AGREEMENT_ID
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  
			-1 as Resultado
			,ERROR_MESSAGE() Mensaje 
			,@@ERROR Codigo 
	END CATCH
END
