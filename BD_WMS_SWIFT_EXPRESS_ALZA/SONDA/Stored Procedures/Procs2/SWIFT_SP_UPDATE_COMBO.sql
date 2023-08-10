-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	08-Dec-16 @ A-TEAM Sprint Chatuluka 
-- Description:			SP que actualiza combos

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-14 @ Team REBORN - Sprint 
-- Description:	   Se agrega LAST_UPDATE

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_UPDATE_COMBO]
					@COMBO_ID = 14
					,@NAME_COMBO = 'Combo hector prueba 1.5'
					,@DESCRIPTION_COMBO = 'Combo hector prueba 1.5'
				-- 
				SELECT * FROM [SONDA].[SWIFT_COMBO]
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_UPDATE_COMBO (@COMBO_ID INT
, @NAME_COMBO VARCHAR(250)
, @DESCRIPTION_COMBO VARCHAR(250))
AS
BEGIN
  BEGIN TRY
    UPDATE [SONDA].[SWIFT_COMBO]
    SET [NAME_COMBO] = @NAME_COMBO
       ,[DESCRIPTION_COMBO] = @DESCRIPTION_COMBO
       ,[LAST_UPDATE] = GETDATE()
    WHERE [COMBO_ID] = @COMBO_ID
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
        WHEN '2627' THEN 'Ya existe un combo con el nombre: ' + @NAME_COMBO
        ELSE ERROR_MESSAGE()
      END Mensaje
     ,@@error Codigo
  END CATCH
END
