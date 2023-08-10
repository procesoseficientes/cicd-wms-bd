-- =============================================
-- Autor:				christian.hernandez
-- Fecha de Creacion: 	14/11/2018 G-Force@Mamut
-- Description:			SP que actualiza una promo de precio especial 


/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_UPDATE_PROMO_SPECIAL_PRICE]
					@PROMO_DISCOUNT_ID = 2114
					,@DISCOUNT = 6
					,@INCLUDE_DISCOUNT = 1
				-- 
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_PROMO_SPECIAL_PRICE_LIST_BY_SCALE] (@SPECIAL_PRICE_LIST_BY_SCALE_ID INT
, @PRICE NUMERIC(18, 6)
, @INCLUDE_DISCOUNT INT)
AS
BEGIN
  BEGIN TRY
    --
    UPDATE [SONDA].[SWIFT_PROMO_SPECIAL_PRICE_LIST_BY_SCALE]
    SET [PRICE] = @PRICE
		,[INCLUDE_DISCOUNT] = @INCLUDE_DISCOUNT
		,[LAST_UPDATE] = GETDATE()
    WHERE [SPECIAL_PRICE_LIST_BY_SCALE_ID] = @SPECIAL_PRICE_LIST_BY_SCALE_ID
    --
    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,'' DbData
  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,CASE CAST(@@error AS VARCHAR)
        WHEN '2627' THEN 'Error al actualizar la promoción por precio especial.'
        ELSE ERROR_MESSAGE()
      END Mensaje
     ,@@error Codigo
  END CATCH
END
