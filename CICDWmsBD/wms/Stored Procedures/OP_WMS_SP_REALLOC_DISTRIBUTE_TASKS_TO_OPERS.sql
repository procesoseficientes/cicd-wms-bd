-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-05-03 @ Team ERGON - Sprint GANONDORF
-- Description:	        distribuye las tareas a los operadores de reubicacion


-- Modificacion 27-Sep-17 @ Nexus Team Sprint DUCKHUNT
					-- pablo.aguilar
					-- Se agrega validación que unicamente asigne tareas a operadores que tengan CAN_REALOCATE 

/*
-- Ejemplo de Ejecucion:
	select * 	  FROM [wms].[OP_WMS_TASK_LIST] [TL]
    WHERE [TL].[TASK_TYPE] = 'TAREA_REUBICACION'
	SELECT * FROM [wms].OP_WMS_LOGINS
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_REALLOC_DISTRIBUTE_TASKS_TO_OPERS]
AS
BEGIN
	SET NOCOUNT ON;
  --


  -- ------------------------------------------------------------------------------------
  -- Declaramos variables y tablas
  -- ------------------------------------------------------------------------------------


	DECLARE
		@WAREHOUSE_TASK VARCHAR(25)
		,@OPERADOR VARCHAR(25) = NULL 
		,@SERIAL_NUMBER NUMERIC;

	DECLARE	@REALLOC_TASKS TABLE (
			[WAVE_PICKING_ID] NUMERIC(18, 0)
			,[WAREHOUSE_TASK] VARCHAR(25)
			,[SERIAL_NUMBER] NUMERIC
		);

  -- ------------------------------------------------------------------------------------
  -- Obtiene tareas de REUBICACION con su warehouse sorce
  -- ------------------------------------------------------------------------------------
	INSERT	INTO @REALLOC_TASKS
	SELECT
		[TL].[WAVE_PICKING_ID]
		,[TL].[WAREHOUSE_SOURCE]
		,[TL].[SERIAL_NUMBER]
	FROM
		[wms].[OP_WMS_TASK_LIST] [TL]
	WHERE
		[TL].[TASK_TYPE] = 'TAREA_REUBICACION'
		AND [TL].[TASK_ASSIGNEDTO] = ''
		AND [TL].[IS_COMPLETED] = 0
		AND [TL].[IS_CANCELED] = 0;

  -- ------------------------------------------------------------------------------------
  -- Ciclo de tareas
  -- ------------------------------------------------------------------------------------

	WHILE EXISTS ( SELECT TOP 1
						1
					FROM
						@REALLOC_TASKS )
	BEGIN

		SELECT
			@WAREHOUSE_TASK = [RT].[WAREHOUSE_TASK]
			,@SERIAL_NUMBER = [RT].[SERIAL_NUMBER]
		FROM
			@REALLOC_TASKS [RT];

			
		SELECT TOP 1
			@OPERADOR = [L].[LOGIN_ID]
		FROM
			[wms].[OP_WMS_LOGINS] [L]
		LEFT JOIN [wms].[OP_WMS_TASK_LIST] [T] ON [T].[TASK_ASSIGNEDTO] = [L].[LOGIN_ID]
											AND [T].[IS_COMPLETED] = 0
											AND [T].[IS_CANCELED] = 0
											AND [T].[TASK_ASSIGNEDTO] <> ''
											AND [T].[TASK_TYPE] = 'TAREA_REUBICACION'
											
		INNER JOIN [wms].[OP_WMS_WAREHOUSE_BY_USER] [WU] ON [WU].[LOGIN_ID] = [L].[LOGIN_ID]
		WHERE
			[WU].[WAREHOUSE_ID] = @WAREHOUSE_TASK
			AND [L].[LOGIN_TYPE] <> 'PC'
			AND [L].[CAN_RELOCATE] = 1
		GROUP BY
			[L].[LOGIN_ID]
		ORDER BY
			COUNT(ISNULL([T].[TASK_ASSIGNEDTO] , 0)) ASC;

		IF @OPERADOR IS NOT NULL
		BEGIN
			UPDATE
				[TL]
			SET	
				[TL].[TASK_ASSIGNEDTO] = @OPERADOR
				,[TL].[ASSIGNED_DATE] = GETDATE()
			FROM
				[wms].[OP_WMS_TASK_LIST] [TL]
			WHERE
				[TL].[SERIAL_NUMBER] = @SERIAL_NUMBER;

		END;


		DELETE
			@REALLOC_TASKS
		WHERE
			[SERIAL_NUMBER] = @SERIAL_NUMBER;

	END;


END;