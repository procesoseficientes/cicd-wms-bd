
-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	07-12-2015
-- Description:			Obtiene las rutas para la secuencia de documentos
--                      
/*
-- Ejemplo de Ejecucion:				
				--


-- TODO: Set parameter values here.

	EXECUTE [SONDA].[SWIFT_SP_GET_ROUTE_BY_DOCUMENT_SEQUENCE]


				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_DOC_TYPE]	 
AS
BEGIN
	SELECT 
		VALUE_TEXT_CLASSIFICATION
	   ,NAME_CLASSIFICATION
	FROM [SONDA].[SWIFT_CLASSIFICATION]
	WHERE GROUP_CLASSIFICATION = 'DOC_TYPE'	
END
