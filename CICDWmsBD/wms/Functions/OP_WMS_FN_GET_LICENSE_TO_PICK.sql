-- =============================================
-- Autor:					pablo.aguilar
-- Fecha de Creacion: 		20-Dec-17 @ Nexus Team Sprint IceAge
-- Description:			    Función que obtiene las licencias a pickear de un material, bodega y cantidad especifica.

-- Autor:					marvin.solares
-- Fecha de Creacion: 		19-Abr-18 @ GForce Team Sprint 
-- Description:			    Se modifica sp para que devuelva la cantidad menos la cantidad comprometida.

-- Modificacion:			marvin.solares
-- Fecha: 					20180926 GForce@Kiwi 
-- Description:				se modifica para que devuelva primero las cantidades en las ubicaciones fast picking

-- Modificacion:			henry.rodriguez
-- Fecha:					18-Julio-2019 G-Force@Dublin
-- Descripcion:				Se modifica para que no devuelva las licencias con proyectos.

-- Autor:				marvin.solares
-- Fecha de Creacion: 	21-Ago-2019 @ G-Force-Team Sprint FlorencioVarela
-- Description:			agrego parámetro de mínimo de días de fecha de expiración
--						para que se omitan con fecha de expiración próximas a vencer

-- Autor:				marvin.solares
-- Fecha de Creacion: 	30-Ago-2019 @ G-Force-Team Sprint FlorencioVarela
-- Descripcion:			agrego como parámetro una licencia de la cual no quiero que se tome en cuenta su inventario disponible en el algoritmo de picking

-- Autor:				Gildardo Alvarado; Arleny Sabillon
-- Fecha de Creacion: 	30-diciem-2020 Equipo soporte wms
-- Descripcion:			Se le cambio la vista al tipo de los que no manejan lote de OP_WMS_VIEW_PICKING_AVAILABLE_GENERAL a OP_WMS_VIEW_PICKING_AVAILABLE_GENERAL_BATCH
--						Se cambio la condicion de cantidad a fecha

-- Autor:				Gildardo Alvarado; 
-- Fecha de Creacion: 	6-Ene-2021 Equipo soporte wms
-- Descripcion:			se agrego el campo DATE_EXPIRATION a la tabla @LICENSE Y @LICENSE_TEMPORAL


/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [wms].[OP_WMS_FN_GET_LICENSE_TO_PICK]('wms/I00000002','BODEGA_02',255,1,NULL,10)
		SELECT * FROM [wms].[OP_WMS_FN_GET_LICENSE_TO_PICK]('autovanguard/VAA1001','BODEGA_01',225,0,NULL)
		SELECT * FROM [wms].OP_WMS_INV_X_LICENSE IL
		INNER JOIN [wms].OP_WMS_LICENSES L ON IL.LICENSE_ID = L.LICENSE_ID WHERE MATERIAL_ID = 'viscosa/VWD1002'
		SELECT * FROM [wms].OP_WMS_MATERIALS WHERE MATERIAL_ID = 'wms/I00000002'
		SELECT * FROM [wms].OP_WMS_TASK_LIST WHERE MATERIAL_ID = 'wms/I00000002'
		
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_LICENSE_TO_PICK] (
		@MATERIAL_ID VARCHAR(50)
		,@WAREHOUSE VARCHAR(25)
		,@QUANTITY_ASSIGNED NUMERIC(18, 4)
		,@HANDLE_BATCH INT
		,@PICKING_TYPE VARCHAR(25) = NULL
		,@PICKING_HEADER_ID INT = NULL
		,@STATUS_CODE VARCHAR(50) = NULL
		,@MIN_DAYS_EXPIRATION_DATE INT
		,@LICENSE_ID_TO_EXCLUDE INT = -1
	)
RETURNS @LICENSE TABLE (
		[CURRENT_LOCATION] VARCHAR(25)
		,[CURRENT_WAREHOUSE] VARCHAR(25)
		,[LICENSE_ID] NUMERIC(18, 0)
		,[CODIGO_POLIZA] VARCHAR(25)
		,[QTY] NUMERIC(18, 4)
		,[FECHA_DOCUMENTO] DATETIME
		,[DATE_EXPIRATION] DATETIME
		,[ORDER] INT NOT NULL
		,[SOURCE] VARCHAR(15)
		,[ALLOW_FAST_PICKING] INT
	)
AS
BEGIN

	DECLARE	@LICENSE_TEMPORAL TABLE (
			[CURRENT_LOCATION] VARCHAR(25)
			,[CURRENT_WAREHOUSE] VARCHAR(25)
			,[LICENSE_ID] NUMERIC(18, 0)
			,[CODIGO_POLIZA] VARCHAR(25)
			,[QTY] NUMERIC(18, 4)
			,[FECHA_DOCUMENTO] DATETIME
			,[DATE_EXPIRATION] DATETIME
			,[ORDER] INT NOT NULL
			,[SOURCE] VARCHAR(15)
			,[ALLOW_FAST_PICKING] INT
		);

	DECLARE	@DISPATCH_BY_STATUS INT = 0;

	SELECT
		@DISPATCH_BY_STATUS = CONVERT(INT, [P].[VALUE])
	FROM
		[wms].[OP_WMS_PARAMETER] [P]
	WHERE
		[P].[GROUP_ID] = 'PICKING_DEMAND'
		AND [P].[PARAMETER_ID] = 'DISPATCH_BY_STATUS';

    -- ------------------------------------------------------------------------------------
    -- Valida si es de un pedido ya preparado y si es asi, le envia solo la licencia preparada
    -- ------------------------------------------------------------------------------------
	IF ISNULL(@PICKING_HEADER_ID, 0) > 0
	BEGIN
		IF (
			@DISPATCH_BY_STATUS = 0
			OR @STATUS_CODE IS NULL
			)
		BEGIN
			INSERT	INTO @LICENSE
					(
						[CURRENT_LOCATION]
						,[CURRENT_WAREHOUSE]
						,[LICENSE_ID]
						,[CODIGO_POLIZA]
						,[QTY]
						,[FECHA_DOCUMENTO]
						,[DATE_EXPIRATION]
						,[ORDER]
						,[ALLOW_FAST_PICKING]
					)
			SELECT
				[CURRENT_LOCATION]
				,[CURRENT_WAREHOUSE]
				,[L].[LICENSE_ID]
				,[CODIGO_POLIZA]
				,([QTY] - ISNULL([CI].[COMMITED_QTY], 0)) [QTY]
				,[L].[CREATED_DATE]
				,[IL].[DATE_EXPIRATION]
				,ROW_NUMBER() OVER (ORDER BY [QTY] ASC, [CURRENT_LOCATION] ASC)
				,0
			FROM
				[wms].[OP_WMS_LICENSES] [L]
			INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
			LEFT JOIN [wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [CI] ON [CI].[MATERIAL_ID] = [IL].[MATERIAL_ID]
											AND [CI].[LICENCE_ID] = [L].[LICENSE_ID]
			WHERE
				[PICKING_DEMAND_HEADER_ID] = @PICKING_HEADER_ID
				AND [IL].[MATERIAL_ID] = @MATERIAL_ID
				AND ([QTY] - ISNULL([CI].[COMMITED_QTY], 0)) > 0
				AND [IL].[LICENSE_ID] <> @LICENSE_ID_TO_EXCLUDE
				AND [IL].[PROJECT_ID] IS NULL;
			GOTO END_WHILE;
		END;
		ELSE
		BEGIN
			INSERT	INTO @LICENSE
					(
						[CURRENT_LOCATION]
						,[CURRENT_WAREHOUSE]
						,[LICENSE_ID]
						,[CODIGO_POLIZA]
						,[QTY]
						,[FECHA_DOCUMENTO]
						,[DATE_EXPIRATION]
						,[ORDER]
						,[ALLOW_FAST_PICKING]
					)
			SELECT
				[CURRENT_LOCATION]
				,[CURRENT_WAREHOUSE]
				,[L].[LICENSE_ID]
				,[CODIGO_POLIZA]
				,([QTY] - ISNULL([CI].[COMMITED_QTY], 0)) [QTY]
				,[L].[CREATED_DATE]
				,[IL].[DATE_EXPIRATION]
				,ROW_NUMBER() OVER (ORDER BY [QTY] ASC, [CURRENT_LOCATION] ASC)
				,0
			FROM
				[wms].[OP_WMS_LICENSES] [L]
			INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
			INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SML] ON ([SML].[STATUS_ID] = [IL].[STATUS_ID])
			LEFT JOIN [wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [CI] ON [CI].[MATERIAL_ID] = [IL].[MATERIAL_ID]
											AND [CI].[LICENCE_ID] = [L].[LICENSE_ID]
			WHERE
				[PICKING_DEMAND_HEADER_ID] = @PICKING_HEADER_ID
				AND [IL].[MATERIAL_ID] = @MATERIAL_ID
				AND [SML].[STATUS_CODE] = @STATUS_CODE
				AND ([QTY] - ISNULL([CI].[COMMITED_QTY], 0)) > 0
				AND [IL].[LICENSE_ID] <> @LICENSE_ID_TO_EXCLUDE
				AND [IL].[PROJECT_ID] IS NULL;
			GOTO END_WHILE;
		END;


	END;
    -- ------------------------------------------------------------------------------------
    -- Obtener tipo de picking 
    -- ------------------------------------------------------------------------------------
	IF @PICKING_TYPE IS NULL
		OR @PICKING_TYPE = ''
	BEGIN
		SET @PICKING_TYPE = 'ASCENDENTE';
        --
		SELECT
			@PICKING_TYPE = UPPER([PICKING_TYPE])
		FROM
			[wms].[OP_WMS_WAREHOUSES]
		WHERE
			[WAREHOUSE_ID] = @WAREHOUSE;
	END;
    ---------------------------------------------------------------------------------
    -- Valida si maneja lote
    --------------------------------------------------------------------------------- 
	IF @HANDLE_BATCH = 0
	BEGIN
        ---------------------------------------------------------------------------------
        -- No maneja lote 
        ---------------------------------------------------------------------------------  
		IF (
			@DISPATCH_BY_STATUS = 0
			OR @STATUS_CODE IS NULL
			)
		BEGIN
			INSERT	INTO @LICENSE_TEMPORAL
			SELECT
				[CURRENT_LOCATION]
				,[CURRENT_WAREHOUSE]
				,[LICENSE_ID]
				,[CODIGO_POLIZA]
				,[QTY]
				,[FECHA_DOCUMENTO]
				,[DATE_EXPIRATION]
				,ROW_NUMBER() OVER (ORDER BY  [DATE_EXPIRATION] ASC, [QTY] ASC, [CURRENT_LOCATION] ASC) -- 
				,'ASCENDENTE'
				,[ALLOW_FAST_PICKING]
			FROM
			[wms].[OP_WMS_VIEW_PICKING_AVAILABLE_GENERAL_BATCH]
				--[wms].[OP_WMS_VIEW_PICKING_AVAILABLE_GENERAL]
			WHERE
				[MATERIAL_ID] = @MATERIAL_ID
				AND [QTY] > 0
				AND [LICENSE_ID] <> @LICENSE_ID_TO_EXCLUDE
				AND [CURRENT_WAREHOUSE] = @WAREHOUSE;
		END;
		ELSE
		BEGIN

			INSERT	INTO @LICENSE_TEMPORAL
			SELECT
				[PAG].[CURRENT_LOCATION]
				,[PAG].[CURRENT_WAREHOUSE]
				,[PAG].[LICENSE_ID]
				,[PAG].[CODIGO_POLIZA]
				,[PAG].[QTY]
				,[PAG].[FECHA_DOCUMENTO]
				,NULL --[PAG].[DATE_EXPIRATION] -- No existe en la vista
				,ROW_NUMBER() OVER (ORDER BY [PAG].[ALLOW_FAST_PICKING] DESC, [PAG].[QTY] ASC, [PAG].[CURRENT_LOCATION] ASC)
				,'ASCENDENTE'
				,[PAG].[ALLOW_FAST_PICKING]
			FROM
				[wms].[OP_WMS_VIEW_PICKING_AVAILABLE_GENERAL] [PAG]
			INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SML] ON ([SML].[STATUS_ID] = [PAG].[STATUS_ID])
			WHERE
				[PAG].[MATERIAL_ID] = @MATERIAL_ID
				AND [SML].[STATUS_CODE] = @STATUS_CODE
				AND [PAG].[QTY] > 0
				AND [PAG].[LICENSE_ID] <> @LICENSE_ID_TO_EXCLUDE
				AND [PAG].[CURRENT_WAREHOUSE] = @WAREHOUSE;
		END;
	END;
	ELSE
	BEGIN
        ---------------------------------------------------------------------------------
        -- Maneja lote 
        ---------------------------------------------------------------------------------
		DECLARE	@DATE_MIN_EXPIRATION_DATE DATE = CAST(DATEADD(DAY,
											@MIN_DAYS_EXPIRATION_DATE,
											GETDATE()) AS DATE);
		IF (
			@DISPATCH_BY_STATUS = 0
			OR @STATUS_CODE IS NULL
			)
		BEGIN

			INSERT	INTO @LICENSE_TEMPORAL
			SELECT
				[PAGB].[CURRENT_LOCATION]
				,[PAGB].[CURRENT_WAREHOUSE]
				,[PAGB].[LICENSE_ID]
				,[PAGB].[CODIGO_POLIZA]
				,[PAGB].[QTY]
				,[PAGB].[FECHA_DOCUMENTO]
				,[PAGB].[DATE_EXPIRATION]
				,ROW_NUMBER() OVER (ORDER BY [PAGB].[ALLOW_FAST_PICKING] DESC, [PAGB].[DATE_EXPIRATION] ASC, [PAGB].[QTY] ASC, [PAGB].[CURRENT_LOCATION] ASC)
				,'ASCENDENTE'
				,[PAGB].[ALLOW_FAST_PICKING]
			FROM
				[wms].[OP_WMS_VIEW_PICKING_AVAILABLE_GENERAL_BATCH] [PAGB]
			WHERE
				[PAGB].[MATERIAL_ID] = @MATERIAL_ID
				AND [PAGB].[QTY] > 0
				AND [PAGB].[CURRENT_WAREHOUSE] = @WAREHOUSE
				AND [PAGB].[LICENSE_ID] <> @LICENSE_ID_TO_EXCLUDE
				AND @DATE_MIN_EXPIRATION_DATE < [PAGB].[DATE_EXPIRATION];
		END;
		ELSE
		BEGIN
			INSERT	INTO @LICENSE_TEMPORAL
			SELECT
				[PAGB].[CURRENT_LOCATION]
				,[PAGB].[CURRENT_WAREHOUSE]
				,[PAGB].[LICENSE_ID]
				,[PAGB].[CODIGO_POLIZA]
				,[PAGB].[QTY]
				,[PAGB].[FECHA_DOCUMENTO]
				,[PAGB].[DATE_EXPIRATION]
				,ROW_NUMBER() OVER (ORDER BY [PAGB].[ALLOW_FAST_PICKING] DESC, [PAGB].[DATE_EXPIRATION] ASC, [PAGB].[QTY] ASC, [PAGB].[CURRENT_LOCATION] ASC)
				,'ASCENDENTE'
				,[PAGB].[ALLOW_FAST_PICKING]
			FROM
				[wms].[OP_WMS_VIEW_PICKING_AVAILABLE_GENERAL_BATCH] [PAGB]
			WHERE
				[PAGB].[MATERIAL_ID] = @MATERIAL_ID
				AND [PAGB].[STATUS_CODE] = @STATUS_CODE
				AND [PAGB].[QTY] > 0
				AND [PAGB].[CURRENT_WAREHOUSE] = @WAREHOUSE
				AND [PAGB].[LICENSE_ID] <> @LICENSE_ID_TO_EXCLUDE
				AND @DATE_MIN_EXPIRATION_DATE < [PAGB].[DATE_EXPIRATION];
		END;

	END;

    -- ------------------------------------------------------------------------------------
    -- Si el picking es ascendente unicamente se retorna la tabla temporal que ya está ordenada
    -- ------------------------------------------------------------------------------------
	IF @PICKING_TYPE = 'ASCENDENTE'
	BEGIN
		INSERT	INTO @LICENSE
				(
					[CURRENT_LOCATION]
					,[CURRENT_WAREHOUSE]
					,[LICENSE_ID]
					,[CODIGO_POLIZA]
					,[QTY]
					,[FECHA_DOCUMENTO]
					,[DATE_EXPIRATION]
					,[ORDER]
					,[ALLOW_FAST_PICKING]
				)
		SELECT
			[CURRENT_LOCATION]
			,[CURRENT_WAREHOUSE]
			,[LICENSE_ID]
			,[CODIGO_POLIZA]
			,[QTY]
			,[FECHA_DOCUMENTO]
			,[DATE_EXPIRATION]
			,[ORDER]
			,[ALLOW_FAST_PICKING]
		FROM
			@LICENSE_TEMPORAL
		ORDER BY
			[ORDER] ASC;

		GOTO END_WHILE;

	END;
	ELSE
	BEGIN

		DECLARE
			@QTY_TEMP NUMERIC(18, 4)
			,@LICENSE_ID INT
			,@CODIGO_POLIZA VARCHAR(50)
			,@FECHA_DOCUMENTO DATETIME
			,@DATE_EXPIRATION DATETIME
			,@CURRENT_QTY NUMERIC(18, 4)
			,@LOCATION_SPOT VARCHAR(25)
			,@ORDER INT = 0
			,@HAS_RESULT INT = 0
			,@ALLOW_FAST_PICKING INT = 0
			,@LAST_DATE_EXPIRATION DATETIME;
        --
		SET @QTY_TEMP = @QUANTITY_ASSIGNED;

		IF @HANDLE_BATCH = 0
		BEGIN
            ---------------------------------------------------------------------------------
            -- No maneja lote 
            ---------------------------------------------------------------------------------  
			WHILE (@QTY_TEMP > 0)
			BEGIN

				SET @HAS_RESULT = 0;

				SELECT TOP 1
					@LAST_DATE_EXPIRATION = [DATE_EXPIRATION]
				FROM
					@LICENSE_TEMPORAL
				ORDER BY
					[DATE_EXPIRATION] ASC;

				SELECT TOP 1
					@CURRENT_QTY = [QTY]
					,@LICENSE_ID = [LICENSE_ID]
					,@LOCATION_SPOT = [CURRENT_LOCATION]
					,@CODIGO_POLIZA = [CODIGO_POLIZA]
					,@FECHA_DOCUMENTO = [FECHA_DOCUMENTO]
					,@DATE_EXPIRATION = [DATE_EXPIRATION]
					,@ALLOW_FAST_PICKING = [ALLOW_FAST_PICKING]
					,@HAS_RESULT = 1
				FROM
					@LICENSE_TEMPORAL
				WHERE
					[DATE_EXPIRATION] = @LAST_DATE_EXPIRATION
					--[QTY] <= @QTY_TEMP
				ORDER BY
					[QTY] ASC
					,[CURRENT_LOCATION] ASC;

				IF @HAS_RESULT = 0
				BEGIN
					INSERT	INTO @LICENSE
							(
								[CURRENT_LOCATION]
								,[CURRENT_WAREHOUSE]
								,[LICENSE_ID]
								,[CODIGO_POLIZA]
								,[QTY]
								,[FECHA_DOCUMENTO]
								,[DATE_EXPIRATION]
								,[ORDER]
								,[SOURCE]
								,[ALLOW_FAST_PICKING]
							)
					SELECT
						[CURRENT_LOCATION]
						,[CURRENT_WAREHOUSE]
						,[LICENSE_ID]
						,[CODIGO_POLIZA]
						,[QTY]
						,[FECHA_DOCUMENTO]
						,[DATE_EXPIRATION]
						,@ORDER
						+ ROW_NUMBER() OVER (ORDER BY [ALLOW_FAST_PICKING] DESC, [QTY] ASC, [CURRENT_LOCATION] ASC)
						,'ASCENDENTE'
						,[ALLOW_FAST_PICKING]
					FROM
						@LICENSE_TEMPORAL
					WHERE
						[LICENSE_ID] NOT IN (SELECT
											[LICENSE_ID]
											FROM
											@LICENSE);
					GOTO END_WHILE;
				END;

				DELETE FROM
					@LICENSE_TEMPORAL
				WHERE
					[LICENSE_ID] = @LICENSE_ID;


				SELECT
					@QTY_TEMP = @QTY_TEMP - @CURRENT_QTY;

                --
				INSERT	INTO @LICENSE
						(
							[CURRENT_LOCATION]
							,[CURRENT_WAREHOUSE]
							,[LICENSE_ID]
							,[CODIGO_POLIZA]
							,[QTY]
							,[FECHA_DOCUMENTO]
							,[DATE_EXPIRATION]
							,[ORDER]
							,[SOURCE]
							,[ALLOW_FAST_PICKING]
						)
				VALUES
						(
							@LOCATION_SPOT
							,   -- CURRENT_LOCATION - varchar(25)
							@WAREHOUSE
							,       -- CURRENT_WAREHOUSE - varchar(25)
							@LICENSE_ID
							,      -- LICENSE_ID - numeric
							@CODIGO_POLIZA
							,   -- CODIGO_POLIZA - varchar(25)
							@CURRENT_QTY
							,     -- QTY - numeric
							@FECHA_DOCUMENTO
							, -- FECHA_DOCUMENTO - datetime
							@DATE_EXPIRATION
							, -- FECHA_DOCUMENTO - datetime
							@ORDER
							,           -- ORDER - int							
							'DESCENDENTE'
							,@ALLOW_FAST_PICKING
						);

				SET @ORDER = @ORDER + 1;

			END;

		END;
		ELSE
		BEGIN
            ---------------------------------------------------------------------------------
            -- Maneja lote 
            ---------------------------------------------------------------------------------  
			WHILE (@QTY_TEMP > 0)
			BEGIN
				SET @HAS_RESULT = 0;

				SELECT TOP 1
					@LAST_DATE_EXPIRATION = [DATE_EXPIRATION]
				FROM
					@LICENSE_TEMPORAL
				ORDER BY
					[DATE_EXPIRATION] ASC;

				SELECT TOP 1
					@CURRENT_QTY = [QTY]
					,@LICENSE_ID = [LICENSE_ID]
					,@LOCATION_SPOT = [CURRENT_LOCATION]
					,@CODIGO_POLIZA = [CODIGO_POLIZA]
					,@FECHA_DOCUMENTO = [FECHA_DOCUMENTO]
					,@DATE_EXPIRATION = [DATE_EXPIRATION]
					,@ALLOW_FAST_PICKING = [ALLOW_FAST_PICKING]
					,@HAS_RESULT = 1
				FROM
					@LICENSE_TEMPORAL
				WHERE
					[QTY] <= @QTY_TEMP
					AND [DATE_EXPIRATION] = @LAST_DATE_EXPIRATION
				ORDER BY
					[ALLOW_FAST_PICKING] DESC
					,[DATE_EXPIRATION] ASC
					,[QTY] DESC
					,[CURRENT_LOCATION] ASC;

				IF @HAS_RESULT = 0
				BEGIN

					INSERT	INTO @LICENSE
							(
								[CURRENT_LOCATION]
								,[CURRENT_WAREHOUSE]
								,[LICENSE_ID]
								,[CODIGO_POLIZA]
								,[QTY]
								,[FECHA_DOCUMENTO]
								,[DATE_EXPIRATION]
								,[ORDER]
								,[SOURCE]
								,[ALLOW_FAST_PICKING]
							)
					SELECT
						[CURRENT_LOCATION]
						,[CURRENT_WAREHOUSE]
						,[LICENSE_ID]
						,[CODIGO_POLIZA]
						,[QTY]
						,[FECHA_DOCUMENTO]
						,[DATE_EXPIRATION]
						,@ORDER
						+ ROW_NUMBER() OVER (ORDER BY [ALLOW_FAST_PICKING] DESC, [DATE_EXPIRATION] ASC, [QTY] ASC, [CURRENT_LOCATION] ASC)
						,'ASCENDENTE'
						,[ALLOW_FAST_PICKING]
					FROM
						@LICENSE_TEMPORAL
					WHERE
						[LICENSE_ID] NOT IN (SELECT
											[LICENSE_ID]
											FROM
											@LICENSE);
					GOTO END_WHILE;
				END;

				DELETE FROM
					@LICENSE_TEMPORAL
				WHERE
					[LICENSE_ID] = @LICENSE_ID;
                --
				SELECT
					@QTY_TEMP = @QTY_TEMP - @CURRENT_QTY;

                --
				INSERT	INTO @LICENSE
						(
							[CURRENT_LOCATION]
							,[CURRENT_WAREHOUSE]
							,[LICENSE_ID]
							,[CODIGO_POLIZA]
							,[QTY]
							,[FECHA_DOCUMENTO]
							,[DATE_EXPIRATION]
							,[ORDER]
							,[SOURCE]
							,[ALLOW_FAST_PICKING]
						)
				VALUES
						(
							@LOCATION_SPOT
							,   -- CURRENT_LOCATION - varchar(25)
							@WAREHOUSE
							,       -- CURRENT_WAREHOUSE - varchar(25)
							@LICENSE_ID
							,      -- LICENSE_ID - numeric
							@CODIGO_POLIZA
							,   -- CODIGO_POLIZA - varchar(25)
							@CURRENT_QTY
							,     -- QTY - numeric
							@FECHA_DOCUMENTO
							, -- FECHA_DOCUMENTO - datetime

							@DATE_EXPIRATION
							, -- DATE_EXPIRATION - datetime
							@ORDER
							,           -- ORDER - int
							'DESCENDENTE'
							,@ALLOW_FAST_PICKING
						);

				SET @ORDER = @ORDER + 1;

			END;
		END;
	END;

	END_WHILE:
	RETURN;
END;