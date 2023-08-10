/*
	-- =============================================
-- Autor:				hector.gonzalez
-- Fecha de Creacion: 	10-06-2016
-- Description:			Función que valida que la ruta tenga ORDEN DE VENTA.


-- Ejemplo de Ejecucion:	
							SELECT [SONDA].[SWIFT_FUNC_VALIDATE_DOCUMENT_TAKE_INVENTORY]('RUDI@SONDA')
-- =============================================
*/
CREATE FUNCTION [SONDA].[SWIFT_FUNC_VALIDATE_DOCUMENT_TAKE_INVENTORY]
( 
	@CODE_ROUTE VARCHAR(50)
)
RETURNS BIT
	AS
BEGIN
	DECLARE @DOC INT = 0
	--
	SELECT TOP 1 @DOC = 1
	FROM  [SONDA].[SWIFT_DOCUMENT_SEQUENCE] DS
	WHERE DS.ASSIGNED_TO = @CODE_ROUTE
		AND DS.DOC_TYPE = 'TAKE_INVENTORY'
		AND DS.CURRENT_DOC < DS.DOC_TO
	--
	RETURN @DOC
 END;
