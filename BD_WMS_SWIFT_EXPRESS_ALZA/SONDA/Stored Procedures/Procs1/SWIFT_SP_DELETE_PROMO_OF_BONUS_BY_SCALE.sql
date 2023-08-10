-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/12/2017 @ A-TEAM Sprint Jibade 
-- Description:			SP que borra un registro de la tabla SWIFT_PROMO y SWIFT_PROMO_BONUS_BY_SCALE

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-14 @ Team REBORN - Sprint 
-- Description:	   Se agrego update de SWIFT_PROMO

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [SONDA].[SWIFT_PROMO_BONUS_BY_SCALE]
				--
				EXEC [SONDA].SWIFT_SP_DELETE_PROMO_OF_BONUS_BY_SCALE
					@PROMO_BONUS_BY_SCALE_ID = 1
				-- 
				SELECT * FROM [SONDA].SWIFT_PROMO_BONUS_BY_SCALE
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_PROMO_OF_BONUS_BY_SCALE] (@PROMO_BONUS_BY_SCALE_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @PROMO_ID INT;
  --
  SET @PROMO_ID = (SELECT TOP 1
      [PROMO_ID]
    FROM [SONDA].[SWIFT_PROMO_BONUS_BY_SCALE]
    WHERE [PROMO_BONUS_BY_SCALE_ID] = @PROMO_BONUS_BY_SCALE_ID)

  --
  BEGIN TRY
    DELETE FROM [SONDA].[SWIFT_PROMO_BONUS_BY_SCALE]
    WHERE [PROMO_BONUS_BY_SCALE_ID] = @PROMO_BONUS_BY_SCALE_ID

    --
    UPDATE [SONDA].[SWIFT_PROMO]
    SET [LAST_UPDATE] = GETDATE()
    WHERE [PROMO_ID] = @PROMO_ID;
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
