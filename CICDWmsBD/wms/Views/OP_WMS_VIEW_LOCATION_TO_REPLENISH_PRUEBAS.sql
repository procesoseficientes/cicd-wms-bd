﻿
-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-05-02 @ Team ERGON - Sprint Ganondof
-- Description:	 Se crea vista que obtiene las ubicaciones que necesitan reabastecimiento. 

-- Autor:	        marvin.solares
-- Fecha de Creacion: 	20181010 GForce@Langosta
-- Description: Se modifica para que no tome en cuenta si el inventario esta bloqueado por interfaces

/*
-- Ejemplo de Ejecucion:
			SELECT * FROM [wms].OP_WMS_VIEW_LOCATION_TO_REPLENISH
*/
-- =============================================
CREATE VIEW [wms].[OP_WMS_VIEW_LOCATION_TO_REPLENISH_PRUEBAS]
AS
SELECT
	[MS].[LOCATION_SPOT]
	,[MS].[MATERIAL_ID]
	,MAX([MS].[MAX_QUANTITY]) - SUM(ISNULL([IL].[QTY], 0)) [QTY_TO_REPLENISH]
	,[MS].[MIN_QUANTITY] [MIN_QUANTITY]
	,[MS].[MAX_QUANTITY] [MAX_QUANTITY]
	,[S].[ZONE]
	,[Z].[RECEIVE_EXPLODED_MATERIALS]
	,[S].[WAREHOUSE_PARENT]
	,SUM(ISNULL([IL].[QTY], 0)) [AVAILABLE]
FROM
	 [wms].[OP_WMS_MATERIALS_JOIN_SPOTS] [MS]
INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [S] ON [MS].[LOCATION_SPOT] = [S].[LOCATION_SPOT]
INNER JOIN [wms].[OP_WMS_ZONE] [Z] ON [Z].[ZONE] = [S].[ZONE]
LEFT JOIN [wms].[OP_WMS_LICENSES] [L] ON [L].[CURRENT_LOCATION] = [MS].[LOCATION_SPOT]
LEFT JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON [L].[LICENSE_ID] = [IL].[LICENSE_ID]
											AND [IL].[MATERIAL_ID] = [MS].[MATERIAL_ID]
											AND [IL].[LOCKED_BY_INTERFACES] = 0
LEFT JOIN [wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [CI] ON [L].[LICENSE_ID] = [CI].[LICENCE_ID]
											AND [CI].[MATERIAL_ID] = [MS].[MATERIAL_ID]
LEFT JOIN [wms].[OP_WMS_TASK_LIST] [TL] ON ([TL].[IS_COMPLETED] <> 1
											AND [TL].[IS_PAUSED] <> 3
											AND [TL].[CANCELED_DATETIME] IS NULL
											AND ([MS].[MATERIAL_ID] = [TL].[MATERIAL_ID] OR [MS].[MATERIAL_ID] = [TL].[REPLENISH_MATERIAL_ID_TARGET])
											AND [TL].[LOCATION_SPOT_TARGET] = [MS].[LOCATION_SPOT]
											AND [TL].[TASK_TYPE] = 'TAREA_REUBICACION'
											AND ([TL].[TASK_SUBTYPE] = 'REUBICACION_LP' OR [TL].[TASK_SUBTYPE] = 'REUBICACION_BUFFER'))  
WHERE
[TL].[SERIAL_NUMBER] IS NULL 
GROUP BY
	[MS].[LOCATION_SPOT]
	,[MS].[MATERIAL_ID]
	,[MS].[MAX_QUANTITY]
	,[MS].[MIN_QUANTITY]
	,[S].[ZONE]
	,[Z].[RECEIVE_EXPLODED_MATERIALS]
	,[S].[WAREHOUSE_PARENT]
HAVING
	[MS].[MIN_QUANTITY] > SUM(ISNULL([IL].[QTY], 0));
