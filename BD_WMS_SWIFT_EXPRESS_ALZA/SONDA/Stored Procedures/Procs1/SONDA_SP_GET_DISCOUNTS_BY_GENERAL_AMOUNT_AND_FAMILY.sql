-- =============================================
-- Autor:				        rudi.garcia
-- Fecha de Creacion: 	11-May-2018 @ G-Force Sprint Caribú
-- Description:			SP que obtiene los descuentos generales por familia

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_GET_DISCOUNTS_BY_GENERAL_AMOUNT_AND_FAMILY]
					@CODE_ROUTE = '44'
*/
-- =============================================

CREATE PROCEDURE [SONDA].[SONDA_SP_GET_DISCOUNTS_BY_GENERAL_AMOUNT_AND_FAMILY] (@CODE_ROUTE VARCHAR(50))
AS
BEGIN
  --
  DECLARE @DISCOUNT_LIST TABLE (
    [DISCOUNT_LIST_ID] INT UNIQUE
  )
  --
  INSERT INTO @DISCOUNT_LIST
    SELECT
      [DL].[DISCOUNT_LIST_ID]
    FROM [SONDA].[SWIFT_DISCOUNT_LIST] [DL]
    WHERE [DL].[CODE_ROUTE] = @CODE_ROUTE
  --
  SELECT DISTINCT
    [DGF].[DISCOUNT_LIST_ID]
   ,[DGF].[CODE_FAMILY]
   ,[DGF].[LOW_AMOUNT]
   ,[DGF].[HIGH_AMOUNT]
   ,[DGF].[DISCOUNT_TYPE]
   ,[DGF].[DISCOUNT]
   ,[DGF].[PROMO_ID]
   ,[DGF].[PROMO_NAME]
   ,[DGF].[PROMO_TYPE]
   ,[DGF].[FREQUENCY]
  FROM [SONDA].[SWIFT_DISCOUNT_LIST_BY_GENERAL_AMOUNT_AND_FAMILY] AS [DGF]
  INNER JOIN @DISCOUNT_LIST [DL]
    ON (
    [DL].[DISCOUNT_LIST_ID] = [DGF].[DISCOUNT_LIST_ID]
    )
  WHERE [DGF].[DISCOUNT_LIST_ID] > 0

END
