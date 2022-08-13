
-- =============================================
-- Autor:				        rudi.garcia
-- Fecha de Creacion: 	2017-03-2 @ TeamErgon Sprint Ganondorf
-- Description:			    SP que obtiene las encabezados de las tareas de picking 

-- Modificacion 29-Jan-2018 @ Reborn-Team Sprint Trotzdem
-- rudi.garcia
-- Se agregaron el left join a la tabla de [OP_WMS_CONFIGURATIONS] para obtener la descripcion de la prioridad

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [wms].OP_WMS_FUNC_GET_MY_REALLOC_TASK_HEADER('ACAMACHO')
*/
-- =============================================
CREATE FUNCTION [wms].OP_WMS_FUNC_GET_MY_REALLOC_TASK_HEADER
(	
	@pLOGIN_ID varchar(25)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		[T].WAVE_PICKING_ID,
		'OLA DE REUBICACIÓN ' AS TASK_COMMENTS,
		MAX(CONVERT(VARCHAR(12), [T].ASSIGNED_DATE)) AS ASSIGNED_DATE
   ,MAX([T].[LOCATION_SPOT_TARGET]) AS [LOCATION_SPOT_TARGET]
   ,MAX([T].[PRIORITY]) AS [PRIORITY]
   ,MAX([C].[PARAM_CAPTION]) AS [PRIORITY_DESCRIPTION]
FROM 
	[wms].OP_WMS_TASK_LIST [T]
LEFT JOIN [wms].[OP_WMS_CONFIGURATIONS] [C]
    ON (
    [C].[PARAM_GROUP] = 'PRIORITY'
    AND [C].[PARAM_TYPE] = 'SISTEMA'
    AND [C].[NUMERIC_VALUE] = [T].[PRIORITY]
    )
WHERE 
	TASK_ASSIGNEDTO = @pLOGIN_ID
	AND IS_COMPLETED <> 1 AND IS_PAUSED = 0 AND IS_CANCELED = 0
	AND [TASK_TYPE] = 'TAREA_REUBICACION'
GROUP BY 
	WAVE_PICKING_ID	
)