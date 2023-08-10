-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/14/2017 @ A-TEAM Sprint Jibade 
-- Description:			SP que borra un registro de la tabla SWIFT_PROMO_SKU_BY_PROMO_RULE

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-14 @ Team REBORN - Sprint 
-- Description:	   Se agrega update a [SWIFT_PROMO_BY_COMBO_PROMO_RULE]
/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [SONDA].[SWIFT_PROMO_BY_COMBO_PROMO_RULE] WHERE [PROMO_RULE_BY_COMBO_ID] = 9
				SELECT * FROM [SONDA].SWIFT_PROMO_SKU_BY_PROMO_RULE
				--
				EXEC [SONDA].[SWIFT_SP_DELETE_PROMO_SKU_BY_PROMO_RULE]
					@PROMO_RULE_BY_COMBO_ID = 9,
					@CODE_SKU = '100002',
					@PACK_UNIT = 1
				-- 
				SELECT * FROM [SONDA].SWIFT_PROMO_SKU_BY_PROMO_RULE
        SELECT * FROM [SONDA].[SWIFT_PROMO_BY_COMBO_PROMO_RULE] WHERE [PROMO_RULE_BY_COMBO_ID] = 9
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_PROMO_SKU_BY_PROMO_RULE] (@PROMO_RULE_BY_COMBO_ID INT,
@CODE_SKU VARCHAR(50),
@PACK_UNIT INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY

    DELETE FROM [SONDA].[SWIFT_PROMO_SKU_BY_PROMO_RULE]
    WHERE [PROMO_RULE_BY_COMBO_ID] = @PROMO_RULE_BY_COMBO_ID
      AND [CODE_SKU] = @CODE_SKU
      AND [PACK_UNIT] = @PACK_UNIT
    --

    UPDATE [SONDA].[SWIFT_PROMO_BY_COMBO_PROMO_RULE]
    SET [LAST_UPDATE] = GETDATE()
    WHERE [PROMO_RULE_BY_COMBO_ID] = @PROMO_RULE_BY_COMBO_ID;


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
