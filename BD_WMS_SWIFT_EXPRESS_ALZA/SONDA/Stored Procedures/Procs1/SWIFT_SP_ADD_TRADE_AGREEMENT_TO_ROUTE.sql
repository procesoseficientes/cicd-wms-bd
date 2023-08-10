-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	1/12/2017 @ A-TEAM Sprint  
-- Description:			SP que asocia un acuerdo comercial a una ruta

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-16 @ Team REBORN - Sprint 
-- Description:	   Se agrega UPDATE a tabla SWIFT_TRADE_AGREEMENT

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_ADD_TRADE_AGREEMENT_TO_ROUTE]
					@CODE_ROUTE = '001'
					,@TRADE_AGREEMENT_ID = 20
				-- 
				SELECT * FROM [SONDA].[SWIFT_ROUTES]
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_ADD_TRADE_AGREEMENT_TO_ROUTE (@CODE_ROUTE VARCHAR(50)
, @TRADE_AGREEMENT_ID INT)
AS
BEGIN
  BEGIN TRY
    UPDATE [SONDA].[SWIFT_ROUTES]
    SET [TRADE_AGREEMENT_ID] = @TRADE_AGREEMENT_ID
    WHERE [CODE_ROUTE] = @CODE_ROUTE
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
     ,CASE CAST(@@error AS VARCHAR)
        WHEN '2627' THEN 'No se pudo asociar el acuerdo comercial a la ruta.'
        ELSE ERROR_MESSAGE()
      END Mensaje
     ,@@error Codigo
  END CATCH
END
