-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	6/08/2018 GForce@Dinosaurio
-- Description:			actualiza el detalle de la confirmacion de una tarea de recepcion por orden de compra.


-- Autor:				marvin.solares
-- Fecha de Creacion: 	20182007 GForce@FocaMonje
-- Description:			se actualiza para que permita trabajar varias ordenes de compra amarradas consolidadas en una tarea.

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20180823 GForce@Humano
-- Description:			se guardan las series correlativas asociadas a las series amarradas a la tarea de recepcion de erp

-- Modificacion 20180811 GForce@Jaguarundi
-- marvin.solares
-- Description:			se modifica sentencia que obtiene ERP_OBJECT_TYPE para que contemple recepciones generales que no tienen tipo de objeto
--						y se ajusta para que pueda confirmar documentos provenientes de una recepcion general

-- Modificacion:		Gildardo.Alvarado@ProcesosEficientes
-- Fecha:				18/02/2021
-- Description:			Se valida que ingrese la bodega correcta a las recepciones hechas por traslado ERP

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_CONFIRMED_RECEPTION_ERP_BY_XML]
					

*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_CONFIRMED_RECEPTION_ERP_BY_XML] (
		@XML XML
		,@XML_SERIES XML
		,@LOGIN VARCHAR(50)
		,@TASK_ID INT
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@DETAIL_ID INT = 0
		,@ERP_OBJECT_TYPE INT
		,@WAREHOUSE_CODE VARCHAR(25)
		,@RECEPTION_HEADER_ID INT
		,@HEADER_ID INT
		,@COST_CENTER VARCHAR(25)
		,@IS_COMPLETED INT = 1
		,@HAS_DETAIL INT = 0
		,@WAREHOUSE_NAME_ERROR NVARCHAR(MAX)
		,@COUNTER INT = 1;

	--
	DECLARE	@DETAIL_ERP_RECEPTION TABLE (
			[ERP_RECEPTION_DOCUMENT_DETAIL_ID] [INT]
			,[ERP_RECEPTION_DOCUMENT_HEADER_ID] [INT]
			,[MATERIAL_ID] [VARCHAR](50)
			,[QTY] [NUMERIC](19, 6)
			,[LINE_NUM] [INT]
			,[ERP_OBJECT_TYPE] [INT]
			,[ATTEMPTED_WITH_ERROR] [INT]
			,[IS_POSTED_ERP] [INT]
			,[POSTED_ERP] [DATETIME]
			,[POSTED_RESPONSE] [VARCHAR](500)
			,[ERP_REFERENCE] [VARCHAR](15)
			,[ERP_REFERENCE_DOC_NUM] [VARCHAR](15)
			,[WAREHOUSE_CODE] [VARCHAR](25)
			,[CURRENCY] [VARCHAR](50)
			,[RATE] [NUMERIC](18, 6)
			,[TAX_CODE] [VARCHAR](50)
			,[VAT_PERCENT] [NUMERIC](18, 6)
			,[PRICE] [NUMERIC](18, 6)
			,[DISCOUNT] [NUMERIC](18, 6)
			,[COST_CENTER] [VARCHAR](25)
			,[QTY_ASSIGNED] [INT]
			,[UNIT] [VARCHAR](100)
			,[UNIT_DESCRIPTION] [VARCHAR](100)
			,[QTY_CONFIRMED] [NUMERIC](19, 6)
		);

	DECLARE	@DETAIL_RECEPTION_SERIES TABLE (
			[ID] INT
			,[MATERIAL_ID] [VARCHAR](50)
			,[SERIAL] [VARCHAR](50)
			,[SERIAL_PREFIX] [VARCHAR](20)
			,[SERIAL_CORRELATIVE] [NUMERIC](18, 0)
			,[SERIAL_CORRELATIVE_ID] [VARCHAR](20)
		);
	--
	DECLARE	@OPERACION TABLE (
			[Resultado] INT
			,[Mensaje] VARCHAR(1000)
			,[Codigo] INT
			,[DbData] VARCHAR(1000)
		);
	--

	DECLARE	@DOCUMENT_TYPE VARCHAR(100);
	BEGIN TRAN;
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Inserta los valores del XML en la tabla @OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL
		-- ------------------------------------------------------------------------------------
		INSERT	INTO @DETAIL_ERP_RECEPTION
				(
					[ERP_RECEPTION_DOCUMENT_DETAIL_ID]
					,[ERP_RECEPTION_DOCUMENT_HEADER_ID]
					,[MATERIAL_ID]
					,[QTY]
					,[LINE_NUM]
					,[UNIT]
					,[UNIT_DESCRIPTION]
					,[QTY_CONFIRMED]
					,[WAREHOUSE_CODE]
				)
		SELECT
			[x].[Rec].[query]('./ERP_RECEPTION_DOCUMENT_DETAIL_ID').[value]('.',
											'int')  -- ERP_RECEPTION_DOCUMENT_DETAIL_ID - int
			,[x].[Rec].[query]('./ERP_RECEPTION_DOCUMENT_HEADER_ID').[value]('.',
											'int')  -- ERP_RECEPTION_DOCUMENT_HEADER_ID - int
			,[x].[Rec].[query]('./MATERIAL_ID').[value]('.',
											'varchar(50)')  -- MATERIAL_ID - varchar(50)
			,[x].[Rec].[query]('./QTY').[value]('.',
											'numeric(19, 6)')  -- QTY - int
			,[x].[Rec].[query]('./LINE_NUM').[value]('.',
											'int')  -- LINE_NUM - int
			,[x].[Rec].[query]('./UNIT').[value]('.',
											'varchar(50)')  -- UNIT - varchar(100)
			,[x].[Rec].[query]('./UNIT_DESCRIPTION').[value]('.',
											'varchar(100)')  -- UNIT_DESCRIPTION - varchar(100)
			,[x].[Rec].[query]('./QTY_CONFIRMED').[value]('.',
											'numeric(19, 6)')  -- QTY_CONFIRMED - numeric
			,[x].[Rec].[query]('./WAREHOUSE_CODE').[value]('.',
											'VARCHAR(50)')  -- QTY_CONFIRMED - numeric
		FROM
			@XML.[nodes]('/ArrayOfOrdenDeCompraDetalle/OrdenDeCompraDetalle')
			AS [x] ([Rec]);

		SELECT TOP 1
			@DOCUMENT_TYPE = [h].[TYPE]
		FROM
			@DETAIL_ERP_RECEPTION [d]
		INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [h] ON [h].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [d].[ERP_RECEPTION_DOCUMENT_HEADER_ID];
		-- ------------------------------------------------------------------------------------
		-- Inserta los valores del XML_SERIES en la tabla @DETAIL_RECEPTION_SERIES
		-- ------------------------------------------------------------------------------------
		INSERT	INTO @DETAIL_RECEPTION_SERIES
				(
					[ID]
					,[MATERIAL_ID]
					,[SERIAL]
					,[SERIAL_PREFIX]
					,[SERIAL_CORRELATIVE]
					,[SERIAL_CORRELATIVE_ID]
				)
		SELECT
			[x].[Rec].[query]('./ID').[value]('.', 'int')  -- ERP_RECEPTION_DOCUMENT_DETAIL_ID - int
			,[x].[Rec].[query]('./MATERIAL_ID').[value]('.',
											'varchar(50)')  -- ERP_RECEPTION_DOCUMENT_HEADER_ID - int
			,[x].[Rec].[query]('./SERIAL').[value]('.',
											'varchar(50)')  -- MATERIAL_ID - varchar(50)
			,[x].[Rec].[query]('./SERIAL_PREFIX').[value]('.',
											'varchar(20)')  -- QTY - int
			,[x].[Rec].[query]('./SERIAL_CORRELATIVE').[value]('.',
											'numeric(18,0)')  -- LINE_NUM - int
			,[x].[Rec].[query]('./SERIAL_CORRELATIVE_ID').[value]('.',
											'varchar(20)')  -- UNIT - varchar(100)
		FROM
			@XML_SERIES.[nodes]('/ArrayOfSerieRecepcionDetalle/SerieRecepcionDetalle')
			AS [x] ([Rec])
		INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [x].[Rec].[query]('./MATERIAL_ID').[value]('.',
											'varchar(50)') = [M].[MATERIAL_ID]
											AND [M].[HANDLE_CORRELATIVE_SERIALS] = 1
											AND @DOCUMENT_TYPE NOT IN (
											'RECEPCION_GENERAL',
											'DEVOLUCION_FACTURA');

		DECLARE	@ID_TABLA INT;
		DECLARE
			@SERIAL_PREFIX VARCHAR(20)
			,@SERIAL_CORRELATIVE NUMERIC(18, 0)
			,@SERIAL_CORRELATIVE_ID VARCHAR(20);

		WHILE EXISTS ( SELECT TOP 1
							1
						FROM
							@DETAIL_RECEPTION_SERIES )
		BEGIN
			SELECT TOP 1
				@ID_TABLA = [RS].[ID]
				,@SERIAL_PREFIX = [RS].[SERIAL_PREFIX]
				,@SERIAL_CORRELATIVE = [RS].[SERIAL_CORRELATIVE]
				,@SERIAL_CORRELATIVE_ID = [RS].[SERIAL_CORRELATIVE_ID]
			FROM
				@DETAIL_RECEPTION_SERIES [RS];

			IF EXISTS ( SELECT TOP 1
							1
						FROM
							[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER]
						WHERE
							[SERIAL_PREFIX] = @SERIAL_PREFIX
							AND [SERIAL_CORRELATIVE] = @SERIAL_CORRELATIVE
							AND [SERIAL_CORRELATIVE_ID] = @SERIAL_CORRELATIVE_ID
							AND [STATUS] > 0 )
			BEGIN
				RAISERROR('Esta tratando de ingresar un correlativo que fue previamente asignado a otra serie.', 16,1);
			END;

			UPDATE
				[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER]
			SET	
				[SERIAL_PREFIX] = @SERIAL_PREFIX
				,[SERIAL_CORRELATIVE] = @SERIAL_CORRELATIVE
				,[SERIAL_CORRELATIVE_ID] = @SERIAL_CORRELATIVE_ID
			WHERE
				[CORRELATIVE] = @ID_TABLA;

			DELETE FROM
				@DETAIL_RECEPTION_SERIES
			WHERE
				[ID] = @ID_TABLA;
		END;

		-- ------------------------------------------------------------------------------------
		-- obtenemos los ids de todos los documentos que estan consolidados
		-- ------------------------------------------------------------------------------------
		DECLARE	@CURSOR_RECEPTION_HEADER_ID INT;

		DECLARE [HEADERS_FROM_TASK] CURSOR
		FOR
		SELECT
			[ERP_RECEPTION_DOCUMENT_HEADER_ID]
		FROM
			@DETAIL_ERP_RECEPTION
		GROUP BY
			[ERP_RECEPTION_DOCUMENT_HEADER_ID];

		
		OPEN [HEADERS_FROM_TASK];

		FETCH NEXT FROM [HEADERS_FROM_TASK]
		INTO @CURSOR_RECEPTION_HEADER_ID;

		-- ------------------------------------------------------------------------------------
		-- el object type es el mismo para toda la tarea
		-- ------------------------------------------------------------------------------------

		SELECT TOP 1
			@ERP_OBJECT_TYPE = [RDD].[ERP_OBJECT_TYPE]
		FROM
			@DETAIL_ERP_RECEPTION [DRE]
		INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [RDD] ON [RDD].[ERP_RECEPTION_DOCUMENT_DETAIL_ID] = [DRE].[ERP_RECEPTION_DOCUMENT_DETAIL_ID];

		-- ------------------------------------------------------------------------------------
		-- si es null ERP_OBJECT_TYPE le asignamos -1 porque viene de una recepcion general
		-- ------------------------------------------------------------------------------------
		SET @ERP_OBJECT_TYPE = ISNULL(@ERP_OBJECT_TYPE, -1);--'-1' es para recepcion general


		WHILE @@FETCH_STATUS = 0
		BEGIN
		-- ------------------------------------------------------------------------------------
		-- Obtiene valores persistentes del detalle de la recepcion
		-- ------------------------------------------------------------------------------------	

			SELECT TOP 1
				@WAREHOUSE_CODE = [RDD].[WAREHOUSE_CODE]
				,@COST_CENTER = [RDD].[COST_CENTER]
				,@RECEPTION_HEADER_ID = [DRE].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
				,@HEADER_ID = [RDD].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
			FROM
				@DETAIL_ERP_RECEPTION [DRE]
			INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [RDD] ON [RDD].[ERP_RECEPTION_DOCUMENT_DETAIL_ID] = [DRE].[ERP_RECEPTION_DOCUMENT_DETAIL_ID]
			WHERE
				[DRE].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @CURSOR_RECEPTION_HEADER_ID;

			-- ------------------------------------------------------------------------------------
			-- SI ES RECEPCION GENERAL ASIGNAMOS VALORES 
			-- ------------------------------------------------------------------------------------
			IF @CURSOR_RECEPTION_HEADER_ID = -50 --ESTE VALOR LO ASIGNAMOS CUANDO ES RECEPCION GENERAL EN EL CODIGO BO
				
			BEGIN
				SELECT TOP 1
					@RECEPTION_HEADER_ID = [RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
				FROM
					[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH]
				WHERE
					[TASK_ID] = @TASK_ID;
			END;
		

		-- ------------------------------------------------------------------------------------
		-- Verifica que la tarea este completada
		-- ------------------------------------------------------------------------------------
			IF EXISTS ( SELECT
							*
						FROM
							[wms].[OP_WMS_TASK_LIST]
						WHERE
							[SERIAL_NUMBER] = @TASK_ID
							AND [IS_COMPLETED] <> 1 )
			BEGIN
				RAISERROR('La tarea de recepción debe de estar completada para confirmar la recepción.', 16,1);
			END;
		
		-- ------------------------------------------------------------------------------------
		-- Verifica la bodega de destino para la recepcion por traslado 
		-- ------------------------------------------------------------------------------------
			
			IF ((SELECT [wms].[OP_WMS_FN_GET_WAREHOUSE_ID_BY_TASK_ID](@TASK_ID)) IS NOT NULL) 
			BEGIN
				DECLARE	@DETAIL_ERP_RECEPTION_COUNT TABLE (
					 ID  INT NOT NULL  IDENTITY(1,1)
					,[ERP_RECEPTION_DOCUMENT_DETAIL_ID] [INT]
					,[WAREHOUSE_CODE] [VARCHAR](25)
				);
				
				INSERT	INTO @DETAIL_ERP_RECEPTION_COUNT
				(
					[ERP_RECEPTION_DOCUMENT_DETAIL_ID]
					,[WAREHOUSE_CODE]
				)
				SELECT 
					[ERP_RECEPTION_DOCUMENT_DETAIL_ID],
					[WAREHOUSE_CODE]
				FROM
					@DETAIL_ERP_RECEPTION
				
				SET @WAREHOUSE_NAME_ERROR = 'La tarea tiene que estar en la bodega destino del traslado ' + (SELECT [wms].[OP_WMS_FN_GET_WAREHOUSE_ID_BY_TASK_ID](@TASK_ID)) 
				
				WHILE @COUNTER <= (SELECT COUNT(WAREHOUSE_CODE) FROM @DETAIL_ERP_RECEPTION) 
				BEGIN  
					
					SELECT TOP 1
						[ERP_RECEPTION_DOCUMENT_DETAIL_ID],
						[WAREHOUSE_CODE]
					FROM
						@DETAIL_ERP_RECEPTION_COUNT

					IF NOT EXISTS (
						SELECT 
							*
						FROM [wms].[OP_WMS_TRANSFER_REQUEST_HEADER] TH 
							INNER JOIN [wms].[OP_WMS_TASK_LIST] TK 
								ON (TH.TRANSFER_REQUEST_ID = TK.TRANSFER_REQUEST_ID)
							INNER JOIN wms.OP_WMS_WAREHOUSES W
								ON (W.WAREHOUSE_ID = TH.WAREHOUSE_TO)
							INNER JOIN @DETAIL_ERP_RECEPTION_COUNT DT
								ON (DT.WAREHOUSE_CODE = W.ERP_WAREHOUSE)
						WHERE SERIAL_NUMBER = @TASK_ID
								AND DT.WAREHOUSE_CODE = (SELECT [wms].[OP_WMS_FN_GET_WAREHOUSE_CODE_ERP_BY_WAREHOUSE_ID](TH.WAREHOUSE_TO))
								AND DT.ID = @COUNTER
						)
					BEGIN 
						RAISERROR( @WAREHOUSE_NAME_ERROR, 16,1);
					END;
				
				
					DELETE FROM @DETAIL_ERP_RECEPTION_COUNT WHERE ID = @COUNTER
					SET @COUNTER = @COUNTER + 1	
				END;
			END;

		-- ------------------------------------------------------------------------------------
		-- Hace merge entre la tabla OP_WMS_CLASS y los valores insertados anteriormente 
		-- Que corresponden al header iterado
		-- ------------------------------------------------------------------------------------
			MERGE [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL]
				AS [RD]
			USING
				(SELECT
						[ERP_RECEPTION_DOCUMENT_DETAIL_ID]
						,[ERP_RECEPTION_DOCUMENT_HEADER_ID]
						,[MATERIAL_ID]
						,[QTY]
						,[LINE_NUM]
						,[UNIT]
						,[UNIT_DESCRIPTION]
						,[QTY_CONFIRMED]
						,[WAREHOUSE_CODE]
					FROM
						@DETAIL_ERP_RECEPTION
					WHERE
						[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @CURSOR_RECEPTION_HEADER_ID)
				AS [DET]
			ON [DET].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [RD].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
				AND [DET].[MATERIAL_ID] = [RD].[MATERIAL_ID]
				AND ([DET].[UNIT] = [RD].[UNIT] OR [RD].[UNIT] IS NULL)
				AND [DET].[ERP_RECEPTION_DOCUMENT_DETAIL_ID] = [RD].[ERP_RECEPTION_DOCUMENT_DETAIL_ID]
			WHEN MATCHED THEN
				UPDATE SET
							[RD].[QTY_CONFIRMED] = [DET].[QTY_CONFIRMED]
							,[RD].[UNIT] = [DET].[UNIT]
							,[RD].[UNIT_DESCRIPTION] = [DET].[UNIT_DESCRIPTION]
							,[RD].[QTY_ASSIGNED] = [DET].[QTY_CONFIRMED]
							,[RD].[IS_CONFIRMED] = 1
							,[RD].[WAREHOUSE_CODE] = CASE
											WHEN ISNULL([DET].[WAREHOUSE_CODE],
											'') <> ''
											THEN [DET].[WAREHOUSE_CODE]
											ELSE [RD].[WAREHOUSE_CODE]
											END
			WHEN NOT MATCHED THEN
				INSERT
						(
							[ERP_RECEPTION_DOCUMENT_HEADER_ID]
							,[MATERIAL_ID]
							,[QTY]
							,[LINE_NUM]
							,[ERP_OBJECT_TYPE]
							,[ATTEMPTED_WITH_ERROR]
							,[IS_POSTED_ERP]
							,[POSTED_ERP]
							,[POSTED_RESPONSE]
							,[ERP_REFERENCE]
							,[ERP_REFERENCE_DOC_NUM]
							,[WAREHOUSE_CODE]
							,[CURRENCY]
							,[RATE]
							,[TAX_CODE]
							,[VAT_PERCENT]
							,[PRICE]
							,[DISCOUNT]
							,[COST_CENTER]
							,[QTY_ASSIGNED]
							,[UNIT]
							,[UNIT_DESCRIPTION]
							,[QTY_CONFIRMED]
							,[IS_CONFIRMED]
						)
				VALUES	(
							@RECEPTION_HEADER_ID
							,[DET].[MATERIAL_ID]
							,[DET].[QTY]
							,-1	  -- LINE_NUM
							,@ERP_OBJECT_TYPE
							,0	  -- ATTEMPTED_WITH_ERROR
							,0    -- IS_POSTED_ERP
							,NULL -- POSTED_ERP
							,NULL -- POSTED_RESPONSE
							,NULL -- ERP_REFERENCE
							,NULL -- ERP_REFERENCE_DOC_NUM
							,[DET].[WAREHOUSE_CODE]
							,NULL --CURRENCY
							,NULL --RATE
							,NULL --TAX_CODE
							,NULL --VAT_PERCENT
							,NULL --PRICE
							,NULL --DISCOUNT
							,@COST_CENTER		--COST_CENTER
							,[DET].[QTY]
							,[DET].[UNIT]
							,[DET].[UNIT_DESCRIPTION]
							,[DET].[QTY_CONFIRMED]
							,1
							
						);

		-- ------------------------------------------------------------------------------------
		-- se actualiza para poder enviar a erp
		-- ------------------------------------------------------------------------------------
			INSERT	INTO @OPERACION
					EXEC [wms].[OP_WMS_SP_AUTHORIZE_ERP_RECEPTION_DOCUMENT] @ERP_RECEPTION_DOCUMENT_HEADER_ID = @RECEPTION_HEADER_ID, -- int
						@LAST_UPDATE_BY = @LOGIN,
						@CONFIRMED = 1; -- varchar(50)
						
		
			IF EXISTS ( SELECT TOP 1
							1
						FROM
							@OPERACION
						WHERE
							[Resultado] = -1 )
			BEGIN
				RAISERROR('Error al marcar como autorizada la tarea de recepcion', 16,1);
			END;

		-- ------------------------------------------------------------------------------------
		-- Verifica que todas las lineas hayan sido confirmadas
		-- ------------------------------------------------------------------------------------
			IF EXISTS ( SELECT TOP 1
							1
						FROM
							[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL]
						WHERE
							(
								[IS_CONFIRMED] = 0
								OR [QTY_CONFIRMED] < [QTY]
							)
							AND [ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_HEADER_ID )
			BEGIN
				SELECT
					@IS_COMPLETED = 0;
			END;




		-- ------------------------------------------------------------------------------------
		-- Actualiza las lineas que no fueron confirmadas, las confirma y les deja un valor de confirmacion 0 para la obtencion de los detalles de ordenes
		-- de compra en la pantalla de ingreso erp
		-- ------------------------------------------------------------------------------------
			UPDATE
				[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL]
			SET	
				[IS_CONFIRMED] = 1
				,[QTY_ASSIGNED] = 0
				,[QTY_CONFIRMED] = 0
			WHERE
				[IS_CONFIRMED] = 0
				AND [ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_HEADER_ID;

			
		-- ------------------------------------------------------------------------------------
		-- Validar si no se confirmo nada para el documento
		-- ------------------------------------------------------------------------------------
			SELECT TOP 1
				@HAS_DETAIL = 1
			FROM
				[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL]
			WHERE
				[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_HEADER_ID
				AND [QTY_CONFIRMED] > 0; 

		-- ------------------------------------------------------------------------------------
		-- Actualiza el encabezado y le coloca is_completed dependiendo al valor anterior
		-- ------------------------------------------------------------------------------------
			UPDATE
				[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
			SET	
				[IS_COMPLETE] = @IS_COMPLETED
				,[DATE_CONFIRMED] = GETDATE()
				,[IS_POSTED_ERP] = CASE	WHEN @HAS_DETAIL = 0
										THEN 1
										ELSE 0
									END
				,[POSTED_RESPONSE] = CASE	WHEN @HAS_DETAIL = 0
											THEN 'No se confirmó detalle para documento, no se enviará a ERP.'
											ELSE ''
										END
			WHERE
				[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_HEADER_ID;

			
			SELECT
				@IS_COMPLETED = 1
				,@HAS_DETAIL = 0; 

			FETCH NEXT FROM [HEADERS_FROM_TASK]
		INTO @CURSOR_RECEPTION_HEADER_ID;
		END;

		COMMIT;	

		CLOSE [HEADERS_FROM_TASK];
		DEALLOCATE [HEADERS_FROM_TASK];
		--
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,'' [DbData];
	END TRY
	BEGIN CATCH
		-- ------------------------------------------------------------------------------------
		-- Despliega el error
		-- ------------------------------------------------------------------------------------
		ROLLBACK;
		--
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo]; 
	END CATCH;

END;