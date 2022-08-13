-- =============================================
-- Autor:				juancarlos.escalante
-- Fecha de Creacion: 	03-10-2016
-- Description:			Vista que obtiene los mismos registros que la vista OP_WMS_VIEW_PICKING_TASK mas los nuevos de recepción

-- Modificacion 02-Nov-16 @ A-Team Sprint 4
-- alberto.ruiz
-- Se ajustaron los campos de COMPLETED_DATE y ACCEPTED_DATE

-- Modificacion 02-Nov-16 @ A-Team Sprint 4
-- rudi.garcia
-- Se quito el grupo CODIGO_POLIZA_SOURCE, SERIAL_NUMBER, para que esto no duplique data.


-- Modificacion 02-Nov-16 @ A-Team Sprint 4
-- hector.gonzalez
-- Se agrego columna IS_FROM_ERP


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-02-03 Team ERGON - Sprint ERGON II
-- Description:	 Se agrego columna IS_FROM_SONDA

-- Modificación: rudi.garcia
-- Fecha de Creacion: 	2017-03-01 Team ERGON - Sprint IV ERGON
-- Description:	 Se agrego columna WAREHOUSE_SOURCE  

-- Modificación: rudi.garcia
-- Fecha de Creacion: 	28-Nov-17 Team ERGON - Sprint IV ERGON
-- Description:	 Se agrego columna [PRIORITY]  

-- Modificación: rudi.garcia
-- Fecha de Creacion: 	12-Jan-2018 Team Reborn - Sprint Ramsey
-- Description:	 Se cambio el Max por el Min en el campo IS_COMPLETED

-- Modificación: rudi.garcia
-- Fecha de Creacion: 	02-Jan-2019 Team G-Force - Sprint Perezoso
-- Description:	 Se agrego el campo de quien creo la tarea.

-- Autor:				rudi.garcia
-- Fecha de Creacion: 	26-Jul-2019 @ G-Force-Team Sprint Dublin
-- Description:			se agrega manejo de proyectos, se agrega orderNumber de la consulta

-- Autor:				henry.rodriguez
-- Fecha:				06-Septiembre-2019 G-Force@Gumarcaj
-- Descripcion:			Se modifica [PHT].[NUMERO_ORDEN] a [PHS].[NUMERO_ORDEN]

-- Autor:				henry.rodriguez
-- Fecha:				06-Diciembre-2019 G-Force@Kioto
-- Descripcion:			Se agrega campo Regimen en group by para mostrar las tareas por regimen fiscal

-- Autor:				Elder Lucas
-- Fecha:				25 de julio de 2022
-- Descripcion:			Se agren campos para manejo de tareas de masterpack

/*
	Ejemplo Ejecucion: 
    SELECT * FROM [wms].[OP_WMS_VIEW_TASK] where wave_picking_id = 4386
 */
-- =============================================
CREATE VIEW [wms].[OP_WMS_VIEW_TASK]
AS
SELECT
	[WAVE_PICKING_ID]
	,[A].[CLIENT_NAME]
	,[A].[CLIENT_OWNER]
	,[TASK_TYPE]
	,[TASK_SUBTYPE]
	,[TASK_ASSIGNEDTO]
	,[TASK_COMMENTS]
	,[A].[REGIMEN]
	,MAX([IS_PAUSED]) AS [IS_PAUSED]
	,MAX([SERIAL_NUMBER]) AS [SERIAL_NUMBER]
	,MAX([ASSIGNED_DATE]) AS [ASSIGNED_DATE]
	,MAX([ACCEPTED_DATE]) AS [ACCEPTED_DATE]
	,MAX([COMPLETED_DATE]) AS [COMPLETED_DATE]
	,MAX([COMPLETED_DATE]) AS [PICKING_FINISHED_DATE]
	,MAX([IS_CANCELED]) AS [IS_CANCELED]
	,MAX([QUANTITY_PENDING]) AS [QUANTITY_PENDING]
	,MAX([QUANTITY_ASSIGNED]) AS [QUANTITY_ASSIGNED]
	,MAX([A].[ORDER_NUMBER]) AS [NUMERO_ORDEN_SOURCE]
	,MAX([PHS].[NUMERO_ORDEN]) AS [NUMERO_ORDEN_TARGET]
	,[MATERIAL_ID]
	,[BARCODE_ID]
	,[MATERIAL_NAME]
	,(CASE MIN([A].[IS_COMPLETED])
		WHEN 0 THEN CASE MAX([A].[IS_ACCEPTED])
						WHEN 0 THEN 'INCOMPLETA'
						WHEN 1 THEN 'ACEPTADA'
      -- ELSE
					END
		ELSE 'COMPLETA'
		END) AS [IS_COMPLETED]
	,NULL AS [CODIGO_POLIZA_SOURCE]--A.CODIGO_POLIZA_SOURCE
	,[A].[CODIGO_POLIZA_TARGET]
	,[A].[IS_DISCRETIONARY]
	,CASE [A].[IS_DISCRETIONARY]
		WHEN 1 THEN 'Discrecional'
		ELSE 'Dirigido'
		END [TYPE_PICKING]
	,[A].[IS_ACCEPTED]
	,CASE [A].[IS_FROM_ERP]
		WHEN 1 THEN 'Si'
		WHEN 0 THEN 'No'
		ELSE 'No'
		END AS [IS_FROM_ERP]
	,CASE [A].[IS_FROM_SONDA]
		WHEN 1 THEN 'Si'
		WHEN 0 THEN 'No'
		ELSE 'No'
		END AS [IS_FROM_SONDA]
	,MAX([A].[LOCATION_SPOT_TARGET]) AS [LOCATION_SPOT_TARGET]
	,MAX([A].[WAREHOUSE_SOURCE]) AS [WAREHOUSE_SOURCE]
	,MAX([A].[PRIORITY]) AS [PRIORITY]
	,MAX([A].[TASK_OWNER]) [CREATE_BY]
	,[A].[PROJECT_ID]
	,[A].[PROJECT_CODE]
	,[A].[PROJECT_NAME]
	,[A].[PROJECT_SHORT_NAME]
	,[A].[ORDER_NUMBER]
FROM
	[wms].[OP_WMS_TASK_LIST] AS [A]
LEFT JOIN [wms].[OP_WMS_POLIZA_HEADER] [PHS] ON [PHS].[DOC_ID] = [A].[DOC_ID_SOURCE]
											AND [PHS].[WAREHOUSE_REGIMEN] = [A].[REGIMEN]
LEFT JOIN [wms].[OP_WMS_POLIZA_HEADER] [PHT] ON [PHT].[DOC_ID] = [A].[DOC_ID_TARGET]
											AND [PHT].[WAREHOUSE_REGIMEN] = [A].[REGIMEN]
GROUP BY
	[WAVE_PICKING_ID]
	,[A].[CLIENT_NAME]
	,[A].[CLIENT_OWNER]
	,[TASK_TYPE]
	,[TASK_SUBTYPE]
	,[TASK_ASSIGNEDTO]
	,[TASK_COMMENTS]
	,[MATERIAL_ID]
	,[BARCODE_ID]
	,[MATERIAL_NAME]
         --,A.CODIGO_POLIZA_SOURCE
	,[A].[CODIGO_POLIZA_TARGET]
	,[A].[IS_DISCRETIONARY]
         --,A.SERIAL_NUMBER
	,[A].[IS_ACCEPTED]
	,[A].[IS_FROM_ERP]
	,[A].[IS_FROM_SONDA]
	,[A].[LOCATION_SPOT_TARGET]
	,[A].[PROJECT_ID]
	,[A].[PROJECT_CODE]
	,[A].[PROJECT_NAME]
	,[A].[PROJECT_SHORT_NAME]
	,[A].[REGIMEN]
	,[A].[COMPLETED_DATE]
	,[A].[ORDER_NUMBER];
GO

