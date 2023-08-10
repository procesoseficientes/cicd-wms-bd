-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	10-Feb-17 @ A-TEAM Sprint Chatuluka
-- Description:			SP que obtiene los combos a utilizar en la ruta

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_GET_COMBOS_BY_ROUTE]
					@CODE_ROUTE = '4'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_COMBOS_BY_ROUTE](
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
		[C].[COMBO_ID]
		,[C].[NAME_COMBO]
		,[C].[DESCRIPTION_COMBO]
	FROM [SONDA].[SWIFT_COMBO] [C]
	INNER JOIN [SONDA].[SWIFT_BONUS_LIST_BY_COMBO] [BLC] ON (
		[BLC].[COMBO_ID] = [C].[COMBO_ID]
	)
	INNER JOIN @BONUS_LIST [BL] ON (
		[BL].[BONUS_LIST_ID] = [BLC].[BONUS_LIST_ID]
	)
END
