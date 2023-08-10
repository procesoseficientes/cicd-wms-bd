-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	7/26/2017 @ Sprint Bearbeitung 
-- Description:			SP que actualiza un registro de la tabla SWIFT_TRADE_AGREEMENT_BY_PROMO

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-16 @ Team REBORN - Sprint 
-- Description:	   Se agrega LAST_UPDATE

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_UPDATE_PROMO_OF_TRADE_AGREEMENT]
					@TRADE_AGREEMENT_ID = 1
					, @PROMO_ID = 4
					, @FREQUENCY = 'ALWAYS'
				-- 
				SELECT * FROM [SONDA].SWIFT_TRADE_AGREEMENT_BY_PROMO
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_PROMO_OF_TRADE_AGREEMENT] (@TRADE_AGREEMENT_ID INT
, @PROMO_ID INT
, @FREQUENCY VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY
    UPDATE [SONDA].SWIFT_TRADE_AGREEMENT_BY_PROMO
    SET [FREQUENCY] = @FREQUENCY
       ,[LAST_UPDATE] = GETDATE()
    WHERE [TRADE_AGREEMENT_ID] = @TRADE_AGREEMENT_ID
    AND [PROMO_ID] = @PROMO_ID
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
