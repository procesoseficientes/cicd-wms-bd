-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	1/26/2018 @ NEXUS-Team Sprint Trotzdem 
-- Description:			SP que actualiza la prioridad de la tarea

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_UPDATE_TASK_PRIORITY]
					@TASK_ID = 355533
					,@TASK_TYPE = 'TAREA_PICKING'
					,@PRIORITY = 2
				-- 
				SELECT PRIORITY, * 
				FROM [wms].[OP_WMS_TASK_LIST] 
				WHERE SERIAL_NUMBER = 355533
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_TASK_PRIORITY] (
		@TASK_ID INT
		,@TASK_TYPE VARCHAR(50)
		,@PRIORITY INT
	)
AS
BEGIN
	SET NOCOUNT ON;
  --

	DECLARE	@WAVE_PICKING_ID INT = 0;
	BEGIN TRY
		IF @TASK_TYPE = 'TAREA_CONTEO_FISICO'
		BEGIN
			UPDATE
				[wms].[OP_WMS_TASK]
			SET	
				[PRIORITY] = @PRIORITY
			WHERE
				[TASK_ID] = @TASK_ID;
		END;
		IF @TASK_TYPE = 'TAREA_PICKING'
			OR @TASK_TYPE = 'TAREA_REUBICACION'
		BEGIN
			SELECT
				@WAVE_PICKING_ID = [WAVE_PICKING_ID]
			FROM
				[wms].[OP_WMS_TASK_LIST]
			WHERE
				[SERIAL_NUMBER] = @TASK_ID;
      --
			UPDATE
				[wms].[OP_WMS_TASK_LIST]
			SET	
				[PRIORITY] = @PRIORITY
			WHERE
				[WAVE_PICKING_ID] = @WAVE_PICKING_ID;
		END;
		ELSE
		BEGIN
			UPDATE
				[wms].[OP_WMS_TASK_LIST]
			SET	
				[PRIORITY] = @PRIORITY
			WHERE
				[SERIAL_NUMBER] = @TASK_ID;
		END;
    --
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,'' [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,CASE CAST(@@ERROR AS VARCHAR)
				WHEN '2627' THEN ''
				ELSE ERROR_MESSAGE()
				END [Mensaje]
			,@@ERROR [Codigo]
			,'' [DbData];
	END CATCH;
END;