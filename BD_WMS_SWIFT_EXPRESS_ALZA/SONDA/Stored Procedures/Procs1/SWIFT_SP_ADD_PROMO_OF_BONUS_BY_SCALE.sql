-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/12/2017 @ A-TEAM Sprint Jibade
-- Description:			Agrega una promocion de tipo bonificacion por escala

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_ADD_PROMO_OF_BONUS_BY_SCALE]
					@PROMO_ID = 82,
					@CODE_SKU = 'U00000237', -- varchar(50)
					@PACK_UNIT = 1, -- int
					@LOW_LIMIT = 1, -- int
					@HIGH_LIMIT = 10, -- int
					@CODE_SKU_BONUS = 'U00000238', -- varchar(50)
					@PACK_UNIT_BONUS = 1, -- int
					@BONUS_QTY = 10 -- int
				-- 
				SELECT * FROM [SONDA].[SWIFT_PROMO]
				SELECT * FROM [SONDA].[SWIFT_PROMO_BONUS_BY_SCALE]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_ADD_PROMO_OF_BONUS_BY_SCALE] (@PROMO_ID INT
, @CODE_SKU VARCHAR(50)
, @PACK_UNIT INT
, @LOW_LIMIT INT
, @HIGH_LIMIT INT
, @CODE_SKU_BONUS VARCHAR(50)
, @PACK_UNIT_BONUS INT
, @BONUS_QTY INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY

    EXEC [SONDA].[SWIFT_SP_VALIDATED_BONUS_SCALE_OF_PROMO] @PROMO_ID = @PROMO_ID
                                                        ,@CODE_SKU = @CODE_SKU
                                                        ,@PACK_UNIT = @PACK_UNIT
                                                        ,@LOW_LIMIT = @LOW_LIMIT
                                                        ,@HIGH_LIMIT = @HIGH_LIMIT
                                                        ,@CODE_SKU_BONUS = @CODE_SKU_BONUS
                                                        ,@PACK_UNIT_BONUS = @PACK_UNIT_BONUS
                                                        ,@BONUS_QTY = @BONUS_QTY
    --
    DECLARE @ID INT
    --
    INSERT INTO [SONDA].[SWIFT_PROMO_BONUS_BY_SCALE] ([PROMO_ID]
    , [CODE_SKU]
    , [PACK_UNIT]
    , [LOW_LIMIT]
    , [HIGH_LIMIT]
    , [CODE_SKU_BONUS]
    , [PACK_UNIT_BONUS]
    , [BONUS_QTY])
      VALUES (@PROMO_ID  -- PROMO_ID - int
      , @CODE_SKU  -- CODE_SKU - varchar(50)
      , @PACK_UNIT  -- PACK_UNIT - int
      , @LOW_LIMIT  -- LOW_LIMIT - numeric
      , @HIGH_LIMIT  -- HIGH_LIMIT - numeric
      , @CODE_SKU_BONUS  -- CODE_SKU_BONUS - varchar(50)
      , @PACK_UNIT_BONUS  -- PACK_UNIT_BONUS - int
      , @BONUS_QTY  -- BONUS_QTY - numeric
      )
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
        WHEN '2627' THEN 'Ya existe sku "'+@CODE_SKU+'" con bonificación "'+@CODE_SKU_BONUS+'" en el mismo rango'
        ELSE ERROR_MESSAGE()
      END Mensaje
     ,@@error Codigo
  END CATCH
END
