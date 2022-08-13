-- =============================================
-- Autor: pablo.aguilar
-- Fecha de Modificaci[on: 2017-04-28 ErgonTeam@Ganondorf
-- Description:	 Se agrega la zona 

-- Modificacion 24-Nov-17 @ Nexus Team Sprint GTA
					-- pablo.aguilar
					-- Se modifica para que valide si el inventario esta bloqueado. 

/*
-- Ejemplo de Ejecucion:
			SELECT * FROM [wms].[OP_WMS_VIEW_REALLOC_AVAILABLE_GENERAL]
*/
-- =============================================
CREATE VIEW [wms].[OP_WMS_VIEW_REALLOC_AVAILABLE_GENERAL]
AS
SELECT
	[inv].[MATERIAL_ID]
	,[inv].[MATERIAL_NAME]
	,[mt].[CLIENT_OWNER]
	,[mt].[ALTERNATE_BARCODE]
	,[mt].[BARCODE_ID]
	,[inv].[TERMS_OF_TRADE]
	,[cl].[CLIENT_NAME]
	,[li].[CODIGO_POLIZA]
	,[ph].[FECHA_DOCUMENTO]
	,[li].[CURRENT_LOCATION]
	,[li].[CURRENT_WAREHOUSE]
	,[li].[LICENSE_ID]
	,[inv].[QTY] - ISNULL([CI].[COMMITED_QTY], 0) AS [QTY]
	,ISNULL([CI].[COMMITED_QTY], 0) [COMMITED_QTY]
	,[inv].[QTY] [LICENCE_QTY]
	,[mt].[BATCH_REQUESTED]
	,[mt].[IS_CAR]
	,[SH].[ZONE]
FROM
	[wms].[OP_WMS_INV_X_LICENSE] AS [inv]
INNER JOIN [wms].[OP_WMS_MATERIALS] AS [mt] ON [inv].[MATERIAL_ID] = [mt].[MATERIAL_ID]
INNER JOIN [wms].[OP_WMS_LICENSES] AS [li] ON [inv].[LICENSE_ID] = [li].[LICENSE_ID]
INNER JOIN [wms].[OP_WMS_VIEW_CLIENTS] AS [cl] ON [li].[CLIENT_OWNER] = [cl].[CLIENT_CODE] COLLATE DATABASE_DEFAULT
INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] AS [ph] ON UPPER([li].[CODIGO_POLIZA]) = UPPER([ph].[CODIGO_POLIZA])
INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [SH] ON [li].[CURRENT_LOCATION] = [SH].[LOCATION_SPOT]
LEFT JOIN [wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [CI] ON [CI].[LICENCE_ID] = [inv].[LICENSE_ID]
											AND [CI].[MATERIAL_ID] = [inv].[MATERIAL_ID]
INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [owph] ON [li].[CODIGO_POLIZA] = [owph].[CODIGO_POLIZA]
INNER JOIN [wms].[OP_WMS_TARIFICADOR_HEADER] [owth] ON [owph].[ACUERDO_COMERCIAL] = [owth].[ACUERDO_COMERCIAL_ID]
INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE]
	AS [SML] ON [SML].[STATUS_ID] = [inv].[STATUS_ID]
INNER JOIN [wms].[OP_WMS_CONFIGURATIONS] [C] ON (
											[C].[PARAM_TYPE] = 'PRODUCTOS'
											AND [C].[PARAM_GROUP] = 'BLOQUEO_EXPIRACION'
											AND [C].[PARAM_NAME] = 'BLOQUEO_DIAS_PRONTA_EXPIRACION'
											)
WHERE
	([li].[REGIMEN] = 'GENERAL')
	AND GETDATE() BETWEEN [owth].[VALID_FROM]
					AND		[owth].[VALID_TO]
	AND ([li].[CURRENT_LOCATION] IS NOT NULL)
	AND [SH].[ALLOW_REALLOC] = 1
	AND [inv].[QTY] > 0
	AND [inv].[LOCKED_BY_INTERFACES] = 0
	AND [SML].[BLOCKS_INVENTORY] <> 1
	AND [inv].[LOCKED_BY_INTERFACES] <> 1
	AND (
			[mt].[BATCH_REQUESTED] = 0
			OR GETDATE() < DATEADD(DAY,
									[C].[NUMERIC_VALUE] * -1,
									[inv].[DATE_EXPIRATION])
		);