-- =============================================
-- Autor:				        rudi.garcia
-- Fecha de Creacion: 	11-May-2018 @ G-Force Sprint Caribú
-- Description:			SP que obtiene los descuentos por tipo de pago y familia

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_GET_DISCOUNTS_BY_FAMILY_AND_PAYMENT_TYPE]
					@CODE_ROUTE = '44'
*/
-- =============================================

CREATE PROCEDURE [SONDA].[SONDA_SP_GET_DISCOUNTS_BY_FAMILY_AND_PAYMENT_TYPE] (@CODE_ROUTE VARCHAR(50))
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
    [DPF].[DISCOUNT_LIST_ID]
   ,[DPF].[PAYMENT_TYPE]
   ,[DPF].[CODE_FAMILY]
   ,[DPF].[DISCOUNT_TYPE]
   ,[DPF].[DISCOUNT]
   ,[DPF].[PROMO_ID]
   ,[DPF].[PROMO_NAME]
   ,[DPF].[PROMO_TYPE]
   ,[DPF].[FREQUENCY]
  FROM [SONDA].[SWIFT_DISCOUNT_LIST_BY_PAYMENT_TYPE_AND_FAMILY] AS [DPF]
  INNER JOIN @DISCOUNT_LIST [DL]
    ON (
    [DL].[DISCOUNT_LIST_ID] = [DPF].[DISCOUNT_LIST_ID]
    )
  WHERE [DPF].[DISCOUNT_LIST_ID] > 0

END
