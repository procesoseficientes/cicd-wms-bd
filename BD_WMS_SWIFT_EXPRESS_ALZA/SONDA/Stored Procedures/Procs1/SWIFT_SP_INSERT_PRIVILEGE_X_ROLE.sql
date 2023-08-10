CREATE PROC [SONDA].[SWIFT_SP_INSERT_PRIVILEGE_X_ROLE]
	  @ROLE_ID NUMERIC(18,0)
	, @PRIVILEGE_ID NUMERIC(18,0)
AS
BEGIN TRY
BEGIN
	BEGIN TRAN t1
		BEGIN		
			INSERT INTO [SONDA].[SWIFT_PRIVILEGES_X_ROLE]
           ([ROLE_ID]
           ,[PRIVILEGE_ID])
     VALUES
           (@ROLE_ID
           ,@PRIVILEGE_ID)			
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
