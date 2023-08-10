-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/14/2017 @ A-TEAM Sprint Jibade 
-- Description:			SP que borra un registro de la tabla SWIFT_PROMO_BY_BONUS_RULE

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-14 @ Team REBORN - Sprint 
-- Description:	   Se agrega UPDATE a SWIFT_PROMO

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [SONDA].SWIFT_PROMO WHERE PROMO_ID = 6
        SELECT * FROM [SONDA].SWIFT_PROMO_BY_BONUS_RULE
				--
				EXEC [SONDA].[SWIFT_SP_DELETE_PROMO_BY_BONUS_RULE]
					@PROMO_ID = 6
					, @PROMO_RULE_BY_COMBO_ID = 8
				-- 
				SELECT * FROM [SONDA].SWIFT_PROMO_BY_BONUS_RULE
        SELECT * FROM [SONDA].SWIFT_PROMO WHERE PROMO_ID = 6
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_BONUS_COMBO_RULE_OF_PROMO] (@PROMO_ID INT
, @PROMO_RULE_BY_COMBO_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY
    DELETE FROM [SONDA].[SWIFT_PROMO_SKU_BY_PROMO_RULE]
    WHERE [PROMO_RULE_BY_COMBO_ID] = @PROMO_RULE_BY_COMBO_ID
    --
    DELETE FROM [SONDA].[SWIFT_PROMO_BY_BONUS_RULE]
    WHERE [PROMO_ID] = @PROMO_ID
      AND [PROMO_RULE_BY_COMBO_ID] = @PROMO_RULE_BY_COMBO_ID
    --
    DELETE FROM [SONDA].[SWIFT_PROMO_BY_COMBO_PROMO_RULE]
    WHERE [PROMO_RULE_BY_COMBO_ID] = @PROMO_RULE_BY_COMBO_ID
    --
    UPDATE [SONDA].[SWIFT_PROMO]
    SET [LAST_UPDATE] = DEFAULT
    WHERE [PROMO_ID] = @PROMO_ID;

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
