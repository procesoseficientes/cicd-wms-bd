-- =============================================
-- Author:	rudi.garcia
-- Fecha de Creacion: 	11-Apr-2018 @Team G-Force - Sprint Búho
-- Description:	 Sp que obtiene las ubicaciones de las tareas .

/*
-- Ejemplo de Ejecucion:
	 EXEC [wms].[OP_WMS_SP_GET_MATERIAL_TASK_BY_LOGIN] @LOGIN_ID = 'ACAMACHO', @TASK_TYPE = 'TAREA_REUBICACION'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_MATERIAL_TASK_BY_LOGIN] (@LOGIN_ID VARCHAR(25)
, @TASK_TYPE VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [TL].[LOCATION_SPOT_SOURCE]
   ,[TL].[MATERIAL_ID]
   ,[TL].[MATERIAL_NAME]
   ,SUM([TL].[QUANTITY_PENDING]) AS [QUANTITY_PENDING]
  FROM [wms].[OP_WMS_TASK_LIST] [TL]
  LEFT JOIN [wms].[OP_WMS_CONFIGURATIONS] [C]
    ON (
    [C].[PARAM_GROUP] = 'PRIORITY'
    AND [C].[PARAM_TYPE] = 'SISTEMA'
    AND [C].[NUMERIC_VALUE] = [TL].[PRIORITY]
    )
  WHERE TASK_ASSIGNEDTO = @LOGIN_ID
  AND IS_COMPLETED <> 1
  AND IS_PAUSED = 0
  AND IS_CANCELED = 0
  AND [TASK_TYPE] = @TASK_TYPE
  GROUP BY [TL].[LOCATION_SPOT_SOURCE]
          ,[TL].[MATERIAL_ID]
          ,[TL].[MATERIAL_NAME]
END