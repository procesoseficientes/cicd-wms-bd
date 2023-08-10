-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-07-03 @ Team REBORN - Sprint Anpassung
-- Description:	        Sp que borra de la tabla SWIFT_PROMO_BONUS_BY_GENERAL_AMOUNT una bonificacion por monto general

/*
-- Ejemplo de Ejecucion:
			EXEC  [SONDA].[SWIFT_SP_DELETE_PROMO_OF_BONUS_BY_GENERAL_AMOUNT] @PROMO_BONUS_BY_GENERAL_AMOUNT_ID = 2
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_PROMO_OF_BONUS_BY_GENERAL_AMOUNT] (@PROMO_BONUS_BY_GENERAL_AMOUNT_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --

  BEGIN TRY    

    --Eliminamos la Bonificacion por monto general

    DELETE [SONDA].[SWIFT_PROMO_BONUS_BY_GENERAL_AMOUNT]
    WHERE [PROMO_BONUS_BY_GENERAL_AMOUNT_ID] = @PROMO_BONUS_BY_GENERAL_AMOUNT_ID


    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,CAST(@PROMO_BONUS_BY_GENERAL_AMOUNT_ID AS VARCHAR) DbData

  END TRY
  BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
      ROLLBACK TRANSACTION
    END

    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@error Codigo

  END CATCH;

END
