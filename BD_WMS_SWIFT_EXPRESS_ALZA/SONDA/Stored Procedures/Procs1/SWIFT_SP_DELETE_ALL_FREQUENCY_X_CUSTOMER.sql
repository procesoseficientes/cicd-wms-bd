﻿CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_ALL_FREQUENCY_X_CUSTOMER]
	@ID_FREQUENCY VARCHAR(25)	
	
AS
BEGIN TRY
	
	DECLARE @CODE_FREQUENCY VARCHAR(50)

	SELECT @CODE_FREQUENCY = CODE_FREQUENCY FROM [SONDA].SWIFT_FREQUENCY WHERE ID_FREQUENCY= @ID_FREQUENCY					
			
			DELETE [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER]
			WHERE ID_FREQUENCY=ID_FREQUENCY

	EXEC [SONDA].[SONDA_SP_GENERATE_ROUTE_PLAN] @CODE_FREQUENCY, @CODE_FREQUENCY
	IF @@error = 0 BEGIN		
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '0' DbData
	END		
	ELSE BEGIN
		
		SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo
	END

END TRY
BEGIN CATCH     
	 SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
END CATCH
