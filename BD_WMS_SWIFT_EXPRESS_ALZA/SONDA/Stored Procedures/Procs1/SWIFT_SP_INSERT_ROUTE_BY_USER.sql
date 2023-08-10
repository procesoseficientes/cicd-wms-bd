CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_ROUTE_BY_USER]	
    @CODE_ROUTE AS VARCHAR(50)
	,@LOGIN AS VARCHAR(50)	

AS
BEGIN TRY
	INSERT INTO [SONDA].[SWIFT_ROUTE_BY_USER]
	(			   
		[CODE_ROUTE]
		,[LOGIN]
	) 
	VALUES 
	(		  
		@CODE_ROUTE
		,@LOGIN
	)
	IF @@error = 0 BEGIN		
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo
	END		
	ELSE BEGIN
		
		SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo
	END
END TRY
BEGIN CATCH     
	 SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
END CATCH
