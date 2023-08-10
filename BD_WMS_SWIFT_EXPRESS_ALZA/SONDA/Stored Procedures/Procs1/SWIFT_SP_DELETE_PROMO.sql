-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/12/2017 @ A-TEAM Sprint Jibade 
-- Description:			SP que borra un registro de la tabla SWIFT_PROMO y SWIFT_TRADE_AGREEMENT_BY_PROMO

-- Modificacion:	        hector.gonzalez
-- Fecha de Creacion: 	2017-07-20 @ Team REBORN - Sprint Bearbeitung
-- Description:	   

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [SONDA].[SWIFT_PROMO]
				--
				EXEC [SONDA].SWIFT_SP_DELETE_PROMO
					@PROMO_ID = 82
				-- 
				SELECT * FROM [SONDA].SWIFT_PROMO
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_DELETE_PROMO (@PROMO_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY

    --
    DELETE FROM [SONDA].[SWIFT_PROMO]
    WHERE [PROMO_ID] = @PROMO_ID
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
        WHEN '547' THEN 'No se puede eliminar la promoción debido a que está siendo utilizada en un Acuerdo Comercial'
        ELSE ERROR_MESSAGE()
      END Mensaje
     ,@@error Codigo

  END CATCH
END
