-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	6/29/2017 @ A-TEAM Sprint Anpassung 
-- Description:			SP que actualiza una promo de Descuento por Escala

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-14 @ Team REBORN - Sprint 
-- Description:	   se agrego LAST_UPDATE

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_UPDATE_PROMO_DISCOUNT_BY_SCALE]
					@PROMO_DISCOUNT_BY_SCALE_ID = 2
					, @DISCOUNT = 5.3213546546
				-- 
				SELECT * FROM [SONDA].[SWIFT_PROMO_DISCOUNT_BY_SCALE]
				WHERE [PROMO_DISCOUNT_ID] = 2
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_PROMO_DISCOUNT_BY_SCALE] (@PROMO_DISCOUNT_BY_SCALE_ID INT
, @DISCOUNT NUMERIC(18, 6)
, @IS_UNIQUE INT)
AS
BEGIN
  BEGIN TRY
    --
    UPDATE [SONDA].[SWIFT_PROMO_DISCOUNT_BY_SCALE]
    SET [DISCOUNT] = @DISCOUNT
		,[IS_UNIQUE] = @IS_UNIQUE
		,[LAST_UPDATE] = GETDATE()
    WHERE [PROMO_DISCOUNT_ID] = @PROMO_DISCOUNT_BY_SCALE_ID
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
        WHEN '2627' THEN 'Error al actualizar la promoción de descuento por escala.'
        ELSE ERROR_MESSAGE()
      END Mensaje
     ,@@error Codigo
  END CATCH
END
