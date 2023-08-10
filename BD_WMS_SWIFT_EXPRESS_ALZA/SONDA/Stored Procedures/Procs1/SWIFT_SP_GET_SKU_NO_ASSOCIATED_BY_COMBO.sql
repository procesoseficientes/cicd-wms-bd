-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	08-Feb-17 @ A-TEAM Sprint Chatuluka 
-- Description:			SP que obtiene los productos disponibles para asociar al combo

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_SKU_NO_ASSOCIATED_BY_COMBO]
					@COMBO_ID = 5
				--
				EXEC [SONDA].[SWIFT_SP_GET_SKU_NO_ASSOCIATED_BY_COMBO]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_SKU_NO_ASSOCIATED_BY_COMBO](
	@COMBO_ID INT = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT 
		ROW_NUMBER() OVER (ORDER BY [S].[CODE_SKU],[PU].[PACK_UNIT]) [ID]
		,[S].[CODE_SKU]
		,[S].[DESCRIPTION_SKU]
		,[FS].[FAMILY_SKU]
		,[FS].[CODE_FAMILY_SKU]
		,[FS].[DESCRIPTION_FAMILY_SKU]
		,[PU].[PACK_UNIT]
		,[PU].[CODE_PACK_UNIT]
		,[PU].[DESCRIPTION_PACK_UNIT]
	FROM [SONDA].[SWIFT_VIEW_ALL_SKU] [S]
	LEFT JOIN [SONDA].[SWIFT_FAMILY_SKU] [FS] ON (
		[FS].[CODE_FAMILY_SKU] = [S].[CODE_FAMILY_SKU]
	)
	INNER JOIN [SONDA].[SONDA_PACK_CONVERSION] [PC] ON (
		[PC].[CODE_SKU] = [S].[CODE_SKU]
	)
	INNER JOIN [SONDA].[SONDA_PACK_UNIT] [PU] ON (
		[PU].[CODE_PACK_UNIT] = [PC].[CODE_PACK_UNIT_FROM]
	)
	LEFT JOIN [SONDA].[SWIFT_SKU_BY_COMBO] [C] ON (
		[C].[CODE_SKU] = [S].[CODE_SKU]
		AND [C].[PACK_UNIT] = [PU].[PACK_UNIT]
		AND [C].[COMBO_ID] = @COMBO_ID
	)
	WHERE [C].[COMBO_ID] IS NULL
	ORDER BY
		[S].[CODE_SKU]
		,[PU].[PACK_UNIT]
END
