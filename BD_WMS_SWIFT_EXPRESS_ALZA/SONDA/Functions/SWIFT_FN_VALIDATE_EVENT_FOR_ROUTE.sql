-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		20-06-2016
-- Description:			    Verifica si una regla esta asociada a una ruta y si esta activa

/*
-- Ejemplo de Ejecucion:
        SELECT [SONDA].[SWIFT_FN_VALIDATE_EVENT_FOR_ROUTE]('NoValidarAntiguedadDeSaldos','RUDI@SONDA')
*/
-- =============================================
CREATE FUNCTION [SONDA].[SWIFT_FN_VALIDATE_EVENT_FOR_ROUTE]
( 
	@TYPE_ACTION VARCHAR(50)
	,@CODE_ROUTE VARCHAR(50)
)
RETURNS INT
	AS
BEGIN
	DECLARE @RESULT INT = 0
	--
	SELECT TOP 1 @RESULT = 1  
	FROM [SONDA].[SWIFT_EVENT] [E]
	INNER JOIN [SONDA].[SWIFT_RULE_X_EVENT] [RE] ON (
		[RE].[EVENT_ID] = [E].[EVENT_ID]
	)
	INNER JOIN [SONDA].[SWIFT_RULE_X_ROUTE] [RR] ON (
		[RR].[RULE_ID] = [RE].[RULE_ID]
	)
	WHERE [E].[TYPE_ACTION] = @TYPE_ACTION
		AND ([E].[ENABLED] = 'Si' OR [E].[ENABLED] = 'SI')
		AND [RR].[CODE_ROUTE] = [RR].[CODE_ROUTE]
	--
	RETURN @RESULT
 END;
