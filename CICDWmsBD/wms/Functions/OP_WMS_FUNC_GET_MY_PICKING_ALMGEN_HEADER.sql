
-- =============================================
-- Autor:				        rudi.garcia
-- Fecha de Creacion: 	2017-03-2 @ TeamErgon Sprint IV Ergon
-- Description:			    SP que obtiene las encabezados de las tareas de picking 

-- Modificacion 10/5/2017 @ NEXUS-Team Sprint ewms
-- rodrigo.gomez
-- Se coloca la validacion de si esta en linea de picking por la tarea no por la bodega

-- Modificacion 29-Jan-2018 @ Reborn-Team Sprint Trotzdem
-- rudi.garcia
-- Se agregaron el left join a la tabla de [OP_WMS_CONFIGURATIONS] para obtener la descripcion de la prioridad

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [wms].OP_WMS_FUNC_GET_MY_PICKING_ALMGEN_HEADER('ACAMACHO')
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FUNC_GET_MY_PICKING_ALMGEN_HEADER] (@pLOGIN_ID VARCHAR(25))
RETURNS TABLE
	AS
  RETURN
	(SELECT
			[T].[WAVE_PICKING_ID]
			,'OLA DE PICKING ALM.GEN' AS [TASK_COMMENTS]
			,MAX(CONVERT(VARCHAR(12), [T].[ASSIGNED_DATE])) AS [ASSIGNED_DATE]
			,MAX([T].[LOCATION_SPOT_TARGET]) AS [LOCATION_SPOT_TARGET]
			,CASE MAX([PDH].[IS_CONSOLIDATED])
				WHEN 1 THEN ''
				ELSE ISNULL(MAX([PDH].[TYPE_DEMAND_NAME]),
							'')
				END AS [TYPE_DEMAND_NAME]
			,MAX([T].[PRIORITY]) AS [PRIORITY]
			,MAX([C].[PARAM_CAPTION]) AS [PRIORITY_DESCRIPTION]
		FROM
			[wms].[OP_WMS_TASK_LIST] [T]
		LEFT JOIN [wms].[OP_WMS_CONFIGURATIONS] [C] ON (
											[C].[PARAM_GROUP] = 'PRIORITY'
											AND [C].[PARAM_TYPE] = 'SISTEMA'
											AND [C].[NUMERIC_VALUE] = [T].[PRIORITY]
											)
		LEFT JOIN [wms].[OP_WMS_WAREHOUSES] [W] ON [W].[WAREHOUSE_ID] = [T].[WAREHOUSE_SOURCE]
		LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH] ON ([PDH].[WAVE_PICKING_ID] = [T].[WAVE_PICKING_ID])
		WHERE
			[T].[TASK_ASSIGNEDTO] = @pLOGIN_ID
			AND [T].[IS_COMPLETED] <> 1
			AND [T].[IS_PAUSED] = 0
			AND [T].[IS_CANCELED] = 0
			AND [T].[REGIMEN] = 'GENERAL'
			AND [T].[TASK_TYPE] = 'TAREA_PICKING'
			AND (
					[T].[IN_PICKING_LINE] = 0
					OR (
						[T].[IS_FROM_SONDA] = 0
						AND [T].[IS_FROM_ERP] = 0
						)
				)
		GROUP BY
			[T].[WAVE_PICKING_ID]);