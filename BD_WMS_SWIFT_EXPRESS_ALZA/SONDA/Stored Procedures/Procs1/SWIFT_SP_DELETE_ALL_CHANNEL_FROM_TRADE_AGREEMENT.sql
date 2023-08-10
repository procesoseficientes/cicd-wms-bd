-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	12-09-2016 @ A-TEAM Sprint 1
-- Description:			SP que elimina todos los canales del acuerdo comercial

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SWIFT_SP_DELETE_ALL_CHANNEL_FROM_TRADE_AGREEMENT
					@TRADE_AGREEMENT_ID = 1
				-- 
				SELECT * FROM [SONDA].SWIFT_TRADE_AGREEMENT_BY_CHANNEL
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_DELETE_ALL_CHANNEL_FROM_TRADE_AGREEMENT(
	@TRADE_AGREEMENT_ID INT
)
AS
BEGIN
	BEGIN TRY
		DELETE FROM [SONDA].SWIFT_TRADE_AGREEMENT_BY_CHANNEL
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
