-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	08-Feb-17 @ A-TEAM Sprint Chatuluka
-- Description:			SP que borra un producto del combo

-- Modificacion 09-Feb-17 @ A-Team Sprint Chatuluka
-- alberto.ruiz
-- Se agrego validacion para que permita elimnar si el combo esta asociado a un acuerdo comercial

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-14 @ Team REBORN - Sprint 
-- Description:	   Se quito validacion para que no se pueda eliminar sku si esta sociado a un acuerdo comercial antiguo y se agrega update a SWIFT_COMBO

/*
-- Ejemplo de Ejecucion:
	      SELECT * FROM [SONDA].SWIFT_COMBO 
  			SELECT * FROM [SONDA].[SWIFT_SKU_BY_COMBO]
				--
				EXEC [SONDA].[SWIFT_SP_DELETE_SKU_BY_COMBO]
					@COMBO_ID = 5
					,@CODE_SKU = '100002'
					,@PACK_UNIT = 8
				-- 
				SELECT * FROM [SONDA].[SWIFT_SKU_BY_COMBO]
        SELECT * FROM [SONDA].SWIFT_COMBO 
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_DELETE_SKU_BY_COMBO (@COMBO_ID INT
, @CODE_SKU VARCHAR(50)
, @PACK_UNIT INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY

    -- ------------------------------------------------------------------------------------
    -- Valida si esta en un acuerdo comercial
    -- ------------------------------------------------------------------------------------


    DELETE FROM [SONDA].[SWIFT_SKU_BY_COMBO]
    WHERE [COMBO_ID] = @COMBO_ID
      AND [CODE_SKU] = @CODE_SKU
      AND [PACK_UNIT] = @PACK_UNIT
    --
    UPDATE [SONDA].[SWIFT_COMBO]
    SET [LAST_UPDATE] = GETDATE()
    WHERE [COMBO_ID] = @COMBO_ID;

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
