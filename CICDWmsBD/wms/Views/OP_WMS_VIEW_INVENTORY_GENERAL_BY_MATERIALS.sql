-- =============================================
-- Autor:					rudi.garcia
-- Fecha de Creacion: 		23-Nov-16 @ A-Team Sprint 5
-- Description:			    Se agrego el campo VIN y se agreo la condicion si maneja carro con el campo IS_CAR


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-04-17 Team ERGON - Sprint ERGON EPONA
-- Description:	 Se agrega el campo de bodega y se modifica la forma en que valida el inventario

-- Modificación:        hector.gonzalez
-- Fecha de Creacion: 	2017-06-16 Team ERGON - Sprint ERGON BreathOfTheWild
-- Description:	        Se agrego columna SERIAL y LEFT JOIN a [OP_WMS_MATERIAL_X_SERIAL_NUMBER]

-- Modificacion 8/31/2017 @ NEXUS-Team Sprint CommandAndConquer
-- rodrigo.gomez
-- Se agrega validacion de inventario bloqueado

-- Modificacion 8/31/2017 @ NEXUS-Team Sprint CommandAndConquer
-- rodrigo.gomez
-- Se agrega validacion de inventario bloqueado

-- Modificacion 28-Nov-2017 @ NEXUS-Team Sprint CommandAndConquer
-- rudi.garcia
-- Se quito las condiciones de que si el producto manejra lotte, sea carro, o numeros de serie. y se agregaron los campos TCM].[TONE] ,[TCM].[CALIBER] ,[li].[CURRENT_LOCATION]

-- Modificacion			henry.rodriguez
-- fecha:				19-Julio-2019 G-Force@Dublin
-- Descripcion:			Se agrego campo de Project_id

/*
-- Ejemplo de Ejecucion:
		SELECT * FROM [wms].OP_WMS_VIEW_INVENTORY_GENERAL_BY_MATERIALS 
*/
-- =============================================
CREATE VIEW [wms].[OP_WMS_VIEW_INVENTORY_GENERAL_BY_MATERIALS]
AS
SELECT
	[li].[LICENSE_ID]
	,[inv].[MATERIAL_ID]
	,[inv].[MATERIAL_NAME]
	,[mt].[CLIENT_OWNER]
	,[mt].[ALTERNATE_BARCODE]
	,[mt].[BARCODE_ID]
	,[inv].[TERMS_OF_TRADE]
	,[cl].[CLIENT_NAME]
	,[inv].[QTY] AS [QTY]
	,ISNULL([CI].[COMMITED_QTY], 0) AS [ON_PICKING]
	,[inv].[QTY] - ISNULL([CI].[COMMITED_QTY], 0) AS [AVAILABLE]
	,[inv].[BATCH]
	,[inv].[DATE_EXPIRATION]
	,[inv].[VIN]
	,[li].[CURRENT_WAREHOUSE]
	,[inv].[HANDLE_SERIAL]
	,[MS].[SERIAL]
	,[MS].[STATUS] AS [SERIE_STATUS]
	,[TCM].[TONE]
	,[TCM].[CALIBER]
	,[li].[CURRENT_LOCATION]
	,[inv].[PROJECT_ID]
FROM
	[wms].[OP_WMS_INV_X_LICENSE] AS [inv]
INNER JOIN [wms].[OP_WMS_MATERIALS] AS [mt] ON [inv].[MATERIAL_ID] = [mt].[MATERIAL_ID]
INNER JOIN [wms].[OP_WMS_LICENSES] AS [li] ON [inv].[LICENSE_ID] = [li].[LICENSE_ID]
INNER JOIN [wms].[OP_WMS_VIEW_CLIENTS] AS [cl] ON [li].[CLIENT_OWNER] = [cl].[CLIENT_CODE] COLLATE DATABASE_DEFAULT
LEFT JOIN [wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [CI] ON [CI].[LICENCE_ID] = [inv].[LICENSE_ID]
											AND [CI].[MATERIAL_ID] = [inv].[MATERIAL_ID]
LEFT JOIN [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [MS] ON [inv].[LICENSE_ID] = [MS].[LICENSE_ID]
											AND [inv].[MATERIAL_ID] = [MS].[MATERIAL_ID]
											AND [MS].[STATUS] > 0
LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM] ON ([TCM].[TONE_AND_CALIBER_ID] = [inv].[TONE_AND_CALIBER_ID])
WHERE
	([li].[REGIMEN] = 'GENERAL')
	AND [inv].[QTY] > 0
	AND [mt].[CLIENT_OWNER] IS NOT NULL;