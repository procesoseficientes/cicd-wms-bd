-- =============================================
-- Autor:				juancarlos.escalante
-- Fecha de Creacion: 	30-09-2016
-- Description:			Sp para obtener todas las tareas, una tarea en especifico o las tareas de un operador que estén abiertas


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-01-13 Team ERGON - Sprint ERGON 1
-- Description:	 Se agrega el campo de ubicación y prioridad, y se ordena en base a la prioridad.


-- Modificacion 24-Nov-17 @ Nexus Team Sprint GTA
					-- pablo.aguilar
					-- Se agrega que retorne tipo y subtipo

-- Modificacion 2/12/2018 @ REBORN-Team Sprint Ulrich
					-- rodrigo.gomez
					-- Se agrega codigo y nombre de proveedor

					-- Modificacion 01-Aug-18 @ G_FORCE Team Sprint FOCAMONGE
										-- pablo.aguilar
										-- Se agrega group by por recepciones consolidadas. 
-- Modificacion:		kevin.guerra
-- Fecha de Creacion: 	11-Dic-2019 GForce@Madagascar-SWIFT
-- Description:	        Se agrega el regimen en la consulta.

/*
	Ejemplo Ejecucion: 
		EXEC	[wms].[OP_WMS_SP_GET_RECEPTION_TASK]
			@REGIMEN = 'GENERAL',
				@TASK_ASSIGNEDTO = 'ACAMACHO'
 */
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_RECEPTION_TASK]
	@REGIMEN VARCHAR(50)
	,@SERIAL_NUMBER NUMERIC(18, 0) = NULL
	,@TASK_ASSIGNEDTO VARCHAR(25) = NULL
AS
BEGIN

	SELECT
		MAX([TL].[SERIAL_NUMBER]) AS [TAREA]
		,[TL].[CLIENT_OWNER] AS [CLIENT_CODE]
		,[TL].[CLIENT_NAME] AS [CLIENTE]
		,[PH].[CODIGO_POLIZA] AS [POLIZA]
		,MAX([PH].[NUMERO_ORDEN]) [ORDEN]
		,[TL].[TASK_TYPE] [TIPO]
		,[TL].[LOCATION_SPOT_TARGET]
		,[TL].[TASK_SUBTYPE] [SUBTIPO]
		,[TL].REGIMEN
		,ISNULL([owc].[PARAM_CAPTION], 'Baja') AS [PRIORITY]
		,CASE	WHEN MAX([R].[DOC_NUM]) <> MIN([R].[DOC_NUM])
				THEN 'Consolidada'
				ELSE MAX(CAST([R].[DOC_NUM] AS VARCHAR))
			END [DOCUMENTO_ERP]
		,CASE	WHEN [R].[SOURCE] = 'INVOICE' THEN 1
				ELSE 0
			END [ES_FACTURA]
		,MAX([R].[CODE_SUPPLIER]) [CODE_SUPPLIER]
		,MAX([R].[NAME_SUPPLIER]) [NAME_SUPPLIER]
	FROM
		[wms].[OP_WMS_TASK_LIST] [TL]
	INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH] ON [PH].[DOC_ID] = [TL].[DOC_ID_SOURCE]
	LEFT JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [R] ON [R].[TASK_ID] = [TL].[SERIAL_NUMBER]
	LEFT JOIN [wms].[OP_WMS_CONFIGURATIONS] [owc] ON (
											[TL].[PRIORITY] = [owc].[NUMERIC_VALUE]
											AND [owc].[PARAM_TYPE] = 'SISTEMA'
											AND [owc].[PARAM_GROUP] = 'PRIORITY'
											)
	WHERE
		(
			@TASK_ASSIGNEDTO IS NULL
			OR [TL].[TASK_ASSIGNEDTO] = @TASK_ASSIGNEDTO
		)
		AND (
				@SERIAL_NUMBER IS NULL
				OR [TL].[SERIAL_NUMBER] = @SERIAL_NUMBER
			)
		AND [TL].[TASK_TYPE] = 'TAREA_RECEPCION'
		AND [TL].[IS_COMPLETED] = 0
		AND [TL].[IS_PAUSED] < 1
		AND [TL].[IS_CANCELED] = 0
		AND [TL].[REGIMEN] = @REGIMEN
	GROUP BY
		ISNULL([owc].[PARAM_CAPTION], 'Baja')
		,CASE	WHEN [R].[SOURCE] = 'INVOICE' THEN 1
				ELSE 0
			END
		,[TL].[CLIENT_OWNER]
		,[TL].[CLIENT_NAME]
		,[PH].[CODIGO_POLIZA]
		,[TL].[TASK_TYPE]
		,[TL].[LOCATION_SPOT_TARGET]
		,[TL].[TASK_SUBTYPE]
		,[TL].REGIMEN
		,[TL].[PRIORITY]
		,[TL].[ASSIGNED_DATE]
	ORDER BY
		[TL].[PRIORITY] DESC
		,[TL].[ASSIGNED_DATE] ASC; 

END;