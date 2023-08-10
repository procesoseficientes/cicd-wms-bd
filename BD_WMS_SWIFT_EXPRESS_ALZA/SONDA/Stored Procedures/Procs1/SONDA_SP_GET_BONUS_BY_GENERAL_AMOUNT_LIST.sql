-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	7/31/2017 @ Sprint Bearbeitung
-- Description:			SP que obtiene las bonificaciones por monto general por ruta

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_GET_BONUS_BY_GENERAL_AMOUNT_LIST]
					@CODE_ROUTE = '44'
*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_GET_BONUS_BY_GENERAL_AMOUNT_LIST(
	@CODE_ROUTE VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE	@BONUS_LIST TABLE (
		[BONUS_LIST_ID] INT
		,UNIQUE ([BONUS_LIST_ID])
	);
	--
	INSERT INTO @BONUS_LIST
			([BONUS_LIST_ID])
	SELECT [BL].[BONUS_LIST_ID]
	FROM [SONDA].[SWIFT_BONUS_LIST] [BL]
	WHERE [CODE_ROUTE] = @CODE_ROUTE;
	--
	SELECT DISTINCT
		[BLGA].[BONUS_LIST_ID]
		,[BLGA].[LOW_LIMIT]
		,[BLGA].[HIGH_LIMIT]
		,[BLGA].[CODE_SKU_BONUS]
		,[BLGA].[CODE_PACK_UNIT_BONUS]
		,[BLGA].[BONUS_QTY]
		,[BLGA].[PROMO_ID]
		,[BLGA].[PROMO_NAME]
		,[BLGA].[PROMO_TYPE]
    ,[BLGA].[FREQUENCY]
	FROM [SONDA].[SWIFT_BONUS_LIST_BY_GENERAL_AMOUNT] AS [BLGA]
		INNER JOIN @BONUS_LIST [BL] ON ([BL].[BONUS_LIST_ID] = [BLGA].[BONUS_LIST_ID])
	WHERE [BLGA].[BONUS_LIST_ID] > 0;
END
