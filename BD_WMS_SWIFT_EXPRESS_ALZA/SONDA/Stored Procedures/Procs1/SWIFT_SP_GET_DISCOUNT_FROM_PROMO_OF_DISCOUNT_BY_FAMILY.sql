-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	30-Apr-2018 @ A-TEAM Sprint Caribú  
-- Description:			SP que obtine los descuentos por familia.

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SWIFT_SP_GET_DISCOUNT_FROM_PROMO_OF_DISCOUNT_BY_FAMILY
				@PROMO_ID = 3299
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_DISCOUNT_FROM_PROMO_OF_DISCOUNT_BY_FAMILY(
	@PROMO_ID INT = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT [DF].[PROMO_DISCOUNT_ID] AS [PROMO_IDENTITY]
			,[DF].[PROMO_ID]
			,[DF].[CODE_FAMILY_SKU]			
			,[FS].[DESCRIPTION_FAMILY_SKU]
			,[DF].[LOW_AMOUNT]
			,[DF].[HIGH_AMOUNT]
			,[DF].[DISCOUNT]
			,CASE [DF].[DISCOUNT_TYPE]
				WHEN 'PERCENTAGE' THEN 'PORCENTAJE'
				WHEN 'MONETARY' THEN 'MONETARIO' 
			END [DISCOUNT_TYPE]	
	FROM [SONDA].[SWIFT_PROMO_DISCOUNT_BY_FAMILY] [DF]
		INNER JOIN [SONDA].[SWIFT_FAMILY_SKU] [FS] ON ([FS].[CODE_FAMILY_SKU] = [DF].[CODE_FAMILY_SKU])		
	WHERE [DF].[PROMO_ID] = @PROMO_ID

END
