-- =============================================
-- Autor:	        rudi.garcia
-- Fecha de Creacion: 	21-Aug-2018 G-Force@Humano
-- Description:	        Sp que obtiene las licencias generadas del despacho.

-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_LICENSE_DISPATCH_BY_WAVE_PICKING] (
		@WAVE_PICKING_ID INT
		,@LOGIN VARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	 	SELECT DISTINCT
		[TL].[LOCATION_SPOT_TARGET]
		,[L].[LICENSE_ID]
		,[L].[CURRENT_LOCATION]
	FROM [wms].[OP_WMS_LICENSES] [L]
	INNER JOIN [wms].[OP_WMS_TASK_LIST] [TL] ON [L].[WAVE_PICKING_ID] = [TL].[WAVE_PICKING_ID] 
	INNER JOIN wms.OP_WMS_INV_X_LICENSE IXL on L.LICENSE_ID = IXL.LICENSE_ID AND TL.MATERIAL_ID = IXL.MATERIAL_ID
	WHERE
		[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
		AND [L].[CURRENT_LOCATION] = @LOGIN GROUP BY [TL].[LOCATION_SPOT_TARGET]
		,[L].[LICENSE_ID]
		,[L].[CURRENT_LOCATION];

END;