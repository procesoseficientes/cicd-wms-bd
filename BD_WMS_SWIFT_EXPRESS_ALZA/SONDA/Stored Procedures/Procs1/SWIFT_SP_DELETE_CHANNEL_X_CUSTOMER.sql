-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	09-09-2016 @ A-TEAM Sprint 1
-- Description:			SP que elimina el cliente del canal

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-16 @ Team REBORN - Sprint 
-- Description:	   Se agrega update a tabla [SWIFT_TRADE_AGREEMENT_BY_CHANNEL]

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SWIFT_SP_DELETE_CHANNEL_X_CUSTOMER
					@CHANNEL_ID = 5
					,@CODE_CUSTOMER = 'SO-005'
				-- 
				SELECT * FROM [SONDA].SWIFT_CHANNEL_X_CUSTOMER
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_DELETE_CHANNEL_X_CUSTOMER (@CHANNEL_ID INT
, @CODE_CUSTOMER VARCHAR(50))
AS
BEGIN
  BEGIN TRY
    DELETE FROM [SONDA].SWIFT_CHANNEL_X_CUSTOMER
    WHERE CHANNEL_ID = @CHANNEL_ID
      AND CODE_CUSTOMER = @CODE_CUSTOMER
    --

    UPDATE [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CHANNEL]
    SET [LAST_UPDATE] = GETDATE()
    WHERE [CHANNEL_ID] = @CHANNEL_ID

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
