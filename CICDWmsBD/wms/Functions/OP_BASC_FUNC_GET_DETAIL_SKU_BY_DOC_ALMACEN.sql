-- =============================================
-- Author:		rudi.garcia
-- Create date: 15-02-2016
-- Description:	Obtiene el detalle del sku por el documento
-- =============================================
CREATE FUNCTION [wms].OP_BASC_FUNC_GET_DETAIL_SKU_BY_DOC_ALMACEN
(	
	@DOC_ID INT
	,@MATERIAL VARCHAR(200)
)
RETURNS TABLE 
AS
RETURN 
(
	
	SELECT DISTINCT TOP 1
		@MATERIAL AS SKU
		,IL.MATERIAL_ID
		,IL.MATERIAL_NAME		
	FROM [wms].[OP_WMS_INV_X_LICENSE] IL
	INNER JOIN [wms].[OP_WMS_LICENSES] L ON (IL.LICENSE_ID = L.LICENSE_ID)
	INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] PH ON (L.CODIGO_POLIZA = PH.CODIGO_POLIZA)
	WHERE 
		@MATERIAL LIKE '%' + IL.MATERIAL_ID +'%'	
		AND PH.DOC_ID = @DOC_ID	
)