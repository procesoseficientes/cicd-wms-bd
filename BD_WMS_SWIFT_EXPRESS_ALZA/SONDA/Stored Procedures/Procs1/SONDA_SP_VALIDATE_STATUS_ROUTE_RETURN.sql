-- =============================================
-- Author:         diego.as
-- Create date:    10-02-2016
-- Description:    Valida si el campo STATUS_DOC de la tabla 
--				   [SONDA].SONDA_DOC_ROUTE_RETURN_HEADER es igual a 'COMPLETE'
--				   recibiendo como parametro el Identity de la fila a validar. 

/*
Ejemplo de Ejecucion:
	
					DECLARE @ID_HEADER INT = 5
					EXEC [SONDA].[SONDA_SP_VALIDATE_STATUS_ROUTE_RETURN] 
					@IDENTITY_HEADER = @ID_HEADER
					
					----------------------------------------------------

					DECLARE @ID_HEADER INT = 5
					SELECT 
						RH.STATUS_DOC 
					FROM [SONDA].[SONDA_DOC_ROUTE_RETURN_HEADER] AS RH
					WHERE RH.ID_DOC_RETURN_HEADER = @ID_HEADER
*/
-- =============================================


CREATE PROCEDURE [SONDA].[SONDA_SP_VALIDATE_STATUS_ROUTE_RETURN]
     @IDENTITY_HEADER AS INT		
AS
BEGIN 
	SET NOCOUNT ON;
	DECLARE @STATE INT
	
	IF (SELECT 
			RH.STATUS_DOC 
		FROM [SONDA].[SONDA_DOC_ROUTE_RETURN_HEADER] AS RH 
		WHERE RH.ID_DOC_RETURN_HEADER = @IDENTITY_HEADER) = 'COMPLETE' 
		
		BEGIN
			SET @STATE = 1
		END
	ELSE
		BEGIN
			SET @STATE = 0
		END
	
	SELECT @STATE AS STATE

END
