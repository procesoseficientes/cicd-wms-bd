/*
	-- =============================================
-- Autor:				JOSE ROBERTO
-- Fecha de Creacion: 	10-12-2015
-- Description:			Función que valida que la ruta tenga una SERIE asignada
--						de FACTURAS

-- Ejemplo de Ejecucion:	
							SELECT [SONDA].[SWIFT_FUNC_VALIDATE_DOCUMENT_SALE]('001')
-- =============================================
*/
CREATE FUNCTION [SONDA].[SWIFT_FUNC_VALIDATE_DOCUMENT_SALE]
( 
	@CODE_ROUTE VARCHAR(50)
)
RETURNS BIT
	AS
BEGIN
	DECLARE @DOC BIT = 0
	--
	SELECT @DOC = COUNT(*)
	FROM [SONDA].[SONDA_POS_RES_SAT] RS
	WHERE RS.AUTH_ASSIGNED_TO = @CODE_ROUTE
	--
	RETURN @DOC
 END;
