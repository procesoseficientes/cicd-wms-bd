-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	13-02-2017 @ Sprint Ergon III
-- Description:			Obtiene los encabezados de tarea de picking

-- Modificación: rudi.garcia
-- Fecha de Creacion: 	2017-02-28 Team ERGON - Sprint IV ERGON
-- Description:	 se agrega el campo del WAREHOUSE_SOURCE


-- Modificación: rudi.garcia
-- Fecha de Creacion: 	2017-04-19 Team ERGON - Sprint Epona
-- Description:	 Se agrego el campo 


-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-05-25 ErgonTeam@Sheik
-- Description:	 Se le quita del group by el A.CODIGO_POLIZA_TARGET

-- Modificación: rudi.garcia
-- Fecha de Creacion: 	28-Nov-17 Team ERGON - Sprint IV ERGON
-- Description:	 Se agrego columna [PRIORITY]  

-- Modificacion 11-Dec-17 @ Nexus Team Sprint HeyYouPikachu!
-- pablo.aguilar
--  Se modifica para que traiga el min de IS_CANCELED para que se deje de mostrar unicamente ssi todas las lineas se cancelaron.

-- Autor:				rudi.garcia
-- Fecha de Creacion: 	26-Jul-2019 @ G-Force-Team Sprint Dublin
-- Description:			se agrega manejo de proyectos, se agrega orderNumber de la consulta

/*
	Ejemplo Ejecucion: 
    SELECT * FROM [wms].OP_WMS_VIEW_TASK_PICKING_HEADER
 */
-- =============================================
CREATE VIEW [wms].[OP_WMS_VIEW_TASK_PICKING_HEADER]
AS
SELECT
	MAX([A].[SERIAL_NUMBER]) AS [SERIAL_NUMBER]
	,[A].[WAVE_PICKING_ID] AS [WAVE_PICKING_ID]
	,MAX([A].[CLIENT_NAME]) AS [CLIENT_NAME]
	,MAX([A].[TASK_TYPE]) AS [TASK_TYPE]
	,MAX([A].[TASK_SUBTYPE]) AS [TASK_SUBTYPE]
	,MAX([A].[TASK_COMMENTS]) AS [TASK_COMMENTS]
	,MAX([A].[REGIMEN]) AS [REGIMEN]
	,MAX([A].[IS_PAUSED]) AS [IS_PAUSED]
	,MAX([A].[ASSIGNED_DATE]) AS [ASSIGNED_DATE]
	,MAX([A].[ACCEPTED_DATE]) AS [ACCEPTED_DATE]
	,MAX([A].[COMPLETED_DATE]) AS [PICKING_FINISHED_DATE]
	,MIN([A].[IS_CANCELED]) AS [IS_CANCELED]
	,MAX([A].[QUANTITY_PENDING]) AS [QUANTITY_PENDING]
	,MAX([A].[QUANTITY_ASSIGNED]) AS [QUANTITY_ASSIGNED]
	,MAX([PHS].[NUMERO_ORDEN]) AS [NUMERO_ORDEN_SOURCE]
	,MAX([A].[ORDER_NUMBER]) AS [NUMERO_ORDEN_TARGET]
	,NULL AS [CODIGO_POLIZA_SOURCE]
	,MAX([A].[CODIGO_POLIZA_TARGET]) AS [CODIGO_POLIZA_TARGET]
	,CASE MIN([A].[IS_COMPLETED])
		WHEN 0 THEN CASE MAX([A].[IS_ACCEPTED])
						WHEN 0 THEN 'INCOMPLETA'
						WHEN 1 THEN 'ACEPTADA'
						ELSE 'INCOMPLETA'
					END
		ELSE 'COMPLETA'
		END AS [IS_COMPLETED]
	,MAX([A].[IS_DISCRETIONARY]) AS [IS_DISCRETIONARY]
	,CASE MAX([A].[IS_DISCRETIONARY])
		WHEN 1 THEN 'Discrecional'
		ELSE 'Dirigido'
		END AS [TYPE_PICKING]
	,MAX([A].[IS_ACCEPTED]) AS [IS_ACCEPTED]
	,CASE MAX([A].[IS_FROM_ERP])
		WHEN 1 THEN 'Si'
		WHEN 0 THEN 'No'
		ELSE 'No'
		END AS [IS_FROM_ERP]
	,CASE MAX([A].[IS_FROM_SONDA])
		WHEN 1 THEN 'Si'
		WHEN 0 THEN 'No'
		ELSE 'No'
		END AS [IS_FROM_SONDA]
	,MAX([A].[LOCATION_SPOT_TARGET]) AS [LOCATION_SPOT_TARGET]
	,MAX([A].[WAREHOUSE_SOURCE]) AS [WAREHOUSE_SOURCE]
	,CASE	WHEN MAX([A].[TASK_ASSIGNEDTO]) = ''
					OR MIN([A].[TASK_ASSIGNEDTO]) = ''
			THEN 'Sin Asignación'
			WHEN MAX([A].[TASK_ASSIGNEDTO]) <> MIN([A].[TASK_ASSIGNEDTO])
			THEN 'Multiple'
			WHEN MAX([A].[TASK_ASSIGNEDTO]) = MIN([A].[TASK_ASSIGNEDTO])
			THEN MAX([A].[TASK_ASSIGNEDTO])
		END AS [TASK_ASSIGNEDTO]
	,MAX([A].[PRIORITY]) AS [PRIORITY]
	,MAX([A].[TASK_OWNER]) AS [CREATE_BY]
	,MAX([A].[PROJECT_ID]) AS [PROJECT_ID]
	,MAX([A].[PROJECT_CODE]) AS [PROJECT_CODE]
	,MAX([A].[PROJECT_NAME]) AS [PROJECT_NAME]
	,MAX([A].[PROJECT_SHORT_NAME]) AS [PROJECT_SHORT_NAME]
	,MAX([A].[ORDER_NUMBER]) AS [ORDER_NUMBER]
FROM
	[wms].[OP_WMS_TASK_LIST] [A]
LEFT OUTER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PHS] ON [PHS].[DOC_ID] = [A].[DOC_ID_SOURCE]
											AND [PHS].[WAREHOUSE_REGIMEN] = [A].[REGIMEN]
LEFT OUTER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PHT] ON [PHT].[DOC_ID] = [A].[DOC_ID_TARGET]
											AND [PHT].[WAREHOUSE_REGIMEN] = [A].[REGIMEN]
WHERE
	[A].[TASK_TYPE] = 'TAREA_PICKING'
GROUP BY
	[A].[WAVE_PICKING_ID];