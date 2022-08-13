-- =============================================
-- Autor:					rudi.garcia
-- Fecha de Creacion: 		2017-03-01 Team ERGON - Sprint IV ERGON 
-- Description:			     Se agrego el campo [LOCATION_SPOT_TARGET]

-- Modificacion 29-Jan-2018 @ Reborn-Team Sprint Trotzdem
-- rudi.garcia
-- Se agregaron el left join a la tabla de [OP_WMS_CONFIGURATIONS] para obtener la descripcion de la prioridad

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [wms].[OP_WMS_VIEW_PICKING_TASK]
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FUNC_GET_MY_PICKING_LIST_HEADER] (@pLOGIN_ID VARCHAR(25))
RETURNS TABLE
	AS
RETURN
	(SELECT
			[A].[WAVE_PICKING_ID]
			,MAX(ISNULL([TASK_COMMENTS], 'SC')
					+ ' DESPACHO FISCAL') AS [TASK_COMMENTS]
			,MAX(CONVERT(VARCHAR(12), [ASSIGNED_DATE])) AS [ASSIGNED_DATE]
			,MAX([A].[LOCATION_SPOT_TARGET]) AS [LOCATION_SPOT_TARGET]
			,MAX([A].[PRIORITY]) AS [PRIORITY]
			,MAX([C].[PARAM_CAPTION]) AS [PRIORITY_DESCRIPTION]
		FROM
			[wms].[OP_WMS_VIEW_PICKING_TASK] [A]
		LEFT JOIN [wms].[OP_WMS_CONFIGURATIONS] [C] ON (
											[C].[PARAM_GROUP] = 'PRIORITY'
											AND [C].[PARAM_TYPE] = 'SISTEMA'
											AND [C].[NUMERIC_VALUE] = [A].[PRIORITY]
											)
		WHERE
			[TASK_ASSIGNEDTO] = @pLOGIN_ID
			AND [A].[IS_COMPLETED] = 'INCOMPLETA'
			AND [A].[IS_PAUSED] = 0
			AND [A].[IS_CANCELED] = 0
			AND [A].[TASK_SUBTYPE] = 'DESPACHO_FISCAL'
			AND [REGIMEN] = 'FISCAL'
		GROUP BY
			[A].[WAVE_PICKING_ID]);