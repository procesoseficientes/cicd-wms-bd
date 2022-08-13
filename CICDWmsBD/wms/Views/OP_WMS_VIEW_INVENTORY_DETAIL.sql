

-- =============================================
-- Modificación:	        rudi.garcia
-- Fecha de Creacion: 	2017-03-13 @ Team ERGON - Sprint VERGON 
-- Description:	        Se agrego el campo [IS_EXTERNAL_INVENTORY]

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-09-08 @ Team REBORN - Sprint 
-- Description:	   Se agrego INNER JOIN a [OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE]

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-09-16 @ Team REBORN - Sprint 
-- Description:	   Se agrega tono y calibre

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20190725 GForce@Dublin
-- Descripcion:			Se agrega la informacion del proyecto en el que la licencia esta asignada

/*
-- Ejemplo de Ejecucion:
			select count(*) from [wms].OP_WMS_VIEW_INVENTORY_DETAIL
*/
-- =============================================

CREATE VIEW [wms].[OP_WMS_VIEW_INVENTORY_DETAIL]
AS
SELECT
	(SELECT TOP 1
			[CLIENT_NAME]
		FROM
			[wms].[OP_WMS_VIEW_CLIENTS]
		WHERE
			([CLIENT_CODE] = [B].[CLIENT_OWNER]
    COLLATE DATABASE_DEFAULT)) AS [CLIENT_NAME]
	,ISNULL((SELECT TOP (1)
					[NUMERO_ORDEN]
				FROM
					[wms].[OP_WMS_POLIZA_HEADER] AS [C]
				WHERE
					([CODIGO_POLIZA] = [B].[CODIGO_POLIZA])),
			'0') AS [NUMERO_ORDEN]
	,ISNULL((SELECT TOP (1)
					[NUMERO_DUA]
				FROM
					[wms].[OP_WMS_POLIZA_HEADER] AS [C]
				WHERE
					([CODIGO_POLIZA] = [B].[CODIGO_POLIZA])),
			'0') AS [NUMERO_DUA]
	,ISNULL((SELECT TOP (1)
					CONVERT(VARCHAR(20), [FECHA_LLEGADA]) AS [Expr1]
				FROM
					[wms].[OP_WMS_POLIZA_HEADER] AS [C]
				WHERE
					([CODIGO_POLIZA] = [B].[CODIGO_POLIZA])),
			'0') AS [FECHA_LLEGADA]
	,[A].[LICENSE_ID]
	,[A].[TERMS_OF_TRADE]
	,[C].[MATERIAL_ID]
	,[C].[MATERIAL_CLASS]
	,[C].[BARCODE_ID]
	,ISNULL([C].[VOLUME_FACTOR], 0) AS [VOLUME_FACTOR]
	,[A].[BARCODE_ID] AS [ALTERNATE_BARCODE]
	,[A].[MATERIAL_NAME]
	,[A].[QTY]
	,[B].[CLIENT_OWNER]
	,[B].[REGIMEN]
	,[B].[CODIGO_POLIZA]
	,[B].[CURRENT_LOCATION]
	,ISNULL([C].[VOLUME_FACTOR], 0) AS [VOLUMEN]
	,ISNULL([C].[VOLUME_FACTOR], 0) * [A].[QTY] AS [TOTAL_VOLUMEN]
	,[B].[LAST_UPDATED_BY]
	,[A].[SERIAL_NUMBER]
	,[A].[DATE_EXPIRATION]
	,[A].[BATCH]
	,[B].[CURRENT_WAREHOUSE]
  --Cambio
	,(SELECT TOP (1)
			[DOC_ID]
		FROM
			[wms].[OP_WMS_POLIZA_HEADER] AS [Z]
		WHERE
			([Z].[CODIGO_POLIZA] = [B].[CODIGO_POLIZA])) AS [DOC_ID]
	,[B].[USED_MT2]
	,[A].[VIN]
	,CASE [B].[CODIGO_POLIZA_RECTIFICACION]
		WHEN NULL THEN 'SI'
		ELSE 'NO'
		END AS [PENDIENTE_RECTIFICACION]
	,[RDH].[CODE_SUPPLIER]
	,[RDH].[NAME_SUPPLIER]
	,[SH].[ZONE]
	,[A].[IS_EXTERNAL_INVENTORY]
	,[S].[STATUS_NAME]
	,CASE [S].[BLOCKS_INVENTORY]
		WHEN 1 THEN 'Si'
		WHEN 0 THEN 'No'
		ELSE 'No'
		END [BLOCKS_INVENTORY]
	,[S].[COLOR]
	,[TC].[TONE]
	,[TC].[CALIBER]
	,[P].[OPPORTUNITY_CODE] [PROJECT_CODE]
	,[P].[SHORT_NAME] [PROJECT_SHORT_NAME]
FROM
	[wms].[OP_WMS_INV_X_LICENSE] AS [A]
INNER JOIN [wms].[OP_WMS_LICENSES] AS [B] ON [A].[LICENSE_ID] = [B].[LICENSE_ID]
INNER JOIN [wms].[OP_WMS_MATERIALS] AS [C] ON [A].[MATERIAL_ID] = [C].[MATERIAL_ID]
INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [S] ON (
											[A].[STATUS_ID] = [S].[STATUS_ID]
											AND [S].[STATUS_ID] > 0
											)
LEFT JOIN [wms].[OP_WMS_TASK_LIST] [TL] ON (
											[TL].[CODIGO_POLIZA_SOURCE] = [B].[CODIGO_POLIZA]
											AND [TL].[TASK_TYPE] = 'TAREA_RECEPCION'
											)
LEFT JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH] ON (
											[RDH].[TASK_ID] = [TL].[SERIAL_NUMBER]
											AND [RDH].[TASK_ID] > 0
											)
LEFT JOIN [wms].[OP_WMS_SHELF_SPOTS] [SH] ON (
											[B].[CURRENT_LOCATION] = [SH].[LOCATION_SPOT]
											AND [SH].[LOCATION_SPOT] > ''
											)
LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TC] ON (
											[A].[TONE_AND_CALIBER_ID] = [TC].[TONE_AND_CALIBER_ID]
											AND [TC].[TONE_AND_CALIBER_ID] > 0
											)
LEFT JOIN [wms].[OP_WMS_PROJECT] [P] ON [A].[PROJECT_ID] = [P].[ID];										;