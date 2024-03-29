﻿CREATE PROC [SONDA].[SWIFT_SP_DELETE_ROLE]
	@ROLE_ID NUMERIC(18,0)	
AS
BEGIN TRY
BEGIN	
	BEGIN TRAN t1
		BEGIN						
			DELETE [SONDA].SWIFT_PRIVILEGES_X_ROLE
			WHERE ROLE_ID = @ROLE_ID
			DELETE [SONDA].SWIFT_ROLE
			WHERE ROLE_ID = @ROLE_ID;
		END		
	IF @@error = 0 BEGIN
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo 	
		COMMIT TRAN t1
	END		
	ELSE BEGIN
		ROLLBACK TRAN t1
		SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
	END
END
END TRY
BEGIN CATCH
     ROLLBACK TRAN t1
	 SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
END CATCH
