-- =============================================
-- Autor:				PEDRO LOUKOTA
-- Fecha de Creacion: 	07-12-2015
-- Description:			Seleciona la secuencia de documentos por serie

-- Modificado 10-05-2016
		-- rudi.garcia
		-- Se agrego la condicion por tipo de documento.

/*
-- Ejemplo de Ejecucion:				
				--
      DECLARE @SERIE varchar(100)

      -- TODO: Set parameter values here.
      
        EXECUTE [SONDA].[SWIFT_SP_GET_DOCUMENT_SEQUENCE_RANK_BY_SERIE] 
                        @SERIE = 'C'
                        ,@DOC_TYPE = 'DRAFT'
GO

				--				
*/
-- =============================================

CREATE PROCEDURE [SONDA].SWIFT_SP_GET_DOCUMENT_SEQUENCE_RANK_BY_SERIE
	@SERIE varchar(100)
  , @DOC_TYPE VARCHAR(50)
AS
BEGIN
	SELECT ISNULL(MAX(DOC_TO), 0) AS [RANK]
	FROM [SONDA].[SWIFT_DOCUMENT_SEQUENCE]
	WHERE SERIE = @SERIE
  AND DOC_TYPE = @DOC_TYPE
END
