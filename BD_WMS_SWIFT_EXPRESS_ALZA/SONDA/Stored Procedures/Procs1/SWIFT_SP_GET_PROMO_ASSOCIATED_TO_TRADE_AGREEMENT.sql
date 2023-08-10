-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	7/26/2017 @ Sprint Bearbeitung 
-- Description:			Obtiene las promos de un acuerdo comercial

-- Modificacion:		Christian Hernandez 
-- Fecha de modificacion:5/15/2018 (validacion para DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE para Tipo de pago por familia)

-- Modificacion:		Marvin.Garcia
-- Fecha de modificacion:19/06/2018 (validacion para DISCOUNT_BY_GENERAL_AMOUNT_AND_FAMILY)
/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_PROMO_ASSOCIATED_TO_TRADE_AGREEMENT] 
					@TRADE_AGREEMENT_ID = 1
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_PROMO_ASSOCIATED_TO_TRADE_AGREEMENT] (@TRADE_AGREEMENT_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [SP].[PROMO_ID]
   ,[SP].[PROMO_NAME]
   ,CASE [SP].[PROMO_TYPE]  
      WHEN 'BONUS_BY_COMBO' THEN 'Bonificación Combos'
      WHEN 'BONUS_BY_GENERAL_AMOUNT' THEN 'BMG'
      WHEN 'BONUS_BY_MULTIPLE' THEN 'Bonificación Múltiplos'
      WHEN 'BONUS_BY_SCALE' THEN 'Bonificación Escalas'
      WHEN 'DISCOUNT_BY_GENERAL_AMOUNT' THEN 'DMG'
      WHEN 'DISCOUNT_BY_SCALE' THEN 'Descuento Escalas'
      WHEN 'SALES_BY_MULTIPLE' THEN 'VM'
      WHEN 'DISCOUNT_BY_GENERAL_AMOUNT_AND_FAMILY' THEN 'Descuento por familia'   	  
      WHEN 'DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE' THEN 'Tipo de pago por familia'
      WHEN 'SPECIAL_PRICE' THEN 'Precio Especial'
    END [PROMO_TYPE]
   ,[STAP].[TRADE_AGREEMENT_ID]
   ,[STAP].[FREQUENCY]
  FROM [SONDA].[SWIFT_PROMO] [SP]
  INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_PROMO] [STAP]
    ON [STAP].[PROMO_ID] = [SP].[PROMO_ID]
  WHERE [STAP].[TRADE_AGREEMENT_ID] = @TRADE_AGREEMENT_ID
END
