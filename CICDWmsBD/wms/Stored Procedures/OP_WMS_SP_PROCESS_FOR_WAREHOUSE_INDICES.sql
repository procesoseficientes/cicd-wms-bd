-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	07-Jun-2019 G-Force@Berlin-Swift3PL
-- Description:			Sp que procesa todos los indices de las bodegas

-- Autor:				marvin.solares
-- Fecha de Creacion: 	27-Jun-2019 G-Force@Cancun
-- Description:			Se agrega al proceso la obtencion de ultimo precio de compra y ultima fecha de compra por material

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_PROCESS_FOR_WAREHOUSE_INDICES]
				
*/
-- =============================================  
CREATE PROCEDURE [wms].[OP_WMS_SP_PROCESS_FOR_WAREHOUSE_INDICES]
AS
BEGIN
	BEGIN TRAN;
	BEGIN TRY
		SET NOCOUNT ON;

    -- --------------------------------------------------
    -- Declaramos las variables necearias 
    -- --------------------------------------------------
		DECLARE	@AVERAGE_INVENTORY TABLE (
				[CODE_WAREHOUSE] VARCHAR(25)
				,[MATERIAL_CODE] VARCHAR(50)
				,[AVERAGE_SALES] NUMERIC(18, 6)
				,[DATE_OF_LAST_PICKING] DATETIME
			);

		DECLARE	@LAST_DATE_TABLE TABLE (
				[CODE_WAREHOUSE] VARCHAR(25)
				,[MATERIAL_CODE] VARCHAR(50)
				,[DATE_OF_LAST_RECEPTION] DATETIME
				,[DATE_OF_THE_LAST_PHYSICAL_COUNT] DATETIME
			);


		DECLARE	@MATERIAL_DATA_BY_WARESHOUSE TABLE (
				[CODE_WAREHOUSE] VARCHAR(25)
				,[MATERIAL_CODE] VARCHAR(50)
				,[AVARAGE_SALES] NUMERIC(18, 6) DEFAULT (0)
				,[DATE_OF_LAST_RECEPTION] DATETIME
				,[DATE_OF_LAST_PICKING] DATETIME
				,[DATE_OF_THE_LAST_PHYSICAL_COUNT] DATETIME
				,[LAST_PRICE_PURCHASE_BY_ERP] NUMERIC(18, 6)
				,[LAST_DATE_PURCHASE_BY_ERP] DATE
			);

		DECLARE
			@MONTH_NUMBER INT = 3
			,@CURRENT_MONTH_NUMBER INT = 1
			,@MONTH1_END DATE
			,@MONTH1_START DATE;

    -- --------------------------------------------------
    -- Establecemos las fechas 
    -- --------------------------------------------------
		SET @MONTH1_END = DATEADD(DAY, -1, GETDATE());
		SET @MONTH1_START = DATEADD(MONTH, -@MONTH_NUMBER,
									@MONTH1_END);

    -- --------------------------------------------------
    -- Obtemos las ventas de los ultimos meses y la fecha del ultimo picking
    -- --------------------------------------------------
		INSERT	INTO @AVERAGE_INVENTORY
				(
					[CODE_WAREHOUSE]
					,[MATERIAL_CODE]
					,[AVERAGE_SALES]
					,[DATE_OF_LAST_PICKING]
				)
		SELECT
			[T].[SOURCE_WAREHOUSE] AS [CODE_WAREHOUSE]
			,[T].[MATERIAL_CODE]
			,(SUM([T].[QUANTITY_UNITS]) * -1)
			/ @MONTH_NUMBER AS [AVERAGE_SALES]
			,MAX([T].[TRANS_DATE]) AS [DATE_OF_LAST_PICKING]
		FROM
			[wms].[OP_WMS_TRANS] [T]
		WHERE
			[T].[LICENSE_ID] IS NOT NULL
			AND [T].[TRANS_TYPE] IN ('DESPACHO_ALMGEN',
										'DESPACHO_FISCAL',
										'DESPACHO_GENERAL')
			AND CAST([T].[TRANS_DATE] AS DATE) BETWEEN @MONTH1_START
											AND
											@MONTH1_END
		GROUP BY
			[T].[SOURCE_WAREHOUSE]
			,[T].[MATERIAL_CODE];

    -- --------------------------------------------------
    -- Obtemos la fecha de la ultima recepcion y conteo
    -- --------------------------------------------------
		INSERT	INTO @LAST_DATE_TABLE
				(
					[CODE_WAREHOUSE]
					,[MATERIAL_CODE]
					,[DATE_OF_LAST_RECEPTION]
					,[DATE_OF_THE_LAST_PHYSICAL_COUNT]
				)
		SELECT
			[LD].[CODE_WAREHOUSE]
			,[LD].[MATERIAL_CODE]
			,MAX([LD].[DATE_OF_LAST_RECEPTION]) AS [DATE_OF_LAST_RECEPTION]
			,MAX([LD].[DATE_OF_THE_LAST_PHYSICAL_COUNT]) AS [DATE_OF_THE_LAST_PHYSICAL_COUNT]
		FROM
			(SELECT
					[T].[TARGET_WAREHOUSE] AS [CODE_WAREHOUSE]
					,[T].[MATERIAL_CODE]
					,CASE [T].[TRANS_TYPE]
						WHEN 'INGRESO_FISCAL'
						THEN MAX([T].[TRANS_DATE])
						WHEN 'INGRESO_GENERAL'
						THEN MAX([T].[TRANS_DATE])
						WHEN 'INICIALIZACION_FISCAL'
						THEN MAX([T].[TRANS_DATE])
						WHEN 'INICIALIZACION_GENERAL'
						THEN MAX([T].[TRANS_DATE])
						ELSE NULL
						END [DATE_OF_LAST_RECEPTION]
					,CASE [T].[TRANS_TYPE]
						WHEN 'CONTEO_FISICO'
						THEN MAX([T].[TRANS_DATE])
						ELSE NULL
						END [DATE_OF_THE_LAST_PHYSICAL_COUNT]
				FROM
					[wms].[OP_WMS_TRANS] [T]
				WHERE
					[T].[LICENSE_ID] IS NOT NULL
					AND [T].[TRANS_TYPE] IN (
					'INGRESO_FISCAL', 'INGRESO_GENERAL',
					'INICIALIZACION_FISCAL',
					'INICIALIZACION_GENERAL',
					'CONTEO_FISICO')
					AND CAST([T].[TRANS_DATE] AS DATE) BETWEEN @MONTH1_START
											AND
											@MONTH1_END
				GROUP BY
					[T].[TARGET_WAREHOUSE]
					,[T].[MATERIAL_CODE]
					,[T].[TRANS_TYPE]) AS [LD]
		GROUP BY
			[LD].[CODE_WAREHOUSE]
			,[LD].[MATERIAL_CODE];

    -- --------------------------------------------------
    -- Insertamos los datos obtenidos
    -- --------------------------------------------------
		INSERT	INTO @MATERIAL_DATA_BY_WARESHOUSE
				(
					[CODE_WAREHOUSE]
					,[MATERIAL_CODE]
					,[AVARAGE_SALES]
					,[DATE_OF_LAST_PICKING]
				)
		SELECT
			[CODE_WAREHOUSE]
			,[MATERIAL_CODE]
			,[AVERAGE_SALES]
			,[DATE_OF_LAST_PICKING]
		FROM
			@AVERAGE_INVENTORY;

    -- --------------------------------------------------
    -- Hacemos marge con la tabla @LAST_DATE_TABLE
    -- --------------------------------------------------
		MERGE @MATERIAL_DATA_BY_WARESHOUSE AS [TARGET]
		USING @LAST_DATE_TABLE AS [SOURCE]
		ON (
			[TARGET].[CODE_WAREHOUSE] = [SOURCE].[CODE_WAREHOUSE]
			AND [TARGET].[MATERIAL_CODE] = [SOURCE].[MATERIAL_CODE]
			)
		WHEN MATCHED THEN
			UPDATE SET
					[TARGET].[DATE_OF_LAST_RECEPTION] = [SOURCE].[DATE_OF_LAST_RECEPTION]
					,[TARGET].[DATE_OF_THE_LAST_PHYSICAL_COUNT] = [SOURCE].[DATE_OF_THE_LAST_PHYSICAL_COUNT]
		WHEN NOT MATCHED THEN
			INSERT
					(
						[CODE_WAREHOUSE]
						,[MATERIAL_CODE]
						,[DATE_OF_LAST_RECEPTION]
						,[DATE_OF_THE_LAST_PHYSICAL_COUNT]
					)
			VALUES	(
						[SOURCE].[CODE_WAREHOUSE]
						,[SOURCE].[MATERIAL_CODE]
						,[SOURCE].[DATE_OF_LAST_RECEPTION]
						,[SOURCE].[DATE_OF_THE_LAST_PHYSICAL_COUNT]
					);

	-- ------------------------------------------------------------------------------------
	-- RECORRO LA TABLA OBTENIDA PARA CONSULTAR EN ERP EL ULTIMO PRECIO Y ULTIMA FECHA DE COMPRA POR MATERIAL
	-- ------------------------------------------------------------------------------------
		SELECT
			*
		INTO
			[#MATERIAL_DATA_TEMP]
		FROM
			@MATERIAL_DATA_BY_WARESHOUSE;

		DECLARE
			@INTERFACE_DATA_BASE_NAME VARCHAR(200)
			,@ERP_DATABASE VARCHAR(200)
			,@SCHEMA_NAME VARCHAR(200)
			,@QUERY NVARCHAR(2000);

		DECLARE	@MATERIAL_PRICE TABLE (
				[DocDate] DATE
				,[Price] NUMERIC(19, 6)
			);

		WHILE (EXISTS ( SELECT TOP 1
							1
						FROM
							[#MATERIAL_DATA_TEMP] ))
		BEGIN
			DECLARE	@MATERIAL_ID_TEMP VARCHAR(64);
			DECLARE
				@PRICE_PURCHASE NUMERIC(18, 6)
				,@DATE_PURCHASE DATE
				,@MATERIAL_OWNER VARCHAR(64);

			SET @INTERFACE_DATA_BASE_NAME = '';
			SET @ERP_DATABASE = '';
			SET @SCHEMA_NAME = '';

			DELETE FROM
				@MATERIAL_PRICE;

			SELECT TOP 1
				@MATERIAL_ID_TEMP = [MATERIAL_CODE]
			FROM
				[#MATERIAL_DATA_TEMP];

			SELECT
				@MATERIAL_OWNER = [CLIENT_OWNER]
			FROM
				[wms].[OP_WMS_MATERIALS]
			WHERE
				[MATERIAL_ID] = @MATERIAL_ID_TEMP;

			-- ------------------------------------------------------------------------------------
			-- Obtiene la fuente del dueño de la recepcion
			-- ------------------------------------------------------------------------------------
			

			SELECT
				@INTERFACE_DATA_BASE_NAME = [ES].[INTERFACE_DATA_BASE_NAME]
				,@ERP_DATABASE = [C].[ERP_DATABASE]
				,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
			FROM
				[wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
			INNER JOIN [wms].[OP_WMS_COMPANY] [C] ON ([C].[EXTERNAL_SOURCE_ID] = [ES].[EXTERNAL_SOURCE_ID])
			WHERE
				[C].[CLIENT_CODE] = @MATERIAL_OWNER
				AND [ES].[READ_ERP] = 1;

			IF @ERP_DATABASE IS NOT NULL
				AND @ERP_DATABASE <> ''
			BEGIN
				SELECT
					@QUERY = N'EXEC '
					+ @INTERFACE_DATA_BASE_NAME + '.'
					+ @SCHEMA_NAME
					+ '.SWIFT_SP_GET_LAST_PURCHASE @DATABASE ='''
					+ @ERP_DATABASE + ''',@MATERIAL_ID ='''
					+ REPLACE(@MATERIAL_ID_TEMP,
								CONCAT(@MATERIAL_OWNER, '/'),
								'') + '''';
	--
				BEGIN TRY
					INSERT	INTO @MATERIAL_PRICE
							([DocDate], [Price])
							EXEC [sp_executesql] @QUERY;
				END TRY
				BEGIN CATCH
					PRINT @QUERY;
					PRINT ERROR_MESSAGE();
				END CATCH;
			
				
				SELECT TOP 1
					@PRICE_PURCHASE = [Price]
					,@DATE_PURCHASE = [DocDate]
				FROM
					@MATERIAL_PRICE;

				UPDATE
					@MATERIAL_DATA_BY_WARESHOUSE
				SET	
					[LAST_PRICE_PURCHASE_BY_ERP] = @PRICE_PURCHASE
					,[LAST_DATE_PURCHASE_BY_ERP] = @DATE_PURCHASE
				WHERE
					[MATERIAL_CODE] = @MATERIAL_ID_TEMP;

			END;

			DELETE FROM
				[#MATERIAL_DATA_TEMP]
			WHERE
				[MATERIAL_CODE] = @MATERIAL_ID_TEMP;
		END;
    -- --------------------------------------------------
    -- Insertamos los datos procesados
    -- --------------------------------------------------
		INSERT	INTO [wms].[OP_WMS_WAREHOUSE_INDICES]
				(
					[CODE_WAREHOUSE]
					,[MATERIAL_CODE]
					,[BARCODE_ID]
					,[MATERIAL_NAME]
					,[AVARAGE_SALES]
					,[QTY]
					,[INVENTORY_COVERAGE]
					,[INVENTORY_ROTATION]
					,[DATE_OF_LAST_RECEPTION]
					,[DATE_OF_LAST_PICKING]
					,[DATE_OF_THE_LAST_PHYSICAL_COUNT]
					,[IDLE]
					,[DATE_START]
					,[DATE_END]
					,[DATE_OF_PROCESS]
					,[LAST_PRICE_PURCHASE_BY_ERP]
					,[LAST_DATE_PURCHASE_BY_ERP]
				)
		SELECT
			[MDW].[CODE_WAREHOUSE]
			,[MDW].[MATERIAL_CODE]
			,MAX([IL].[BARCODE_ID]) AS [BARCODE_ID]
			,MAX([IL].[MATERIAL_NAME]) AS [MATERIAL_NAME]
			,[MDW].[AVARAGE_SALES]
			,SUM([IL].[QTY]) AS [QTY]
			,CAST([MDW].[AVARAGE_SALES] / SUM([IL].[QTY]) AS NUMERIC(18,
											6)) AS [INVENTORY_COVERAGE]
			,CAST(CASE [MDW].[AVARAGE_SALES]
					WHEN 0 THEN 0
					ELSE SUM([IL].[QTY])
							/ [MDW].[AVARAGE_SALES]
					END AS NUMERIC(18, 6)) AS [INVENTORY_ROTATION]
			,[MDW].[DATE_OF_LAST_RECEPTION]
			,[MDW].[DATE_OF_LAST_PICKING]
			,[MDW].[DATE_OF_THE_LAST_PHYSICAL_COUNT]
			,MAX([IL].[IDLE]) AS [MAX_IDLE]
			,@MONTH1_START AS [DATE_START]
			,@MONTH1_END AS [DATE_END]
			,GETDATE() AS [DATE_OF_PROCESS]
			,[MDW].[LAST_PRICE_PURCHASE_BY_ERP]
			,[MDW].[LAST_DATE_PURCHASE_BY_ERP]
		FROM
			@MATERIAL_DATA_BY_WARESHOUSE [MDW]
		INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON ([MDW].[CODE_WAREHOUSE] = [L].[CURRENT_WAREHOUSE])
		INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON (
											[L].[LICENSE_ID] = [IL].[LICENSE_ID]
											AND [MDW].[MATERIAL_CODE] = [IL].[MATERIAL_ID]
											)
		WHERE
			[IL].[QTY] > 0
		GROUP BY
			[CODE_WAREHOUSE]
			,[MATERIAL_CODE]
			,[AVARAGE_SALES]
			,[DATE_OF_LAST_PICKING]
			,[DATE_OF_LAST_RECEPTION]
			,[DATE_OF_THE_LAST_PHYSICAL_COUNT]
			,[LAST_PRICE_PURCHASE_BY_ERP]
			,[LAST_DATE_PURCHASE_BY_ERP];
		COMMIT;
    -- --------------------------------------------------
    -- Retornamos el objeto operacion que fue exitoso
    -- --------------------------------------------------
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo];

	END TRY
	BEGIN CATCH
		ROLLBACK;
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;
END;