-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	07-12-2015
-- Description:			Obtiene las rutas para la secuencia de documentos

-- Modificado 09-05-2016
    -- rudi.garcia
    -- Se agrego un left join en vez de un subSelect para obtener las rutas disponibles y se quito el parametro de seria.
/*
-- Ejemplo de Ejecucion:				
				--


-- TODO: Set parameter values here.

	EXECUTE [SONDA].[SWIFT_SP_GET_ROUTE_BY_DOCUMENT_SEQUENCE]
                @DOC_TYPE = 'DRAFT'
              ,@ASSIGNED_TO = 'RUDI@SONDA'

				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_ROUTE_BY_DOCUMENT_SEQUENCE
	 @DOC_TYPE VARCHAR(50)
  , @ASSIGNED_TO VARCHAR(50) = NULL
AS
BEGIN	
  SELECT 
		 VR.CODE_ROUTE
		,VR.NAME_ROUTE
	FROM [SONDA].SWIFT_VIEW_ROUTES VR   
  LEFT JOIN [SONDA].SWIFT_DOCUMENT_SEQUENCE PR ON (VR.CODE_ROUTE = PR.ASSIGNED_TO AND PR.DOC_TYPE = @DOC_TYPE)
  WHERE PR.DOC_TYPE IS NULL
  OR VR.CODE_ROUTE = @ASSIGNED_TO
END
