-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	08-Feb-17 @ A-TEAM Sprint Chatuluka 
-- Description:			SP que actualiza la cantidad de un producto del combo

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-14 @ Team REBORN - Sprint 
-- Description:	   Se agrega LAST_UPDATE
/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_UPDATE_SKU_BY_COMBO]
					@COMBO_ID = 5
					,@CODE_SKU = '100002'
					,@PACK_UNIT = 9
					,@QTY = 2
				-- 
				SELECT * FROM [SONDA].[SWIFT_SKU_BY_COMBO] 
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_UPDATE_SKU_BY_COMBO (@COMBO_ID INT
, @CODE_SKU VARCHAR(50)
, @PACK_UNIT INT
, @QTY INT)
AS
BEGIN
  BEGIN TRY
    UPDATE [SONDA].[SWIFT_SKU_BY_COMBO]
    SET [QTY] = @QTY
       ,[LAST_UPDATE] = GETDATE()
    WHERE [COMBO_ID] = @COMBO_ID
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
     ,ERROR_MESSAGE() Mensaje
     ,@@error Codigo
  END CATCH
END
