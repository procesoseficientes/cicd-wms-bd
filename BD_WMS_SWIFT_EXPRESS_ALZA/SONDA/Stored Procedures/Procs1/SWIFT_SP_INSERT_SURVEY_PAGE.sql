CREATE PROC [SONDA].[SWIFT_SP_INSERT_SURVEY_PAGE]
	  @SURVEY_ID NUMERIC(18,0)
	, @NAME VARCHAR(50)
	, @DESCRIPTION VARCHAR(250)
	, @ORDER SMALLINT	
AS
BEGIN TRY
DECLARE @return_value int,
          @pID numeric(18, 0)
BEGIN
	BEGIN TRAN t1
	EXEC @return_value = [SONDA].[SWIFT_SP_GET_NEXT_SEQUENCE] @SEQUENCE_NAME = N'SURVEY_PAGE',
                                                              @pRESULT = @pID OUTPUT
		BEGIN		
			INSERT INTO [SONDA].[SWIFT_SURVEY_PAGE]
           ([PAGE_ID]
		   ,[SURVEY_ID]
           ,[NAME]
           ,[DESCRIPTION]
           ,[ORDER])
     VALUES
           (@pID
		   ,@SURVEY_ID
           ,@NAME
           ,@DESCRIPTION
           ,@ORDER)
			
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
