-- =============================================
-- Autor:				Christian.Hernandez
-- Fecha de Creacion: 	11/13/2018 G-Force@Mamut 
-- Description:			SP que obtiene UNO O TODOS los registros de promociones de Descuento Precios especiales
-- filtrados por PROMO_ID

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_PROMO_SPECIAL_PRICE_LIST_BY_SCALE]
				@PROMO_ID = 3360
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_PROMO_SPECIAL_PRICE_LIST_BY_SCALE](
	@PROMO_ID INT = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT [PDS].[SPECIAL_PRICE_LIST_BY_SCALE_ID]
			,[PDS].[PROMO_ID]
			,[PDS].[CODE_SKU]
			,[VAS1].[DESCRIPTION_SKU]
			,FS.[CODE_FAMILY_SKU]
			,FS.[DESCRIPTION_FAMILY_SKU]
			,[PDS].[PACK_UNIT]
			,[PU1].[DESCRIPTION_PACK_UNIT]
			,[PDS].[LOW_LIMIT]
			,[PDS].[HIGH_LIMIT]
			,[PDS].[PRICE]
			,[pds].INCLUDE_DISCOUNT
	FROM [SONDA].[SONDA_PACK_UNIT] [PU1] 
		INNER JOIN [SONDA].[SWIFT_PROMO_SPECIAL_PRICE_LIST_BY_SCALE] [PDS] ON [PU1].[PACK_UNIT] = [PDS].[PACK_UNIT]
		INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] [VAS1] ON [VAS1].[CODE_SKU] = [PDS].[CODE_SKU]	
		LEFT JOIN SONDA.[SWIFT_FAMILY_SKU] FS ON [FS].[CODE_FAMILY_SKU] = [VAS1].[CODE_FAMILY_SKU]
	WHERE [PDS].[PROMO_ID] = @PROMO_ID

END
