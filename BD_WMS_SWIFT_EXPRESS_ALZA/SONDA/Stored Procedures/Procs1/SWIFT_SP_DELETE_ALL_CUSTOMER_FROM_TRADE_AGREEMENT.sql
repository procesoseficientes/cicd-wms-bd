
/*==================================================

Autor:				diego.as
Fecha de Creacion:	12-09-2016 @ A-TEAM Sprint 1
Descripcion:		Elimina a un cliente de un acuerdo comercial

Ejemplo de Ejecución:

	EXEC [SONDA].[SWIFT_SP_DELETE_ALL_CUSTOMER_FROM_TRADE_AGREEMENT]
		@TRADE_AGREEMENT_ID = 1

==================================================*/

CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_ALL_CUSTOMER_FROM_TRADE_AGREEMENT] (@TRADE_AGREEMENT_ID INT)
AS
BEGIN
  BEGIN TRY

    DELETE FROM [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER]
    WHERE TRADE_AGREEMENT_ID = @TRADE_AGREEMENT_ID

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
