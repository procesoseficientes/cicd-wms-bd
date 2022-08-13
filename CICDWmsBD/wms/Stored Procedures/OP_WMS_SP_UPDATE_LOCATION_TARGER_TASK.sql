
-- =============================================
-- Autor:				        rudi.garcia
-- Fecha de Creacion: 	2017-03-2 @ TeamErgon Sprint IV Ergon
-- Description:			    SP que obtiene las tareas pendientes de operador.

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_UPDATE_LOCATION_TARGER_TASK]
					@WAVE_PICKING_ID = 4403					
          ,@LOGIN = 'ACAMACHO'
          ,@LOCATION_SPOT_TARGET = 'B01-R01-C01-NA'
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_LOCATION_TARGER_TASK] (
		@WAVE_PICKING_ID INT
		,@LOGIN VARCHAR(25)
		,@LOCATION_SPOT_TARGET VARCHAR(50)
	)
AS
UPDATE
	[T]
SET	
	[T].[LOCATION_SPOT_TARGET] = @LOCATION_SPOT_TARGET
FROM
	[wms].[OP_WMS_TASK_LIST] [T] WITH (INDEX ([IX_OP_WMS_TASK_LIST_ASSIG_TO]))
WHERE
	[T].[TASK_TYPE] = 'TAREA_PICKING'
	AND [T].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
	AND [T].[TASK_ASSIGNEDTO] = @LOGIN;

  
SELECT
	1 AS [Resultado]
	,'Proceso Exitoso' [Mensaje]
	,0 [Codigo]
	,'' [DbData];