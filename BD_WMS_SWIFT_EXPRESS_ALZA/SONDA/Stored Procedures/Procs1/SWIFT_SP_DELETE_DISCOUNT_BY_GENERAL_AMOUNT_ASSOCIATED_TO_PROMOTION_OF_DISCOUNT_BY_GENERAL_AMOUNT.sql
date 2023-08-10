-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	7/23/2017 @ Reborn-TEAM Sprint Bearbeitung
-- Description:			SP que borra los descuentos por monto general asociados a una promocion

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-14 @ Team REBORN - Sprint 
-- Description:	   Se agrega UPDATE de tabla SWIFT_PROMO
/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [SONDA].SWIFT_PROMO_DISCOUNT_BY_GENERAL_AMOUNT
				--
				EXEC [SONDA].[SWIFT_SP_DELETE_DISCOUNT_BY_GENERAL_AMOUNT_ASSOCIATED_TO_PROMOTION_OF_DISCOUNT_BY_GENERAL_AMOUNT]
				@DISCOUNT_BY_GENERAL_AMOUNT_ID = 8
				-- 
				SELECT * FROM [SONDA].SWIFT_PROMO_DISCOUNT_BY_GENERAL_AMOUNT
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_DISCOUNT_BY_GENERAL_AMOUNT_ASSOCIATED_TO_PROMOTION_OF_DISCOUNT_BY_GENERAL_AMOUNT] (@DISCOUNT_BY_GENERAL_AMOUNT_ID INT)
AS
BEGIN
  BEGIN TRY

    DECLARE @PROMO_ID INT;
    --
    SET @PROMO_ID = (SELECT TOP 1
        [PROMO_ID]
      FROM [SONDA].[SWIFT_PROMO_DISCOUNT_BY_GENERAL_AMOUNT]
      WHERE [DISCOUNT_BY_GENERAL_AMOUNT_ID] = @DISCOUNT_BY_GENERAL_AMOUNT_ID)
    --
    DELETE FROM [SONDA].[SWIFT_PROMO_DISCOUNT_BY_GENERAL_AMOUNT]
    WHERE [DISCOUNT_BY_GENERAL_AMOUNT_ID] = @DISCOUNT_BY_GENERAL_AMOUNT_ID
    --
    UPDATE [SONDA].[SWIFT_PROMO]
    SET [LAST_UPDATE] = GETDATE()
    WHERE [PROMO_ID] = @PROMO_ID;
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
     ,ERROR_MESSAGE() Mensaje
     ,@@error Codigo
  END CATCH
END
