-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	09-09-2016 @ A-TEAM Sprint 1
-- Description:			Borra todos los producto del acuerdo comercial

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].DELETE_ALL_DISCOUNT_FROM_TRADE_AGREEMENT
					@CHANNEL_ID = 1
				-- 
				SELECT * FROM [SONDA].SWIFT_TRADE_AGREEMENT_DISCOUNT WHERE TRADE_AGREEMENT_ID = 1
*/
-- =============================================
CREATE PROCEDURE [SONDA].DELETE_ALL_DISCOUNT_FROM_TRADE_AGREEMENT(
	@TRADE_AGREEMENT_ID  INT
)
AS
BEGIN
	BEGIN TRY
		DELETE FROM [SONDA].SWIFT_TRADE_AGREEMENT_DISCOUNT
		WHERE TRADE_AGREEMENT_ID = @TRADE_AGREEMENT_ID
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '0' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
