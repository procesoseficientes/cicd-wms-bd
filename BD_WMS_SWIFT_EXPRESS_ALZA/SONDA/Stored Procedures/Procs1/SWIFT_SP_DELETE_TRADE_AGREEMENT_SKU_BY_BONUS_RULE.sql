﻿-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	09-Feb-17 @ A-TEAM Sprint Chatuluka 
-- Description:			SP que borra 

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [SONDA].[SWIFT_TRADE_AGREEMENT_SKU_BY_BONUS_RULE]
				--
				EXEC [SONDA].[SWIFT_SP_DELETE_TRADE_AGREEMENT_SKU_BY_BONUS_RULE]
					@TRADE_AGREEMENT_BONUS_RULE_BY_COMBO_ID = 3
					,@CODE_SKU = '10003'
					,@PACK_UNIT = 8
				-- 
				SELECT * FROM [SONDA].[SWIFT_TRADE_AGREEMENT_SKU_BY_BONUS_RULE]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_TRADE_AGREEMENT_SKU_BY_BONUS_RULE](
	@TRADE_AGREEMENT_BONUS_RULE_BY_COMBO_ID INT
	,@CODE_SKU VARCHAR(50)
	,@PACK_UNIT INT
)
AS
BEGIN
	BEGIN TRY
		DELETE FROM [SONDA].[SWIFT_TRADE_AGREEMENT_SKU_BY_BONUS_RULE] 
		WHERE [TRADE_AGREEMENT_BONUS_RULE_BY_COMBO_ID] = @TRADE_AGREEMENT_BONUS_RULE_BY_COMBO_ID
			AND [CODE_SKU] = @CODE_SKU
			AND [PACK_UNIT] = @PACK_UNIT
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
