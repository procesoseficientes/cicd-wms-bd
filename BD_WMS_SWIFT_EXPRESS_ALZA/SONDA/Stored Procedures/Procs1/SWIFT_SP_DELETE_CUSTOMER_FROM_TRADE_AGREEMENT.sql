/*==================================================

Autor:				diego.as
Fecha de Creacion:	12-09-2016 @ A-TEAM Sprint 1
Descripcion:		Elimina a un cliente de un acuerdo comercial

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-16 @ Team REBORN - Sprint 
-- Description:	   Se agrega UPDATE a tabla SWIFT_TRADE_AGREEMENT

Ejemplo de Ejecución:
SELECT * FROM [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER]
	
  EXEC [SONDA].[SWIFT_SP_DELETE_CUSTOMER_FROM_TRADE_AGREEMENT]
		@TRADE_AGREEMENT_ID = 1038
		,@CODE_CUSTOMER = 'C002'

SELECT * FROM [SONDA].[SWIFT_TRADE_AGREEMENT] WHERE [TRADE_AGREEMENT_ID] = 1

==================================================*/

CREATE PROCEDURE [SONDA].SWIFT_SP_DELETE_CUSTOMER_FROM_TRADE_AGREEMENT (@TRADE_AGREEMENT_ID INT
, @CODE_CUSTOMER VARCHAR(50))
AS
BEGIN
  BEGIN TRY

    DELETE FROM [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER]
    WHERE TRADE_AGREEMENT_ID = @TRADE_AGREEMENT_ID
      AND CODE_CUSTOMER = @CODE_CUSTOMER
    --

    UPDATE [SONDA].[SWIFT_TRADE_AGREEMENT]
    SET [LAST_UPDATE] = GETDATE()
    WHERE [TRADE_AGREEMENT_ID] = @TRADE_AGREEMENT_ID;

    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo

  END TRY
  BEGIN CATCH

    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@error Codigo

  END CATCH
END
