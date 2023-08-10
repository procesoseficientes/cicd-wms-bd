-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	07-12-2015
-- Description:			Seleciona la secuencia de documentos

-- Modificado 09-05-2016
    -- rudi.garcia
    -- Se agrego un inner join a la tabla de SWIFT_CLASSIFICATION para obtener la descripcion del tipo de documento
                        
/*
-- Ejemplo de Ejecucion:				
				--Obtener por Ruta:
          EXECUTE [SONDA].[SWIFT_SP_GET_DOCUMENT_SEQUENCE] @CODE_ROUTE = 'RUDI@SONDA'

        --Obtener Todos:
            EXECUTE [SONDA].[SWIFT_SP_GET_DOCUMENT_SEQUENCE]
				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_DOCUMENT_SEQUENCE
	@CODE_ROUTE VARCHAR(50) = NULL
AS
BEGIN
	SELECT
		 DS.ID_DOCUMENT_SECUENCE
		,DS.DOC_TYPE
		,C.NAME_CLASSIFICATION DOC_TYPE_DESCRIPTION
		,DS.SERIE
		,DS.POST_DATETIME
		,DS.DOC_FROM
		,DS.DOC_TO
		,DS.BRANCH_NAME
		,DS.BRANCH_ADDRESS
		,DS.ASSIGNED_TO
		,R.NAME_ROUTE
	FROM [SONDA].[SWIFT_DOCUMENT_SEQUENCE] DS
	LEFT JOIN [SONDA].[SWIFT_ROUTES] R ON (R.CODE_ROUTE = DS.ASSIGNED_TO)
  INNER JOIN [SONDA].SWIFT_CLASSIFICATION C ON (C.GROUP_CLASSIFICATION = 'DOC_TYPE' AND DS.DOC_TYPE = C.VALUE_TEXT_CLASSIFICATION)
	WHERE @CODE_ROUTE IS NULL OR CODE_ROUTE = @CODE_ROUTE
	
END
