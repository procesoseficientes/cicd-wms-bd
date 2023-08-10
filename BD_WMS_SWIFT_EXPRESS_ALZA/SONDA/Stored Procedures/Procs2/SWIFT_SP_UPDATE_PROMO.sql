-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/12/2017 @ A-TEAM Sprint Jibade 
-- Description:			SP que actualiza la tabla SWIFT_PROMO

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-14 @ Team REBORN - Sprint 
-- Description:	    Se agrega LAST_UPDATE

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_UPDATE_PROMO]
					@PROMO_ID = 82
					, @PROMO_NAME = 'PROMO 002'
					, @PROMO_TYPE = 'BONUS_BY_SCALE'
				-- 
				SELECT * FROM [SONDA].SWIFT_PROMO
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_PROMO] (@PROMO_ID INT
, @PROMO_NAME VARCHAR(250)
, @PROMO_TYPE VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY
    UPDATE [SONDA].[SWIFT_PROMO]
    SET [PROMO_NAME] = @PROMO_NAME
       ,[PROMO_TYPE] = @PROMO_TYPE
       ,[LAST_UPDATE] = GETDATE()
    WHERE [PROMO_ID] = @PROMO_ID
    --
    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,CAST(@PROMO_ID AS VARCHAR) DbData
  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,CASE CAST(@@error AS VARCHAR)
        WHEN '2627' THEN 'Error al actualizar la promocion.'
        ELSE ERROR_MESSAGE()
      END Mensaje
     ,@@error Codigo
  END CATCH
END
