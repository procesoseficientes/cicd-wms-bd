-- =============================================
-- Autor:				        rudi.garcia
-- Fecha de Creacion: 	2017-03-2 @ TeamErgon Sprint IV Ergon
-- Description:			    SP que obtiene el detalle de los picking.


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-04-12 Team ERGON - Sprint ERGON EPONA
-- Description:	 Se modifica función para que no busque en subquerys la información de la ubicación y la licencia.
--                se cambia la forma que calculaba el quantity pending y el quantity assign


/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [wms].OP_WMS_FUNC_GET_MY_PICKING_LIST_DETAIL_ALMGEN('ACAMACHO')
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FUNC_GET_MY_PICKING_LIST_DETAIL_ALMGEN] (@pLOGIN_ID VARCHAR(25))
RETURNS TABLE
AS
  RETURN
  (

  SELECT
    [T].[WAVE_PICKING_ID]
   ,[T].[CODIGO_POLIZA_SOURCE]
   ,[T].[CODIGO_POLIZA_TARGET]
   ,[T].[LICENSE_ID_SOURCE]
   ,[S].[LOCATION_SPOT] [LOCATION_SPOT_SOURCE]
   ,[IL].[QTY] QTY_AVAILABLE
   ,[T].[SERIAL_NUMBER]
   ,[T].[WAREHOUSE_SOURCE]
   ,[T].[REGIMEN]
   ,[T].[MATERIAL_ID]
   ,[T].[BARCODE_ID]
   ,[T].[MATERIAL_NAME]
   ,[T].[MATERIAL_SHORT_NAME]
   ,[T].[ALTERNATE_BARCODE]
   ,[T].[QUANTITY_PENDING] [QUANTITY_PENDING]
   ,[T].[QUANTITY_ASSIGNED] QUANTITY_ASSIGNED
   ,[S].[SPOT_TYPE] [TIPO]
   ,[L].[USED_MT2] [MT2AVAILABLE]
   ,[T].[LOCATION_SPOT_TARGET]
  FROM [wms].[OP_WMS_TASK_LIST] [T]
  INNER JOIN [wms].[OP_WMS_LICENSES] [L]
    ON [T].[LICENSE_ID_SOURCE] = [L].[LICENSE_ID]
  INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [S]
    ON [L].[CURRENT_LOCATION] = [S].[LOCATION_SPOT]
  INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL]
    ON [L].[LICENSE_ID] = [IL].[LICENSE_ID]
    AND [IL].[MATERIAL_ID] = [T].[MATERIAL_ID]
  WHERE [T].TASK_ASSIGNEDTO = @pLOGIN_ID
  AND [T].[TASK_TYPE] = 'TAREA_PICKING'
  AND [T].[REGIMEN] = 'GENERAL'
  AND [T].[IS_COMPLETED] <> 1
  AND [T].[IS_CANCELED] = 0
  AND [T].[IS_PAUSED] = 0
  AND [T].[QUANTITY_PENDING] > 0

  )