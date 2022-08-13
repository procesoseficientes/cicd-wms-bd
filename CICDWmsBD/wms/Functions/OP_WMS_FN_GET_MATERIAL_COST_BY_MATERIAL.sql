-- =============================================
-- Autor:					marvin.solares
-- Fecha de Creacion: 		7/9/2018 GForce@FocaMonje 
-- Description:			    devuelve el costo promedio del material

/*
-- Ejemplo de Ejecucion:
         select [wms].OP_WMS_FN_GET_MATERIAL_COST_BY_MATERIAL('arium/100009','arium')
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_MATERIAL_COST_BY_MATERIAL] (
		@MATERIAL_ID AS VARCHAR(50)
		,@CLIENT_OWNER VARCHAR(25)
	)
RETURNS NUMERIC(18,6)
AS
BEGIN
	DECLARE	@VALUE NUMERIC(18,6);
	--
	SELECT
		@VALUE = [M].[ERP_AVERAGE_PRICE]
	FROM
		[wms].[OP_WMS_MATERIALS] [M]
	WHERE
		[M].[MATERIAL_ID] = @MATERIAL_ID
		AND [M].[CLIENT_OWNER] = @CLIENT_OWNER;
	--
	RETURN ISNULL(@VALUE,0.00);

END;