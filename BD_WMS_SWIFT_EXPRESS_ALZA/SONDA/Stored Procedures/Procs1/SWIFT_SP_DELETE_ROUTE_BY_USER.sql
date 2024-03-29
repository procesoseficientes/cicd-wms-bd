﻿CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_ROUTE_BY_USER]	
    @CODE_ROUTE AS VARCHAR(50) = NULL
	,@LOGIN AS VARCHAR(50)	

AS
BEGIN TRY
		DELETE FROM [SONDA].[SWIFT_ROUTE_BY_USER] 
		WHERE LOGIN = @LOGIN
		AND (CODE_ROUTE = @CODE_ROUTE OR @CODE_ROUTE IS NULL  )

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
