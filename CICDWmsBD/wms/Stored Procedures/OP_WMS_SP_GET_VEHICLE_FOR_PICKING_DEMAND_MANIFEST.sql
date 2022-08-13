﻿-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	08-Nov-17 @ Nexus Team Sprint  F-Zero
-- Description:			SP que retorna los vehiculos a asignar en demanda de despacho. 
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_VEHICLE_FOR_PICKING_DEMAND_MANIFEST]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_VEHICLE_FOR_PICKING_DEMAND_MANIFEST]
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE	@HAS_NEXT INT = 0;
	--
	SELECT
		@HAS_NEXT = CAST([VALUE] AS INT)
	FROM
		[wms].[OP_WMS_PARAMETER]
	WHERE
		[GROUP_ID] = 'NEXT'
		AND [PARAMETER_ID] = 'HAS_NEXT';
	--
	SELECT
		[V].[VEHICLE_CODE]
		,CONCAT([V].[BRAND], ' ', [V].[LINE], ' ',
				[V].[MODEL]) [VEHICLE]
		,[T].[TRANSPORT_COMPANY_CODE]
		,[T].[NAME] [TRANSPORT_COMPANY_NAME]
		,[V].[PLATE_NUMBER]
		,[V].[RATING]
		,[V].[VOLUME_FACTOR] * ([V].[FILL_RATE] / 100) [MAX_VOLUME]
		,SUM(ISNULL([M].[VOLUME_FACTOR], 0)
				* ISNULL([MD].[QTY], 0)) [USED_VOLUME]
		,SUM(ISNULL([M].[VOLUME_FACTOR], 0)
				* ISNULL([MD].[QTY], 0)) [ORIGINAL_USED_VOLUME]
		,([V].[VOLUME_FACTOR] * ([V].[FILL_RATE] / 100))
		- SUM(ISNULL([M].[VOLUME_FACTOR], 0)
				* ISNULL([MD].[QTY], 0)) [AVAILABLE_VOLUME]
		,([V].[VOLUME_FACTOR] * ([V].[FILL_RATE] / 100))
		- SUM(ISNULL([M].[VOLUME_FACTOR], 0)
				* ISNULL([MD].[QTY], 0)) [ORIGINAL_AVAILABLE_VOLUME]
		,[V].[WEIGHT] * ([V].[FILL_RATE] / 100) [MAX_WEIGHT]
		,SUM(ISNULL([wms].[OP_WMS_FN_CONVERT_FROM_WEIGHT_MEASURE_UNIT_TO_DEFAULT]([M].[WEIGTH],
											[M].[WEIGHT_MEASUREMENT]),
					0) * ISNULL([MD].[QTY], 0)) [USED_WEIGHT]
		,SUM(ISNULL([wms].[OP_WMS_FN_CONVERT_FROM_WEIGHT_MEASURE_UNIT_TO_DEFAULT]([M].[WEIGTH],
											[M].[WEIGHT_MEASUREMENT]),
					0) * ISNULL([MD].[QTY], 0)) [ORIGINAL_USED_WEIGHT]
		,([V].[WEIGHT] * ([V].[FILL_RATE] / 100))
		- SUM(ISNULL([wms].[OP_WMS_FN_CONVERT_FROM_WEIGHT_MEASURE_UNIT_TO_DEFAULT]([M].[WEIGTH],
											[M].[WEIGHT_MEASUREMENT]),
						0) * ISNULL([MD].[QTY], 0)) [AVAILABLE_WEIGHT]
		,([V].[WEIGHT] * ([V].[FILL_RATE] / 100))
		- SUM(ISNULL([wms].[OP_WMS_FN_CONVERT_FROM_WEIGHT_MEASURE_UNIT_TO_DEFAULT]([M].[WEIGTH],
											[M].[WEIGHT_MEASUREMENT]),
						0) * ISNULL([MD].[QTY], 0)) [ORIGINAL_AVAILABLE_WEIGHT]
		,[V].[STATUS] [STATUS]
		,ROW_NUMBER() OVER (ORDER BY [IS_OWN] DESC 
			, (([V].[WEIGHT] * ([V].[FILL_RATE] / 100))
				- SUM(ISNULL([wms].[OP_WMS_FN_CONVERT_FROM_WEIGHT_MEASURE_UNIT_TO_DEFAULT]([M].[WEIGTH],
											[M].[WEIGHT_MEASUREMENT]),
								0) * ISNULL([MD].[QTY], 0))) ASC
			, [V].[RATING] DESC) AS [PRIORITY]
		,[T].[IS_OWN]
		,[V].[PILOT_CODE]
		,[V].[FILL_RATE]
	FROM
		[wms].[OP_WMS_VEHICLE] [V]
	LEFT JOIN [wms].[OP_WMS_TRANSPORT_COMPANY] [T] ON [T].[TRANSPORT_COMPANY_CODE] = [V].[TRANSPORT_COMPANY_CODE]
	LEFT JOIN [wms].[OP_WMS_MANIFEST_HEADER] [MH] ON [MH].[VEHICLE] = [V].[VEHICLE_CODE]
											AND [MH].[STATUS] NOT IN (
											'ASSIGNED',
											'CANCELED',
											'COMPLETED',
											'CERTIFIED',
											'CERTIFYING')
	LEFT JOIN [wms].[OP_WMS_MANIFEST_DETAIL] [MD] ON [MD].[MANIFEST_HEADER_ID] = [MH].[MANIFEST_HEADER_ID]
	LEFT JOIN [wms].[OP_WMS_PILOT] [P] ON [P].[PILOT_CODE] = [V].[PILOT_CODE]
	LEFT JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [MD].[MATERIAL_ID]
	WHERE
		[V].[IS_ACTIVE] = 1
		AND [V].[PILOT_CODE] IS NOT NULL
	GROUP BY
		[VEHICLE_CODE]
		,[V].[BRAND]
		,[V].[LINE]
		,[V].[MODEL]
		,[T].[NAME]
		,[V].[VOLUME_FACTOR]
		,[V].[WEIGHT]
		,[T].[TRANSPORT_COMPANY_CODE]
		,[V].[PLATE_NUMBER]
		,[V].[RATING]
		,[V].[FILL_RATE]
		,[V].[STATUS]
		,[T].[IS_OWN]
		,[V].[PILOT_CODE]
	HAVING
		--Validar que no sobre pase el volumen y peso máximo
		[V].[VOLUME_FACTOR] * ([V].[FILL_RATE] / 100) > SUM(ISNULL([M].[VOLUME_FACTOR],
											0)
											* ISNULL([MD].[QTY],
											0))
		AND [V].[WEIGHT] * ([V].[FILL_RATE] / 100) > SUM(ISNULL([wms].[OP_WMS_FN_CONVERT_FROM_WEIGHT_MEASURE_UNIT_TO_DEFAULT]([M].[WEIGTH],
											[M].[WEIGHT_MEASUREMENT]),
											0)
											* ISNULL([MD].[QTY],
											0)); 

END;