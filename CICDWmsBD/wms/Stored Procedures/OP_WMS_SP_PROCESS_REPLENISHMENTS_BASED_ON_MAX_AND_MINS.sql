﻿-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-05-02 @ Team ERGON - Sprint Ganondorf
-- Description:	 Proceso para validar los maximos y minos para crear tareas de reabastecimiento

-- Autor:	marvin.solares
-- Fecha de Creacion: 	2018-02-12 @ Team Reborn - Sprint ulrick
-- Description:	 se modifica para que devuelva objeto Operation

--Modificación:			Elder Lucas
--Fecha:				24-08-2022
--Descripción:			Control de decimales en masterpack


--Modificación:			Elder Lucas
--Fecha:				26-08-2022
--Descripción:			Calculo de unidades totales de masterpack

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
		,@RESULT VARCHAR(400)
		,@MASTERPACK_COMPONENT_ID VARCHAR(25)
		,@MASTERPACK_COMPONENT_QTY NUMERIC(18,6)
		,@MASTERPACK_COMPONENT_TOTAL_QTY NUMERIC (18,6)
		,@MAX_QTY INT;

		DECLARE @MAT_MALO VARCHAR(MAX)
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
			,@MAX_QTY = [MAX_QUANTITY]
		FROM
			[#LOCATION_AND_MATERIAL_TO_REPLENISH]
		ORDER BY
			[RECEIVE_EXPLODED_MATERIALS] DESC;

		IF EXISTS(SELECT TOP 1 1 FROM WMS.OP_WMS_COMPONENTS_BY_MASTER_PACK WHERE MASTER_PACK_CODE = @MATERIAL_ID)
			BEGIN
			IF OBJECT_ID(N'tempdb..#KIT_DETAIL') IS NOT NULL
			BEGIN
				DROP TABLE #KIT_DETAIL
			END
				--PRINT @MATERIAL_ID
				SELECT MASTER_PACK_CODE, COMPONENT_MATERIAL, QTY INTO #KIT_DETAIL FROM WMS.OP_WMS_COMPONENTS_BY_MASTER_PACK WHERE MASTER_PACK_CODE = @MATERIAL_ID
					
					WHILE EXISTS(SELECT TOP 1 1 FROM #KIT_DETAIL)
					BEGIN
						--PRINT 2
						SELECT TOP 1
						@MASTERPACK_COMPONENT_ID = COMPONENT_MATERIAL,
						@MASTERPACK_COMPONENT_QTY = QTY
						FROM #KIT_DETAIL

						SELECT 
						@MASTERPACK_COMPONENT_TOTAL_QTY = SUM(IXL.QTY) 
						FROM WMS.OP_WMS_INV_X_LICENSE IXL
						INNER JOIN WMS.OP_WMS_LICENSES L ON IXL.LICENSE_ID = L.LICENSE_ID
						--INNER JOIN WMS.NEW_SHELF_SPOTS SS ON SS.LOCATION_SPOT = L.CURRENT_LOCATION
						WHERE IXL.MATERIAL_ID = @MASTERPACK_COMPONENT_ID AND L.CURRENT_LOCATION = @LOCATION_SPOT
							AND IXL.QTY > 0
							AND IXL.LOCKED_BY_INTERFACES = 0

		
						PRINT '@LOCATION_SPOT'
						PRINT @LOCATION_SPOT
						PRINT '@MASTERPACK_COMPONENT_QTY'
						PRINT @MASTERPACK_COMPONENT_QTY
						PRINT '@MASTERPACK_COMPONENT_TOTAL_QTY'
						PRINT @MASTERPACK_COMPONENT_TOTAL_QTY
						PRINT '@QTY_TO_REPLENISH_BEFORE'
						PRINT @QTY_TO_REPLENISH
						IF (@MASTERPACK_COMPONENT_TOTAL_QTY > 0 AND (@QTY_TO_REPLENISH > (@MAX_QTY - (@MASTERPACK_COMPONENT_TOTAL_QTY/@MASTERPACK_COMPONENT_QTY))))
						BEGIN
							SELECT @QTY_TO_REPLENISH = (@MAX_QTY - (@MASTERPACK_COMPONENT_TOTAL_QTY/@MASTERPACK_COMPONENT_QTY))
						END

						DELETE FROM #KIT_DETAIL WHERE COMPONENT_MATERIAL = @MASTERPACK_COMPONENT_ID
		END
		END

		--REDONDEAMOS AL ENTERO INFERIOR MAS CERCANO

		SET @QTY_TO_REPLENISH = CEILING(@QTY_TO_REPLENISH)


		SELECT DISTINCT
			[DZ].[ZONE]
		INTO
		[#ZONES_FOR_REALLOC]
		FROM
			[wms].[OP_WMS_ZONE] [Z] WITH (NOLOCK)
		INNER JOIN [wms].[OP_WMS_ZONE_TO_REPLENISH_IN_ZONE] [ZR] WITH (NOLOCK) ON [ZR].REPLENISH_ZONE_ID = [Z].[ZONE_ID]
		INNER JOIN [wms].[OP_WMS_ZONE] [DZ] WITH (NOLOCK) ON  [ZR].[ZONE_ID] = [DZ].[ZONE_ID]
		WHERE
			[Z].[ZONE] = @ZONE;


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
					[wms].[OP_WMS_VIEW_REALLOC_AVAILABLE_GENERAL] [V] WITH (NOLOCK)
				INNER JOIN [#ZONES_FOR_REALLOC] [Z] ON [V].[ZONE] = [Z].[ZONE]
				WHERE
					[V].[MATERIAL_ID] = @PARENT_MATERIAL_ID;

				
				PRINT '@QTY_AVAILABLE_TO_REPLENISH ANTES DE CASE'
				PRINT @QTY_AVAILABLE_TO_REPLENISH
				PRINT '@ZONE'
				PRINT @ZONE
				SELECT
					@QTY_AVAILABLE_TO_REPLENISH = CASE
											WHEN (@QTY_TO_REPLENISH 
											/ @CONVERTION_TO_BASE_CHILD) < @QTY_AVAILABLE_TO_REPLENISH
											THEN (@QTY_TO_REPLENISH 
											/ @CONVERTION_TO_BASE_CHILD)
											ELSE @QTY_AVAILABLE_TO_REPLENISH
											END;

				PRINT '@QTY_AVAILABLE_TO_REPLENISH LUEGO DE CASE'
				PRINT @QTY_AVAILABLE_TO_REPLENISH

				IF @QTY_AVAILABLE_TO_REPLENISH > 0 AND @QTY_TO_REPLENISH > 0
				BEGIN

					PRINT 'Crear reubicación de material ';
					SELECT
						@RESULT = 'OK';

          ---------------------------------------------------------------------------------
          -- Crear tarea
          ---------------------------------------------------------------------------------  
					PRINT 'DATOS PARA CREAR LA TAREA'
					PRINT @ZONE
					PRINT @LOCATION_SPOT
					PRINT @MATERIAL_ID
					PRINT @QTY_AVAILABLE_TO_REPLENISH
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
							PRINT 'SI CREO LA TAREA'
					END;
					ELSE
					BEGIN
					PRINT 'NO CREO LA TAREA'
					END
				END
				ELSE 
				BEGIN
				SET @MAT_MALO = CONCAT(@MAT_MALO, ', ', @MATERIAL_ID)
				PRINT 'EL MATERIAL NO TIENE INVENTARIO DISPONIBLE PARA REUBICAR '
				PRINT @MATERIAL_ID
				END

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

		DELETE FROM
			[#LOCATION_AND_MATERIAL_TO_REPLENISH]
		WHERE
			@LOCATION_SPOT = [LOCATION_SPOT]
			AND @MATERIAL_ID = [MATERIAL_ID];

	
	END;
	PRINT @MAT_MALO + 'FINAL'
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
