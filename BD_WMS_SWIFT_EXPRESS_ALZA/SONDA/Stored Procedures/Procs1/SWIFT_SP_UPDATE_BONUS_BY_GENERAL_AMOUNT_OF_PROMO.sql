-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-07-03 @ Team REBORN - Sprint 
-- Description:	        SP QUE ACTUALIZA UN REGISTRO DE LA TABLA [SWIFT_PROMO_BONUS_BY_GENERAL_AMOUNT]

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-14 @ Team REBORN - Sprint 
-- Description:	   Se agrega LAST_UPDATE

/*
-- Ejemplo de Ejecucion:
			EXEC  [SONDA].[SWIFT_SP_UPDATE_BONUS_BY_GENERAL_AMOUNT_OF_PROMO] @PROMO_BONUS_BY_GENERAL_AMOUNT_ID = 2, 
                                                            @PROMO_ID = 1103,                                                            
                                                            @CODE_SKU_BONUS = 'U00000443', 
                                                            @PACK_UNIT_BONUS = 1, 
                                                            @BONUS_QTY = 4
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_BONUS_BY_GENERAL_AMOUNT_OF_PROMO] (@PROMO_BONUS_BY_GENERAL_AMOUNT_ID INT, @PROMO_ID INT, @CODE_SKU_BONUS VARCHAR(50), @PACK_UNIT_BONUS INT, @BONUS_QTY INT)
AS
BEGIN
  SET NOCOUNT ON;
  --

  BEGIN TRY
    BEGIN TRANSACTION


    UPDATE [SONDA].[SWIFT_PROMO_BONUS_BY_GENERAL_AMOUNT]
    SET [PROMO_ID] = @PROMO_ID
       ,[CODE_SKU_BONUS] = @CODE_SKU_BONUS
       ,[PACK_UNIT_BONUS] = @PACK_UNIT_BONUS
       ,[BONUS_QTY] = @BONUS_QTY
       ,[LAST_UPDATE] = GETDATE()
    WHERE [PROMO_BONUS_BY_GENERAL_AMOUNT_ID] = @PROMO_BONUS_BY_GENERAL_AMOUNT_ID;

    COMMIT TRANSACTION

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
     ,CASE CAST(@@error AS VARCHAR)
        WHEN '2627' THEN 'Error al actualizar la bonificacion por monto general'
        ELSE ERROR_MESSAGE()
      END Mensaje
     ,@@error Codigo


  END CATCH;


END
