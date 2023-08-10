-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	10-Feb-17 @ A-TEAM Sprint Chatuluka
-- Description:			SP que obtiene los combos por lista de bonificacion a utilizar en la ruta

-- Modificacion 7/31/2017 @ Sprint Bearbeitung
					-- rodrigo.gomez
					-- Se agregan las nuevas columnas al SELECT y se cambia la comparacion al principio para que valide por CODE_ROUTE de la tabla.

-- Modificacion 17-Aug-2017 @Reborn Team Sprint Bearbeitung
-- rudi.garcia
-- Se agrego la columna de "FREQUENCY"

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_GET_BONUS_LIST_BY_COMBO]
					@CODE_ROUTE = '44'
*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_GET_BONUS_LIST_BY_COMBO(
	@CODE_ROUTE VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @BONUS_LIST TABLE ([BONUS_LIST_ID] INT, UNIQUE([BONUS_LIST_ID]))
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
		,[BLC].[BONUS_TYPE]
		,[BLC].[BONUS_SUB_TYPE]
		,[BLC].[IS_BONUS_BY_LOW_PURCHASE]
		,[BLC].[IS_BONUS_BY_COMBO]
		,[BLC].[LOW_QTY]
		,[BLC].[PROMO_ID]
		,[BLC].[PROMO_NAME]
		,[BLC].[PROMO_TYPE]
    ,[BLC].[FREQUENCY]
	FROM [SONDA].[SWIFT_BONUS_LIST_BY_COMBO] [BLC] 
	INNER JOIN @BONUS_LIST [BL] ON (
		[BL].[BONUS_LIST_ID] = [BLC].[BONUS_LIST_ID]
	)
	WHERE [BL].[BONUS_LIST_ID] > 0
END
