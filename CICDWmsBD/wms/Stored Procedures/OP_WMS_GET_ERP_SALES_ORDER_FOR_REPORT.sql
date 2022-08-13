-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		28-Sep-17 @ Nexus Team Sprint DuckHunt
-- Description:			    SP de reporte de pedidos de ERP

-- Modificacion 10/4/2017 @ NEXUS-Team Sprint ewms
					-- rodrigo.gomez
					-- Se agrega el cambio para la lectura de external_source desde erp

-- Modificacion 24-Nov-17 @ Nexus Team Sprint GTA
					-- alberto.ruiz
					-- Se agrega la columna USE_PICKING_LINE

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20190204 GForce@Rinoceronte
-- Description:			Se modifica tipo de dato de campo DOC_NUM

/*
-- Ejemplo de Ejecucion:
		EXEC [wms].[OP_WMS_GET_ERP_SALES_ORDER_FOR_REPORT]
			@WAREHOUSE = 'BODEGA_01',
			@START_DATE = '2017-09-29 00:00:00.00',
			@END_DATE = '2017-09-29 00:37:47.493'

*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_ERP_SALES_ORDER_FOR_REPORT] (
		@WAREHOUSE VARCHAR(50)
		,@START_DATE DATETIME
		,@END_DATE DATETIME
		,@LOGIN VARCHAR(50) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@SOURCE_NAME VARCHAR(50)
		,@EXTERNAL_SOURCE_ID INT
		,@DATA_BASE_NAME VARCHAR(50)
		,@SCHEMA_NAME VARCHAR(50)
		,@QUERY NVARCHAR(MAX)
		,@ERP_WAREHOUSE VARCHAR(50);
	--
	CREATE TABLE [#EXTERNAL_SOURCE] (
		[EXTERNAL_SOURCE_ID] INT
		,[SOURCE_NAME] VARCHAR(50) NULL
		,[DATA_BASE_NAME] VARCHAR(50) NULL
		,[SCHEMA_NAME] VARCHAR(50) NULL
		,PRIMARY KEY CLUSTERED ([EXTERNAL_SOURCE_ID])
	);
	--
	CREATE TABLE [#PICKING_DEMAND_DETAIL] (
		[DOC_NUM] VARCHAR(50)
		,[MATERIAL_ID] VARCHAR(50)
		,[QTY] DECIMAL(16, 6)
		,[OWNER] VARCHAR(50)
		,[LINE_SEQ] INT
		,[PICKING_DEMAND_HEADER_ID] INT
	);
	--
	CREATE TABLE [#RESULT] (
		[POSTED_DATETIME] DATETIME
		,[SALES_ORDER_ID] VARCHAR(50)
		,[U_Serie] NVARCHAR(50)
		,[U_NoDocto] NVARCHAR(10)
		,[CLIENT_ID] NVARCHAR(15)
		,[NAME_CUSTOMER] NVARCHAR(100)
		,[SLPNAME] NVARCHAR(155)
		,[CODE_SELLER] NVARCHAR(50)
		,[SKU] NVARCHAR(50)
		,[DESCRIPTION_SKU] NVARCHAR(100)
		,[BARCODE_ID] VARCHAR(25)
		,[ALTERNATE_BARCODE] VARCHAR(25)
		,[QTY] DECIMAL(19, 6)
		,[QTY_PENDING] DECIMAL(19, 6)
		,[PRICE] DECIMAL(19, 6)
		,[TOTAL_LINE] DECIMAL(38, 11)
		,[TOTAL_LINEA_CON_DESCUENTO_APLICADO] DECIMAL(38, 6)
		,[CODE_WAREHOUSE] NVARCHAR(50)
		,[DISCOUNT] DECIMAL(24, 6)
		,[LINE_SEQ] INT
		,[EXTERNAL_SOURCE_ID] INT
		,[SOURCE_NAME] VARCHAR(50)
		,[MASTER_ID_MATERIAL] VARCHAR(50)
		,[MATERIAL_OWNER] VARCHAR(50)
		,[SOURCE] VARCHAR(50)
		,[IS_MASTER_PACK] INT
		,[DOC_STATUS] VARCHAR(50)
		,[OPEN_QTY] NUMERIC(19, 6)
		,[DELIVERY_DATE] DATE
		,[STATE_CODE] VARCHAR(50)
		,[STATUS] VARCHAR(50)
		,[WEIGTH] NUMERIC(18, 6)
		,[MATERIAL_IN_SWIFT] INT
		,[ADRESS_CUSTOMER] VARCHAR(300)
		,[TYPE_DEMAND_NAME] VARCHAR(50)
		,[USE_PICKING_LINE] INT
	);

	-- ------------------------------------------------------------------------------------
	-- Obtiene la bodega de ERP
	-- ------------------------------------------------------------------------------------
	SELECT
		@ERP_WAREHOUSE = [ERP_WAREHOUSE]
	FROM
		[wms].[OP_WMS_WAREHOUSES]
	WHERE
		[WAREHOUSE_ID] = @WAREHOUSE;

	-- ------------------------------------------------------------------------------------
    -- Obtiene las fuentes externas
    -- ------------------------------------------------------------------------------------
	INSERT	INTO [#EXTERNAL_SOURCE]
	SELECT
		[ES].[EXTERNAL_SOURCE_ID]
		,[ES].[SOURCE_NAME]
		,[ES].[INTERFACE_DATA_BASE_NAME]
		,[ES].[SCHEMA_NAME]
	FROM
		[wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
	WHERE
		[ES].[READ_ERP] = 1;

	-- ------------------------------------------------------------------------------------
	-- Ciclo para obtener las ordenes de venta de todas las fuentes externas
	-- ------------------------------------------------------------------------------------
	PRINT '--> Inicia el ciclo';
	--
	WHILE EXISTS ( SELECT TOP 1
						1
					FROM
						[#EXTERNAL_SOURCE] )
	BEGIN
		-- ------------------------------------------------------------------------------------
		-- Se toma la primera fuente extermna
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@EXTERNAL_SOURCE_ID = [SO].[EXTERNAL_SOURCE_ID]
			,@SOURCE_NAME = [SO].[SOURCE_NAME]
			,@DATA_BASE_NAME = [SO].[DATA_BASE_NAME]
			,@SCHEMA_NAME = [SO].[SCHEMA_NAME]
			,@QUERY = N''
		FROM
			[#EXTERNAL_SOURCE] [SO]
		ORDER BY
			[SO].[EXTERNAL_SOURCE_ID];
		--
		PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME;
		PRINT '----> @DATA_BASE_NAME: ' + @DATA_BASE_NAME;
		PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME;

		-- ------------------------------------------------------------------------------------
		-- Obtiene las demandas
		-- ------------------------------------------------------------------------------------
		INSERT	INTO [#PICKING_DEMAND_DETAIL]
		SELECT
			[H].[DOC_NUM]
			,[D].[MATERIAL_ID]
			,SUM([D].[QTY]) [QTY]
			,[H].[OWNER]
			,[D].[LINE_NUM] [LINE_SEQ]
			,MAX([D].[PICKING_DEMAND_HEADER_ID])
		FROM
			[wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [D]
		INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H] ON [D].[PICKING_DEMAND_HEADER_ID] = [H].[PICKING_DEMAND_HEADER_ID]
		WHERE
			[H].[EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID
			AND [H].[IS_FROM_ERP] = 1
		GROUP BY
			[H].[OWNER]
			,[H].[DOC_NUM]
			,[D].[MATERIAL_ID]
			,[D].[LINE_NUM];

    -- ------------------------------------------------------------------------------------
    -- Obtiene el detalle de la ordenes de venta de la fuente externa
    -- ------------------------------------------------------------------------------------
		SELECT
			@QUERY = N'
		DECLARE 
			@SEQUENCE_HEADER INT
			,@SEQUENCE_DETAIL INT

		EXEC ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
			+ '.[ERP_SP_INSERT_SALES_ORDER_HEADER_FOR_REPORT] 
						@START_DATE = '''
			+ CAST(@START_DATE AS VARCHAR) + ''', 
						@END_DATE = '''
			+ CAST(@END_DATE AS VARCHAR) + ''', 
			 @WAREHOUSE = ''' + @ERP_WAREHOUSE
			+ ''',
						@SEQUENCE = @SEQUENCE_HEADER OUTPUT	-- int
		EXEC ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
			+ '.[ERP_SP_INSERT_SALES_ORDER_DETAIL_FOR_REPORT] 
						@START_DATE = '''
			+ CAST(@START_DATE AS VARCHAR) + ''', 
						@END_DATE = '''
			+ CAST(@END_DATE AS VARCHAR) + ''',
			 @WAREHOUSE = ''' + @ERP_WAREHOUSE
			+ ''',
						@SEQUENCE = @SEQUENCE_DETAIL OUTPUT	-- int

		INSERT INTO #RESULT
              SELECT
                [SOD].[DocDate] AS POSTED_DATETIME
               ,[SOD].[DOCNUM] AS SALES_ORDER_ID
               ,[SOD].[U_Serie]
               ,[SOD].[U_NoDocto]
               ,[SOD].[CardCode] AS CLIENT_ID
               ,[SOD].[CardName] AS NAME_CUSTOMER
               ,[SOD].[SLPNAME]
               ,[SOH].[SLPCODE] AS CODE_SELLER
               ,ISNULL([SOD].[U_OWNERSKU],'''') +'
			+ '''/'' +[SOD].[ItemCode] AS SKU
               ,[SOD].[Dscription] AS DESCRIPTION_SKU
               ,[M].[BARCODE_ID]
               ,[M].[ALTERNATE_BARCODE] 
               ,[SOD].[Quantity] [QTY]
               ,[SOD].[Quantity] - ISNULL([DD].[QTY], 0) [QTY_PENDING]
               ,[SOD].[PRECIO_CON_IVA] AS PRICE
               ,[SOD].[TOTAL_LINEA_SIN_DESCUENTO] AS TOTAL_LINE
               ,[SOD].[TOTAL_LINEA_CON_DESCUENTO_APLICADO]
               ,[SOD].[WhsCode] AS CODE_WAREHOUSE
               ,[SOD].[DESCUENTO_FACTURA] AS DISCOUNT
               ,[SOD].[NUMERO_LINEA] AS LINE_SEQ
               ,' + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR)
			+ ' [EXTERNAL_SOURCE_ID]
				,''' + @SOURCE_NAME + ''' [SOURCE_NAME]
				,[SOD].[U_MasterIdSKU] [MASTER_ID_MATERIAL]
				,[SOD].[U_OwnerSKU] [MATERIAL_OWNER]
				,[SOD].[Owner] [SOURCE]
				,[M].[IS_MASTER_PACK]
				,[SOH].[DOCSTATUS]
				,[SOD].[OPENQTY]
				,[SOH].DOCDUEDATE
				,[SOH].SHIPTOSTATE
				,[SOH].STATUS
				,[M].WEIGTH
				,CASE 
					WHEN [M].[MATERIAL_ID] IS NULL THEN 0
					ELSE 1
			   END [MATERIAL_IN_SWIFT]
			   ,soh.[Address2]
			   ,soh.TYPE_DEMAND_NAME TYPE_DEMAND_NAME
			   ,M.USE_PICKING_LINE USE_PICKING_LINE
              FROM ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
			+ '.[ERP_SALES_ORDER_DETAIL_CHANNEL_MODERN] [SOD] WITH(NOLOCK)
			  INNER JOIN ' + @DATA_BASE_NAME + '.'
			+ @SCHEMA_NAME
			+ '.[ERP_SALES_ORDER_HEADER_CHANNEL_MODERN] [SOH] WITH(NOLOCK) ON (
				[SOH].[DOCNUM] = [SOD].[DOCNUM]  COLLATE DATABASE_DEFAULT
				AND [SOH].[OWNER] = [SOD].[OWNER] COLLATE DATABASE_DEFAULT
			  )
			  INNER JOIN [wms].[OP_WMS_COMPANY] [OWC] WITH(NOLOCK) ON (
							[OWC].CLIENT_CODE = [SOD].[OWNER] COLLATE DATABASE_DEFAULT
							AND [OWC].[EXTERNAL_SOURCE_ID] = '
			+ CAST(@EXTERNAL_SOURCE_ID AS VARCHAR) COLLATE DATABASE_DEFAULT
			+ '
			  )

              LEFT JOIN [wms].[OP_WMS_MATERIALS] [M] WITH(NOLOCK) ON (
            			 [SOD].[ItemCode] = [M].[ITEM_CODE_ERP] COLLATE DATABASE_DEFAULT
              )
			   LEFT JOIN #PICKING_DEMAND_DETAIL [DD]
                    ON ([SOD].[DOCNUM] COLLATE DATABASE_DEFAULT= [DD].[DOC_NUM] COLLATE DATABASE_DEFAULT
                      AND [M].[MATERIAL_ID] COLLATE DATABASE_DEFAULT = [DD].[MATERIAL_ID] COLLATE DATABASE_DEFAULT
					  AND [DD].[OWNER] COLLATE DATABASE_DEFAULT = [SOD].[Owner] COLLATE DATABASE_DEFAULT
					  AND SOD.[NUMERO_LINEA] = [DD].[LINE_SEQ])

              WHERE [SOD].[Sequence] = @SEQUENCE_DETAIL 
				AND [SOH].[Sequence] = @SEQUENCE_HEADER
				AND [SOD].[WhsCode] = ''' + @ERP_WAREHOUSE COLLATE DATABASE_DEFAULT
			+ ''';
		EXEC ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
			+ '.[ERP_SP_DELETE_SALES_ORDER_BY_SEQUENCE] 
				@SEQUENCE = @SEQUENCE_HEADER 
		EXEC ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
			+ '.[ERP_SP_DELETE_SALES_ORDER_BY_SEQUENCE] 
				@SEQUENCE = @SEQUENCE_DETAIL ';
		--
		PRINT '--> @QUERY: ' + @QUERY;
		--
		EXEC (@QUERY);

		-- ------------------------------------------------------------------------------------
		-- Se elimina la fuente externa
		-- ------------------------------------------------------------------------------------
		DELETE FROM
			[#EXTERNAL_SOURCE]
		WHERE
			[EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID;
		--
		TRUNCATE TABLE [#PICKING_DEMAND_DETAIL];
	END;
	--
	PRINT 'Fin de ciclo';

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado final
	-- ------------------------------------------------------------------------------------
	SELECT
		[DD].[PICKING_DEMAND_HEADER_ID]
		,[DH].[WAVE_PICKING_ID]
		,[DD].[QTY]
		,[DD].[IS_POSTED_ERP]
		,[DD].[ERP_REFERENCE]
		,[DD].[MASTER_ID_MATERIAL]
		,[DD].[LINE_NUM]
		,[DH].[OWNER]
		,[DH].[DOC_NUM]
		,[DH].[EXTERNAL_SOURCE_ID]
		,[DD].[MATERIAL_ID]
		,[DD].[POSTED_RESPONSE]
	INTO
		[#DEMANDS]
	FROM
		[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH]
	INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [DD] ON [DD].[PICKING_DEMAND_HEADER_ID] = [DH].[PICKING_DEMAND_HEADER_ID];

	--
	SELECT
		[R].[SOURCE]
		,[R].[SALES_ORDER_ID]
		,MAX([R].[POSTED_DATETIME]) [POSTED_DATETIME]
		,MAX([R].[DELIVERY_DATE]) [DELIVERY_DATE]
		,COUNT([D].[PICKING_DEMAND_HEADER_ID]) [QTY_WAVE_PICKING]
		,MAX([R].[CLIENT_ID]) [CLIENT_CODE]
		,MAX([R].[NAME_CUSTOMER]) [CLIENT_NAME]
		,MAX([R].[CODE_SELLER]) [CODE_SELLER]
		,MAX([R].[SLPNAME]) [SELLER_NAME]
		,MAX([R].[STATE_CODE]) [STATE_CODE]
		,[R].[SKU]
		,MAX([R].[DESCRIPTION_SKU]) [DESCRIPTION_SKU]
		,[R].[LINE_SEQ]
		,MAX([R].[IS_MASTER_PACK]) [IS_MASTER_PACK]
		,CASE	WHEN MAX([R].[IS_MASTER_PACK]) = 1 THEN 'SI'
				ELSE 'NO'
			END [IS_MASTER_PACK_DESCRIPTION]
		,[D].[WAVE_PICKING_ID]
		,MAX([R].[QTY]) [QTY]
		,MAX([R].[QTY_PENDING]) [QTY_PENDING]
		,MAX(ISNULL([D].[QTY], 0)) [QTY_SWIFT]
		,MAX([R].[OPEN_QTY]) [OPEN_QTY]
		,MAX([R].[DOC_STATUS]) [DOC_STATUS]
		,CASE MAX([R].[DOC_STATUS])
			WHEN 'O' THEN 'ABIERTA'
			ELSE 'CERRADA'
			END [DOC_STATUS_DESCRIPTION]
		,MAX([D].[IS_POSTED_ERP]) [IS_POSTED_ERP]
		,CASE	WHEN MAX([D].[IS_POSTED_ERP]) = 1
				THEN 'ENVIADA'
				WHEN MAX([D].[IS_POSTED_ERP]) = -1
				THEN 'CON ERROR'
				ELSE 'NO ENVIADA'
			END [IS_POSTED_ERP_DESCRIPTION]
		,MAX([D].[ERP_REFERENCE]) [ERP_REFERENCE]
		,MAX([R].[STATUS]) [CANCELED]
		,ISNULL(MAX([R].[WEIGTH]), 0) [WEIGHT]
		,(ISNULL(MAX([R].[WEIGTH]), 0)
			* SUM(ISNULL([R].[QTY], 0))) [WEIGHT_SALE_ORDER]
		,(ISNULL(MAX([R].[WEIGTH]), 0)
			* SUM(ISNULL([D].[QTY], 0))) [WEIGHT_SWIFT]
		,MAX([MD].[MANIFEST_HEADER_ID]) [MANIFEST_HEADER_ID]
		,MAX([MH].[DRIVER]) [DRIVER]
		,MAX([MH].[VEHICLE]) [VEHICLE]
		,MAX([D].[POSTED_RESPONSE]) [POSTED_RESPONSE]
		,MAX([R].[MATERIAL_IN_SWIFT]) [MATERIAL_IN_SWIFT]
		,MAX([R].[ADRESS_CUSTOMER]) [ADRESS_CUSTOMER]
		,MAX([R].[TYPE_DEMAND_NAME]) [TYPE_DEMAND_NAME]
		,MAX(ISNULL([R].[USE_PICKING_LINE], 0)) [USE_PICKING_LINE]
	FROM
		[#RESULT] [R]
	LEFT JOIN [#DEMANDS] [D] ON (
									[D].[EXTERNAL_SOURCE_ID] = [R].[EXTERNAL_SOURCE_ID]
									AND [D].[OWNER] = [R].[SOURCE] COLLATE DATABASE_DEFAULT
									AND [D].[DOC_NUM] = [R].[SALES_ORDER_ID] COLLATE DATABASE_DEFAULT
									AND [D].[MASTER_ID_MATERIAL] = [R].[MASTER_ID_MATERIAL] COLLATE DATABASE_DEFAULT
									AND [D].[LINE_NUM] = [R].[LINE_SEQ]
								)
	LEFT JOIN [wms].[OP_WMS_MANIFEST_DETAIL] [MD] ON (
											[MD].[PICKING_DEMAND_HEADER_ID] = [D].[PICKING_DEMAND_HEADER_ID]
											AND [MD].[LINE_NUM] = [D].[LINE_NUM] 
											AND [MD].[MATERIAL_ID] = [D].[MATERIAL_ID] COLLATE DATABASE_DEFAULT
											)
	LEFT JOIN [wms].[OP_WMS_MANIFEST_HEADER] [MH] ON ([MH].[MANIFEST_HEADER_ID] = [MD].[MANIFEST_HEADER_ID])
	GROUP BY
		[R].[SOURCE]
		,[R].[SALES_ORDER_ID]
		,[R].[SKU]
		,[R].[LINE_SEQ]
		,[D].[WAVE_PICKING_ID]
	ORDER BY
		[R].[SOURCE]
		,[R].[SALES_ORDER_ID]
		,[R].[SKU]
		,[R].[LINE_SEQ]
		,[D].[WAVE_PICKING_ID];


	-- ------------------------------------------------------------------------------------
	-- Agrega log
	-- ------------------------------------------------------------------------------------
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
				,'CUMPLIMIENTO DE DEMANDA - ERP'  -- REPORT_NAME - varchar(250)
				,@LOGIN  -- PARAMETER_LOGIN - varchar(50)
				,@WAREHOUSE  -- PARAMETER_WAREHOUSE - varchar(50)
				,@START_DATE  -- PARAMETER_START_DATETIME - datetime
				,@END_DATE  -- PARAMETER_END_DATETIME - datetime
				,NULL  -- EXTRA_PARAMETER - varchar(max)
			);
END;