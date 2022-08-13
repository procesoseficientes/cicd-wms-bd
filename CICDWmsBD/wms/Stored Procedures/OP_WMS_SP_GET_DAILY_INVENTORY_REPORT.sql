-- =============================================
-- Autor:					pablo.aguilar
-- Fecha de Creacion: 		15-Nov-17 @ Nexus Team Sprint F-ZERO
-- Description:			    Reporte para ver estado de inventario, del dia. 

/*
-- Ejemplo de Ejecucion:
        exec [wms].[OP_WMS_SP_GET_DAILY_INVENTORY_REPORT] @REPORT_DATETIME = '2017-11-16 14:38:02.607', @WAREHOUSE = 'BODEGA_01|BODEGA_02', @LOGIN = 'PABS'
		SELECT * 	FROM
		[wms].[OP_WMS_TRANS] [T]
*/ 
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_DAILY_INVENTORY_REPORT] (
		@REPORT_DATETIME DATETIME
		,@WAREHOUSE VARCHAR(MAX)
		,@LOGIN VARCHAR(25)
	)
AS
BEGIN
	SET NOCOUNT ON;
  --

	DECLARE	@DELIMITER CHAR(1) = '|';

	
   
	DECLARE	@TRANSACTIONS TABLE (
			[MATERIAL_ID] VARCHAR(50)
			,[WAREHOUSE] VARCHAR(50)
			,[QTY_INCOME] NUMERIC(18, 4)
			,[QTY_OUTPUT] NUMERIC(18, 4)
			,[TYPE] VARCHAR(25)
		);

	DECLARE	@WAREHOUSES TABLE (
			[WAREHOUSE_ID] VARCHAR(50)
		);
		
	INSERT	INTO @WAREHOUSES
			(
				[WAREHOUSE_ID]
			)
	SELECT
		[W].[VALUE] [WAREHOUSE_ID]
	FROM
		[wms].[OP_WMS_FN_SPLIT](@WAREHOUSE, @DELIMITER) [W];
  -- ------------------------------------------------------------------------------------
  -- Despachos
  -- ------------------------------------------------------------------------------------
	INSERT	INTO @TRANSACTIONS
			(
				[MATERIAL_ID]
				,[WAREHOUSE]
				,[QTY_INCOME]
				,[QTY_OUTPUT]
				,[TYPE]
  			)
	SELECT
		[T].[MATERIAL_CODE]
		,[T].[SOURCE_WAREHOUSE]
		,0 [QTY_INCOME]
		,SUM([T].[QUANTITY_UNITS]) [QTY_OUTPUT]
		,'DESPACHO' [TYPE]
	FROM
		[wms].[OP_WMS_TRANS] [T]
	INNER JOIN @WAREHOUSES [W] ON [T].[SOURCE_WAREHOUSE] = [W].[WAREHOUSE_ID]
	WHERE
		[T].[TRANS_TYPE] IN ('DESPACHO_ALMGEN',
								'DESPACHO_FISCAL',
								'DESPACHO_GENERAL',
								'EXPLODE_OUT')
		AND CONVERT(DATE, [T].[TRANS_DATE]) = CONVERT(DATE, @REPORT_DATETIME)
		AND [T].[STATUS] = 'PROCESSED'
		AND [T].[MATERIAL_CODE] <> ''
	GROUP BY
		[T].[MATERIAL_CODE]
		,[T].[SOURCE_WAREHOUSE];


  
  -- ------------------------------------------------------------------------------------
  -- Ingresos
  -- ------------------------------------------------------------------------------------
	INSERT	INTO @TRANSACTIONS
			(
				[MATERIAL_ID]
				,[WAREHOUSE]
				,[QTY_INCOME]
				,[QTY_OUTPUT]
				,[TYPE]
  			)
	SELECT
		[T].[MATERIAL_CODE]
		,[T].[TARGET_WAREHOUSE]
		,SUM([T].[QUANTITY_UNITS]) [QTY_INCOME]
		,0 [QTY_OUTPUT]
		,'INGRESOS' [TYPE]
	FROM
		[wms].[OP_WMS_TRANS] [T]
	INNER JOIN @WAREHOUSES [W] ON [T].[TARGET_WAREHOUSE] = [W].[WAREHOUSE_ID]
	WHERE
		[T].[TRANS_TYPE] IN ('INGRESO_FISCAL',
								'INGRESO_GENERAL',
								'INICIALIZACION_FISCAL',
								'INICIALIZACION_GENERAL',
								'EXPLODE_IN')
		AND CONVERT(DATE, [T].[TRANS_DATE]) = CONVERT(DATE, @REPORT_DATETIME)
		AND [T].[STATUS] = 'PROCESSED'
		AND [T].[MATERIAL_CODE] <> ''
	GROUP BY
		[T].[MATERIAL_CODE]
		,[T].[TARGET_WAREHOUSE];
		


    -- ------------------------------------------------------------------------------------
  -- Reubicaciones parciales validar si cambiaron de Bodega para realizar la salida y la entrada. 
  -- ------------------------------------------------------------------------------------
	INSERT	INTO @TRANSACTIONS
			(
				[MATERIAL_ID]
				,[WAREHOUSE]
				,[QTY_INCOME]
				,[QTY_OUTPUT]
				,[TYPE]
  			)
	SELECT
		[T].[MATERIAL_CODE]
		,[W].[WAREHOUSE_ID]
		,SUM(CASE	WHEN [W].[WAREHOUSE_ID] = [T].[TARGET_WAREHOUSE]
					THEN [T].[QUANTITY_UNITS]
					ELSE 0
				END) [QTY_INCOME]
		,SUM(CASE	WHEN [W].[WAREHOUSE_ID] = [T].[SOURCE_WAREHOUSE]
					THEN [T].[QUANTITY_UNITS] * -1
					ELSE 0
				END) [QTY_OUTPUT]
		,'REUBICACION PARCIAL' [TYPE]
	FROM
		[wms].[OP_WMS_TRANS] [T]
	INNER JOIN [wms].[OP_WMS_WAREHOUSES] [W] ON [W].[WAREHOUSE_ID] = [T].[SOURCE_WAREHOUSE]
											OR [W].[WAREHOUSE_ID] = [T].[TARGET_WAREHOUSE]
	INNER JOIN @WAREHOUSES [WP] ON [W].[WAREHOUSE_ID] = [WP].[WAREHOUSE_ID]
	WHERE
		[T].[TRANS_TYPE] = 'REUBICACION_PARCIAL'
		AND CONVERT(DATE, [T].[TRANS_DATE]) = CONVERT(DATE, @REPORT_DATETIME)
		AND [T].[SOURCE_WAREHOUSE] <> [T].[TARGET_WAREHOUSE]
		AND [T].[STATUS] = 'PROCESSED'
		AND [T].[MATERIAL_CODE] <> ''
	GROUP BY
		[T].[MATERIAL_CODE]
		,[W].[WAREHOUSE_ID];

   -- ------------------------------------------------------------------------------------
  -- Reubicaciones validar si cambiaron de Bodega para realizar la salida y la entrada. 
  -- ------------------------------------------------------------------------------------
	INSERT	INTO @TRANSACTIONS
			(
				[MATERIAL_ID]
				,[WAREHOUSE]
				,[QTY_INCOME]
				,[QTY_OUTPUT]
				,[TYPE]
  			)
	SELECT
		[T].[MATERIAL_CODE]
		,[W].[WAREHOUSE_ID]
		,SUM(CASE	WHEN [W].[WAREHOUSE_ID] = [T].[TARGET_WAREHOUSE]
					THEN [T].[QUANTITY_UNITS]
					ELSE 0
				END) [QTY_INCOME]
		,SUM(CASE	WHEN [W].[WAREHOUSE_ID] = [T].[SOURCE_WAREHOUSE]
					THEN [T].[QUANTITY_UNITS] * -1
					ELSE 0
				END) [QTY_OUTPUT]
		,'REUBICACION COMPLETA' [TYPE]
	FROM
		[wms].[OP_WMS_TRANS] [T]
	INNER JOIN [wms].[OP_WMS_WAREHOUSES] [W] ON [W].[WAREHOUSE_ID] = [T].[SOURCE_WAREHOUSE]
											OR [W].[WAREHOUSE_ID] = [T].[TARGET_WAREHOUSE]
	INNER JOIN @WAREHOUSES [WP] ON [W].[WAREHOUSE_ID] = [WP].[WAREHOUSE_ID]
	WHERE
		[T].[TRANS_TYPE] = 'REUBICACION_COMPLETA'
		AND CONVERT(DATE, [T].[TRANS_DATE]) = CONVERT(DATE, @REPORT_DATETIME)
		AND [T].[SOURCE_WAREHOUSE] <> [T].[TARGET_WAREHOUSE]
		AND [T].[STATUS] = 'PROCESSED'
		AND [T].[MATERIAL_CODE] <> ''
	GROUP BY
		[T].[MATERIAL_CODE]
		,[W].[WAREHOUSE_ID];


		-- ------------------------------------------------------------------------------------
		-- Resumen de transacciones
		-- ------------------------------------------------------------------------------------
	SELECT
		[T].[MATERIAL_ID]
		,[T].[WAREHOUSE]
		,SUM([QTY_INCOME]) [QTY_INCOME]
		,SUM([QTY_OUTPUT]) [QTY_OUTPUT]
	INTO
		[#RESUME_TRANSACTIONS]
	FROM
		@TRANSACTIONS [T]
	GROUP BY
		[T].[WAREHOUSE]
		,[T].[MATERIAL_ID];
		



		-- ------------------------------------------------------------------------------------
		-- Resumen de inventario del dia anterior 
		-- ------------------------------------------------------------------------------------
	SELECT
		[I].[MATERIAL_ID]
		,SUM([I].[QTY]) [INITIAL_INVENTORY]
		,[S].[WAREHOUSE_PARENT] [WAREHOUSE]
	INTO
		[#INVENTORY]
	FROM
		[wms].[OP_WMS_INV_HISTORY] [I]
	INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [S] ON [I].[CURRENT_LOCATION] = [S].[LOCATION_SPOT]
	INNER JOIN @WAREHOUSES [W] ON [W].[WAREHOUSE_ID] = [S].[WAREHOUSE_PARENT]
	WHERE
		CONVERT(DATE, [I].[SNAPSHOT_DATE]) = CONVERT(DATE, DATEADD(DAY,
											-1,
											@REPORT_DATETIME))
	GROUP BY
		[S].[WAREHOUSE_PARENT]
		,[I].[MATERIAL_ID];





	SELECT
		ISNULL([I].[MATERIAL_ID], [T].[MATERIAL_ID]) [MATERIAL_ID]
		,ISNULL([I].[WAREHOUSE], [T].[WAREHOUSE]) [WAREHOUSE]
		,ISNULL([I].[INITIAL_INVENTORY], 0) [INITIAL_INVENTORY]
		,ISNULL([T].[QTY_INCOME], 0) [QTY_INCOME_TRANSACTION]
		,ISNULL([T].[QTY_OUTPUT], 0) [QTY_OUTPUT_TRANSACTION]
		,ISNULL([I].[INITIAL_INVENTORY], 0)
		+ ISNULL([T].[QTY_INCOME], 0)
		+ ISNULL([T].[QTY_OUTPUT], 0) [FINAL_INVENTORY]
		,[M].[MATERIAL_NAME]
		,[M].[IS_MASTER_PACK]
	FROM
		[#INVENTORY] [I]
	FULL OUTER JOIN [#RESUME_TRANSACTIONS] [T] ON [T].[MATERIAL_ID] = [I].[MATERIAL_ID]
											AND [T].[WAREHOUSE] = [I].[WAREHOUSE]
	LEFT JOIN [wms].[OP_WMS_MATERIALS] [M] ON ISNULL([I].[MATERIAL_ID],
											[T].[MATERIAL_ID]) = [M].[MATERIAL_ID];
								
  

	INSERT	INTO [wms].[OP_WMS_LOG_REPORT]
			(
				[LOG_DATETIME]
				,[REPORT_NAME]
				,[PARAMETER_LOGIN]
				,[PARAMETER_WAREHOUSE]
				,[PARAMETER_START_DATETIME]
				,[PARAMETER_END_DATETIME]
				,[EXTRA_PARAMETER]
			)
	VALUES
			(
				GETDATE()  -- LOG_DATETIME - datetime
				,'REPORTE DIARIO DE INVENTARIO'  -- REPORT_NAME - varchar(250)
				,@LOGIN  -- PARAMETER_LOGIN - varchar(50)
				,NULL  -- PARAMETER_WAREHOUSE - varchar(50)
				,@REPORT_DATETIME  -- PARAMETER_START_DATETIME - datetime
				,NULL  -- PARAMETER_END_DATETIME - datetime
				,@WAREHOUSE  -- EXTRA_PARAMETER - varchar(max)
			);

END;