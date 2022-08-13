-- =============================================
-- Autor:				jonathan.salvador
-- Fecha de Creacion: 	16-Dic-2019 G-Force@Madagascar
-- Description:	        Sp que obtiene el inventario en las licencias de despacho generadas para la ola consultada.

-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_LICENSES_DISPATCH_BY_WAVE_PICKING_SUPER] (
		@WAVE_PICKING_ID INT
		,@LOGIN_ID VARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;
  --

	    -- -----------------------------------------------------------------------------------------
    -- SE OBTIENE EL INVENTARIO EN TODAS LAS LICENCIAS DE DESPACHO GENERADAS PARA LA OLA DE PICKING CONSULTADA
    -- -----------------------------------------------------------------------------------------
	SELECT DISTINCT
		[TL].[LOCATION_SPOT_TARGET]
		,[L].[LICENSE_ID]
		,[L].[CURRENT_LOCATION]
		,[IL].[MATERIAL_ID]
		,[IL].[MATERIAL_NAME]
		,[IL].[QTY]
		,[L].[CURRENT_WAREHOUSE]
		,CASE WHEN L.CURRENT_LOCATION = (SELECT TOP 1 LOCATION_SPOT FROM wms.OP_WMS_SHELF_SPOTS WHERE SPOT_TYPE = 'PUERTA' AND LOCATION_SPOT = L.CURRENT_LOCATION) THEN 'green'
		ELSE 'red'
		END AS IS_ALLOCATED
		, (SELECT COUNT(IV.MATERIAL_ID) FROM wms.OP_WMS_INV_X_LICENSE AS IV WHERE IV.LICENSE_ID = L.LICENSE_ID) [COUNT_MATERIALS]
	FROM
		[wms].[OP_WMS_INV_X_LICENSE] [IL]
		INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON ([L].[LICENSE_ID] = [IL].[LICENSE_ID])
	INNER JOIN [wms].[OP_WMS_TASK_LIST] [TL] ON ([TL].[WAVE_PICKING_ID] = [L].[WAVE_PICKING_ID])
	WHERE
		[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
END;