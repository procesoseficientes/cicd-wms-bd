-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-05-17 @ Team ERGON - Sprint Sheik
-- Description:	        SP que obtiene el detalle de una fuente externa por sos ordenes de venta

-- Modificacion 14-Jul-17 @ Nexus Team Sprint AgeOfEmpires
					-- alberto.ruiz
					-- Se agrega campo IS_MASTER_PACK

-- Modificacion 8/8/2017 @ NEXUS-Team Sprint Banjo-Kazooie
					-- rodrigo.gomez
					-- Se agregan los campos de INTERCOMPANY en el detalle

-- Modificacion 8/30/2017 @ NEXUS-Team Sprint CommandAndConquer
					-- rodrigo.gomez
					-- Se agrega la columna SOURCE
					 
-- Modificacion 23-Sep-17 @ Nexus Team Sprint dUCKhUNT 
					-- pablo.aguilar
					-- Se arregla validación de ordenes parciales 

-- Modificacion 03-Nov-17 @ Nexus Team Sprint F-ZERO
					-- pablo.aguilar
					--  Se agrega para que retorne información de descuento.

-- Modificacion 5/31/2018 @ GFORCE-Team Sprint Dinosaurio
					-- rodrigo.gomez
					-- Se agrega unidad de medida

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_GET_SALE_ORDER_DETAIL_BY_ORDERS_FROM_EXTERNAL]  @EXTERNAL_SOURCES_ID = '1|1|1'
	                                                                      				,@SALES_ORDER_IDS = '49264|49265|49267'
																						,@CODE_WAREHOUSE = 'C002'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_SALE_ORDER_DETAIL_BY_ORDERS_FROM_EXTERNAL] (
		@EXTERNAL_SOURCES_ID VARCHAR(MAX)
		,@SALES_ORDER_IDS VARCHAR(MAX)
		,@CODE_WAREHOUSE VARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@SOURCE_NAME VARCHAR(50)
		,@DATA_BASE_NAME VARCHAR(50)
		,@SCHEMA_NAME VARCHAR(50)
		,@QUERY NVARCHAR(MAX)
		,@DELIMITER CHAR(1) = '|'
		,@SALE_ORDER_ID INT
		,@EXTERNAL_SOURCE_ID INT;
	--
	CREATE TABLE [#SALES_ORDER_DETAIL] (
		[SALES_ORDER_ID] [INT] NOT NULL
		,[SKU] VARCHAR(200)
		,[LINE_SEQ] INT NULL
		,[QTY] DECIMAL(18, 2) NULL
		,[QTY_PENDING] DECIMAL(18, 2) NULL
		,[QTY_ORIGINAL] DECIMAL(18, 2) NULL
		,[PRICE] MONEY NULL
		,[DISCOUNT] MONEY NULL
		,[TOTAL_LINE] MONEY NULL
		,[POSTED_DATETIME] DATETIME
		,[SERIE] VARCHAR(50)
		,[SERIE_2] VARCHAR(50)
		,[REQUERIES_SERIE] INT
		,[COMBO_REFERENCE] VARCHAR(50)
		,[PARENT_SEQ] INT
		,[IS_ACTIVE_ROUTE] INT
		,[CODE_PACK_UNIT] VARCHAR(50)
		,[IS_BONUS] INT
		,[DESCRIPTION_SKU] VARCHAR(200)
		,[BARCODE_ID] VARCHAR(25)
		,[ALTERNATE_BARCODE] VARCHAR(25)
		,[EXTERNAL_SOURCE_ID] INT
		,[SOURCE_NAME] VARCHAR(50)
		,[ERP_OBJECT_TYPE] INT
		,[IS_MASTER_PACK] INT
		,[MATERIAL_OWNER] VARCHAR(50)
		,[MASTER_ID_MATERIAL] VARCHAR(50)
		,[SOURCE] VARCHAR(50)
		,[DISCOUNT_TYPE] VARCHAR(50)
		,[MATERIAL_WEIGHT] DECIMAL(18, 6)
		,[MATERIAL_VOLUME] DECIMAL(18, 4)
		,[USE_PICKING_LINE] INT
		,[unitMsr] VARCHAR(250)
	);
	--
	CREATE INDEX [IN_TEMP_SALES_ORDER_DETAIL]
	ON [#SALES_ORDER_DETAIL]
	([SALES_ORDER_ID]);
	--
	CREATE TABLE [#PICKING_DEMAND_DETAIL] (
		[DOC_NUM] [INT] NOT NULL
		,[MATERIAL_ID] VARCHAR(50)
		,[LINE_NUM] INT
		,[QTY] INT
		,[OWNER] VARCHAR(50)
	);
	--
	CREATE INDEX [IN_TEMP_PICKING_DEMAND_DETAIL]
	ON [#PICKING_DEMAND_DETAIL]
	([DOC_NUM]) INCLUDE([MATERIAL_ID],[LINE_NUM],[QTY]);
	--
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Se obtinen las ordenes de venta, con sus external source
		-- ------------------------------------------------------------------------------------
		SELECT
			[ES].[ID] [ORDER]
			,CAST([ES].[VALUE] AS INT) [EXTERNAL_SOURCE_ID]
			,CONVERT(INT, [SO].[VALUE]) [SALE_ORDER_ID]
			,[SES].[SOURCE_NAME]
			,[SES].[DATA_BASE_NAME]
			,[SES].[SCHEMA_NAME]
		INTO
			[#TB_SALES_ORDER_ID]
		FROM
			[wms].[OP_WMS_FN_SPLIT](@EXTERNAL_SOURCES_ID,
										@DELIMITER) [ES]
		INNER JOIN [wms].[OP_WMS_FN_SPLIT](@SALES_ORDER_IDS,
											@DELIMITER) [SO] ON ([SO].[ID] = [ES].[ID])
		INNER JOIN [wms].[OP_SETUP_EXTERNAL_SOURCE] [SES] ON [ES].[VALUE] = [SES].[EXTERNAL_SOURCE_ID];
		--
		SELECT DISTINCT
			[EXTERNAL_SOURCE_ID]
			,[SOURCE_NAME]
			,[DATA_BASE_NAME]
			,[SCHEMA_NAME]
		INTO
			[#EXTERNAL_SOURCE]
		FROM
			[#TB_SALES_ORDER_ID];
		--
		CREATE INDEX [IN_TEMP_SALES_ORDER_ID_SALE_ORDER_ID]
		ON [#TB_SALES_ORDER_ID]
		([SALE_ORDER_ID]) INCLUDE([ORDER],[EXTERNAL_SOURCE_ID],[SOURCE_NAME],[DATA_BASE_NAME],[schema_name]);
		-- ------------------------------------------------------------------------------------
		-- Ciclo para obtener las ordenes de venta de todas las fuentes externas
		-- ------------------------------------------------------------------------------------
		PRINT '--> Inicia el ciclo';
		--
		WHILE EXISTS ( SELECT TOP 1
							1
						FROM
							[#EXTERNAL_SOURCE] [T] )
		BEGIN
			-- ------------------------------------------------------------------------------------
			-- Obtiene la fuente externa
			-- ------------------------------------------------------------------------------------
			SELECT TOP 1
				@EXTERNAL_SOURCE_ID = [SO].[EXTERNAL_SOURCE_ID]
				,@SOURCE_NAME = [SO].[SOURCE_NAME]
				,@DATA_BASE_NAME = [SO].[DATA_BASE_NAME]
				,@SCHEMA_NAME = [SO].[SCHEMA_NAME]
				--,@SALE_ORDER_ID = [SO].[SALE_ORDER_ID]
			FROM
				[#EXTERNAL_SOURCE] [SO];
			--
			PRINT '----> @EXTERNAL_SOURCE_ID: '
				+ CAST(@EXTERNAL_SOURCE_ID AS VARCHAR);
			PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME;
			PRINT '----> @DATA_BASE_NAME: '
				+ @DATA_BASE_NAME;
			PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME;
			--
			INSERT	INTO [#PICKING_DEMAND_DETAIL]
			SELECT
				[H].[DOC_NUM]
				,[D].[MATERIAL_ID]
				,[D].[LINE_NUM]
				,SUM([D].[QTY]) [QTY]
				,[H].[OWNER]
			FROM
				[wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [D]
			INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H] ON [D].[PICKING_DEMAND_HEADER_ID] = [H].[PICKING_DEMAND_HEADER_ID]
			INNER JOIN [#TB_SALES_ORDER_ID] [S] ON [S].[SALE_ORDER_ID] = [H].[DOC_NUM]
											AND [S].[EXTERNAL_SOURCE_ID] = [H].[EXTERNAL_SOURCE_ID]
			WHERE
				[H].[IS_FROM_SONDA] = 1
				AND [H].[EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID
			GROUP BY
				[H].[OWNER]
				,[H].[DOC_NUM]
				,[D].[MATERIAL_ID]
				,[D].[LINE_NUM];
				
      -- ------------------------------------------------------------------------------------
      -- Obtiene el detalle de la ordenes de venta de la fuente externa
      -- ------------------------------------------------------------------------------------
			SELECT
				@QUERY = N'INSERT INTO [#SALES_ORDER_DETAIL]
				SELECT DISTINCT
					[SOD].[SALES_ORDER_ID]
					,[OWC].[CLIENT_CODE] +'
				+ '''/'' + [VAS].[OWNER_ID] [SKU]
					,[SOD].[LINE_SEQ]
					,([SOD].[QTY] * ISNULL(UMM.QTY, 1)) - ISNULL([DD].[QTY], 0) [QTY]
					,([SOD].[QTY] * ISNULL(UMM.QTY, 1)) - ISNULL([DD].[QTY], 0) [QTY_PENDING]
					,([SOD].[QTY] * ISNULL(UMM.QTY, 1)) [QTY_ORIGINAL]
					,[SOD].[PRICE]
					,[SOD].[DISCOUNT]
					,[SOD].[TOTAL_LINE]
					,[SOD].[POSTED_DATETIME]
					,[SOD].[SERIE]
					,[SOD].[SERIE_2]
					,[SOD].[REQUERIES_SERIE]
					,[SOD].[COMBO_REFERENCE]
					,[SOD].[PARENT_SEQ]
					,[SOD].[IS_ACTIVE_ROUTE]
					,[SOD].[CODE_PACK_UNIT]
					,[SOD].[IS_BONUS]
					,[M].[MATERIAL_NAME] [DESCRIPTION_SKU]
					,[M].[BARCODE_ID]
					,[M].[ALTERNATE_BARCODE]
					,'
				+ CAST(@EXTERNAL_SOURCE_ID AS VARCHAR)
				+ ' [EXTERNAL_SOURCE_ID]
					,''' + @SOURCE_NAME
				+ ''' [SOURCE_NAME]
					, -1 [ERP_OBJECT_TYPE]
					,[M].[IS_MASTER_PACK]
					,[VAS].[OWNER] [MATERIAL_OWNER]
					,[VAS].[CODE_SKU] [MASTER_ID_MATERIAL]
					,[C].[OWNER] [SOURCE]
					,[SOD].[DISCOUNT_TYPE] 
					,[wms].[OP_WMS_FN_CONVERT_FROM_WEIGHT_MEASURE_UNIT_TO_DEFAULT]([M].[WEIGTH], [M].[WEIGHT_MEASUREMENT]) [MATERIAL_WEIGHT]
					,[M].[VOLUME_FACTOR] [MATERIAL_VOLUME]
					,[M].[USE_PICKING_LINE]
					,[SOD].[CODE_PACK_UNIT]
				FROM ' + @DATA_BASE_NAME + '.'
				+ @SCHEMA_NAME
				+ '.[SONDA_SALES_ORDER_DETAIL] [SOD]
				INNER JOIN ' + @DATA_BASE_NAME + '.'
				+ @SCHEMA_NAME
				+ '.[SONDA_SALES_ORDER_HEADER] [SOH] ON [SOD].[SALES_ORDER_ID] = [SOH].[SALES_ORDER_ID]
				INNER JOIN  ' + @DATA_BASE_NAME + '.'
				+ @SCHEMA_NAME
				+ '.[SWIFT_VIEW_ALL_COSTUMER] [C] ON [C].[CODE_CUSTOMER] = [SOH].[CLIENT_ID]
				INNER JOIN ' + @DATA_BASE_NAME + '.'
				+ @SCHEMA_NAME
				+ '.[SWIFT_VIEW_ALL_SKU] [VAS] ON [SOD].[SKU] = [VAS].[CODE_SKU]
				INNER JOIN [wms].[OP_WMS_COMPANY] [OWC] ON [OWC].[COMPANY_NAME] = [VAS].[OWNER]
															AND [OWC].[EXTERNAL_SOURCE_ID] = '
				+ CAST(@EXTERNAL_SOURCE_ID AS VARCHAR)
				+ '
				INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [OWC].[CLIENT_CODE] +'
				+ '''/'' + [VAS].[OWNER_ID] = [M].[MATERIAL_ID]
															AND [M].[CLIENT_OWNER] = [VAS].[OWNER]
				INNER JOIN #TB_SALES_ORDER_ID [S] ON [SOD].[SALES_ORDER_ID] = [S].[SALE_ORDER_ID]
				LEFT JOIN #PICKING_DEMAND_DETAIL [DD] ON [SOD].[SALES_ORDER_ID] = [DD].[DOC_NUM]
														AND [M].[MATERIAL_ID] = [DD].[MATERIAL_ID]
														--AND [DD].[OWNER] = [OWC].[COMPANY_NAME] 
														AND SOD.[LINE_SEQ] = [DD].[LINE_NUM]
				LEFT JOIN [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UMM] ON [M].[MATERIAL_ID] = [UMM].[MATERIAL_ID]
                                                              AND [UMM].[MEASUREMENT_UNIT] = [SOD].[CODE_PACK_UNIT]
				WHERE  CEILING(([SOD].[QTY] * ISNULL(UMM.QTY, 1)) - ISNULL([DD].[QTY], 0)) > 0'
				+ ';';
			--
			PRINT '--> @QUERY: ' + @QUERY;
			--
			EXEC (@QUERY);



      -- ------------------------------------------------------------------------------------
      -- Eleminamos la fuente externa
      -- ------------------------------------------------------------------------------------
			DELETE FROM
				[#EXTERNAL_SOURCE]
			WHERE
				[EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID;
			--
			DELETE
				[#PICKING_DEMAND_DETAIL]
			WHERE
				[DOC_NUM] > 0;
			--      
		END;
		--
		PRINT '--> Termino el ciclo';
		
		-- ------------------------------------------------------------------------------------
		-- Muestra el resultado
		-- ------------------------------------------------------------------------------------
		SELECT
			[SOD].[SALES_ORDER_ID]
			,[SOD].[SKU]
			,[SOD].[LINE_SEQ]
			,[SOD].[QTY] [QTY]
			,[SOD].[QTY_PENDING] [QTY_PENDING]
			,[SOD].[QTY_ORIGINAL] [QTY_ORIGINAL]
			,[SOD].[PRICE]
			,[SOD].[DISCOUNT]
			,[SOD].[TOTAL_LINE]
			,[SOD].[POSTED_DATETIME]
			,[SOD].[SERIE]
			,[SOD].[SERIE_2]
			,[SOD].[REQUERIES_SERIE]
			,[SOD].[COMBO_REFERENCE]
			,[SOD].[PARENT_SEQ]
			,[SOD].[IS_ACTIVE_ROUTE]
			,[SOD].[CODE_PACK_UNIT]
			,[SOD].[IS_BONUS]
			,ISNULL([A].[AVAILABLE_QTY], 0) [AVAILABLE_QTY]
			,[SOD].[DESCRIPTION_SKU]
			,[SOD].[BARCODE_ID]
			,[SOD].[ALTERNATE_BARCODE]
			,[SOD].[EXTERNAL_SOURCE_ID]
			,[SOD].[SOURCE_NAME]
			,[SOD].[ERP_OBJECT_TYPE]
			,[SOD].[IS_MASTER_PACK]
			,[SOD].[MATERIAL_OWNER]
			,[SOD].[MASTER_ID_MATERIAL]
			,[SOD].[SOURCE]
			,[SOD].[DISCOUNT_TYPE]
			,[SOD].[MATERIAL_WEIGHT]
			,[SOD].[MATERIAL_VOLUME]
			,[SOD].[USE_PICKING_LINE]
			,ISNULL([UMM].[MEASUREMENT_UNIT], 'Unidad Base')
			+ ' 1x'
			+ CAST(ISNULL([UMM].[QTY], 1) AS VARCHAR) [MEASUREMENT_UNIT]
			,ISNULL([UMM].[MEASUREMENT_UNIT], 'Unidad Base') [unitMsr]
		FROM
			[#SALES_ORDER_DETAIL] [SOD]
		LEFT JOIN [wms].[OP_WMS_VIEW_INVENTORY_FOR_PICKING] [A] ON [SOD].[SKU] = [A].[MATERIAL_ID]
											AND [A].[CURRENT_WAREHOUSE] = @CODE_WAREHOUSE
		LEFT JOIN [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UMM] ON [UMM].[MATERIAL_ID] = [SOD].[SKU]
											AND [UMM].[MEASUREMENT_UNIT] = [SOD].[unitMsr]
		WHERE
			[SOD].[SALES_ORDER_ID] > 0;
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;
END;