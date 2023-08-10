-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/14/2017 @ A-TEAM Sprint Jibade 
-- Description:			Obtiene los skus a bonificar en promociones de bonificaciones por combo

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_BONUS_FROM_PROMO_OF_BONUS_BY_COMBO]
					@PROMO_RULE_BY_COMBO_ID = 33
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_BONUS_FROM_PROMO_OF_BONUS_BY_COMBO](
	@PROMO_RULE_BY_COMBO_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT [PSPR].[PROMO_RULE_BY_COMBO_ID]
			,[PSPR].[CODE_SKU]
			,[VAS].[DESCRIPTION_SKU]
			,[PSPR].[PACK_UNIT]
			,[PU].[DESCRIPTION_PACK_UNIT]
			,[PSPR].[QTY]
			,[PSPR].[IS_MULTIPLE]
	FROM [SONDA].[SWIFT_PROMO_SKU_BY_PROMO_RULE] [PSPR] 
		INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] [VAS] ON [VAS].[CODE_SKU] = [PSPR].[CODE_SKU]
		INNER JOIN [SONDA].[SONDA_PACK_UNIT] [PU] ON [PU].[PACK_UNIT] = [PSPR].[PACK_UNIT]
	WHERE [PSPR].[PROMO_RULE_BY_COMBO_ID] = @PROMO_RULE_BY_COMBO_ID
END
