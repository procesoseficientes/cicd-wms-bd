﻿CREATE PROC [SONDA].[SWIFT_SP_UPDATE_ROLE]
	  @ROLE_ID NUMERIC(18,0)
	, @NAME VARCHAR(50)
	, @DESCRIPTION VARCHAR(250)
	, @USER VARCHAR(50)	
AS
BEGIN TRY
BEGIN
	BEGIN TRAN t1
		BEGIN		
			UPDATE [SONDA].[SWIFT_ROLE]
			   SET [NAME] = @NAME
				  ,[DESCRIPTION] = @DESCRIPTION
				  ,[LAST_UPDATED] = CURRENT_TIMESTAMP
				  ,[LAST_UPDATED_BY] = @USER
			 WHERE [ROLE_ID] = @ROLE_ID
			DELETE [SONDA].[SWIFT_PRIVILEGES_X_ROLE] WHERE [ROLE_ID] = @ROLE_ID
		END	
	
	IF @@error = 0 BEGIN		
		COMMIT TRAN t1
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo	
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
