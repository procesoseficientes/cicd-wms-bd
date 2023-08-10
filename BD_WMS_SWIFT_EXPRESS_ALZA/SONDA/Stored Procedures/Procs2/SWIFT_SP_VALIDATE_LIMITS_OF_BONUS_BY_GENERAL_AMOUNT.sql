-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-07-26 @ Team REBORN - Sprint 
-- Description:			SP que valida la escala de la bonificacion por monto general para que no existan colisiones

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_VALIDATE_LIMITS_OF_BONUS_BY_GENERAL_AMOUNT]
				@PROMO_ID = 8,
				@LOW_AMOUNT = 1000.000000,
				@HIGH_AMOUNT = 2999.990000
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_VALIDATE_LIMITS_OF_BONUS_BY_GENERAL_AMOUNT] (@PROMO_ID INT
, @LOW_LIMIT DECIMAL(18, 6)
, @HIGH_LIMIT DECIMAL(18, 6)
, @CODE_SKU VARCHAR(50)
, @PACK_UNIT INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @MESSAGE VARCHAR(250) = NULL
  --
  SELECT TOP 1
    @MESSAGE =
              CASE
                WHEN @LOW_LIMIT BETWEEN S.[LOW_LIMIT] AND S.[HIGH_LIMIT] THEN 'Límite inferior del Rango de Venta Mínima se encuentra entre rango existente.'
                WHEN @HIGH_LIMIT BETWEEN S.[LOW_LIMIT] AND S.[HIGH_LIMIT] THEN 'Límite superior del Rango de Venta Máxima se encuentra entre rango existente.'
                WHEN S.[LOW_LIMIT] BETWEEN @LOW_LIMIT AND @HIGH_LIMIT THEN 'Rango de Venta Mínima y Venta Máxima, absorbe un rango existente.'
                ELSE 'Rangos mal definidos.'
              END
  FROM [SONDA].[SWIFT_PROMO_BONUS_BY_GENERAL_AMOUNT] AS S
  WHERE S.[PROMO_ID] = @PROMO_ID
  AND [S].[CODE_SKU_BONUS] = @CODE_SKU
  AND [S].[PACK_UNIT_BONUS] = @PACK_UNIT
  AND (
  (
  @LOW_LIMIT BETWEEN S.[LOW_LIMIT] AND S.[HIGH_LIMIT]
  OR @HIGH_LIMIT BETWEEN S.[LOW_LIMIT] AND S.[HIGH_LIMIT]
  )
  OR (
  S.[LOW_LIMIT] BETWEEN @LOW_LIMIT AND @HIGH_LIMIT
  OR S.[HIGH_LIMIT] BETWEEN @LOW_LIMIT AND @HIGH_LIMIT
  )
  )
  --
  IF @MESSAGE IS NOT NULL
  BEGIN
    RAISERROR (@MESSAGE, 16, 1)
  END
END
