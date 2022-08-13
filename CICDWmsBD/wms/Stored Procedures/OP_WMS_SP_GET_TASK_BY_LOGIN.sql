-- =============================================
-- Author:	rudi.garcia
-- Fecha de Creacion: 	11-Apr-2018 @Team G-Force - Sprint Búho
-- Description:	 Sp que obtiene las ubicaciones de las tareas.

/*
-- Ejemplo de Ejecucion:
	 EXEC [wms].[OP_WMS_SP_GET_TASK_BY_LOGIN] @LOGIN_ID = 'ACAMACHO', @TASK_TYPE = 'TAREA_REUBICACION'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TASK_BY_LOGIN] (@LOGIN_ID VARCHAR(25)
, @TASK_TYPE VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [TL].[WAVE_PICKING_ID]
   ,[TL].[SERIAL_NUMBER]
   ,[TL].[BARCODE_ID]
   ,[TL].[LOCATION_SPOT_SOURCE]   

   ,[TL].[CODIGO_POLIZA_SOURCE]   
   ,[TL].[LICENSE_ID_SOURCE]
   ,[TL].[QUANTITY_PENDING] AS QTY_AVAILABLE

   ,[TL].[LOCATION_SPOT_TARGET]
   ,[TL].[MATERIAL_ID]
   ,[TL].[TASK_SUBTYPE]   
   
   ,[TL].[CLIENT_NAME]
   ,CASE ([PDH].[IS_CONSOLIDATED])
      WHEN 1 THEN ''
      ELSE ISNULL([PDH].[TYPE_DEMAND_NAME],
        '')
    END AS [TYPE_DEMAND_NAME]
  FROM [wms].[OP_WMS_TASK_LIST] [TL]
  LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
    ON ([PDH].[WAVE_PICKING_ID] = [TL].[WAVE_PICKING_ID])
  LEFT JOIN [wms].[OP_WMS_CONFIGURATIONS] [C]
    ON (
    [C].[PARAM_GROUP] = 'PRIORITY'
    AND [C].[PARAM_TYPE] = 'SISTEMA'
    AND [C].[NUMERIC_VALUE] = [TL].[PRIORITY]
    )
  WHERE [TL].TASK_ASSIGNEDTO = @LOGIN_ID
  AND [TL].IS_COMPLETED <> 1
  AND [TL].IS_PAUSED = 0
  AND [TL].IS_CANCELED = 0
  AND [TL].[TASK_TYPE] = @TASK_TYPE
END