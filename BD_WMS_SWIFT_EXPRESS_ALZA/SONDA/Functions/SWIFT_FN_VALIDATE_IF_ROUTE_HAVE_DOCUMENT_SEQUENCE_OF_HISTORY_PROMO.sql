-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		23-Mar-17 @ A-Team Sprint Fenyang
-- Description:			    Valida que la ruta tenga sequencia de documentos de HISTORY_PROMO 

/*
-- Ejemplo de Ejecucion:
        SELECT [SONDA].[SWIFT_FN_VALIDATE_IF_ROUTE_HAVE_DOCUMENT_SEQUENCE_OF_HISTORY_PROMO]('demo')
  
        SELECT *
        FROM [SONDA].[SWIFT_DOCUMENT_SEQUENCE] [DS]  

*/
-- =============================================
CREATE FUNCTION [SONDA].SWIFT_FN_VALIDATE_IF_ROUTE_HAVE_DOCUMENT_SEQUENCE_OF_HISTORY_PROMO (@CODE_ROUTE VARCHAR(50))
RETURNS INT
AS
BEGIN
  DECLARE @HAVE_DOCUMENT_SEQUENCE INT = 0
  --
  SELECT TOP 1
    @HAVE_DOCUMENT_SEQUENCE = 1
  FROM [SONDA].[SWIFT_DOCUMENT_SEQUENCE] [DS]
  WHERE [DS].[ASSIGNED_TO] = @CODE_ROUTE
  AND [DS].[DOC_TYPE] = 'HISTORY_BY_PROMO'
  AND (DS.CURRENT_DOC + 1) >= DS.DOC_FROM
  AND (DS.CURRENT_DOC + 1) <= DS.DOC_TO
  --
  RETURN @HAVE_DOCUMENT_SEQUENCE
END
