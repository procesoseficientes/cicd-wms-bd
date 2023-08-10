-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	16-Feb-17 @ A-TEAM Sprint Chatuluka 
-- Description:			SP que obtiene los descuentos generales por ruta

-- Modificacion 7/31/2017 @ Sprint Bearbeitung
					-- rodrigo.gomez
					-- Se agregan las nuevas columnas al SELECT y se cambia la comparacion al principio para que valide por CODE_ROUTE de la tabla.

-- Modificacion 17-Aug-2017 @Reborn Team Sprint Bearbeitung
-- rudi.garcia
-- Se agrego la columna de "FREQUENCY"

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_GET_DISCOUNTS_BY_GENERAL_AMOUNT_LIST]
					@CODE_ROUTE = '44'
*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_GET_DISCOUNTS_BY_GENERAL_AMOUNT_LIST(
	@CODE_ROUTE VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @DISCOUNT_LIST TABLE ([DISCOUNT_LIST_ID] INT UNIQUE)
	--
	INSERT INTO @DISCOUNT_LIST
	SELECT
		[DL].[DISCOUNT_LIST_ID]
	FROM [SONDA].[SWIFT_DISCOUNT_LIST] [DL]
	WHERE [DL].[CODE_ROUTE] = @CODE_ROUTE
	--
	SELECT DISTINCT
		[DLG].[DISCOUNT_LIST_ID]
		,[DLG].[LOW_AMOUNT]
		,[DLG].[HIGH_AMOUNT]
		,[DLG].[DISCOUNT]
		,[DLG].[PROMO_ID]
		,[DLG].[PROMO_NAME]
		,[DLG].[PROMO_TYPE]
    ,[DLG].[FREQUENCY]
	FROM [SONDA].[SWIFT_DISCOUNT_LIST_BY_GENERAL_AMOUNT] AS [DLG]
	INNER JOIN @DISCOUNT_LIST [DL] ON (
		[DL].[DISCOUNT_LIST_ID] = [DLG].[DISCOUNT_LIST_ID]
	)
	WHERE [DLG].[DISCOUNT_LIST_ID] > 0
END
