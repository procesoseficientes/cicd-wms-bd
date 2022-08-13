-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	20180726 GForce@FocaMonje
-- Description:			Obtiene el reporte de las operaciones de picking

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_PICKING_REPORT]
					@START_DATE = '20180725',
					@END_DATE = '20180726'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_PICKING_REPORT] (
		@START_DATE DATE
		,@END_DATE DATE
	)
AS
BEGIN
	
	SELECT
		[WAVE_PICKING_ID]
		,MAX([COMPLETED_DATE]) [COMPLETED_DATE]
	INTO
		[#COMPLETED_TASK]
	FROM
		[wms].[OP_WMS_TASK_LIST]
	WHERE
		CAST([ASSIGNED_DATE] AS DATE) BETWEEN CAST(@START_DATE AS DATE)
										AND	CAST(@END_DATE AS DATE)
	GROUP BY
		[WAVE_PICKING_ID]
	HAVING
		MIN([IS_COMPLETED]) > 0;
 
	SELECT
		[T].[WAVE_PICKING_ID]
		,[T].[MATERIAL_ID]
		,SUM([T].[QUANTITY_ASSIGNED]) [QUANTITY_ASSIGNED]
		,MAX([T].[ASSIGNED_DATE]) [ASSIGNED_DATE]
		,MAX([T].[ACCEPTED_DATE]) [ACCEPTED_DATE]
		,MAX([T].[COMPLETED_DATE]) [COMPLETED_DATE]
		,RANK() OVER (PARTITION BY [T].[WAVE_PICKING_ID] ORDER BY MAX([T].[COMPLETED_DATE]) ASC) AS [TaskOrder]
		,MAX([LA].[LOGIN_ID]) [CREATED_BY]
		,MAX([LA].[LOGIN_NAME]) [CREATED_BY_NAME]
		,MAX([LO].[LOGIN_ID]) [ASSIGNED_TO]
		,MAX([LO].[LOGIN_NAME]) [ASSIGNED_TO_NAME]
		,MAX([CT].[COMPLETED_DATE]) [WAVE_FINISH_DATE]
		,MAX([T].[WAREHOUSE_SOURCE]) [WAREHOUSE_ID]
	INTO
		[#TASK]
	FROM
		[wms].[OP_WMS_TASK_LIST] [T]
	INNER JOIN [#COMPLETED_TASK] [CT] ON [CT].[WAVE_PICKING_ID] = [T].[WAVE_PICKING_ID]
	INNER JOIN [wms].[OP_WMS_LOGINS] [LA] ON [LA].[LOGIN_ID] = [T].[TASK_OWNER]
	INNER JOIN [wms].[OP_WMS_LOGINS] [LO] ON [LO].[LOGIN_ID] = [T].[TASK_ASSIGNEDTO]
	WHERE
		[T].[WAVE_PICKING_ID] IS NOT NULL
		AND [T].[QUANTITY_ASSIGNED] <> [T].[QUANTITY_PENDING]
	GROUP BY
		[T].[WAVE_PICKING_ID]
		,[T].[MATERIAL_ID];
    
 
	SELECT
		[T].[WAVE_PICKING_ID] [WAVE_PICKING_ID] --[Ola de Picking]
		,[h].[DOC_NUM] [DOC_NUM] --[Pedido]
		,[T].[CREATED_BY] [CREATED_BY]--[Creado por]
		,[T].[CREATED_BY_NAME] [CREATED_BY_NAME] --[Nombre Creado por]
		,[T].[MATERIAL_ID] [MATERIAL_ID] --[Material]
		,[M].[MATERIAL_NAME] [MATERIAL_NAME]
		,[M].[ERP_AVERAGE_PRICE] [MATERIAL_COST]
		,[T].[QUANTITY_ASSIGNED] [QUANTITY_ASSIGNED] -- [Cantidad Asignada]
		,[W].[NAME] [WAREHOUSE_NAME]
		,[T].[ASSIGNED_TO] [ASSIGNED_TO] --[Asignado A]
		,[T].[ASSIGNED_TO_NAME] [ASSIGNED_TO_NAME] -- [Nombre Asignado A]
		,FORMAT([T].[ASSIGNED_DATE], 'dd/MM/yyyy HH:mm:ss') [ASSIGNED_DATE] -- [Fecha de asignación]
		,FORMAT([T].[ACCEPTED_DATE], 'dd/MM/yyyy HH:mm:ss') [ACCEPTED_DATE] -- [Fecha de aceptación Picking]
		,FORMAT([T].[COMPLETED_DATE], 'dd/MM/yyyy HH:mm:ss') [COMPLETED_DATE] --[Fecha de completación Picking]
		,CONVERT(VARCHAR(12), DATEADD(MS,
										DATEDIFF(MS,
											[T].[ASSIGNED_DATE],
											[T].[ACCEPTED_DATE]),
										0), 114) [ACCEPTED_CREATED_INTERVAL]--[Intervalo Creacion Aceptacion]
		,DATEDIFF(MINUTE, [T].[ASSIGNED_DATE],
					[T].[ACCEPTED_DATE]) [ACCEPTED_CREATED_INTERVAL_MINUTES] --[Intervalo Creacion Aceptacion(Minutos)]
		,CONVERT(VARCHAR(12), DATEADD(MS,
										DATEDIFF(MS,
											ISNULL([T1].[COMPLETED_DATE],
											[T].[ACCEPTED_DATE]),
											[T].[COMPLETED_DATE]),
										0), 114) [PICKING_TIME]--[Tiempo Picking]
		,DATEDIFF(MINUTE,
					ISNULL([T1].[COMPLETED_DATE],
							[T].[ACCEPTED_DATE]),
					[T].[COMPLETED_DATE]) [PICKING_TIME_MINUTES] --[Tiempo Picking(Minutos)]
		,CONVERT(VARCHAR(12), DATEADD(MS,
										DATEDIFF(MS,
											[T].[ACCEPTED_DATE],
											[T].[WAVE_FINISH_DATE]),
										0), 114) [TOTAL_TIME_PICKING]  --[Tiempo Total Picking]
		,DATEDIFF(MINUTE, [T].[ACCEPTED_DATE],
					[T].[WAVE_FINISH_DATE]) [TOTAL_TIME_PICKING_MINUTES] --[Tiempo Total Picking(Minutos)]
		,CONVERT(VARCHAR(12), DATEADD(MS,
										DATEDIFF(MS,
											[T].[ASSIGNED_DATE],
											[T].[WAVE_FINISH_DATE]),
										0), 114) [TOTAL_TIME_FROM_TASK_ASSIGNED] --[Tiempo Total desde asignación]
		,DATEDIFF(MINUTE, [T].[ASSIGNED_DATE],
					[T].[WAVE_FINISH_DATE]) [TOTAL_TIME_FROM_TASK_ASSIGNED_MINUTES] -- [Tiempo Total desde asignación(Minutos)]
		,[T].[TaskOrder] [TASK_ORDER] --[Orden Tarea]
	FROM
		[#TASK] [T]
	LEFT JOIN [#TASK] [T1] ON [T].[WAVE_PICKING_ID] = [T1].[WAVE_PICKING_ID]
								AND [T1].[TaskOrder] + 1 = [T].[TaskOrder]
	LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [h] ON [h].[WAVE_PICKING_ID] = [T].[WAVE_PICKING_ID]
											AND [h].[IS_CONSOLIDATED] = 0
	INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [T].[MATERIAL_ID]
	INNER JOIN [wms].[OP_WMS_WAREHOUSES] [W] ON [T].[WAREHOUSE_ID] = [W].[WAREHOUSE_ID]
	ORDER BY
		[T].[WAVE_PICKING_ID]
		,[T].[TaskOrder];
END;