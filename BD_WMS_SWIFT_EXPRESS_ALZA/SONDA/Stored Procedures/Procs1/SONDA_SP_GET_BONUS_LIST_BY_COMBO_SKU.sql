-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	10-Feb-17 @ A-TEAM Sprint Chatuluka
-- Description:			SP que obtiene las bonificaiones de los combos por lista de bonificacion a utilizar en la ruta

-- Modificacion 27-Mar-17 @ A-Team Sprint Fenyang
					-- alberto.ruiz
					-- Se Agrego campo IS_MULTIPLE

-- Modificacion 7/31/2017 @ Sprint Bearbeitung
					-- rodrigo.gomez
					-- Se agregan las nuevas columnas al SELECT y se cambia la comparacion al principio para que valide por CODE_ROUTE de la tabla.

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_GET_BONUS_LIST_BY_COMBO_SKU]
					@CODE_ROUTE = '44'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_BONUS_LIST_BY_COMBO_SKU](
	@CODE_ROUTE VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @BONUS_LIST TABLE ([BONUS_LIST_ID] INT , UNIQUE([BONUS_LIST_ID]))
	--
	INSERT INTO @BONUS_LIST
	SELECT
		[BL].[BONUS_LIST_ID]
	FROM [SONDA].[SWIFT_BONUS_LIST] [BL]
	WHERE [BL].[CODE_ROUTE] = @CODE_ROUTE 
	--
	SELECT DISTINCT
		[BLC].[BONUS_LIST_ID]
		,[BLC].[COMBO_ID]
		,[BLC].[CODE_SKU]
		,[BLC].[CODE_PACK_UNIT]
		,[BLC].[QTY]
		,[BLC].[IS_MULTIPLE]
	FROM [SONDA].[SWIFT_BONUS_LIST_BY_COMBO_SKU] [BLC] 
	INNER JOIN @BONUS_LIST [BL] ON (
		[BL].[BONUS_LIST_ID] = [BLC].[BONUS_LIST_ID]
	)
	WHERE [BL].[BONUS_LIST_ID] > 0
END
