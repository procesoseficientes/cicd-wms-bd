-- =============================================
-- Autorr:		rudi.garcia
-- Fecha de Creacion: 	2017-05-25 @ Team ERGON - Sprint Sheik
-- Description:	        Obtiene las poliza de seguro.

/*
-- Ejemplo de Ejecucion:
			select * from [wms].OP_WMS_FN_GET_INSURANCE_DOC()
*/
-- =============================================

CREATE FUNCTION [wms].OP_WMS_FN_GET_INSURANCE_DOC
(		
)
RETURNS TABLE 
AS
RETURN 
(
	
	SELECT
    CONVERT(VARCHAR(200),[I].[DOC_ID]) AS [DOC_ID]
   ,[I].[POLIZA_INSURANCE]   
  FROM [wms].[OP_WMS_INSURANCE_DOCS] [I]      
  UNION
  SELECT 
   [C].[TEXT_VALUE] AS [DOC_ID]        
  ,[C].[PARAM_CAPTION] AS [POLIZA_INSURANCE]     
  FROM [wms].OP_WMS_FUNC_GET_PARAMETROS_GENERALES('POLIZAS', 'POLIZAS_SEGUROS') [C]
)