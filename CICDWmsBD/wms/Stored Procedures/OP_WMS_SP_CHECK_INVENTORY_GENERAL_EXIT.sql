-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	7/10/2017 @ NEXUS-Team Sprint AgeOfEmpires 
-- Description:			Valida el inventario de un egreso general por medio de un XML.

-- Modificacion:		henry.rodriguez
-- Fecha:				18-Julio-2019 G-Force@Dublin
-- Descricpion:			Se agrego campo Project_Id y validacion si maneja proyecto.

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_CHECK_INVENTORY_GENERAL_EXIT]
					@XML = N'
<EGRESO>
  <MATERIAL>
    <TASK_OWNER>ADMIN</TASK_OWNER>
    <TASK_ASSIGNEDTO>ACAMACHO</TASK_ASSIGNEDTO>
    <QUANTITY_ASSIGNED>3095</QUANTITY_ASSIGNED>
    <CODIGO_POLIZA_TARGET>0</CODIGO_POLIZA_TARGET>
    <MATERIAL_ID>wms/SKUPRUEBA</MATERIAL_ID>
    <BARCODE_ID>wms/SKUPRUEBA</BARCODE_ID>
    <ALTERNATE_BARCODE>wms/SKUPRUEBA</ALTERNATE_BARCODE>
    <MATERIAL_NAME>Prueba</MATERIAL_NAME>
    <CLIENT_OWNER>wms</CLIENT_OWNER>
    <CLIENT_NAME>wms Guatemala</CLIENT_NAME>
    <INVENTORY>3095</INVENTORY>
    <grabo>NO</grabo>
    <IS_MASTER_PACK>1</IS_MASTER_PACK>
  </MATERIAL>
  <MATERIAL>
    <TASK_OWNER>ADMIN</TASK_OWNER>
    <TASK_ASSIGNEDTO>ACAMACHO</TASK_ASSIGNEDTO>
    <QUANTITY_ASSIGNED>9582</QUANTITY_ASSIGNED>
    <CODIGO_POLIZA_TARGET>0</CODIGO_POLIZA_TARGET>
    <MATERIAL_ID>wms/RD001</MATERIAL_ID>
    <BARCODE_ID>wms/RD001</BARCODE_ID>
    <ALTERNATE_BARCODE>wms/RD001</ALTERNATE_BARCODE>
    <MATERIAL_NAME>Radiadores</MATERIAL_NAME>
    <CLIENT_OWNER>wms</CLIENT_OWNER>
    <CLIENT_NAME>wms Guatemala</CLIENT_NAME>
    <INVENTORY>9582</INVENTORY>
    <grabo>NO</grabo>
    <IS_MASTER_PACK>1</IS_MASTER_PACK>
  </MATERIAL>
</EGRESO>'
					, @WAREHOUSE_ID = 'BODEGA_01'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_CHECK_INVENTORY_GENERAL_EXIT] (
		@XML XML
		,@WAREHOUSE_ID VARCHAR(25)
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE	@MATERIAL_ID VARCHAR(50);
	DECLARE	@QUANTITY_ASSIGNED INT;
	DECLARE	@CLIENT_OWNER VARCHAR(25);
	DECLARE	@IS_MASTER_PACK INT;
	DECLARE	@PROJECT_ID AS VARCHAR(50);
	
	DECLARE	@CURRENTLY_AVAILABLE INT;
	DECLARE	@NEEDED_FOR_ASSEMBLY INT;
	DECLARE	@ASSEMBLY_QUANTITY INT;
	--
	DECLARE	@RESULT_DETAIL TABLE (
			[MATERIAL_ID] VARCHAR(50)
			,[QTY] INT
			,[AVAILABLE] INT
			,[QTY_NEEDED] INT
			,[IS_MASTER_PACK] INT
			,UNIQUE NONCLUSTERED ([MATERIAL_ID])
		);
	--
	DECLARE	@RESULT_COMPONENT TABLE (
			[MATERIAL_ID] VARCHAR(50)
			,[QTY] INT
			,[AVAILABLE] INT
			,[QTY_NEEDED] INT
			,[MASTER_PACK_ID] VARCHAR(50)
			--,UNIQUE NONCLUSTERED
			--	([MATERIAL_ID], [MASTER_PACK_ID])
		);
	--
	DECLARE	@MP_COMPONENT TABLE (
			[MATERIAL_ID] VARCHAR(50)
			,[AVAILABLE] INT
			,[QTY_NEEDED] INT
			,[REAL_QTY] INT
			--,UNIQUE NONCLUSTERED ([MATERIAL_ID])
		);
	--
	BEGIN TRY
		print ('inicio');

		-- ------------------------------------------------------------------------------------
		-- Guarda todo el detalle del egreso a una tabla temporal [#EXIT] y elimina todos los que ya fueron grabados
		-- ------------------------------------------------------------------------------------
		SELECT
			[x].[Rec].[query]('./TASK_OWNER').[value]('.',
											'varchar(50)') [TASK_OWNER]
			,[x].[Rec].[query]('./TASK_ASSIGNEDTO').[value]('.',
											'varchar(50)') [TASK_ASSIGNEDTO]
			,[x].[Rec].[query]('./QUANTITY_ASSIGNED').[value]('.',
											'numeric(18,4)') [QUANTITY_ASSIGNED]
			,[x].[Rec].[query]('./CODIGO_POLIZA_TARGET').[value]('.',
											'int') [CODIGO_POLIZA_TARGET]
			,[x].[Rec].[query]('./MATERIAL_ID').[value]('.',
											'varchar(50)') [MATERIAL_ID]
			,[x].[Rec].[query]('./BARCODE_ID').[value]('.',
											'varchar(25)') [BARCODE_ID]
			,[x].[Rec].[query]('./ALTERNATE_BARCODE').[value]('.',
											'varchar(25)') [ALTERNATE_BARCODE]
			,[x].[Rec].[query]('./MATERIAL_NAME').[value]('.',
											'varchar(200)') [MATERIAL_NAME]
			,[x].[Rec].[query]('./CLIENT_OWNER').[value]('.',
											'varchar(25)') [CLIENT_OWNER]
			,[x].[Rec].[query]('./CLIENT_NAME').[value]('.',
											'varchar(200)') [CLIENT_NAME]
			,[x].[Rec].[query]('./INVENTORY').[value]('.',
											'numeric(18,4)') [INVENTORY]
			,[x].[Rec].[query]('./grabo').[value]('.',
											'varchar(10)') [grabo]
			,[x].[Rec].[query]('./IS_MASTER_PACK').[value]('.',
											'int') [IS_MASTER_PACK]
			,[x].[Rec].[query]('./PROJECT_NAME').[value]('.',
											'varchar(150)') [PROJECT_NAME]
			,[x].[Rec].[query]('./PROJECT_ID').[value]('.',
											'varchar(50)') [PROJECT_ID]
		INTO
			[#EXIT]
		FROM
			@XML.[nodes]('/EGRESO/MATERIAL') AS [x] ([Rec]);

		DELETE FROM
			[#EXIT]
		WHERE
			[grabo] = 'SI';
		-- ------------------------------------------------------------------------------------
		-- Procesa los detalles que no son masterpacks
		-- ------------------------------------------------------------------------------------
		WHILE EXISTS ( SELECT TOP 1
							1
						FROM
							[#EXIT]
						WHERE
							[IS_MASTER_PACK] = 0 )
		BEGIN
			SELECT TOP 1
				@MATERIAL_ID = [e].[MATERIAL_ID]
				,@QUANTITY_ASSIGNED = [e].[QUANTITY_ASSIGNED]
				,@CLIENT_OWNER = [e].[CLIENT_OWNER]
				,@PROJECT_ID = [e].[PROJECT_ID]
			FROM
				[#EXIT] [e]
			WHERE
				[e].[IS_MASTER_PACK] = 0;

			IF @PROJECT_ID = ''
			BEGIN
				SET @PROJECT_ID = NULL;
			END;
			-- ------------------------------------------------------------------------------------
			-- Obtiene la cantidad disponible en la vista OP_WMS_VIEW_PICKING_AVAILABLE_GENERAL y le substrae la cantidad asignada
			-- ------------------------------------------------------------------------------------
			IF @PROJECT_ID IS NULL
			BEGIN	
				SELECT
					@CURRENTLY_AVAILABLE = SUM([QTY])
				FROM
					[wms].[OP_WMS_VIEW_PICKING_AVAILABLE_GENERAL]
				WHERE
					[CLIENT_OWNER] = @CLIENT_OWNER
					AND [MATERIAL_ID] = @MATERIAL_ID
					AND [CURRENT_WAREHOUSE] = @WAREHOUSE_ID;
			END;	
			ELSE
			BEGIN
				SELECT
					@CURRENTLY_AVAILABLE = ISNULL(SUM([ORP].[QTY_RESERVED]
											- [ORP].[QTY_DISPATCHED]),
											0)
				FROM
					[wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT] [ORP]
				INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON (
											[ORP].[LICENSE_ID] = [IL].[LICENSE_ID]
											AND [ORP].[MATERIAL_ID] = [IL].[MATERIAL_ID]
											)
				INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON ([L].[LICENSE_ID] = [IL].[LICENSE_ID])
				WHERE
					[ORP].[PROJECT_ID] = @PROJECT_ID
					AND [ORP].[MATERIAL_ID] = @MATERIAL_ID
					AND [L].[CURRENT_WAREHOUSE] = @WAREHOUSE_ID;
			END;
			
			-- ------------------------------------------------------------------------------------
			-- Inserta en la tabla de resultado @DETAIL_RESULT
			-- ------------------------------------------------------------------------------------
			INSERT	INTO @RESULT_DETAIL
					(
						[MATERIAL_ID]
						,[QTY]
						,[AVAILABLE]
						,[QTY_NEEDED]
						,[IS_MASTER_PACK]
					)
			VALUES
					(
						@MATERIAL_ID  -- MATERIAL_ID - varchar(50)
						,@QUANTITY_ASSIGNED  -- QTY - int
						,@CURRENTLY_AVAILABLE  -- AVAILABLE - int
						, @CURRENTLY_AVAILABLE -@QUANTITY_ASSIGNED  -- QTY_NEEDED - int
						,0  -- IS_MASTER_PACK - int
					);
			print ('inserted result detail: '+@MATERIAL_ID);
			-- ------------------------------------------------------------------------------------
			-- Quita el material de la tabla temporal
			-- ------------------------------------------------------------------------------------
			DELETE FROM
				[#EXIT]
			WHERE
				[MATERIAL_ID] = @MATERIAL_ID
				AND [CLIENT_OWNER] = @CLIENT_OWNER;
		END;

		-- ------------------------------------------------------------------------------------
		-- Procesa los detalles masterpacks
		-- ------------------------------------------------------------------------------------
		WHILE EXISTS ( SELECT TOP 1
							1
						FROM
							[#EXIT]
						WHERE
							[IS_MASTER_PACK] = 1 )
		BEGIN
			SELECT TOP 1
				@MATERIAL_ID = [e].[MATERIAL_ID]
				,@QUANTITY_ASSIGNED = [e].[QUANTITY_ASSIGNED]
				,@CLIENT_OWNER = [e].[CLIENT_OWNER]
			FROM
				[#EXIT] [e]
			WHERE
				[IS_MASTER_PACK] = 1;
			-- ------------------------------------------------------------------------------------
			-- Obtiene el inventario disponible de masterpacks ya armados
			-- ------------------------------------------------------------------------------------
			SELECT
				@CURRENTLY_AVAILABLE = (SUM([VPAG].[QTY])
										- (ISNULL([RD].[QTY],
											0)
											+ ISNULL([RC].[QTY],
											0)))
			FROM
				[wms].[OP_WMS_VIEW_PICKING_AVAILABLE_GENERAL] [VPAG]
			LEFT JOIN @RESULT_DETAIL [RD] ON [RD].[MATERIAL_ID] = [VPAG].[MATERIAL_ID]
			LEFT JOIN @RESULT_COMPONENT [RC] ON [RC].[MATERIAL_ID] = [VPAG].[MATERIAL_ID]
			WHERE
				[VPAG].[CLIENT_OWNER] = @CLIENT_OWNER
				AND [VPAG].[MATERIAL_ID] = @MATERIAL_ID
				AND [VPAG].[CURRENT_WAREHOUSE] = @WAREHOUSE_ID
			GROUP BY
				[RD].[QTY]
				,[RC].[QTY];

			-- ------------------------------------------------------------------------------------
			-- Si el inventario disponible es suficiente para el producto lo inserta a la tabla de resultados con sus valores.
			-- De lo contrario explota sus componentes y verifica el inventario utilizando tambien el inventario de resultado.
			-- ------------------------------------------------------------------------------------
			IF @CURRENTLY_AVAILABLE >= @QUANTITY_ASSIGNED
			BEGIN
				INSERT	INTO @RESULT_DETAIL
						(
							[MATERIAL_ID]
							,[QTY]
							,[AVAILABLE]
							,[QTY_NEEDED]
							,[IS_MASTER_PACK]
						)
				VALUES
						(
							@MATERIAL_ID  -- MATERIAL_ID - varchar(50)
							,@QUANTITY_ASSIGNED  -- QTY - int
							,@CURRENTLY_AVAILABLE  -- AVAILABLE - int
							,@CURRENTLY_AVAILABLE
							- @QUANTITY_ASSIGNED  -- QTY_NEEDED - int
							,1  -- IS_MASTER_PACK - int
						);
			END;
			ELSE
			BEGIN
				SELECT
					@NEEDED_FOR_ASSEMBLY = @QUANTITY_ASSIGNED
					- ISNULL(@CURRENTLY_AVAILABLE, 0);
				-- ------------------------------------------------------------------------------------
				-- Explota el masterpack a un nivel y valida que haya inventario suficiente por cada uno de sus componentes.
				-- ------------------------------------------------------------------------------------
				INSERT	INTO @MP_COMPONENT
						(
							[MATERIAL_ID]
							,[AVAILABLE]
							,[QTY_NEEDED]
							,[REAL_QTY]
						)
				SELECT
					[CXMP].[COMPONENT_MATERIAL] [MATERIAL_ID]
					,SUM(ISNULL([IXW].[QTY], 0))
					- (ISNULL([RD].[QTY], 0)
						+ ISNULL([RC].[QTY], 0)) [AVAILABLE]
					,([CXMP].[QTY] * @NEEDED_FOR_ASSEMBLY) [QTY_NEEDED]
					,CAST((SUM(ISNULL([IXW].[QTY], 0))
							- (ISNULL([RD].[QTY], 0)
								+ ISNULL([RC].[QTY], 0)))
					/ [CXMP].[QTY] AS INT) [REAL_QTY]
				FROM
					[wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [CXMP]
				LEFT JOIN [wms].[OP_WMS_VIEW_PICKING_AVAILABLE_GENERAL] [IXW] ON [IXW].[MATERIAL_ID] = [CXMP].[COMPONENT_MATERIAL]
											AND [IXW].[CURRENT_WAREHOUSE] = @WAREHOUSE_ID
				LEFT JOIN @RESULT_DETAIL [RD] ON [RD].[MATERIAL_ID] = [CXMP].[COMPONENT_MATERIAL]
				LEFT JOIN @RESULT_COMPONENT [RC] ON [RC].[MATERIAL_ID] = [CXMP].[COMPONENT_MATERIAL]
				WHERE
					[CXMP].[MASTER_PACK_CODE] = @MATERIAL_ID
				GROUP BY
					[CXMP].[COMPONENT_MATERIAL]
					,[CXMP].[QTY]
					,[RD].[QTY]
					,[RC].[QTY];


				-- ------------------------------------------------------------------------------------
				-- Inserta a la tabla de resultados por componente los que no tengan inventario suficiente y cuanto necesitan de inventario.
				-- ------------------------------------------------------------------------------------
				INSERT	INTO @RESULT_COMPONENT
						(
							[MATERIAL_ID]
							,[QTY]
							,[AVAILABLE]
							,[QTY_NEEDED]
							,[MASTER_PACK_ID]
						)
				SELECT
					[MATERIAL_ID]
					,[QTY_NEEDED]
					,[AVAILABLE]
					,[AVAILABLE] - [QTY_NEEDED]
					,@MATERIAL_ID
				FROM
					@MP_COMPONENT;
				
				-- ------------------------------------------------------------------------------------
				-- Obtiene la cantidad que puede ser ensamblada
				-- ------------------------------------------------------------------------------------
				SELECT TOP 1
					@ASSEMBLY_QUANTITY = ISNULL([REAL_QTY],
											0)
				FROM
					@MP_COMPONENT
				ORDER BY
					[REAL_QTY] ASC;
			END;
			-- ------------------------------------------------------------------------------------
			-- Inserta el MP en la tabla RESULT si no tiene inventario suficiente
			-- ------------------------------------------------------------------------------------
			IF EXISTS ( SELECT TOP 1
							1
						FROM
							@RESULT_COMPONENT
						WHERE
							[MASTER_PACK_ID] = @MATERIAL_ID )
			BEGIN
				INSERT	INTO @RESULT_DETAIL
						(
							[MATERIAL_ID]
							,[QTY]
							,[AVAILABLE]
							,[QTY_NEEDED]
							,[IS_MASTER_PACK]
						)
				VALUES
						(
							@MATERIAL_ID  -- MATERIAL_ID - varchar(50)
							,@QUANTITY_ASSIGNED  -- QTY - int
							,@CURRENTLY_AVAILABLE
							+ @ASSEMBLY_QUANTITY  -- AVAILABLE - int
							,(@CURRENTLY_AVAILABLE
								+ @ASSEMBLY_QUANTITY)
							- @QUANTITY_ASSIGNED  -- QTY_NEEDED - int
							,1  -- IS_MASTER_PACK - int
						);
			END;
			-- ------------------------------------------------------------------------------------
			-- Quita el material de la tabla temporal
			-- ------------------------------------------------------------------------------------
			DELETE FROM
				[#EXIT]
			WHERE
				[MATERIAL_ID] = @MATERIAL_ID
				AND [CLIENT_OWNER] = @CLIENT_OWNER;
			-- ------------------------------------------------------------------------------------
			-- Elimina todos los registros de la tabla @MP_COMPONENT
			-- ------------------------------------------------------------------------------------
			DELETE FROM
				@MP_COMPONENT;
		END;

		-- ------------------------------------------------------------------------------------
		-- Muestra el resultado final y le da valor a la variable @NO_INVENTORY_MATERIAL_QTY
		-- ------------------------------------------------------------------------------------

		SELECT
			[MATERIAL_ID]
			,[QTY]
			,[AVAILABLE]
			,[QTY_NEEDED]
			,[IS_MASTER_PACK]
		FROM
			@RESULT_DETAIL
		WHERE
			[QTY_NEEDED] < 0; 

		-- ------------------------------------------------------------------------------------
		-- Muestra el resultado de los componentes
		-- ------------------------------------------------------------------------------------
		print '@NEEDED_FOR_ASSEMBLY'
		print @NEEDED_FOR_ASSEMBLY
		--select * from @RESULT_DETAIL
		--select * from @RESULT_COMPONENT
		SELECT
			[MATERIAL_ID]
			,[QTY]
			,[AVAILABLE]
			,[QTY_NEEDED]
			,[MASTER_PACK_ID]
		FROM
			@RESULT_COMPONENT
		WHERE
			[QTY_NEEDED] < 0;

	END TRY
	BEGIN CATCH

		DECLARE	@ERROR VARCHAR(1000) = ERROR_MESSAGE();
		PRINT 'CATCH: ' + @ERROR;
		RAISERROR (@ERROR, 16, 1);
	END CATCH;
END;