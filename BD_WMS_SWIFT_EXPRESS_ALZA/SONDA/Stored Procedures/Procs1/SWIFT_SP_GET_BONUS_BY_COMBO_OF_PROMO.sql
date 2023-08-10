-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-06-29 @ Team REBORN - Sprint Anpassung
-- Description:	        Obtiene los combos relacionados a una promocion

/*
-- Ejemplo de Ejecucion:
			EXEC  [SONDA].[SWIFT_SP_GET_BONUS_BY_COMBO_OF_PROMO] @PROMO_ID = 6
*/
-- =============================================

CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_BONUS_BY_COMBO_OF_PROMO] (@PROMO_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [PBBR].[PROMO_ID]
   ,[C].[COMBO_ID]
   ,[C].[NAME_COMBO]
   ,[C].[DESCRIPTION_COMBO]
   ,SUM([SBC].[QTY]) QTY
   ,PBC.PROMO_RULE_BY_COMBO_ID
   ,PBC.BONUS_TYPE
   ,PBC.BONUS_SUB_TYPE
   ,PBC.IS_BONUS_BY_LOW_PURCHASE
   ,PBC.IS_BONUS_BY_COMBO
   ,PBC.LOW_QTY
  FROM [SONDA].[SWIFT_COMBO] [C]
  INNER JOIN [SONDA].[SWIFT_SKU_BY_COMBO] [SBC]
    ON [C].[COMBO_ID] = [SBC].[COMBO_ID]
  INNER JOIN [SONDA].[SWIFT_PROMO_BY_COMBO_PROMO_RULE] [PBC]
    ON [C].[COMBO_ID] = [PBC].[COMBO_ID]
  INNER JOIN [SONDA].[SWIFT_PROMO_BY_BONUS_RULE] [PBBR]
    ON [PBC].[PROMO_RULE_BY_COMBO_ID] = [PBBR].[PROMO_RULE_BY_COMBO_ID]
  WHERE [PBBR].[PROMO_ID] = @PROMO_ID
  GROUP BY [PBBR].[PROMO_ID]
          ,[C].[COMBO_ID]
          ,[C].[NAME_COMBO]
          ,[C].[DESCRIPTION_COMBO]
          ,PBC.PROMO_RULE_BY_COMBO_ID
          ,PBC.BONUS_TYPE
          ,PBC.BONUS_SUB_TYPE
          ,PBC.IS_BONUS_BY_LOW_PURCHASE
          ,PBC.IS_BONUS_BY_COMBO
          ,PBC.LOW_QTY
END
