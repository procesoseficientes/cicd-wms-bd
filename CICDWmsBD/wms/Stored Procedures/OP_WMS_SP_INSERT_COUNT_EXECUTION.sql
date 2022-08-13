-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-02-21 @ Team ERGON - Sprint ERGON III
-- Description:	 Inserción de ejecución de conteo fisico. 

-- Autor:					marvin.solares
-- Fecha de Creacion: 		7/9/2018 GForce@FocaMonje 
-- Description:			    asigna el costo del material a la transaccion



/*
-- Ejemplo de Ejecucion:
			  SELECT * FROM [wms].[OP_WMS_INV_X_LICENSE] [OWIXL] INNER JOIN [wms].[OP_WMS_LICENSES] [OWL] ON [OWIXL].[LICENSE_ID] = [OWL].[LICENSE_ID] WHERE [OWIXL].[QTY] > 0  AND [OWL].[LICENSE_ID] = 45008
  SELECT * FROM [wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] [OWPCD] INNER JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_HEADER] [OWPCH] ON [OWPCD].[PHYSICAL_COUNT_HEADER_ID] = [OWPCH].[PHYSICAL_COUNT_HEADER_ID]
  
  EXEC [wms].[OP_WMS_SP_INSERT_COUNT_EXECUTION] @LOGIN = 'ACAMACHO'
                                                    ,@TASK_ID = 9
                                                    ,@LOCATION = 'B01-R01-C01-NB'
                                                    ,@LICENSE_ID = 127680
                                                    ,@MATERIAL_ID = 'C00030/LECH-CONDEN'
                                                    ,@QTY_SCANNED = 1.0000
                                                    ,@EXPIRATION_DATE = '2016-12-05'
                                                    ,@BATCH = '281617'
                                                    ,@SERIAL = 'GDR007'

  select  * from [wms].[OP_WMS_PHYSICAL_COUNTS_EXECUTION]
  select  * from [wms].[OP_WMS_PHYSICAL_COUNTS_HEADER]
  select  * from [wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_COUNT_EXECUTION] (
		@LOGIN VARCHAR(25)
		,@TASK_ID INT
		,@LOCATION VARCHAR(25)
		,@LICENSE_ID INT
		,@MATERIAL_ID VARCHAR(25)
		,@QTY_SCANNED NUMERIC(18, 4)
		,@EXPIRATION_DATE DATE = NULL
		,@BATCH VARCHAR(50) = NULL
		,@SERIAL VARCHAR(50) = NULL
		,@TYPE VARCHAR(50) = 'INSERT' -- INSERT/UPDATE/ADD
	)
AS
BEGIN
	SET NOCOUNT ON;

	---------------------------------------------------------------------------------
	-- Validar si la tarea fue cancelada
	---------------------------------------------------------------------------------  
	IF EXISTS ( SELECT TOP 1
					1
				FROM
					[wms].[OP_WMS_PHYSICAL_COUNTS_HEADER] [H]
				WHERE
					[H].[STATUS] = 'CANCELED'
					AND [H].[TASK_ID] = @TASK_ID )
	BEGIN
		RAISERROR ('Tarea fue cancelada.', 16, 1);
		RETURN;
	END;

	---------------------------------------------------------------------------------
	-- Validar si la tarea sigue asignada al operador.
	---------------------------------------------------------------------------------  
	IF NOT EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] [D]
					INNER JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_HEADER] [H] ON [D].[PHYSICAL_COUNT_HEADER_ID] = [H].[PHYSICAL_COUNT_HEADER_ID]
					WHERE
						[D].[LOCATION] = @LOCATION
						AND [D].[ASSIGNED_TO] = @LOGIN
						AND [H].[TASK_ID] = @TASK_ID
						AND [D].[STATUS] IN ('IN_PROGRESS',
											'CREATED') )
	BEGIN
		RAISERROR ('La tarea fue reasignada a otro operador o no se encuentra habilitada para operar.', 16, 1);
		RETURN;
	END;

	-- ------------------------------------------------------------------------------------
	-- Valida el tipo de accion
	-- ------------------------------------------------------------------------------------
	IF (@TYPE = 'ADD')
	BEGIN
		DECLARE	@DETAIL_ID INT;
		SELECT TOP 1
			@DETAIL_ID = [D].[PHYSICAL_COUNT_DETAIL_ID]
		FROM
			[wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] [D]
		INNER JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_HEADER] [H] ON [H].[PHYSICAL_COUNT_HEADER_ID] = [D].[PHYSICAL_COUNT_HEADER_ID]
		WHERE
			[H].[TASK_ID] = @TASK_ID
			AND @LOCATION = [D].[LOCATION]
			AND @LOGIN = [D].[ASSIGNED_TO];

		SELECT
			@QTY_SCANNED = [QTY_SCANNED] + @QTY_SCANNED
		FROM
			[wms].[OP_WMS_PHYSICAL_COUNTS_EXECUTION]
		WHERE
			[MATERIAL_ID] = @MATERIAL_ID
			AND [PHYSICAL_COUNT_DETAIL_ID] = @DETAIL_ID;
	END;
	---------------------------------------------------------------------------------
	-- Insertar transaccion de DETALLE de conteo 
	---------------------------------------------------------------------------------
	DECLARE
		@BARCODE_ID VARCHAR(25)
		,@MATERIAL_DESCRIPTION VARCHAR(200)
		,@CLIENT_OWNER VARCHAR(25)
		,@CLIENT_NAME VARCHAR(150)
		,@WAREHOUSE VARCHAR(25);

	SELECT TOP 1
		@BARCODE_ID = [M].[BARCODE_ID]
		,@MATERIAL_DESCRIPTION = [M].[MATERIAL_NAME]
		,@CLIENT_OWNER = [M].[CLIENT_OWNER]
	FROM
		[wms].[OP_WMS_MATERIALS] [M]
	WHERE
		[M].[MATERIAL_ID] = @MATERIAL_ID;

	SELECT TOP 1
		@CLIENT_NAME = [C].[CLIENT_NAME]
	FROM
		[wms].[OP_WMS_CLIENTS] [C]
	WHERE
		[C].[CLIENT_CODE] = @CLIENT_OWNER;

	SELECT TOP 1
		@WAREHOUSE = [S].[WAREHOUSE_PARENT]
	FROM
		[wms].[OP_WMS_SHELF_SPOTS] [S]
	WHERE
		[S].[LOCATION_SPOT] = @LOCATION;


	INSERT	INTO [wms].[OP_WMS_TRANS]
			(
				[TRANS_DATE]
				,[LOGIN_ID]
				,[LOGIN_NAME]
				,[TRANS_TYPE]
				,[TRANS_DESCRIPTION]
				,[MATERIAL_BARCODE]
				,[MATERIAL_CODE]
				,[MATERIAL_DESCRIPTION]
				,[MATERIAL_COST]
				,[TARGET_LICENSE]
				,[TARGET_LOCATION]
				,[CLIENT_OWNER]
				,[CLIENT_NAME]
				,[QUANTITY_UNITS]
				,[TARGET_WAREHOUSE]
				,[LICENSE_ID]
				,[STATUS]
				,[TASK_ID]
				,[SERIAL]
				,[BATCH]
				,[DATE_EXPIRATION]
				,[TRANS_SUBTYPE]
				,[SOURCE_LOCATION]
			)
	VALUES
			(
				GETDATE()
				,@LOGIN
				,(SELECT TOP 1
						[LOGIN_NAME]
					FROM
						[wms].[OP_WMS_FUNC_GETLOGIN_NAME](@LOGIN))
				,'CONTEO_FISICO'
				,'CONTEO UBICACION'
				,@BARCODE_ID
				,@MATERIAL_ID
				,@MATERIAL_DESCRIPTION
				,[wms].[OP_WMS_FN_GET_MATERIAL_COST_BY_MATERIAL](@MATERIAL_ID,
											@CLIENT_OWNER)
				,@LICENSE_ID
				,@LOCATION
				,@CLIENT_OWNER
				,@CLIENT_NAME
				,@QTY_SCANNED
				,@WAREHOUSE
				,@LICENSE_ID
				,'IN PROGRESS'
				,@TASK_ID
				,@SERIAL
				,@BATCH
				,@EXPIRATION_DATE
				,'INICIO DE UBICACION'
				,''
			);

	---------------------------------------------------------------------------------
	-- Validar si es la tarea esta en progreso e inserta transaccion de tarea de conteo
	---------------------------------------------------------------------------------  
	IF EXISTS ( SELECT TOP 1
					1
				FROM
					[wms].[OP_WMS_TASK] [T]
				WHERE
					@TASK_ID = [T].[TASK_ID]
					AND [T].[IS_ACCEPTED] = 0 )
	BEGIN
		UPDATE
			[wms].[OP_WMS_TASK]
		SET	
			[IS_ACCEPTED] = 1
			,[ACCEPTED_DATE] = GETDATE()
		WHERE
			[TASK_ID] = @TASK_ID;

		INSERT	INTO [wms].[OP_WMS_TRANS]
				(
					[TRANS_DATE]
					,[LOGIN_ID]
					,[LOGIN_NAME]
					,[TRANS_TYPE]
					,[TRANS_DESCRIPTION]
					,[TARGET_WAREHOUSE]
					,[STATUS]
					,[TASK_ID]
					,[TRANS_SUBTYPE]
					,[MATERIAL_BARCODE]
					,[MATERIAL_CODE]
					,[SOURCE_LOCATION]
					,[TARGET_LOCATION]
					,[QUANTITY_UNITS]
				)
		VALUES
				(
					GETDATE()
					,@LOGIN
					,(SELECT TOP 1
							[LOGIN_NAME]
						FROM
							[wms].[OP_WMS_FUNC_GETLOGIN_NAME](@LOGIN))
					,'CONTEO_FISICO'
					,'TAREA CONTEO FISICO'
					,@WAREHOUSE
					,'ACCEPTED'
					,@TASK_ID
					,'INICIO TAREA DE CONTEO'
					,''
					,''
					,''
					,''
					,0
				);

	END;

	---------------------------------------------------------------------------------
	-- Insertar el conteo eliminando si ya existe un conteo para el mismo material 
	---------------------------------------------------------------------------------
	DELETE
		[E]
	FROM
		[wms].[OP_WMS_PHYSICAL_COUNTS_EXECUTION] [E]
	INNER JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] [D] ON [D].[PHYSICAL_COUNT_DETAIL_ID] = [E].[PHYSICAL_COUNT_DETAIL_ID]
	INNER JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_HEADER] [H] ON [H].[PHYSICAL_COUNT_HEADER_ID] = [D].[PHYSICAL_COUNT_HEADER_ID]
	WHERE
		[E].[MATERIAL_ID] = @MATERIAL_ID
		AND [E].[LICENSE_ID] = @LICENSE_ID
		AND [E].[LOCATION] = @LOCATION
		AND [D].[LOCATION] = @LOCATION
		AND [H].[TASK_ID] = @TASK_ID
		--AND [E].[EXECUTED_BY] = @LOGIN
		--AND [D].[ASSIGNED_TO] = @LOGIN
		AND (
				[E].[BATCH] IS NULL
				OR [E].[BATCH] = @BATCH
			)
		AND (
				[E].[SERIAL] IS NULL
				OR [E].[SERIAL] = @SERIAL
			);



	INSERT	INTO [wms].[OP_WMS_PHYSICAL_COUNTS_EXECUTION]
	SELECT TOP 1
		[D].[PHYSICAL_COUNT_DETAIL_ID]
		,[D].[LOCATION]
		,@LICENSE_ID [LICENSE_ID]
		,@MATERIAL_ID [MATERIAL_ID]
		,@QTY_SCANNED [QTY_SCANNED]
		,CASE	WHEN @SERIAL IS NOT NULL THEN 1
				ELSE ISNULL([IL].[QTY], 0)
			END [QTY_EXPECTED]
		,CASE	WHEN @BATCH IS NOT NULL
						AND @SERIAL IS NULL
						AND [IL].[BATCH] <> @BATCH THEN 'M'
				WHEN @EXPIRATION_DATE IS NOT NULL
						AND @SERIAL IS NULL
						AND [IL].[DATE_EXPIRATION] <> @EXPIRATION_DATE
				THEN 'M'
				WHEN @BATCH IS NOT NULL
						AND @SERIAL IS NOT NULL
						AND [S].[BATCH] <> @BATCH THEN 'M'
				WHEN @EXPIRATION_DATE IS NOT NULL
						AND @SERIAL IS NOT NULL
						AND [S].[DATE_EXPIRATION] <> @EXPIRATION_DATE
				THEN 'M'
				WHEN @SERIAL IS NOT NULL
						AND [S].[CORRELATIVE] IS NULL
				THEN 'M'
				WHEN [IL].[QTY] IS NULL THEN 'M'
				WHEN @SERIAL IS NULL
						AND [IL].[QTY] <> @QTY_SCANNED
				THEN 'M'
				ELSE 'H'
			END [HIT_OR_MISS]
		,GETDATE() [EXECUTED]
		,@LOGIN [EXECUTED_BY]
		,@EXPIRATION_DATE [EXPIRATION_DATE]
		,@BATCH [BATCH]
		,@SERIAL [SERIAL]
		,CASE	WHEN @BATCH IS NOT NULL
						AND ISNULL([IL].[HANDLE_SERIAL], 0) = 0
				THEN [IL].[DATE_EXPIRATION]
				WHEN @BATCH IS NOT NULL
						AND ISNULL([IL].[HANDLE_SERIAL], 0) = 1
				THEN [S].[DATE_EXPIRATION]
				ELSE [IL].[DATE_EXPIRATION]
			END [EXPIRATION_DATE_EXPECTED]
		,CASE ISNULL([IL].[HANDLE_SERIAL], 0)
			WHEN 0 THEN [IL].[BATCH]
			WHEN 1 THEN [S].[BATCH]
			ELSE [IL].[BATCH]
			END [BATCH_EXPECTED]
		,[S].[SERIAL] [SERIAL_EXPECTED]
	FROM
		[wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] [D]
	INNER JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_HEADER] [H] ON [D].[PHYSICAL_COUNT_HEADER_ID] = [H].[PHYSICAL_COUNT_HEADER_ID]
	LEFT JOIN [wms].[OP_WMS_LICENSES] [L] ON [L].[CURRENT_LOCATION] = [D].[LOCATION]
											AND [L].[LICENSE_ID] = @LICENSE_ID
	LEFT JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON (
											[IL].[LICENSE_ID] = [L].[LICENSE_ID]
											AND @MATERIAL_ID = [IL].[MATERIAL_ID]
											--AND (
											--[IL].[HANDLE_SERIAL] = 1
											--OR (
											--@BATCH IS NULL
											--OR @BATCH = [IL].[BATCH]
											--)
											--)
											)
	LEFT JOIN [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [S] ON (
											[S].[STATUS] = 1
											AND [S].[MATERIAL_ID] = @MATERIAL_ID
											AND [L].[LICENSE_ID] = [S].[LICENSE_ID]
											AND [S].[SERIAL] = @SERIAL
											AND (
											@BATCH IS NULL
											OR @BATCH = [S].[BATCH]
											)
											)
	WHERE
		[H].[TASK_ID] = @TASK_ID
		AND @LOCATION = [D].[LOCATION]
		AND @LOGIN = [D].[ASSIGNED_TO]
	ORDER BY
		ISNULL([IL].[QTY], 0) DESC;

END;