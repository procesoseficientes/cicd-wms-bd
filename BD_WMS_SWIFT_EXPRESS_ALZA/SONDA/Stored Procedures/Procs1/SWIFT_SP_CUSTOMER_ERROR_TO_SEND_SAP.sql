
-- =============================================
--  Autor:		joel.delcompare
-- Fecha de Creacion: 	2016-04-28 09:40:07
-- Description:		Marca como errado un cliente envidado al ERP 

-- Modificacion 5/10/2017 @ A-Team Sprint Issa
					-- diego.as
					-- Se agrega llamado al SP [SWIFT_SP_INSERT_CUSTOMER_ERP_LOG] para que guarde en el log de transaccion.

-- Modificacion 6/22/2017 @ A-Team Sprint Khalid
					-- rodrigo.gomez
					-- Se actualiza cualquiera de las dos tablas de CUSTOMER_NEW dependiendo del origen del dato.

/*
-- Ejemplo de Ejecucion:
USE SWIFT_EXPRESS
GO

DECLARE @RC int
DECLARE @CODE_CUSTOMER varchar(50)
DECLARE @POSTED_RESPONSE varchar(150)

SET @CODE_CUSTOMER = '173' 
SET @POSTED_RESPONSE = 'No hay tasa de cambio' 

EXECUTE @RC = [SONDA].SWIFT_SP_CUSTOMER_ERROR_TO_SEND_SAP @CODE_CUSTOMER
                                                       ,@POSTED_RESPONSE
GO
*/	
-- =============================================

CREATE PROCEDURE [SONDA].SWIFT_SP_CUSTOMER_ERROR_TO_SEND_SAP (@CODE_CUSTOMER VARCHAR(50),
@POSTED_RESPONSE VARCHAR(150))
AS
BEGIN TRY
  DECLARE @ID NUMERIC(18, 0)
  DECLARE @FROM VARCHAR(50)

  SELECT @FROM = IS_FROM FROM [SONDA].[SWIFT_VIEW_ALL_CUSTOMER_NEW] WHERE [CODE_CUSTOMER] = @CODE_CUSTOMER

  IF @FROM = 'SONDA_CORE' 
  BEGIN
	UPDATE [SONDA].[SWIFT_CUSTOMERS_NEW]
	SET [ATTEMPTED_WITH_ERROR] = ISNULL([ATTEMPTED_WITH_ERROR],0) + 1
		,[POSTED_RESPONSE] = @POSTED_RESPONSE
		, POSTED_ERP = GETDATE()
		, IS_POSTED_ERP=-2
	WHERE [CODE_CUSTOMER] = @CODE_CUSTOMER
  END
  ELSE 
  BEGIN
	UPDATE [SONDA].[SONDA_CUSTOMER_NEW]
	SET [ATTEMPTED_WITH_ERROR] = ISNULL([ATTEMPTED_WITH_ERROR],0) + 1
		,[POSTED_RESPONSE] = @POSTED_RESPONSE
		, POSTED_ERP = GETDATE()
		, IS_POSTED_ERP=-2
	WHERE [CODE_CUSTOMER] = @CODE_CUSTOMER
  END
  --
  EXEC [SONDA].[SWIFT_SP_INSERT_CUSTOMER_ERP_LOG] @ID = -1 , -- int
		@ATTEMPTED_WITH_ERROR = -1 , -- int
		@IS_POSTED_ERP = -2 , -- int
		@POSTED_RESPONSE = @POSTED_RESPONSE , -- varchar(150)
		@ERP_REFERENCE = NULL , -- varchar(256)
		@TYPE = 'CUSTOMER' -- varchar(50)
  --
  IF @@error = 0
  BEGIN
    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,CONVERT(VARCHAR(50), @ID) DbData
  END
  ELSE
  BEGIN
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@ERROR Codigo
  END

END TRY
BEGIN CATCH
  SELECT
    -1 AS Resultado
   ,ERROR_MESSAGE() Mensaje
   ,@@ERROR Codigo
END CATCH
