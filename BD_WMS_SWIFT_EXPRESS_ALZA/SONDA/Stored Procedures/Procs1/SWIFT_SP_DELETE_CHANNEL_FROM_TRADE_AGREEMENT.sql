;
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	12-09-2016 @ A-TEAM Sprint 1
-- Description:			SP que elimina el canal del acuerdo comercial

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-16 @ Team REBORN - Sprint 
-- Description:	   Se agrega update a tabla SWIFT_TRADE_AGREEMENT

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SWIFT_SP_DELETE_CHANNEL_FROM_TRADE_AGREEMENT
					@TRADE_AGREEMENT_ID = 1
					,@CHANNEL_ID = 1
				-- 
				SELECT * FROM [SONDA].SWIFT_TRADE_AGREEMENT_BY_CHANNEL
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_DELETE_CHANNEL_FROM_TRADE_AGREEMENT (@TRADE_AGREEMENT_ID INT
, @CHANNEL_ID INT)
AS
BEGIN
  BEGIN TRY

    DELETE FROM [SONDA].SWIFT_TRADE_AGREEMENT_BY_CHANNEL
    WHERE TRADE_AGREEMENT_ID = @TRADE_AGREEMENT_ID
      AND CHANNEL_ID = @CHANNEL_ID
    --

    UPDATE [SONDA].[SWIFT_TRADE_AGREEMENT]
    SET [LAST_UPDATE] = GETDATE()
    WHERE [TRADE_AGREEMENT_ID] = @TRADE_AGREEMENT_ID;

    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,'0' DbData
  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@error Codigo
  END CATCH
END
