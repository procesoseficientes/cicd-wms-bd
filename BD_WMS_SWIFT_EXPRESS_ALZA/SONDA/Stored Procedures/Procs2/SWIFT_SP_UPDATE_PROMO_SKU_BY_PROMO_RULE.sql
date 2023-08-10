-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/14/2017 @ A-TEAM Sprint Jibade 
-- Description:			SP que actualiza un registro de la tabla SWIFT_PROMO_SKU_BY_PROMO_RULE

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-14 @ Team REBORN - Sprint 
-- Description:	   Se agrega LAST_UPDATE

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_UPDATE_PROMO_SKU_BY_PROMO_RULE]
					@PROMO_RULE_BY_COMBO_ID   = 8
					,@CODE_SKU  = '100001'
					,@PACK_UNIT  = 1
					,@QTY  = 10
					,@IS_MULTIPLE  = 1
				-- 
				SELECT * FROM [SONDA].[SWIFT_PROMO_SKU_BY_PROMO_RULE] 
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_PROMO_SKU_BY_PROMO_RULE] (@PROMO_RULE_BY_COMBO_ID INT
, @CODE_SKU VARCHAR(50)
, @PACK_UNIT INT
, @QTY INT
, @IS_MULTIPLE INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY

    UPDATE [SONDA].[SWIFT_PROMO_SKU_BY_PROMO_RULE]
    SET [QTY] = @QTY
       ,[IS_MULTIPLE] = @IS_MULTIPLE
       ,[LAST_UPDATE] = GETDATE()
    WHERE [PROMO_RULE_BY_COMBO_ID] = @PROMO_RULE_BY_COMBO_ID
    AND [CODE_SKU] = @CODE_SKU
    AND [PACK_UNIT] = @PACK_UNIT
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
        WHEN '2627' THEN 'Error al actualizar el SKU en la bonificacion por combo'
        ELSE ERROR_MESSAGE()
      END Mensaje
     ,@@error Codigo
  END CATCH
END
