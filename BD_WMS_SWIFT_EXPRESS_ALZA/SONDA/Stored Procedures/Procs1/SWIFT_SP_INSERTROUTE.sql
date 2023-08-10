CREATE PROC [SONDA].SWIFT_SP_INSERTROUTE
@CODE_ROUTE VARCHAR(50),
@NAME_ROUTE VARCHAR(50),
@GEOREFERENCE_ROUTE VARCHAR(50),
@COMMENT_ROUTE VARCHAR(MAX),
@LAST_UPDATE VARCHAR(50) = NULL,
@LAST_UPDATE_BY VARCHAR(50)
AS
BEGIN TRY
BEGIN TRAN t1

DECLARE @UserName VARCHAR(50)
SET @UserName = (SELECT TOP 1 [NAME_USER] FROM [SONDA].[USERS] WHERE [LOGIN] = @LAST_UPDATE_BY)
	INSERT INTO SWIFT_ROUTES 
		(CODE_ROUTE
		,NAME_ROUTE
		,GEOREFERENCE_ROUTE
		,COMMENT_ROUTE
		,LAST_UPDATE
		,LAST_UPDATE_BY) 
	VALUES 
		(@CODE_ROUTE
		,@NAME_ROUTE
		,@GEOREFERENCE_ROUTE
		,@COMMENT_ROUTE
		,CURRENT_TIMESTAMP
		,@UserName)

----------------------------------------------------------------------

DECLARE @EschemaName VARCHAR(50)
DECLARE @EnterpriseAddress VARCHAR(150)


SET @EschemaName = (SELECT TOP 1 ENTERPRISE FROM [SONDA].[USERS] WHERE [LOGIN] = @LAST_UPDATE_BY)
SET @EnterpriseAddress = (SELECT TOP 1 ADDRESS_ENTERPRISE FROM [dbo].[SWIFT_ENTERPRISE] WHERE CODE_ENTERPRISE = @EschemaName)

	INSERT INTO [SONDA].[SONDA_POS_RES_SAT]
           ([AUTH_ID]
           ,[AUTH_ASSIGNED_DATETIME]
           ,[AUTH_POST_DATETIME]
           ,[AUTH_ASSIGNED_BY]
           ,[AUTH_DOC_FROM]
           ,[AUTH_DOC_TO]
           ,[AUTH_SERIE]
           ,[AUTH_DOC_TYPE]
           ,[AUTH_ASSIGNED_TO]
           ,[AUTH_CURRENT_DOC]
           ,[AUTH_LIMIT_DATETIME]
           ,[AUTH_STATUS]
           ,[AUTH_BRANCH_NAME]
           ,[AUTH_BRANCH_ADDRESS])
     VALUES
           (@CODE_ROUTE
           ,CURRENT_TIMESTAMP
           ,CURRENT_TIMESTAMP
           ,@LAST_UPDATE_BY
           ,1
           ,2147483647
           ,@CODE_ROUTE
           ,'FACTURA'
           ,@CODE_ROUTE
           ,1
           ,CONVERT(DATETIME,'9999-01-01')
           ,'1'
           ,@EschemaName
           ,@EnterpriseAddress)

	IF @@error = 0 BEGIN		
		COMMIT TRAN t1
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo 	
	END		
	ELSE BEGIN
		ROLLBACK TRAN t1
		SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo			
	END
END TRY
BEGIN CATCH
     ROLLBACK TRAN t1
	 SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
END CATCH
