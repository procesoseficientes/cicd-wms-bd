-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	7/23/2017 @ Reborn-TEAM Sprint Bearbeitung 
-- Description:			SP que actualiza un descuento por monto general asociado a una promocion

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-14 @ Team REBORN - Sprint 
-- Description:	   se agrega LAST_UPDATE

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_UPDATE_DISCOUNT_BY_GENERAL_AMOUNT_ASSOCIATED_TO_PROMOTION_OF_DISCOUNT_BY_GENERAL_AMOUNT]
				@DISCOUNT_BY_GENERAL_AMOUNT_ID = 3,
				@PROMO_ID = 14,
				@DISCOUNT = 1.66542
				-- 
				SELECT * FROM [SONDA].[SWIFT_PROMO_DISCOUNT_BY_GENERAL_AMOUNT]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_DISCOUNT_BY_GENERAL_AMOUNT_ASSOCIATED_TO_PROMOTION_OF_DISCOUNT_BY_GENERAL_AMOUNT] (@DISCOUNT_BY_GENERAL_AMOUNT_ID INT,
@PROMO_ID INT,
@DISCOUNT NUMERIC(18, 6))
AS
BEGIN
  BEGIN TRY
    --
    UPDATE [SONDA].[SWIFT_PROMO_DISCOUNT_BY_GENERAL_AMOUNT]
    SET [DISCOUNT] = @DISCOUNT
       ,[LAST_UPDATE] = GETDATE()
    WHERE [DISCOUNT_BY_GENERAL_AMOUNT_ID] = @DISCOUNT_BY_GENERAL_AMOUNT_ID
    AND [PROMO_ID] = @PROMO_ID
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
