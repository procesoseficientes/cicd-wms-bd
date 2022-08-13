-- =============================================
-- Autor:	        rudi.garcia
-- Fecha de Creacion: 	21-Aug-2018 G-Force@Jaguarundi
-- Description:	        Sp que obtien las licencias para el despacho.

-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_LICENSE_DISPATCH_FOR_PICKING] (@WAVE_PICKING_ID INT)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		[IL].[LICENSE_ID]
		,[L].[CURRENT_LOCATION]
		,[IL].[LAST_UPDATED_BY]
		,[IL].[MATERIAL_ID]
		,[IL].[MATERIAL_NAME]
		,[IL].[QTY]
		,[IL].[QTY] AS [QTY_ORIGIN]
	FROM
		[wms].[OP_WMS_LICENSES] [L]
	INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON ([L].[LICENSE_ID] = [IL].[LICENSE_ID])
	WHERE
		[L].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
		AND [IL].[QTY] > 0;

END;