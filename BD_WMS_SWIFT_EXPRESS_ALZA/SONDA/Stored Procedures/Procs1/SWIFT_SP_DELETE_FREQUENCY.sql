﻿CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_FREQUENCY]	
    @ID_FREQUENCY AS INT	
		
AS
BEGIN TRY

	DELETE FROM [SONDA].SWIFT_FREQUENCY
	WHERE ID_FREQUENCY=  @ID_FREQUENCY;
	
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
