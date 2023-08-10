-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-07-03 @ Team REBORN - Sprint Anpassung
-- Description:	        Obtiene las bonificaciones por combos disponibles para la promo

/*
-- Ejemplo de Ejecucion:
			EXEC  [SONDA].[SWIFT_SP_GET_BONUS_BY_COMBO_OF_PROMO_AVAILABLE] @PROMO_ID = 66
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_BONUS_BY_COMBO_OF_PROMO_AVAILABLE] (@PROMO_ID INT = NULL)
AS
BEGIN
  SET NOCOUNT ON;
  --

  SELECT
    [C].[COMBO_ID]
   ,MAX([C].[NAME_COMBO]) [NAME_COMBO]
   ,MAX([C].[DESCRIPTION_COMBO]) [DESCRIPTION_COMBO]
   ,SUM([SC].[QTY]) [QTY]
  FROM [SONDA].[SWIFT_COMBO] [C]
  INNER JOIN [SONDA].[SWIFT_SKU_BY_COMBO] [SC]
    ON ([C].[COMBO_ID] = [SC].[COMBO_ID])
  LEFT JOIN [SONDA].[SWIFT_VIEW_COMBO_BY_PROMO] [VCBP]
    ON ([VCBP].[COMBO_ID] = [C].[COMBO_ID]
    AND [VCBP].[PROMO_ID] = @PROMO_ID)
  WHERE [VCBP].[COMBO_ID] IS NULL
  AND [C].[COMBO_ID] > 0
  GROUP BY [C].[COMBO_ID]
          ,[VCBP].[PROMO_ID]
  HAVING COUNT([SC].[QTY]) > 0

END
