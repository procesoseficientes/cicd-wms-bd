
-- =============================================
-- Autor:				        pablo.aguilar
-- Fecha de Creacion: 	2017-06-13 @ TeamErgon@Sheik
-- Description:			    Se modifica el SP  OP_WMS_FUNC_GET_MY_PICKING_LIST_DETAIL_ALMAGEN para que no excluya los pausados. 

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-06-15 ErgonTeam@BreathOfTheWild
-- Description:	 Realizar join con la tabla de materiales para retornar el campo SERIAL_NUMBER_REQUESTS, también retornar IS_DISCRETIONARY de OP_WMS_TASK_LIST


/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [wms].OP_WMS_FUNC_GET_MY_PICKING_LIST_DETAIL_ALMAGEN_IN_PROGRESS('ACAMACHO')
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FUNC_GET_MY_PICKING_LIST_DETAIL_ALMAGEN_IN_PROGRESS] (@pLOGIN_ID VARCHAR(25))
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
   ,[M].[SERIAL_NUMBER_REQUESTS]
   ,CAST(ISNULL([T].[IS_DISCRETIONARY], '0') AS INT) [IS_DISCRETIONARY]
  FROM [wms].[OP_WMS_TASK_LIST] [T]
  INNER JOIN [wms].[OP_WMS_LICENSES] [L]
    ON [T].[LICENSE_ID_SOURCE] = [L].[LICENSE_ID]
  INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [S]
    ON [L].[CURRENT_LOCATION] = [S].[LOCATION_SPOT]
  INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL]
    ON [L].[LICENSE_ID] = [IL].[LICENSE_ID]
    AND [IL].[MATERIAL_ID] = [T].[MATERIAL_ID]
  INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
    ON [M].[MATERIAL_ID] = [T].[MATERIAL_ID]
  WHERE [T].TASK_ASSIGNEDTO = @pLOGIN_ID
  AND [T].[TASK_TYPE] = 'TAREA_PICKING'
  AND [T].[REGIMEN] = 'GENERAL'
  AND [T].[IS_COMPLETED] <> 1
  AND [T].[IS_CANCELED] = 0
  --  AND [T].[IS_PAUSED] = 0
  AND [T].[QUANTITY_PENDING] > 0

  )