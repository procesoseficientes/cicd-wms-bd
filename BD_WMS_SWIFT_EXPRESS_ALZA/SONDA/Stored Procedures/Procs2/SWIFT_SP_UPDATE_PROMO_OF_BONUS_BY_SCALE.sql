-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/12/2017 @ A-TEAM Sprint Jibade 
-- Description:			SP que actualiza 

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-14 @ Team REBORN - Sprint 
-- Description:	  Se agrega LAST_UPDATE 

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_UPDATE_PROMO_OF_BONUS_BY_SCALE]
					@PROMO_BONUS_BY_SCALE_ID = 1067, -- int
					@PROMO_ID = 3177, -- int
					@CODE_SKU = '100002', -- varchar(50)
					@PACK_UNIT = 1, -- int
					@LOW_LIMIT = 100, -- int
					@HIGH_LIMIT = 110, -- int
					@CODE_SKU_BONUS = 'U00000237', -- varchar(50)
					@PACK_UNIT_BONUS = 1, -- int
					@BONUS_QTY = 10 -- int
				-- 
				SELECT * FROM [SONDA].[SWIFT_PROMO_BONUS_BY_SCALE]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_PROMO_OF_BONUS_BY_SCALE] (@PROMO_BONUS_BY_SCALE_ID INT
, @BONUS_QTY INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY

    --

    UPDATE [SONDA].[SWIFT_PROMO_BONUS_BY_SCALE]
    SET [BONUS_QTY] = @BONUS_QTY
       ,[LAST_UPDATE] = GETDATE()
    WHERE [PROMO_BONUS_BY_SCALE_ID] = @PROMO_BONUS_BY_SCALE_ID
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
        WHEN '2627' THEN 'Error al actualizar la bonificacion por escala.'
        ELSE ERROR_MESSAGE()
      END Mensaje
     ,@@error Codigo
  END CATCH
END
