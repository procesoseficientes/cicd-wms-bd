-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-05-02 @ Team ERGON - Sprint Ganondorf
-- Description:	 Proceso para validar los maximos y minos para crear tareas de reabastecimiento

-- Autor:	marvin.solares
-- Fecha de Creacion: 	2018-02-12 @ Team Reborn - Sprint ulrick
-- Description:	 se modifica para que devuelva objeto Operation

--Modificación:			Elder Lucas
--Fecha:				24-08-2022
--Descripción:			Control de decimales en masterpack

/*
-- Ejemplo de Ejecucion:
			exec [wms].[OP_WMS_SP_PROCESS_REPLENISHMENTS_BASED_ON_MAX_AND_MINS]
  SELECT * FROM [wms].OP_WMS_TASK_LIST  where task_type = 'TAREA_REUBICACION'
  */
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_PROCESS_REPLENISHMENTS_BASED_ON_MAX_AND_MINS]
AS
BEGIN
	SET NOCOUNT ON;
  --

  ---------------------------------------------------------------------------------
  -- Declara variables
  ---------------------------------------------------------------------------------  
	DECLARE
		@LOCATION_SPOT VARCHAR(25)
		,@MATERIAL_ID VARCHAR(25)
		,@QTY_TO_REPLENISH NUMERIC(18,6)
		,@QTY_AVAILABLE_TO_REPLENISH NUMERIC(18,6)
		,@ZONE VARCHAR(25)
		,@RECEIVE_EXPLODED_MATERIALS INT
		,@PARENT_MATERIAL_ID VARCHAR(25)
		,@CONVERTION_TO_BASE_CHILD NUMERIC(18,6)
		,@LEVEL INT
		,@WAVE_PICKING_ID_LP INT = 0
		,@WAVE_PICKING_ID_BF INT = 0
		,@RESULT VARCHAR(400);


  ---------------------------------------------------------------------------------
  -- Consulta de maximos y minimos 
  ---------------------------------------------------------------------------------  

	SELECT
		[LOCATION_SPOT]
		,[MATERIAL_ID]
		,[QTY_TO_REPLENISH]
		,[MIN_QUANTITY]
		,[MAX_QUANTITY]
		,[ZONE]
		,[RECEIVE_EXPLODED_MATERIALS]
		,[WAREHOUSE_PARENT]
	INTO
		[#LOCATION_AND_MATERIAL_TO_REPLENISH]
	FROM
		[wms].[OP_WMS_VIEW_LOCATION_TO_REPLENISH];

	WHILE EXISTS ( SELECT TOP 1
						1
					FROM
						[#LOCATION_AND_MATERIAL_TO_REPLENISH] )
	BEGIN

		SELECT TOP 1
			@LOCATION_SPOT = [LOCATION_SPOT]
			,@MATERIAL_ID = [MATERIAL_ID]
			,@QTY_TO_REPLENISH = [QTY_TO_REPLENISH]
			,@ZONE = [ZONE]
			,@RECEIVE_EXPLODED_MATERIALS = 1
		FROM
			[#LOCATION_AND_MATERIAL_TO_REPLENISH]
		ORDER BY
			[RECEIVE_EXPLODED_MATERIALS] DESC;
		PRINT 'INICIA ITERACION';


		SELECT
			[Z].[ZONE]
		INTO
		[#ZONES_FOR_REALLOC]
		FROM
			[wms].[OP_WMS_ZONE] [Z]
		INNER JOIN [wms].[OP_WMS_ZONE_TO_REPLENISH_IN_ZONE] [ZR] ON [ZR].REPLENISH_ZONE_ID = [Z].[ZONE_ID]
		INNER JOIN [wms].[OP_WMS_ZONE] [DZ] ON  [ZR].[ZONE_ID] = [DZ].[ZONE_ID]
		WHERE
			[DZ].[ZONE] = @ZONE;

		PRINT '@RECEIVE_EXPLODED_MATERIALS '
			+ CAST(@RECEIVE_EXPLODED_MATERIALS AS VARCHAR);
		PRINT '@QTY_TO_REPLENISH '
			+ CAST(@QTY_TO_REPLENISH AS VARCHAR);
		PRINT '@MATERIAL_ID GH '
			+ CAST(@MATERIAL_ID AS VARCHAR);
		PRINT '@ZONE  '
			+ CAST(@ZONE AS VARCHAR);
		IF @RECEIVE_EXPLODED_MATERIALS = 0
		BEGIN
      ---------------------------------------------------------------------------------
      -- Zona de Linea de picking, buscar unicamente materiales ya explotados 
      ---------------------------------------------------------------------------------  
			PRINT 'IF'
			SELECT
				@QTY_AVAILABLE_TO_REPLENISH = 0;

			SELECT
				@QTY_AVAILABLE_TO_REPLENISH = SUM(ISNULL([V].[QTY],
											0))
			FROM
				[wms].[OP_WMS_VIEW_REALLOC_AVAILABLE_GENERAL] [V]
			INNER JOIN [#ZONES_FOR_REALLOC] [Z] ON [V].[ZONE] = [Z].[ZONE]
			WHERE
				[V].[MATERIAL_ID] = @MATERIAL_ID;

			PRINT '@@QTY_AVAILABLE_TO_REPLENISH GH '
			+ CAST(@QTY_AVAILABLE_TO_REPLENISH AS VARCHAR);

			SELECT
				@QTY_AVAILABLE_TO_REPLENISH = CASE
											WHEN @QTY_TO_REPLENISH < @QTY_AVAILABLE_TO_REPLENISH
											THEN @QTY_TO_REPLENISH
											ELSE @QTY_AVAILABLE_TO_REPLENISH
											END;


			IF @QTY_AVAILABLE_TO_REPLENISH > 0
			BEGIN

				PRINT 'Crear reubicación de materialS '+@ZONE+' '+@LOCATION_SPOT;

				SELECT
					@RESULT = 'OK';

        ---------------------------------------------------------------------------------
        -- Crear tarea
        ---------------------------------------------------------------------------------  
				EXEC [wms].[OP_WMS_SP_CREATE_REPLEANISH_TASK] @MATERIAL_ID = @MATERIAL_ID,
					@WAVE_PICKING_ID = @WAVE_PICKING_ID_LP OUTPUT,
					@TARGET_ZONE = @ZONE,
					@TARGET_LOCATION = @LOCATION_SPOT,
					@MATERIAL_ID_TARGET = NULL,
					@QTY = @QTY_AVAILABLE_TO_REPLENISH,
					@TASK_SUB_TYPE = 'REUBICACION_LP',
					@PRESULT = @RESULT OUTPUT;

				IF @RESULT = 'OK'
				BEGIN
					SELECT
						@QTY_TO_REPLENISH = @QTY_TO_REPLENISH
						- @QTY_AVAILABLE_TO_REPLENISH;
					PRINT 'SUCCESS'
				END;
				PRINT 'END'
			END;



		END;
		ELSE
		BEGIN
      ---------------------------------------------------------------------------------
      -- Zona de BUFFER, buscar  materiales ya explotados o el master pack que pueda suplir la necesidad
      ---------------------------------------------------------------------------------  
	  PRINT 'ELSE'
			IF OBJECT_ID('tempdb..#PARENTS_MATERIALS') IS NOT NULL
				DROP TABLE [#PARENTS_MATERIALS];

			SELECT
				[PARENT_MATERIAL_ID]
				,[CONVERTION_TO_BASE_CHILD]
				,[LEVEL]
			INTO
				[#PARENTS_MATERIALS]
			FROM
				[wms].[OP_WMS_FN_GET_PARENT_MATERIALS_OF_MATERIAL](@MATERIAL_ID);

			WHILE EXISTS ( SELECT TOP 1
								1
							FROM
								[#PARENTS_MATERIALS] )
			BEGIN
				PRINT ' -- INICIA ITERACION MATERIALES MASTERPACK';

				SELECT TOP 1
					@PARENT_MATERIAL_ID = [PARENT_MATERIAL_ID]
					,@CONVERTION_TO_BASE_CHILD = [CONVERTION_TO_BASE_CHILD]
					,@LEVEL = [LEVEL]
				FROM
					[#PARENTS_MATERIALS]
				ORDER BY
					[LEVEL] ASC;


				PRINT '@MATERIAL_ID'
				PRINT @MATERIAL_ID
				PRINT '@PARENT_MATERIAL_ID '
					+ CAST(@PARENT_MATERIAL_ID AS VARCHAR);
				PRINT '@@CONVERTION_TO_BASE_CHILD '
					+ CAST(@CONVERTION_TO_BASE_CHILD AS VARCHAR);
				PRINT '@@LEVEL ' + CAST(@LEVEL AS VARCHAR);

				SELECT
					@QTY_AVAILABLE_TO_REPLENISH = 0;

				SELECT
					@QTY_AVAILABLE_TO_REPLENISH = SUM(ISNULL([V].[QTY],
											0))
				FROM
					[wms].[OP_WMS_VIEW_REALLOC_AVAILABLE_GENERAL] [V]
				INNER JOIN [#ZONES_FOR_REALLOC] [Z] ON [V].[ZONE] = [Z].[ZONE]
				WHERE
					[V].[MATERIAL_ID] = @PARENT_MATERIAL_ID;

				PRINT '@QTY_AVAILABLE_TO_REPLENISH '
					+ CAST( ISNULL(@QTY_AVAILABLE_TO_REPLENISH,-1) AS VARCHAR);
		
				SELECT
					@QTY_AVAILABLE_TO_REPLENISH = CASE
											WHEN (@QTY_TO_REPLENISH 
											/ @CONVERTION_TO_BASE_CHILD) < @QTY_AVAILABLE_TO_REPLENISH
											THEN (@QTY_TO_REPLENISH 
											/ @CONVERTION_TO_BASE_CHILD)
											ELSE @QTY_AVAILABLE_TO_REPLENISH
											END;
				PRINT '@QTY_AVAILABLE_TO_REPLENISH '
					+ CAST( ISNULL(@QTY_AVAILABLE_TO_REPLENISH,-1) AS VARCHAR);

				IF @QTY_AVAILABLE_TO_REPLENISH > 0
				BEGIN

					PRINT 'Crear reubicación de material ';
					SELECT
						@RESULT = 'OK';

			PRINT @ZONE
			PRINT @LOCATION_SPOT
          ---------------------------------------------------------------------------------
          -- Crear tarea
          ---------------------------------------------------------------------------------  
					EXEC [wms].[OP_WMS_SP_CREATE_REPLEANISH_TASK] @MATERIAL_ID = @PARENT_MATERIAL_ID,
						@WAVE_PICKING_ID = @WAVE_PICKING_ID_BF OUTPUT,--Obtiene el valor del SP que crea la tarea y lo utiliza en todo el grupo
						@TARGET_ZONE = @ZONE,
						@TARGET_LOCATION = @LOCATION_SPOT,
						@MATERIAL_ID_TARGET = @MATERIAL_ID,
						@QTY = @QTY_AVAILABLE_TO_REPLENISH,
						@TASK_SUB_TYPE = 'REUBICACION_BUFFER',
						@PRESULT = @RESULT OUTPUT;


					IF @RESULT = 'OK'
					BEGIN
						SELECT
							@QTY_TO_REPLENISH = @QTY_TO_REPLENISH
							- @QTY_AVAILABLE_TO_REPLENISH;
							PRINT 'SS'
					END;
					PRINT 'NN'
				END;

				IF @QTY_TO_REPLENISH <= 0
					DELETE
						[#PARENTS_MATERIALS];
				ELSE
					DELETE
						[#PARENTS_MATERIALS]
					WHERE
						@PARENT_MATERIAL_ID = [PARENT_MATERIAL_ID];


			END;

		END;

		DROP TABLE [#ZONES_FOR_REALLOC];

		PRINT 'DELETE @LOCATION_SPOT ' + @LOCATION_SPOT;
		PRINT 'DELETE @@MATERIAL_ID ' + @MATERIAL_ID;
		DELETE FROM
			[#LOCATION_AND_MATERIAL_TO_REPLENISH]
		WHERE
			@LOCATION_SPOT = [LOCATION_SPOT]
			AND @MATERIAL_ID = [MATERIAL_ID];

	
	END;

  ---------------------------------------------------------------------------------
  -- Asignar tareas creadas 
  ---------------------------------------------------------------------------------  
	EXEC [wms].[OP_WMS_SP_REALLOC_DISTRIBUTE_TASKS_TO_OPERS];

	SELECT
		1 AS [Resultado]
		,'Proceso Exitoso' [Mensaje]
		,0 [Codigo]
		,CAST('1' AS VARCHAR) [DbData];

END;


