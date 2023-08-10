-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	10-Feb-17 @ A-TEAM Sprint Chatuluka
-- Description:			SP que obtiene los productos de los combos a utilizar en la ruta

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_GET_SKU_FOR_COMBOS_BY_ROUTE]
					@CODE_ROUTE = '4'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_SKU_FOR_COMBOS_BY_ROUTE](
	@CODE_ROUTE VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @BONUS_LIST TABLE ([BONUS_LIST_ID] INT)
	--
	INSERT INTO @BONUS_LIST
	SELECT
		[BL].[BONUS_LIST_ID]
	FROM [SONDA].[SWIFT_BONUS_LIST] [BL]
	WHERE [BL].[NAME_BONUS_LIST] LIKE (@CODE_ROUTE + '%')
	--
	SELECT DISTINCT
		[SC].[COMBO_ID]
		,[SC].[CODE_SKU]
		,[PU].[CODE_PACK_UNIT]
		,[SC].[QTY]
	FROM [SONDA].[SWIFT_SKU_BY_COMBO] [SC]
	INNER JOIN [SONDA].[SWIFT_BONUS_LIST_BY_COMBO] [BLC] ON (
		[BLC].[COMBO_ID] = [SC].[COMBO_ID]
	)
	INNER JOIN [SONDA].[SONDA_PACK_UNIT] [PU] ON (
		[PU].[PACK_UNIT] = [SC].[PACK_UNIT]
	)
	INNER JOIN @BONUS_LIST [BL] ON (
		[BL].[BONUS_LIST_ID] = [BLC].[BONUS_LIST_ID]
	)
END
