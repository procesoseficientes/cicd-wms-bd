-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-07-18 @ Team REBORN - Sprint Bearbeitung
-- Description:	        agrega bonificaciones por combo a una promo

/*
-- Ejemplo de Ejecucion:
			EXEC  [SONDA].[SWIFT_SP_ADD_BONUS_BY_COMBO_RULE_TO_PROMO] @PROMO_RULE_BY_COMBO_ID = 2
                                                              ,@PROMO_ID = 6
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_ADD_BONUS_BY_COMBO_RULE_TO_PROMO] (@COMBO_ID INT
, @BONUS_TYPE VARCHAR(50)
, @BONUS_SUB_TYPE VARCHAR(50)
, @IS_BONUS_BY_LOW_PURCHASE INT
, @IS_BONUS_BY_COMBO INT
, @LOW_QTY INT = 1
, @PROMO_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --

  BEGIN TRY
    BEGIN TRANSACTION
    DECLARE @ID INT

    INSERT INTO [SONDA].[SWIFT_PROMO_BY_COMBO_PROMO_RULE] ([COMBO_ID], [BONUS_TYPE], [BONUS_SUB_TYPE], [IS_BONUS_BY_LOW_PURCHASE], [IS_BONUS_BY_COMBO], [LOW_QTY])
      VALUES (@COMBO_ID, @BONUS_TYPE, @BONUS_SUB_TYPE, @IS_BONUS_BY_LOW_PURCHASE, @IS_BONUS_BY_COMBO, @LOW_QTY);

    --
    SET @ID = SCOPE_IDENTITY()
    --

    INSERT INTO [SONDA].[SWIFT_PROMO_BY_BONUS_RULE] ([PROMO_ID], [PROMO_RULE_BY_COMBO_ID])
      VALUES (@PROMO_ID, @ID);

    COMMIT TRANSACTION

    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,CAST(@ID AS VARCHAR) DbData


  END TRY
  BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
      ROLLBACK TRANSACTION
    END
    SELECT
      -1 AS Resultado
     ,CASE CAST(@@error AS VARCHAR)
        WHEN '2627' THEN 'No se pudo insertar la bonificacion por combo a promocion'
        ELSE ERROR_MESSAGE()
      END Mensaje
     ,@@error Codigo

  END CATCH

END
