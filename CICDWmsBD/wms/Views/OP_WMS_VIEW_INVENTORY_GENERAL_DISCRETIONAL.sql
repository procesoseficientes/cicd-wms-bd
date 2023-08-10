
-- =============================================
-- Autor:					rudi.garcia
-- Fecha de Creacion: 		23-Nov-16 @ A-Team Sprint 5
-- Description:			    Se agrego el campo IS_CAR

-- Modificacion:	        hector.gonzalez
-- Fecha de Creacion: 		09-Ene-17 @ A-Team Sprint Balder
-- Description:			      Se agregaron inner join a las tablas OP_WMS_POLIZA_HEADER y OP_WMS_TARIFICADOR_HEADER 
--                        y where que valida si el acuerdo comercial esta caducado o no

-- Modificacion:	        rudi.garcia
-- Fecha de Creacion: 		28-03-17 @ Team-Ergon Sprint Hyper
-- Description:			      Se agrego el campo de bodega para su agrupacion


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-04-17 Team ERGON - Sprint EPONA
-- Description:	 Se elimina el group by por acuerdo comercial.

-- Modificación:        hector.gonzalez
-- Fecha de Creacion: 	2017-06-16 Team ERGON - Sprint BreathOfTheWild
-- Description:	        se agrega [HANDLE_SERIAL]

-- Modificacion 9/7/2017 @ Reborn-Team Sprint Collin
					-- diego.as
					-- Se agrega la columna JOIN a la tabla OP_WMS_INV_X_LICENSE par no tomar en cuenta el inventario bloqueado por estado

-- Modificacion 19/9/2017 @ Reborn-Team Sprint Collin
					-- rudi.garcia
					-- Se agrego la condicion "[LOCKED_BY_INTERFACES] <> 1"

-- Autor:				rudi.garcia
-- Fecha de Creacion: 	26-Jul-2019 @ G-Force-Team Sprint Dublin
-- Description:			se agrega validacion de proyecto en el where

-- Autor:				Alex Carrillo
-- Fecha de Creacion: 	19-01-2022 
-- Description:			se creo vista a partir de la OP_WMS_VIEW_INVENTORY_GENERAL unicamente modificando que pueda ver productos vencidos o en mal estado por picking discrecional

/*
-- Ejemplo de Ejecucion:
		SELECT * FROM [wms].OP_WMS_VIEW_INVENTORY_GENERAL_DISCRETIONAL
*/
-- =============================================
CREATE VIEW [wms].[OP_WMS_VIEW_INVENTORY_GENERAL_DISCRETIONAL]
AS
SELECT
	[inv].[MATERIAL_ID]
	,MAX([inv].[MATERIAL_NAME]) [MATERIAL_NAME]
	,[mt].[CLIENT_OWNER]
	,[mt].[ALTERNATE_BARCODE]
	,[mt].[BARCODE_ID]
	,[cl].[CLIENT_NAME]
	,SUM([inv].[QTY]) AS [QTY]
	,SUM(ISNULL([CI].[COMMITED_QTY], 0)) AS [ON_PICKING]
	,SUM([inv].[QTY]) - SUM(ISNULL([CI].[COMMITED_QTY], 0)) AS [AVAILABLE]
	,[mt].[BATCH_REQUESTED]
	,[mt].[IS_CAR]
	,[li].[CURRENT_WAREHOUSE]
	,[mt].[SERIAL_NUMBER_REQUESTS]
FROM
	[wms].[OP_WMS_INV_X_LICENSE] AS [inv]
INNER JOIN [wms].[OP_WMS_MATERIALS] AS [mt] ON [inv].[MATERIAL_ID] = [mt].[MATERIAL_ID]
INNER JOIN [wms].[OP_WMS_LICENSES] AS [li] ON [inv].[LICENSE_ID] = [li].[LICENSE_ID]
INNER JOIN [wms].[OP_WMS_VIEW_CLIENTS] AS [cl] ON [li].[CLIENT_OWNER] = [cl].[CLIENT_CODE] COLLATE DATABASE_DEFAULT
LEFT JOIN [wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [CI] ON [CI].[LICENCE_ID] = [inv].[LICENSE_ID]
											AND [CI].[MATERIAL_ID] = [inv].[MATERIAL_ID]
											AND [li].[CLIENT_OWNER] = [CI].[CLIENT_OWNER]
INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [owph] ON [li].[CODIGO_POLIZA] = [owph].[CODIGO_POLIZA]
INNER JOIN [wms].[OP_WMS_TARIFICADOR_HEADER] [owth] ON [owph].[ACUERDO_COMERCIAL] = [owth].[ACUERDO_COMERCIAL_ID]
INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SML] ON [SML].[STATUS_ID] = [inv].[STATUS_ID]
WHERE
	([li].[REGIMEN] = 'GENERAL')
	AND GETDATE() BETWEEN [owth].[VALID_FROM]
					AND		[owth].[VALID_TO]
	--AND [SML].[BLOCKS_INVENTORY] <> 1
	AND [inv].[LOCKED_BY_INTERFACES] <> 1
GROUP BY
	[inv].[MATERIAL_ID]
	,[mt].[CLIENT_OWNER]
	,[mt].[ALTERNATE_BARCODE]
	,[mt].[BARCODE_ID]
	,[cl].[CLIENT_NAME]
	,[mt].[BATCH_REQUESTED]
	,[mt].[IS_CAR]
	,[li].[CURRENT_WAREHOUSE]
	,[mt].[SERIAL_NUMBER_REQUESTS]
	,[inv].[STATUS_ID]
	,[inv].[PROJECT_ID]
	,[SML].[STATUS_NAME];