-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/14/2017 @ A-TEAM Sprint Jibade 
-- Description:			SP que actualiza la tabla SWIFT_PROMO_BY_COMBO_PROMO_RULE

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-14 @ Team REBORN - Sprint 
-- Description:	   Se agrego LAST_UPDATE
/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_UPDATE_PROMO_OF_BONUS_BY_COMBO]
					@PROMO_RULE_BY_COMBO_ID = 9
					,@COMBO_ID  = 1
					,@BONUS_TYPE  = 'UNIQUE'
					,@BONUS_SUB_TYPE  = 'UNIQUE'
					,@IS_BONUS_BY_LOW_PURCHASE = 0
					,@IS_BONUS_BY_COMBO = 0
					,@LOW_QTY = 9
				-- 
				SELECT * FROM [SONDA].SWIFT_PROMO_BY_COMBO_PROMO_RULE
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_PROMO_OF_BONUS_BY_COMBO] (@PROMO_RULE_BY_COMBO_ID INT
, @COMBO_ID INT
, @BONUS_TYPE VARCHAR(50)
, @BONUS_SUB_TYPE VARCHAR(50)
, @IS_BONUS_BY_LOW_PURCHASE INT
, @IS_BONUS_BY_COMBO INT
, @LOW_QTY INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY
    UPDATE [SONDA].SWIFT_PROMO_BY_COMBO_PROMO_RULE
    SET [COMBO_ID] = @COMBO_ID
       ,[BONUS_TYPE] = @BONUS_TYPE
       ,[BONUS_SUB_TYPE] = @BONUS_SUB_TYPE
       ,[IS_BONUS_BY_LOW_PURCHASE] = @IS_BONUS_BY_LOW_PURCHASE
       ,[IS_BONUS_BY_COMBO] = @IS_BONUS_BY_COMBO
       ,[LOW_QTY] = @LOW_QTY
       ,[LAST_UPDATE] = GETDATE()
    WHERE [PROMO_RULE_BY_COMBO_ID] = @PROMO_RULE_BY_COMBO_ID
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
        WHEN '2627' THEN 'No se pudo actualizar la bonificacion por combo'
        ELSE ERROR_MESSAGE()
      END Mensaje
     ,@@error Codigo
  END CATCH
END
