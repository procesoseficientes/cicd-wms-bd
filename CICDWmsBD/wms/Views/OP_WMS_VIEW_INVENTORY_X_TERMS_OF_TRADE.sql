


-- =============================================
-- Modificiacion:	        hector.gonzalez
-- Fecha de Creacion: 	2017-04-18 @ Team ERGON - Sprint EPONA
-- Description:	        se agrego LICENCE_ID

-- Modificiacion:	        hector.gonzalez
-- Fecha de Creacion: 	2017-05-22 @ Team ERGON - Sprint Sheik
-- Description:	        Se agrego left join a [OP_WMS_MATERIAL_X_SERIAL_NUMBER] y se agrego SERIAL_NUMBER, BATCH Y DATE_EXPIRATION

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-09-05 @ Team REBORN - Sprint 
-- Description:	   Se agrego INNER JOIN a [OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE]

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-09-16 @ Team REBORN - Sprint 
-- Description:	   Se agrega TONE y CALIBER

/*
-- Ejemplo de Ejecucion:
			SELECT COUNT(*) FROM [wms].OP_WMS_VIEW_INVENTORY_X_TERMS_OF_TRADE  
*/
-- =============================================

CREATE VIEW [wms].[OP_WMS_VIEW_INVENTORY_X_TERMS_OF_TRADE]
AS
SELECT
	[A].[TERMS_OF_TRADE] + '-' + [D].[ACUERDO_COMERCIAL_NOMBRE] AS [TERMS_OF_TRADE]
	,[B].[CURRENT_WAREHOUSE]
	,[B].[CLIENT_OWNER]
	,(SELECT
			[CLIENT_NAME]
		FROM
			[wms].[OP_WMS_VIEW_CLIENTS]
		WHERE
			([CLIENT_CODE] = [B].[CLIENT_OWNER] COLLATE DATABASE_DEFAULT)) AS [CLIENT_NAME]
	,[C].[MATERIAL_ID]
	,[C].[BARCODE_ID]
	,[A].[BARCODE_ID] AS [ALTERNATE_BARCODE]
	,[A].[MATERIAL_NAME]
	,[A].[QTY]
	,ISNULL([C].[VOLUME_FACTOR], 0) AS [VOLUMEN]
	,ISNULL([C].[VOLUME_FACTOR], 0) * [A].[QTY] AS [TOTAL_VOLUMEN]
	,[A].[LICENSE_ID]
	,[SN].[SERIAL] AS [SERIAL_NUMBER]
	,CASE [A].[HANDLE_SERIAL]
		WHEN 1 THEN [SN].[DATE_EXPIRATION]
		WHEN 0 THEN [A].[DATE_EXPIRATION]
		WHEN NULL THEN [A].[DATE_EXPIRATION]
		END AS [DATE_EXPIRATION]
	,CASE [A].[HANDLE_SERIAL]
		WHEN 1 THEN [SN].[BATCH]
		WHEN 0 THEN [A].[BATCH]
		WHEN NULL THEN [A].[BATCH]
		END AS [BATCH]
	,[A].[HANDLE_SERIAL]
	,[S].[STATUS_NAME]
	,CASE [S].[BLOCKS_INVENTORY]
		WHEN 1 THEN 'Si'
		WHEN 0 THEN 'No'
		ELSE 'No'
		END [BLOCKS_INVENTORY]
	,[S].[COLOR]
	,[TC].[TONE]
	,[TC].[CALIBER]
FROM
	[wms].[OP_WMS_INV_X_LICENSE] AS [A]
INNER JOIN [wms].[OP_WMS_LICENSES] AS [B] ON ([A].[LICENSE_ID] = [B].[LICENSE_ID])
INNER JOIN [wms].[OP_WMS_MATERIALS] AS [C] ON [A].[MATERIAL_ID] = [C].[MATERIAL_ID]
INNER JOIN [wms].[OP_WMS_TARIFICADOR_HEADER] AS [D] ON (
											[A].[TERMS_OF_TRADE] = [D].[ACUERDO_COMERCIAL_ID]
											AND [D].[ACUERDO_COMERCIAL_ID] > 0
											)
INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [S] ON (
											[A].[STATUS_ID] = [S].[STATUS_ID]
											AND [S].[STATUS_ID] > 0
											)
LEFT JOIN [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [SN] ON (
											[A].[LICENSE_ID] = [SN].[LICENSE_ID]
											AND [A].[MATERIAL_ID] = [SN].[MATERIAL_ID]
											AND [SN].[LICENSE_ID] > 0
											AND [SN].[STATUS] > 0
											AND [SN].[MATERIAL_ID] > ''
											)
LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TC] ON (
											[A].[TONE_AND_CALIBER_ID] = [TC].[TONE_AND_CALIBER_ID]
											AND [TC].[TONE_AND_CALIBER_ID] > 0
											)
WHERE
	([A].[QTY] > 0);