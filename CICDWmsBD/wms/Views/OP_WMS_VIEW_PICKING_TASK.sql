-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		03-Nov-16 @ A-Team Sprint 4
-- Description:			    Se corrigio la columna que cambio task list

-- Modificación: rudi.garcia
-- Fecha de Creacion: 	2017-03-01 Team ERGON - Sprint IV ERGON 
-- Description:	 Se agrego el campo [LOCATION_SPOT_TARGET]

-- Modificacion 29-Jan-2018 @ Reborn-Team Sprint Trotzdem
-- rudi.garcia
-- Se agrego la columna de prioridad

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [wms].[OP_WMS_VIEW_PICKING_TASK]
*/
-- =============================================
CREATE VIEW [wms].OP_WMS_VIEW_PICKING_TASK
AS
	SELECT
		[WAVE_PICKING_ID]
		,[TASK_TYPE]
		,[TASK_SUBTYPE]
		,[TASK_ASSIGNEDTO]
		,[TASK_COMMENTS]
		,MAX([REGIMEN]) AS [REGIMEN]
		,MAX([IS_PAUSED]) AS [IS_PAUSED]
		,MAX([SERIAL_NUMBER]) AS [SERIAL_NUMBER]
		,MAX([ASSIGNED_DATE]) AS [ASSIGNED_DATE]
		,MAX([A].[COMPLETED_DATE]) AS [PICKING_FINISHED_DATE]
		,MAX([IS_CANCELED]) AS [IS_CANCELED]
		,MAX([QUANTITY_PENDING]) AS [QUANTITY_PENDING]
		,MAX([QUANTITY_ASSIGNED]) AS [QUANTITY_ASSIGNED]
		,(
			SELECT TOP (1)
				[NUMERO_ORDEN]
			FROM
				[wms].[OP_WMS_POLIZA_HEADER] AS [B]
			WHERE
				([CODIGO_POLIZA] = MAX([A].[CODIGO_POLIZA_SOURCE]))
				AND ([WAREHOUSE_REGIMEN] = MAX([A].[REGIMEN]))
			) AS [NUMERO_ORDEN_SOURCE]
		,(
			SELECT TOP (1)
				[NUMERO_ORDEN]
			FROM
				[wms].[OP_WMS_POLIZA_HEADER] AS [B]
			WHERE
				([CODIGO_POLIZA] = MAX([A].[CODIGO_POLIZA_TARGET]))
				AND ([WAREHOUSE_REGIMEN] = MAX([A].[REGIMEN]))
			) AS [NUMERO_ORDEN_TARGET]
		,[MATERIAL_ID]
		,[BARCODE_ID]
		,[MATERIAL_NAME]
		,(CASE MAX([A].[IS_COMPLETED])
			WHEN 0 THEN 'INCOMPLETA'
			ELSE 'COMPLETA'
			END) AS [IS_COMPLETED]
		,[A].[CODIGO_POLIZA_TARGET]
		,[A].[IS_DISCRETIONARY]
		,CASE [A].[IS_DISCRETIONARY]
			WHEN 1 THEN 'Discrecional'
			ELSE 'Dirigido'
			END [TYPE_PICKING]
    ,MAX([A].[LOCATION_SPOT_TARGET]) AS [LOCATION_SPOT_TARGET]
    ,MAX([A].[PRIORITY]) AS [PRIORITY]
	FROM
		[wms].[OP_WMS_TASK_LIST] AS [A]
	GROUP BY
		[WAVE_PICKING_ID]
		,[TASK_TYPE]
		,[TASK_SUBTYPE]
		,[TASK_ASSIGNEDTO]
		,[TASK_COMMENTS]
		,[MATERIAL_ID]
		,[BARCODE_ID]
		,[MATERIAL_NAME]
		,[A].[CODIGO_POLIZA_TARGET]
		,[A].[IS_DISCRETIONARY];