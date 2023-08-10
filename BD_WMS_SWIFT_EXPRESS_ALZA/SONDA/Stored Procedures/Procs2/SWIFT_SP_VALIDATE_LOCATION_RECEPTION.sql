
-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	11-1-2016
-- Description:			Validad la ubicacion para la recepcion 

/*
-- Ejemplo de Ejecucion:				
				--
EXECUTE  [SONDA].[SWIFT_SP_VALIDATE_LOCATION_RECEPTION] 
    @LOCATION= 'A3'   
				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_VALIDATE_LOCATION_RECEPTION]	 
	 @LOCATION AS VARCHAR(50)
AS
BEGIN 	

	SET NOCOUNT ON; 	

	IF NOT EXISTS (SELECT TOP 1 1 FROM [SONDA].[SWIFT_LOCATIONS] WHERE [CODE_LOCATION] = @LOCATION) BEGIN
		SELECT 'La ubicación no existe.' as RESULT
		return -1		
	END	

	if  NOT EXISTS (SELECT TOP 1 1 FROM [SONDA].[SWIFT_LOCATIONS] WHERE [CODE_LOCATION] = @LOCATION AND ALLOW_STORAGE = 'SI' )BEGIN
		SELECT 'La ubicación no recepción' as RESULT
		return -1		
	END

	SELECT 'Exito' as RESULT
END
