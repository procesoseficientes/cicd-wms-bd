-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	09-Feb-17 @ A-TEAM Sprint Chatuluka
-- Description:			SP que obtiene los combos QUe no estan asociados aL acuerdo comercial

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_COMBOS_NOT_IN_TRADE_AGREEMENT]
					@TRADE_AGREEMENT_ID = 20
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_COMBOS_NOT_IN_TRADE_AGREEMENT](
	@TRADE_AGREEMENT_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		[C].[COMBO_ID]
			,MAX([C].[NAME_COMBO]) [NAME_COMBO]
			,MAX([C].[DESCRIPTION_COMBO]) [DESCRIPTION_COMBO]
			,SUM([SC].[QTY]) [QTY]
	FROM [SONDA].[SWIFT_COMBO] [C]
	INNER JOIN [SONDA].[SWIFT_SKU_BY_COMBO] [SC] ON (
		[SC].[COMBO_ID] = [C].[COMBO_ID]
	)
	LEFT JOIN [SONDA].[SWIFT_VIEW_COMBO_BY_TRADE_AGREEMENT] [VCTD] ON (
		[VCTD].[COMBO_ID] = [C].[COMBO_ID] AND [VCTD].[TRADE_AGREEMENT_ID] = @TRADE_AGREEMENT_ID
	)
	WHERE [VCTD].[TRADE_AGREEMENT_ID] IS NULL
	GROUP BY [C].[COMBO_ID], [VCTD].[TRADE_AGREEMENT_ID]
	HAVING COUNT([SC].[QTY]) > 0
END
