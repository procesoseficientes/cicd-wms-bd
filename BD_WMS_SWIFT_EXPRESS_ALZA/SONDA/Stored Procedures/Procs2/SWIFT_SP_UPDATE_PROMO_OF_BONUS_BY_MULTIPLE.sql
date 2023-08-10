-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/13/2017 @ A-TEAM Sprint Jibade 
-- Description:			SP que actualiza la tabla SWIFT_PROMO_BONUS_BY_MULTIPLE

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-25 @ Team REBORN - Sprint 
-- Description:	   Se agrega LAST_UPDATE

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_UPDATE_PROMO_OF_BONUS_BY_MULTIPLE]
					@PROMO_BONUS_BY_MULTIPLE_ID = 149, -- int
					@PROMO_ID = 5, -- int
					@CODE_SKU = 'UP0000703', -- varchar(50)
					@PACK_UNIT = 1, -- int
					@MULTIPLE = 2, -- int
					@CODE_SKU_BONUS = 'UP0100683', -- varchar(50)
					@PACK_UNIT_BONUS = 1, -- int
					@BONUS_QTY = 2 -- int
				-- 
				SELECT * FROM [SONDA].[SWIFT_PROMO_BONUS_BY_MULTIPLE] 
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_UPDATE_PROMO_OF_BONUS_BY_MULTIPLE (@PROMO_BONUS_BY_MULTIPLE_ID INT
, @PROMO_ID INT
, @CODE_SKU VARCHAR(50)
, @PACK_UNIT INT
, @MULTIPLE INT
, @CODE_SKU_BONUS VARCHAR(50)
, @PACK_UNIT_BONUS INT
, @BONUS_QTY INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY
    UPDATE [SONDA].[SWIFT_PROMO_BONUS_BY_MULTIPLE]
    SET [PROMO_ID] = @PROMO_ID
       ,[CODE_SKU] = @CODE_SKU
       ,[PACK_UNIT] = @PACK_UNIT
       ,[MULTIPLE] = @MULTIPLE
       ,[CODE_SKU_BONUS] = @CODE_SKU_BONUS
       ,[PACK_UNIT_BONUS] = @PACK_UNIT_BONUS
       ,[BONUS_QTY] = @BONUS_QTY
       ,[LAST_UPDATE] = GETDATE()
    WHERE [PROMO_BONUS_BY_MULTIPLE_ID] = @PROMO_BONUS_BY_MULTIPLE_ID
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
        WHEN '2627' THEN ''
        ELSE ERROR_MESSAGE()
      END Mensaje
     ,@@error Codigo
  END CATCH
END
