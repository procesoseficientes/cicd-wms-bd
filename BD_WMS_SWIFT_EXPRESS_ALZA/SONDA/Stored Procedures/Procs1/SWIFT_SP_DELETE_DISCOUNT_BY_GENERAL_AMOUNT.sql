-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	15-Feb-17 @ A-TEAM Sprint  
-- Description:			SP que borra un registro de Descuento Por Monto General del Acuerdo Comercial

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [SONDA].[SWIFT_TRADE_AGREEMENT_DISCOUNT_BY_GENERAL_AMOUNT]
				--
				EXEC [SONDA].[SWIFT_SP_DELETE_DISCOUNT_BY_GENERAL_AMOUNT]
					@TRADE_AGREEMENT_ID = 21
					,@LOW_AMOUNT = '50'
					,@HIGH_AMOUNT = '100'
				-- 
				SELECT * FROM [SONDA].[SWIFT_TRADE_AGREEMENT_DISCOUNT_BY_GENERAL_AMOUNT]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_DISCOUNT_BY_GENERAL_AMOUNT](
	@TRADE_AGREEMENT_ID INT
	,@LOW_AMOUNT NUMERIC(18, 6)
	,@HIGH_AMOUNT NUMERIC(18, 6)
)
AS
BEGIN
	BEGIN TRY
		DELETE FROM [SONDA].[SWIFT_TRADE_AGREEMENT_DISCOUNT_BY_GENERAL_AMOUNT]
		WHERE TRADE_AGREEMENT_ID = @TRADE_AGREEMENT_ID
			AND LOW_AMOUNT = @LOW_AMOUNT
			AND HIGH_AMOUNT= @HIGH_AMOUNT
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
