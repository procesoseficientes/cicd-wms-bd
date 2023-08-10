/*
	-- =============================================
-- Autor:				JOSE ROBERTO
-- Fecha de Creacion: 	09-12-2015
-- Description:			Función que valida que la ruta tenga ORDEN DE VENTA.

-- Modificacion 22-04-2016
					-- alberto.ruiz
					-- Se agrego que valide si llego al limite de documentos de credito

-- Modificacion 17-05-2016
					-- hector.gonzalez
					-- Se modifico el where para que no acepte numeros de documentos 'menor o igual que'(<=) solo menores asi no deje crear un documento mas si este ya llego a su limite


-- Ejemplo de Ejecucion:	
							SELECT [SONDA].[SWIFT_FUNC_VALIDATE_DOCUMENT_PRESALE]('001')
-- =============================================
*/
CREATE FUNCTION [SONDA].SWIFT_FUNC_VALIDATE_DOCUMENT_PRESALE
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
		AND DS.DOC_TYPE = 'SALES_ORDER'
		AND DS.CURRENT_DOC < DS.DOC_TO
	--
	RETURN @DOC
 END;
