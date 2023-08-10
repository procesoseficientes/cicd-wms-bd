CREATE PROC [SONDA].[SWIFT_SP_INSERT_ROLE]
	  @NAME VARCHAR(50)
	, @DESCRIPTION VARCHAR(250)
	, @USER VARCHAR(50)	
AS
BEGIN TRY
DECLARE @return_value int,
          @pID numeric(18, 0)
BEGIN
	BEGIN TRAN t1
	EXEC @return_value = [SONDA].[SWIFT_SP_GET_NEXT_SEQUENCE] @SEQUENCE_NAME = N'ROLE',
                                                              @pRESULT = @pID OUTPUT
		BEGIN		
			INSERT INTO [SONDA].[SWIFT_ROLE]
           ([ROLE_ID]
           ,[NAME]
           ,[DESCRIPTION]
           ,[LAST_UPDATED]
           ,[LAST_UPDATED_BY])
     VALUES
           (@pID
           ,@NAME
           ,@DESCRIPTION
           ,CURRENT_TIMESTAMP
           ,@USER)
			
		END	
	
	IF @@error = 0 BEGIN		
		COMMIT TRAN t1
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo , CONVERT(VARCHAR(50),@pID) DbData		
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
