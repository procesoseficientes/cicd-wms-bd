-- =============================================
-- Author:     	rudi.garcia
-- Create date: 2016-03-07 18:07:27
-- Description: Obtiene el detalle del documento de ingreso


/*
Ejemplo de Ejecucion:
							EXEC [wms].OP_WMS_SP_GET_DETAILS_DOC_INCOME_BY_CLIENT @CODE_CLIENT = 'C40', @CODE_POLIZA = '297'
*/
-- =============================================


CREATE PROCEDURE [wms].OP_WMS_SP_GET_DETAILS_DOC_INCOME_BY_CLIENT(
  @CODE_CLIENT VARCHAR(50)
  ,@CODE_POLIZA VARCHAR(25))
AS 
  SELECT    
    IL.MATERIAL_ID
    ,'' AS PACKING
    ,IL.MATERIAL_NAME
    ,SUM(IL.ENTERED_QTY) AS QTY    
  FROM [wms].OP_WMS_INV_X_LICENSE IL
  INNER JOIN [wms].OP_WMS_LICENSES L ON IL.LICENSE_ID = L.LICENSE_ID
  WHERE L.CLIENT_OWNER = @CODE_CLIENT
  AND L.CODIGO_POLIZA = @CODE_POLIZA
  GROUP BY IL.MATERIAL_ID, IL.MATERIAL_NAME