-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	15-Feb-17 @ A-TEAM Sprint  Chatuluka
-- Description:			SP que borra Todos los registros de la tabla de 
--						[SWIFT_TRADE_AGREEMENT_DISCOUNT_BY_GENERAL_AMOUNT] por acuerdo comercial

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [SONDA].[SWIFT_TRADE_AGREEMENT_DISCOUNT_BY_GENERAL_AMOUNT]
				--
				EXEC [SONDA].[SWIFT_SP_DELETE_ALL_TRADE_AGREEMENT_DISCOUNT_BY_GENERAL_AMOUNT]
					@TRADE_AGREEMENT_ID = 21
				-- 
				SELECT * FROM [SONDA].[SWIFT_TRADE_AGREEMENT_DISCOUNT_BY_GENERAL_AMOUNT]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_ALL_TRADE_AGREEMENT_DISCOUNT_BY_GENERAL_AMOUNT](
	@TRADE_AGREEMENT_ID INT
)
AS
BEGIN
	BEGIN TRY
		DELETE FROM [SONDA].[SWIFT_TRADE_AGREEMENT_DISCOUNT_BY_GENERAL_AMOUNT]
		WHERE TRADE_AGREEMENT_ID = @TRADE_AGREEMENT_ID
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
