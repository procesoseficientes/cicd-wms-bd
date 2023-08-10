
-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	07-01-2016
-- Description:			Valida el cierre de los batchs

/*
-- Ejemplo de Ejecucion:				
				--
				EXECUTE [SONDA].[SWIFT_SP_VALIDATE_LOCATION_BY_RELOCATE]
					@CODE_LOCATION = 'A3'
					,@IS_SOURCE_LOTATION = 1
				
				--
				EXECUTE [SONDA].[SWIFT_SP_VALIDATE_LOCATION_BY_RELOCATE]
					@CODE_LOCATION = 'A3'
					,@IS_SOURCE_LOTATION = 0
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_VALIDATE_LOCATION_BY_RELOCATE]
	@CODE_LOCATION VARCHAR(50)
	,@IS_SOURCE_LOTATION INT = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RESULT AS INT = 0;
      
	SELECT TOP 1 @RESULT = 1
	FROM [SONDA].[SWIFT_LOCATIONS] AS LO 
	WHERE LO.[CODE_LOCATION] = @CODE_LOCATION
		AND (@IS_SOURCE_LOTATION = 1 OR LO.[ALLOW_RELOCATION] = 'SI')

	SELECT @RESULT AS RESULT

END
