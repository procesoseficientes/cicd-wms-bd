-- =============================================
-- Author:	rudi.garcia
-- Fecha de Creacion: 	11-Apr-2018 @Team G-Force - Sprint Búho
-- Description:	 Sp que obtiene las ubicaciones de las tareas .

/*
-- Ejemplo de Ejecucion:
	 EXEC [wms].[OP_WMS_SP_GET_LOCATION_TASK_BY_LOGIN] @LOGIN_ID = 'ACAMACHO', @TASK_TYPE = 'TAREA_REUBICACION'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_LOCATION_TASK_BY_LOGIN] (@LOGIN_ID VARCHAR(25)
, @TASK_TYPE VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [TL].[LOCATION_SPOT_SOURCE]
   ,[TL].[PRIORITY]
   ,[C].[PARAM_CAPTION] AS [PRIORITY_DESCRIPTION]
  FROM [wms].[OP_WMS_TASK_LIST] [TL]
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
  GROUP BY [TL].[LOCATION_SPOT_SOURCE]
          ,[TL].[PRIORITY]
          ,[C].[PARAM_CAPTION]
  ORDER BY [TL].[PRIORITY] DESC
END