-- =============================================
-- Autor:				        rudi.garcia
-- Fecha de Creacion: 	2017-03-2 @ TeamErgon Sprint IV Ergon
-- Description:			    SP que obtiene las tareas pendientes de operador.

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_TASK_PENDING]
					@WAVE_PICKING_ID = 4403					
          ,@LOGIN = 'ACAMACHO'
*/
-- =============================================

CREATE PROCEDURE [wms].OP_WMS_SP_GET_TASK_PENDING (
  @WAVE_PICKING_ID INT
, @LOGIN VARCHAR(25))
AS

  SELECT
  [VT].[WAVE_PICKING_ID]
  ,[VT].[CLIENT_NAME]
  ,[VT].[MATERIAL_ID]
  ,[VT].[MATERIAL_NAME]
  ,[VT].[BARCODE_ID]
FROM [wms].[OP_WMS_VIEW_TASK] [VT]
WHERE [VT].[TASK_TYPE] = 'TAREA_PICKING'
AND [VT].[IS_COMPLETED] <> 'COMPLETA'
AND [VT].[TASK_ASSIGNEDTO] = @LOGIN
AND [VT].[WAVE_PICKING_ID] = @WAVE_PICKING_ID