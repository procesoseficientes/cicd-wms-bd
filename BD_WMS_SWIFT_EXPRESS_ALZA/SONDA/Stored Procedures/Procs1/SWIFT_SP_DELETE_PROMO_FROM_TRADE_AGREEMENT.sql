-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	7/26/2017 Sprint Bearbeitung
-- Description:			SP que borra un registro de la tabla SWIFT_TRADE_AGREEMENT_BY_PROMO

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-16 @ Team REBORN - Sprint 
-- Description:	   Se agrega UPDATE a tabla SWIFT_TRADE_ATREEMENT

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [SONDA].SWIFT_TRADE_AGREEMENT_BY_PROMO
				--
				EXEC [SONDA].[SWIFT_SP_DELETE_PROMO_FROM_TRADE_AGREEMENT]
					@TRADE_AGREEMENT_ID = 1
					, @PROMO_ID = 5
				-- 
				SELECT * FROM [SONDA].SWIFT_TRADE_AGREEMENT_BY_PROMO 
				WHERE TRADE_AGREEMENT_ID = 1 AND PROMO_ID = 5
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_PROMO_FROM_TRADE_AGREEMENT] (@TRADE_AGREEMENT_ID INT
, @PROMO_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY
    DELETE FROM [SONDA].SWIFT_TRADE_AGREEMENT_BY_PROMO
    WHERE TRADE_AGREEMENT_ID = @TRADE_AGREEMENT_ID
      AND PROMO_ID = @PROMO_ID
    --
    UPDATE [SONDA].[SWIFT_TRADE_AGREEMENT]
    SET [LAST_UPDATE] = GETDATE()
    WHERE [TRADE_AGREEMENT_ID] = @TRADE_AGREEMENT_ID;

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
