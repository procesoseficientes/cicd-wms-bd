-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-07-19 @ Team REBORN - Sprint Bearbeitung
-- Description:	        vista que relaciona las reglas con las promos

/*
-- Ejemplo de Ejecucion: 		
  	SELECT * FROM [SONDA].[SWIFT_VIEW_COMBO_BY_PROMO]
*/
-- =============================================
CREATE VIEW [SONDA].[SWIFT_VIEW_COMBO_BY_PROMO]
AS

SELECT
  [CPR].[PROMO_RULE_BY_COMBO_ID]
 ,[CPR].[COMBO_ID]
 ,[CPR].[BONUS_TYPE]
 ,[CPR].[BONUS_SUB_TYPE]
 ,[CPR].[IS_BONUS_BY_LOW_PURCHASE]
 ,[CPR].[IS_BONUS_BY_COMBO]
 ,[CPR].[LOW_QTY]
 ,[PBR].[PROMO_ID]
FROM [SONDA].[SWIFT_PROMO_BY_COMBO_PROMO_RULE] [CPR]
INNER JOIN [SONDA].[SWIFT_PROMO_BY_BONUS_RULE] [PBR]
  ON [CPR].[PROMO_RULE_BY_COMBO_ID] = [PBR].[PROMO_RULE_BY_COMBO_ID]
WHERE
	[CPR].[PROMO_RULE_BY_COMBO_ID] > 0
