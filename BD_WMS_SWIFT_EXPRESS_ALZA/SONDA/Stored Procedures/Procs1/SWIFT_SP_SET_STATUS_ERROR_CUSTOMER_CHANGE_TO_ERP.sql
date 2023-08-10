/*=======================================================
-- Author:         hector.gonzalez
-- Create date:    11-07-2016
-- Description:    Modifica un registro de la tabla [SWIFT_CUSTOMER_CHANGE] modifica el estado de el cliente enviado a ERP a FALLIDO

-- Modificacion 5/10/2017 @ A-Team Sprint Issa
					-- diego.as
					-- Se agrega llamado al SP [SWIFT_SP_INSERT_CUSTOMER_ERP_LOG] para que guarde en el log de transaccion.				   

-- EJEMPLO DE EJECUCION: 
		EXEC [SONDA].[SWIFT_SP_SET_STATUS_ERROR_CUSTOMER_CHANGE_TO_ERP]
		 @CUSTOMER = '1'
		,@POSTED_RESPONSE = 'Proceso Fallido'
=========================================================*/
CREATE PROCEDURE [SONDA].[SWIFT_SP_SET_STATUS_ERROR_CUSTOMER_CHANGE_TO_ERP]
(
	@CUSTOMER VARCHAR(50)
	,@POSTED_RESPONSE VARCHAR(150)

) AS
BEGIN
	--
	BEGIN TRY
		--
		UPDATE [SONDA].[SWIFT_CUSTOMER_CHANGE]
		SET ATTEMPTED_WITH_ERROR = ISNULL(ATTEMPTED_WITH_ERROR,0) + 1
			,IS_POSTED_ERP = 0
			,POSTED_ERP = GETDATE()
			,POSTED_RESPONSE = @POSTED_RESPONSE
		WHERE CUSTOMER = @CUSTOMER
		--
		EXEC [SONDA].[SWIFT_SP_INSERT_CUSTOMER_ERP_LOG] @ID = -1 , -- int
			@ATTEMPTED_WITH_ERROR = -1 , -- int
			@IS_POSTED_ERP = -2 , -- int
			@POSTED_RESPONSE = @POSTED_RESPONSE , -- varchar(150)
			@ERP_REFERENCE = NULL , -- varchar(256)
			@TYPE = 'CUSTOMER_CHANGE' -- varchar(50)
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
		SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
	END CATCH
	--
END
