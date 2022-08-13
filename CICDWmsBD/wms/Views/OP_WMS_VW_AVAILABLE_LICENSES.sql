-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	19-Jul-2019 @ G-Force-Team Sprint Dublin
-- Description:			vista que obtiene el inventario, excluye lo comprometido y el inventario asignado a proyectos

-- Autor:				marvin.solares
-- Fecha de Creacion: 	31-Julio-2019 GForce@Dublin
-- Description:			se agrega el filtro del regimen para que no muestre licencias de fiscal

-- Autor:				marvin.solares
-- Fecha de Creacion: 	8/8/2019 G-Force@Dublin
--Bug 31239: No crea la demanda de despacho por proyecto
-- Description:			se excluye del query informacion inconsistente de estados

/*
-- Ejemplo de Ejecucion:			
  SELECT * FROM [wms].[OP_WMS_VW_AVAILABLE_LICENSES]
*/
-- =============================================
CREATE VIEW [wms].[OP_WMS_VW_AVAILABLE_LICENSES]
AS
SELECT
	[IL].[PK_LINE]
	,[IL].[LICENSE_ID]
	,[IL].[MATERIAL_ID]
	,[IL].[MATERIAL_NAME]
	,[IL].[QTY]
	,[IL].[QTY] - ISNULL([CIL].[COMMITED_QTY], 0) AS [QTY_AVAILABLE]
	,ISNULL([CIL].[COMMITED_QTY], 0) AS [QTY_RESERVED]
	,[SML].[STATUS_ID]
	,[SML].[STATUS_CODE]
	,[SML].[STATUS_NAME]
	,[IL].[BATCH]
	,[IL].[DATE_EXPIRATION]
	,[IL].[VIN]
	,[TCM].[TONE]
	,[TCM].[CALIBER]
FROM
	[wms].[OP_WMS_INV_X_LICENSE] [IL]
INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON ([IL].[LICENSE_ID] = [L].[LICENSE_ID])
INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SML] ON ([IL].[STATUS_ID] = [SML].[STATUS_ID])
INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [SS] ON ([L].[CURRENT_LOCATION] = [SS].[LOCATION_SPOT])
LEFT JOIN [wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [CIL] ON ([IL].[LICENSE_ID] = [CIL].[LICENCE_ID])
LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM] ON ([IL].[TONE_AND_CALIBER_ID] = [TCM].[TONE_AND_CALIBER_ID])
WHERE
	[SS].[ALLOW_PICKING] = 1
	AND ([IL].[QTY] - ISNULL([CIL].[COMMITED_QTY], 0)) > 0
	AND [IL].[IS_BLOCKED] = 0
	AND [IL].[LOCKED_BY_INTERFACES] = 0
	AND [SML].[BLOCKS_INVENTORY] = 0
	AND [SML].[STATUS_CODE] IS NOT NULL
	AND [SML].[STATUS_CODE] <> ''
	AND [IL].[PROJECT_ID] IS NULL
	AND [L].[REGIMEN] = 'GENERAL';