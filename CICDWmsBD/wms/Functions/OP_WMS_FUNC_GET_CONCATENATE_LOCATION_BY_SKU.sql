-- =============================================
-- Author:		rudi.garcia
-- Create date: 14-02-2016
-- Description:	Obtiene las ubicaciones concateneadas por sku y documento
-- =============================================
CREATE FUNCTION [wms].OP_WMS_FUNC_GET_CONCATENATE_LOCATION_BY_SKU 
(
	@DOC_ID INT
	,@MATERIAL_CODE VARCHAR(200)
)
RETURNS VARCHAR(200)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @UBICACIONES VARCHAR(200)

	SELECT 
		@UBICACIONES = COALESCE(@UBICACIONES + N', ', N'') + T.[TARGET_WAREHOUSE] --T.TARGET_LOCATION
	FROM [wms].[OP_WMS_TRANS] T
	INNER JOIN [wms].[OP_WMS3PL_POLIZA_TRANS_MATCH] PT ON (T.SERIAL_NUMBER = PT.TRANS_ID)
	INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] PH ON (PT.CODIGO_POLIZA = PH.CODIGO_POLIZA) 
	WHERE 
		PH.DOC_ID = @DOC_ID
		AND PT.MATERIAL_CODE = @MATERIAL_CODE
		
	RETURN @UBICACIONES
END