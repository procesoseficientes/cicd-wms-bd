-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-07-03 @ Team REBORN - Sprint Anpassung 
-- Description:	        sp que inserta la promocion y la bonificacion por monto general

/*
-- Ejemplo de Ejecucion:
			EXEC  [SONDA].[SWIFT_SP_ADD_BONUS_BY_GENERAL_AMOUNT_TO_PROMO] @PROMO_NAME = 'Promo Prueba monto general 1', 
                                                                  @LOW_LIMIT = 1000,  
                                                                  @HIGH_LIMIT = 2000,   
                                                                  @CODE_SKU_BONUS = 'U00000331' ,   
                                                                  @PACK_UNIT_BONUS = 2, 
                                                                  @BONUS_QTY = 2 
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_ADD_BONUS_BY_GENERAL_AMOUNT_TO_PROMO] (@PROMO_ID INT,
@LOW_LIMIT DECIMAL(18, 6),
@HIGH_LIMIT DECIMAL(18, 6),
@CODE_SKU_BONUS VARCHAR(50),
@PACK_UNIT_BONUS INT,
@BONUS_QTY INT)
AS
BEGIN
  SET NOCOUNT ON;
  --

  BEGIN TRY

    DECLARE @ID INT
    -- ----------------------------------------------------------------------------------------------------------
    -- Se valida el rango de venta para la Bonificacion por monto general
    -- ----------------------------------------------------------------------------------------------------------
    EXEC [SONDA].[SWIFT_SP_VALIDATE_LIMITS_OF_BONUS_BY_GENERAL_AMOUNT] @PROMO_ID = @PROMO_ID
                                                                    ,@LOW_LIMIT = @LOW_LIMIT
                                                                    ,@HIGH_LIMIT = @HIGH_LIMIT
                                                                    ,@CODE_SKU = @CODE_SKU_BONUS
                                                                    ,@PACK_UNIT = @PACK_UNIT_BONUS

    -- ----------------------------------------------------------------------------------------------------------
    -- Se inserta la bonificacion
    -- ----------------------------------------------------------------------------------------------------------
    INSERT INTO [SONDA].[SWIFT_PROMO_BONUS_BY_GENERAL_AMOUNT] ([PROMO_ID], [LOW_LIMIT], [HIGH_LIMIT], [CODE_SKU_BONUS], [PACK_UNIT_BONUS], [BONUS_QTY])
      VALUES (@PROMO_ID, @LOW_LIMIT, @HIGH_LIMIT, @CODE_SKU_BONUS, @PACK_UNIT_BONUS, @BONUS_QTY);

    --
    SET @ID = SCOPE_IDENTITY()
    --

    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,CAST(@ID AS VARCHAR) DbData

  END TRY
  BEGIN CATCH

    SELECT
      -1 AS Resultado
     ,CASE CAST(@@error AS VARCHAR)
        WHEN '2627' THEN 'No se pudo insertar la bonificacion por monto general SKU: ' + CAST(@CODE_SKU_BONUS AS VARCHAR(50)) + ' repetido'
        ELSE ERROR_MESSAGE()
      END Mensaje
     ,@@error Codigo


  END CATCH;

END
