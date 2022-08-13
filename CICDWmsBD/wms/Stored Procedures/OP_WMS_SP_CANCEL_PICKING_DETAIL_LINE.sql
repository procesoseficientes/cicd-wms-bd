-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-04-12 @ Team ERGON - Sprint ERGON EPONA
-- Description:	 Cancelar una linea de detalle. 

-- Modificacion:  rudi.garcia
-- Fecha de Creacion: 	2017-04-19 @ Team ERGON - Sprint ERGON EPONA
-- Description:	 Se agrego la validacion que cuando la tarea sea fiscal, este no pueda cancelar la linea

-- Modificacion:        hector.gonzalez
-- Fecha de Creacion: 	2017-04-19 @ Team ERGON - Sprint ERGON Sheik
-- Description:	        Se modifico para que tome en cuenta picking consolidado

-- Modificacion:        Elder Lucas
-- Fecha de Creacion: 	2022.02.11
-- Description:	        Se modificó el tipo de dato numeric para aceptar datos con decimales


-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-06-20 ErgonTeam@BreathOfTheWild
-- Description:	 Se modifica para que si cancela una linea de detalle discrecional que manejaba serie, libere la serie reservada para ese picking.


-- Modificacion 04-Mar-19 @ Nexus Team Sprint TOPO
					-- pablo.aguilar
					-- Se agrega cancelación de masterpack y se agrega métodos para validar enciclamiento


/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_CANCEL_PICKING_DETAIL_LINE] @LOGIN_ID = 'BGOMEZ'
                                                        ,@WAVE_PICKING_ID = 79763
                                                        ,@MATERIAL_ID = 'ALZA/10161'

  
      SELECT * FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [OWNPDH]
        INNER JOIN [wms].[OP_WMS_TASK_LIST] [L] ON [OWNPDH].[WAVE_PICKING_ID] = [L].[WAVE_PICKING_ID]
        WHERE [L].[IS_COMPLETED] <> 1 AND [L].[WAVE_PICKING_ID]  = 4417
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_CANCEL_PICKING_DETAIL_LINE] (
		@LOGIN_ID VARCHAR(25)
		,@WAVE_PICKING_ID INT
		,@MATERIAL_ID VARCHAR(25)
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE	@REGIMEN VARCHAR(25);
	DECLARE	@IS_DISCRETIONAL INT;

	
	DECLARE	@USED_DETAILS_ID TABLE ([DETAIL_ID] INT);

  -- ------------------------------------------------------------------------------------
  -- Se obtiene el regimen de la ola de picking
  -- ------------------------------------------------------------------------------------
	SELECT TOP 1
		@REGIMEN = [TL].[REGIMEN]
		,@IS_DISCRETIONAL = [TL].[IS_DISCRETIONARY]
	FROM
		[wms].[OP_WMS_TASK_LIST] [TL] WITH (NOLOCK)
	WHERE
		[WAVE_PICKING_ID] = @WAVE_PICKING_ID;

	IF @REGIMEN = 'FISCAL'
	BEGIN
		RAISERROR ('No se puede cancelar las lineas, cuando la tarea es de fical.', 16, 1);
	END;


	-- ------------------------------------------------------------------------------------
	-- validamos que la tarea no haya sido completada o cancelada previamente
	-- ------------------------------------------------------------------------------------
	IF NOT EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_TASK_LIST]
					WHERE
						[WAVE_PICKING_ID] = @WAVE_PICKING_ID
						AND [MATERIAL_ID] = @MATERIAL_ID
						AND [IS_COMPLETED] = 0 )
	BEGIN 


		RAISERROR ('Tarea ya fue completada para este material.', 16, 1);
		RETURN;
	END; 


  ---------------------------------------------------------------------------------
  -- SI ES DISCRECIONAL Y MANEJA SERIE desasociar series a la ola 
  ---------------------------------------------------------------------------------  
	IF @IS_DISCRETIONAL = 1
		AND EXISTS ( SELECT TOP 1
							1
						FROM
							[wms].[OP_WMS_MATERIALS] [M]
							WITH (NOLOCK)
						WHERE
							[M].[MATERIAL_ID] = @MATERIAL_ID
							AND [M].[SERIAL_NUMBER_REQUESTS] = 1 )
	BEGIN
		UPDATE
			[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER]
		SET	
			[WAVE_PICKING_ID] = NULL
			,[ASSIGNED_TO] = NULL
		WHERE
			[WAVE_PICKING_ID] = @WAVE_PICKING_ID
			AND [STATUS] > 0;
	END;
  --
  ---------------------------------------------------------------------------------
  -- CANCELAR EN TASK_LIST
  ---------------------------------------------------------------------------------  
	UPDATE
		[wms].[OP_WMS_TASK_LIST]
	SET	
		[IS_COMPLETED] = 1
		,[COMPLETED_DATE] = GETDATE()
	WHERE
		[MATERIAL_ID] = @MATERIAL_ID
		AND [WAVE_PICKING_ID] = @WAVE_PICKING_ID;


	SELECT
		[H].[WAVE_PICKING_ID]
		,[D].[MATERIAL_ID]
		,[D].[WAS_IMPLODED]
		,[D].[QTY]
		,[D].[QTY_IMPLODED]
	INTO
		[#Demanda]
	FROM
		[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H]
	INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [D] ON [D].[PICKING_DEMAND_HEADER_ID] = [H].[PICKING_DEMAND_HEADER_ID]
	WHERE
		[H].[WAVE_PICKING_ID] = @WAVE_PICKING_ID;
		--AND [D].[QTY] > 0;


		
	
  ---------------------------------------------------------------------------------
  -- Validar si es una tarea de demanda de despacho.
  ---------------------------------------------------------------------------------  
	IF EXISTS ( SELECT TOP 1
					1
				FROM
					[#Demanda] WITH (NOLOCK)
				WHERE
					[WAVE_PICKING_ID] = @WAVE_PICKING_ID )
	BEGIN


    ---------------------------------------------------------------------------------
    -- Calcular si hubo un diferencial que si fue pickeado 
    ---------------------------------------------------------------------------------  
		DECLARE
			@QTY_PENDING NUMERIC(18,4) = 0
			,@I INT = 0
			,@QTY_LINE NUMERIC(18,4) = 0
			,@DETAIL_ID INT
			,@HEADER_ID INT
			,@ID INT = 0;

		SELECT
			@QTY_PENDING = SUM([T].[QUANTITY_PENDING])
		FROM
			[wms].[OP_WMS_TASK_LIST] [T]
		WHERE
			[T].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
			AND [T].[MATERIAL_ID] = @MATERIAL_ID;



		-- ------------------------------------------------------------------------------------
		-- VALIDAMOS SI EXISTE EN LA DEMANDA EL MATERIAL, SI NO EXISTE Y HAY UN PRODUCTO IMPLOTADO ES QUE HAY QUE CANCELAR EL MASTERPACK
		-- ------------------------------------------------------------------------------------
		IF NOT EXISTS ( SELECT TOP 1
							1
						FROM
							[#Demanda] [d]
						WHERE
							[d].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
							AND [d].[MATERIAL_ID] = @MATERIAL_ID )
			AND EXISTS ( SELECT TOP 1
								1
							FROM
								[#Demanda] [d]
							WHERE
								[d].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
								AND [d].[WAS_IMPLODED] = 1 )
		BEGIN

			PRINT 'VALIDACION DE CANCELACION DE MASTERPACK 1';
					
			SELECT
				MAX([REAL_QTY]) [QTY_CANCELED]
				,[MATER_PACK_CODE]
				,ROW_NUMBER() OVER (ORDER BY [MATER_PACK_CODE] DESC) [ID]
			INTO
				[#MasterPackCancelled]
			FROM
				[wms].[OP_WMS_FN_GET_CANCELLED_MASTERPACK_TO_ASSAMBLE_IN_WAVE_PICKING](@WAVE_PICKING_ID)
			GROUP BY
				[MATER_PACK_CODE];

				

			WHILE EXISTS ( SELECT TOP 1
								1
							FROM
								[#MasterPackCancelled]
							WHERE
								[QTY_CANCELED] > 0 )
			BEGIN 
				
					
			   -- Prueba para verificar el estado de la transaccion
				SELECT
					@I = @I + 1;
			   --
				IF (@I >= 1000)
				BEGIN
					INSERT	INTO [wms].[OP_WMS_SWIFT_3PL_LOG]
							(
								[PROCESS_LOG]
								,[MESSAGE_LOG]
								,[DATETIME_LOG]
								,[LOGIN_ID]
								,[WAVE_PICKING_ID]
								,[MATERIAL_ID]
							)
					VALUES
							(
								'[wms].[OP_WMS_SP_CANCEL_PICKING_DETAIL_LINE]'
								, -- PROCESS_LOG - varchar(250)
								'Error de Maximo Iteracion: '
								+ CONVERT(VARCHAR(10), @I)
								, -- MESSAGE_LOG - varchar(250)
								GETDATE()
								,  -- DATETIME_LOG - datetime
								@LOGIN_ID
								,@WAVE_PICKING_ID
								,@MATERIAL_ID
							);
					RAISERROR('Error de Maximo Iteracion',16,1);
					RETURN;
				END;  
                --Fin prueba      

		

				SELECT TOP 1
					@QTY_PENDING = [QTY_CANCELED]
					,@MATERIAL_ID = [MATER_PACK_CODE]
					,@ID = [ID]
					,@QTY_LINE = 0
				FROM
					[#MasterPackCancelled]
				WHERE
					[QTY_CANCELED] > 0;
				
				
				PRINT @MATERIAL_ID;
				PRINT '@QTY_PENDING  '
					+ CAST(@QTY_PENDING AS VARCHAR);

				SELECT TOP 1
					@QTY_LINE = CASE	WHEN @QTY_PENDING <= [D].[QTY_IMPLODED]
										THEN @QTY_PENDING
										ELSE [D].[QTY_IMPLODED]
								END
					,@DETAIL_ID = [D].[PICKING_DEMAND_DETAIL_ID]
					,@HEADER_ID = [H].[PICKING_DEMAND_HEADER_ID]
				FROM
					[wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [D]
					WITH (NOLOCK)
				INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H]
					WITH (NOLOCK) ON [D].[PICKING_DEMAND_HEADER_ID] = [H].[PICKING_DEMAND_HEADER_ID]
					AND [D].[PICKING_DEMAND_DETAIL_ID] NOT IN (SELECT [DETAIL_ID] FROM @USED_DETAILS_ID)
				WHERE
					[H].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
					AND [D].[MATERIAL_ID] = @MATERIAL_ID
					AND [D].[QTY_IMPLODED] > 0
				ORDER BY
					[H].[PRIORITY] DESC;
				PRINT '@QTY_LINE  '
					+ CAST(@QTY_LINE AS VARCHAR);

				PRINT '@@DETAIL_ID  '
					+ CAST(@DETAIL_ID AS VARCHAR);


					INSERT INTO @USED_DETAILS_ID
							([DETAIL_ID])
					VALUES
							(@DETAIL_ID  -- DETAIL_ID - int
								)
				UPDATE
					[wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL]
				SET	
					[QTY] = [QTY_IMPLODED] - @QTY_LINE
				WHERE
					@DETAIL_ID = [PICKING_DEMAND_DETAIL_ID];

    ---------------------------------------------------------------------------------
    -- Abrir el encabezado de la orden para indicar que existieron faltantes. 
    ---------------------------------------------------------------------------------  
				UPDATE
					[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
				SET	
					[IS_COMPLETED] = 0
				WHERE
					[PICKING_DEMAND_HEADER_ID] = @HEADER_ID;


				SELECT
					@QTY_PENDING = @QTY_PENDING - @QTY_LINE;


				PRINT '@QTY_PENDING '
					+ CAST(@QTY_PENDING AS VARCHAR);
				PRINT '@QTY_LINE '
					+ CAST(@QTY_LINE AS VARCHAR);
				UPDATE
					[#MasterPackCancelled]
				SET	
					[QTY_CANCELED] = [QTY_CANCELED]
					- @QTY_LINE
				WHERE
					[ID] = @ID;
			END; 
				

			--UPDATE
			--	[D]
			--SET	
			--	[D].[QTY] = [D].[QTY_IMPLODED]
			--	- [mc].[QTY_CANCELED]
			--FROM
			--	[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H]
			--INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [D] ON [D].[PICKING_DEMAND_HEADER_ID] = [H].[PICKING_DEMAND_HEADER_ID]
			--INNER JOIN [#MasterPackCancelled] [mc] ON [mc].[MATER_PACK_CODE] = [D].[MATERIAL_ID]
			--								AND [D].[WAS_IMPLODED] = 1
			--WHERE
			--	[H].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
			--	AND [D].[QTY_IMPLODED] > 0;

		END; 
		ELSE
		BEGIN 

		
			WHILE @QTY_PENDING > 0
			BEGIN

		
			   -- Prueba para verificar el estado de la transaccion
				SELECT
					@I = @I + 1;
			   --
				IF (@I >= 1000)
				BEGIN
					INSERT	INTO [wms].[OP_WMS_SWIFT_3PL_LOG]
							(
								[PROCESS_LOG]
								,[MESSAGE_LOG]
								,[DATETIME_LOG]
								,[LOGIN_ID]
								,[WAVE_PICKING_ID]
								,[MATERIAL_ID]
							)
					VALUES
							(
								'[wms].[OP_WMS_SP_CANCEL_PICKING_DETAIL_LINE]'
								, -- PROCESS_LOG - varchar(250)
								'Error de Maximo Iteracion: '
								+ CONVERT(VARCHAR(10), @I)
								, -- MESSAGE_LOG - varchar(250)
								GETDATE()
								,  -- DATETIME_LOG - datetime
								@LOGIN_ID
								,@WAVE_PICKING_ID
								,@MATERIAL_ID
							);
					RAISERROR('Error de Maximo Iteracion',16,1);
					RETURN;
				END;  
                --Fin prueba      

				

				SELECT
					@QTY_LINE = 0; 
				SELECT TOP 1
					@QTY_LINE = CASE	WHEN @QTY_PENDING <= [D].[QTY]
										THEN @QTY_PENDING
										ELSE [D].[QTY]
								END
					,@DETAIL_ID = [D].[PICKING_DEMAND_DETAIL_ID]
					,@HEADER_ID = [H].[PICKING_DEMAND_HEADER_ID]
				FROM
					[wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [D]
					WITH (NOLOCK)
				INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H]
					WITH (NOLOCK) ON [D].[PICKING_DEMAND_HEADER_ID] = [H].[PICKING_DEMAND_HEADER_ID]
				WHERE
					[H].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
					AND [D].[MATERIAL_ID] = @MATERIAL_ID
					AND [D].[QTY] > 0
				ORDER BY
					[H].[PRIORITY] DESC;


				UPDATE
					[wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL]
				SET	
					[QTY] = [QTY] - @QTY_LINE
				WHERE
					@DETAIL_ID = [PICKING_DEMAND_DETAIL_ID];

    ---------------------------------------------------------------------------------
    -- Abrir el encabezado de la orden para indicar que existieron faltantes. 
    ---------------------------------------------------------------------------------  
				UPDATE
					[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
				SET	
					[IS_COMPLETED] = 0
				WHERE
					[PICKING_DEMAND_HEADER_ID] = @HEADER_ID;


				SELECT
					@QTY_PENDING = @QTY_PENDING - @QTY_LINE;
			END;

		END;

	END; 

	EXEC [wms].[OP_WMS_SP_PICKING_HAS_BEEN_COMPLETED] @WAVE_PICKING_ID = @WAVE_PICKING_ID, -- int
		@LOGIN = @LOGIN_ID; -- varchar(50)

END;