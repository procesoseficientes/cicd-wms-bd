
-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	18-Sep-2018 G-Force@Jaguar
-- Description:			marca un pago de factua como envido resultado del proceso exitoso de envio hacia el ERP


CREATE PROCEDURE SONDA.SWIFT_SP_MARK_INVOICE_PAYMENT_AS_SEND_TO_ERP (@INVOICE_ID INT,
@POSTED_RESPONSE VARCHAR(150), @ERP_REFERENCE VARCHAR(256))

AS
BEGIN TRY

  UPDATE [SONDA].[SONDA_POS_INVOICE_HEADER]
  SET [IS_POSTED_ERP_PAYMENT] = 1
     ,[POSTED_ERP_PAYMENT] = GETDATE()
     ,[POSTED_RESPONSE_ERP_PAYMENT] = @POSTED_RESPONSE
     ,[ERP_REFERENCE_PAYMENT] = @ERP_REFERENCE
  WHERE [ID] = @INVOICE_ID
  IF @@error = 0
  BEGIN
    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,'0' DbData
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
