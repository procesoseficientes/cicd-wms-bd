/*=======================================================
-- Author:         hector.gonzalez
-- Create date:    11-07-2016
-- Description:    Modifica un registro de la tabla [SWIFT_SP_UPDATE_STATUS_CUSTOMER_CHANGE] modifica el estado de el cliente enviado a ERP a exitoso
				   

-- EJEMPLO DE EJECUCION: 
		EXEC [SONDA].[SWIFT_SP_SET_STATUS_SEND_CUSTOMER_CHANGE_TO_ERP]
		 @CUSTOMER = '1'
		,@POSTED_RESPONSE = 'Proceso Existoso'
=========================================================*/
CREATE PROCEDURE [SONDA].[SWIFT_SP_SET_STATUS_SEND_CUSTOMER_CHANGE_TO_ERP]
(
	@CUSTOMER INT
	,@POSTED_RESPONSE VARCHAR(150)

) AS
BEGIN
	--
	BEGIN TRY
		--
		UPDATE [SONDA].[SWIFT_CUSTOMER_CHANGE]
		SET ATTEMPTED_WITH_ERROR = 0
			,IS_POSTED_ERP = 1
			,POSTED_ERP = GETDATE()
			,POSTED_RESPONSE = @POSTED_RESPONSE
		WHERE CUSTOMER = @CUSTOMER 

		--
	IF @@error = 0 BEGIN
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '0' DbData
	END		
	ELSE BEGIN		
		SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo
	END


	END TRY
	BEGIN CATCH
		ROLLBACK
		ROLLBACK
		SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
	END CATCH
	--
END
