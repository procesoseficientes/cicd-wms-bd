-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	13-09-2016 @ A-TEAM Sprint 1
-- Description:			Elimina el producto del acuerdo comercial

-- Modificacion 2/10/2017 @ A-Team Sprint 
					-- rodrigo.gomez
					-- Se agrego la utilizacion de la llave primaria de la tabla en 
/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SWIFT_SP_DELETE_DISCOUNT_FROM_TRADE_AGREEMENT
					@TRADE_AGREEMENT_DISCUOUNT_ID = 4
				-- 
				SELECT * FROM [SONDA].SWIFT_TRADE_AGREEMENT_DISCOUNT
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_DELETE_DISCOUNT_FROM_TRADE_AGREEMENT(
	@TRADE_AGREEMENT_DISCUOUNT_ID INT
	--,@CODE_SKU  VARCHAR(50)
)
AS
BEGIN
	BEGIN TRY
		DELETE FROM [SONDA].SWIFT_TRADE_AGREEMENT_DISCOUNT
		WHERE [TRADE_AGREEMENT_DISCUOUNT_ID] = @TRADE_AGREEMENT_DISCUOUNT_ID
			--AND CODE_SKU = @CODE_SKU
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '0' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
