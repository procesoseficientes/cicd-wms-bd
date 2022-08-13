-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	17/Jul/2019 G-Force@Dublin
-- Historia:            Product Backlog Item 30120: Demanda de despacho por proyecto
-- Description:			Retorna lo el inventario de un proyecto

-- Autor:				marvin.solares
-- Fecha de Creacion: 	8/8/2019 G-Force@Dublin
--Bug 31239: No crea la demanda de despacho por proyecto
-- Description:			se excluye del query informacion inconsistente de estados

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [wms].[OP_WMS_FN_GET_INVENTORY_FROM_PROYECT](@PROYECT_ID)
					
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_INVENTORY_FROM_PROYECT] (
		@PROYECT_ID UNIQUEIDENTIFIER
	)
RETURNS TABLE
	AS
  RETURN
	(SELECT
			[IRP].[ID]
			,[IRP].[PROJECT_ID]
			,[P].[OPPORTUNITY_NAME]
			,[IRP].[PK_LINE]
			,[IRP].[LICENSE_ID]
			,[IRP].[MATERIAL_ID]
			,[IRP].[MATERIAL_NAME]
			,([IL].[QTY] - ISNULL([CI].[COMMITED_QTY], 0)) AS [QTY_LICENSE]
			,[IRP].[QTY_RESERVED]
			,[IRP].[QTY_DISPATCHED]
			,[IRP].[RESERVED_PICKING]
			,[IRP].[TONE]
			,[IRP].[CALIBER]
			,[IRP].[BATCH]
			,[IRP].[DATE_EXPIRATION]
			,[SML].[STATUS_CODE]
			,[L].[CURRENT_WAREHOUSE]
			,[L].[CURRENT_LOCATION]
			,[SS].[ALLOW_FAST_PICKING]
			,[L].[CODIGO_POLIZA]
			,[L].[CREATED_DATE] AS [FECHA_DOCUMENTO]
			,[IL].[BARCODE_ID]
			,[M].[ALTERNATE_BARCODE]
			,[IRP].[CLIENT_CODE]
			,[IRP].[CLIENT_NAME]
			,[SML].[STATUS_NAME]
			,[SML].[COLOR]
		FROM
			[wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT] [IRP]
		INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON (
											[IRP].[LICENSE_ID] = [IL].[LICENSE_ID]
											AND [IRP].[MATERIAL_ID] = [IL].[MATERIAL_ID]
											AND [IRP].[PROJECT_ID] = [IL].[PROJECT_ID]
											)
		INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON ([IL].[LICENSE_ID] = [L].[LICENSE_ID])
		INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [SS] ON ([L].[CURRENT_LOCATION] = [SS].[LOCATION_SPOT])
		INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([IL].[MATERIAL_ID] = [M].[MATERIAL_ID])
		INNER JOIN [wms].[OP_WMS_PROJECT] [P] ON ([IRP].[PROJECT_ID] = [P].[ID])
		INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SML] ON (
											[IL].[STATUS_ID] = [SML].[STATUS_ID]
											AND [SML].[STATUS_CODE] <> ''
											AND [SML].[STATUS_CODE] IS NOT NULL
											)
		LEFT OUTER JOIN [wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [CI] ON (
											[IRP].[LICENSE_ID] = [CI].[LICENCE_ID]
											AND [IRP].[MATERIAL_ID] = [CI].[MATERIAL_ID]
											)
		WHERE
			[IRP].[PROJECT_ID] = @PROYECT_ID);