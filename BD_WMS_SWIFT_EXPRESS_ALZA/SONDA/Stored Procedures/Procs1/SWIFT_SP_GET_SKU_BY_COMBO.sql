-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	08-Feb-17 @ A-TEAM Sprint Chatuluka 
-- Description:			SP para obtener los productos de un combo

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_SKU_BY_COMBO]
					@COMBO_ID = 5
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_SKU_BY_COMBO](
	@COMBO_ID INT = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT 
		[C].[COMBO_ID]
		,[C].[QTY]
		,[S].[CODE_SKU]
		,[S].[DESCRIPTION_SKU]
		,[FS].[FAMILY_SKU]
		,[FS].[CODE_FAMILY_SKU]
		,[FS].[DESCRIPTION_FAMILY_SKU]
		,[PU].[PACK_UNIT]
		,[PU].[CODE_PACK_UNIT]
		,[PU].[DESCRIPTION_PACK_UNIT]
	FROM [SONDA].[SWIFT_SKU_BY_COMBO] [C]
	INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] [S] ON (
		[C].[CODE_SKU] = [S].[CODE_SKU]
	)
	LEFT JOIN [SONDA].[SWIFT_FAMILY_SKU] [FS] ON (
		[FS].[CODE_FAMILY_SKU] = [S].[CODE_FAMILY_SKU]
	)
	INNER JOIN [SONDA].[SONDA_PACK_UNIT] [PU] ON (
		[C].[PACK_UNIT] = [PU].[PACK_UNIT]
	)
	WHERE [C].[COMBO_ID] = @COMBO_ID
	ORDER BY
		[s].[CODE_SKU]
		,[PU].[PACK_UNIT]
END
