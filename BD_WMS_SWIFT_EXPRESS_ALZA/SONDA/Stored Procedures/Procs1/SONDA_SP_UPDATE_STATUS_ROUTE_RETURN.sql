-- =============================================
-- Author:         diego.as
-- Create date:    10-02-2016
-- Description:    Actualiza el campo STATUS_DOC de la tabla 
--				   [SONDA].SONDA_DOC_ROUTE_RETURN_HEADER
--				   recibiendo como parametro el Identity de la fila a actualizar 

/*
Ejemplo de Ejecucion:
	
	DECLARE @ID_HEADER INT = 1
			,@STATE VARCHAR(20) = 'PENDING'

					EXEC [SONDA].[SONDA_SP_INSERT_RETURN_RECEPTION_HEADER] 
					@IDENTITY_HEADER = @ID_HEADER
					,@STATUS = @STATE

					SELECT * FROM [SONDA].[SONDA_DOC_ROUTE_RETURN_HEADER]
		
				
*/
-- =============================================


CREATE PROCEDURE [SONDA].[SONDA_SP_UPDATE_STATUS_ROUTE_RETURN]
     @IDENTITY_HEADER AS INT
	,@STATUS AS VARCHAR(20)
		
AS
BEGIN 

	SET NOCOUNT ON;

	UPDATE [SONDA].[SONDA_DOC_ROUTE_RETURN_HEADER]
	   SET [STATUS_DOC] = @STATUS
	 WHERE [ID_DOC_RETURN_HEADER] = @IDENTITY_HEADER

END
