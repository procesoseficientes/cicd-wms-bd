-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		28-Sep-17 @ Nexus Team Sprint DuckHunt
-- Description:			    SP de reporte de pedidos de ERP

-- Modificacion 24-Nov-17 @ Nexus Team Sprint GTA
					-- alberto.ruiz
					-- Se agrega la columna de IS_BONUS y USE_PICKING_LINE

-- Modificacion 12-Jan-18 @ Nexus Team Sprint Ramsey
					-- alberto.ruiz
					-- Se corrige para que muestre la placa y el nombre del piloto

/*
-- Ejemplo de Ejecucion:
		EXEC [wms].[OP_WMS_GET_SONDA_SALES_ORDER_FOR_REPORT]
			@WAREHOUSE = 'BODEGA_01',
			@START_DATE = '2017-09-28 00:00:00.000',
			@END_DATE = '2017-09-29 00:00:00.000'

*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_SONDA_SALES_ORDER_FOR_REPORT] (
	@WAREHOUSE VARCHAR(50)
	,@START_DATE DATETIME
	,@END_DATE DATETIME
	,@LOGIN VARCHAR(50) = NULL
) AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@SOURCE_NAME VARCHAR(50)
		,@EXTERNAL_SOURCE_ID INT
		,@DATA_BASE_NAME VARCHAR(50)
		,@SCHEMA_NAME VARCHAR(50)
		,@QUERY NVARCHAR(MAX);
	--
	CREATE TABLE [#EXTERNAL_SOURCE] (
		[EXTERNAL_SOURCE_ID] INT
		,[SOURCE_NAME] VARCHAR(50) NULL
		,[DATA_BASE_NAME] VARCHAR(50) NULL
		,[SCHEMA_NAME] VARCHAR(50) NULL
		,PRIMARY KEY CLUSTERED ([EXTERNAL_SOURCE_ID])
	)
	--
	CREATE TABLE [#PICKING_DEMAND_DETAIL] (
		[DOC_NUM] INT
		,[MATERIAL_ID] VARCHAR(50)
		,[QTY] DECIMAL(16, 6)
		,[OWNER] VARCHAR(50)
		,[LINE_SEQ] INT
	);
	--
	CREATE TABLE [#PICKING_DEMAND] (
		[DOC_NUM] INT
		,[PICKING_DEMAND_HEADER_ID] INT
		,[WAVE_PICKING_ID] INT
		,[LINE_NUM] INT
		,[MATERIAL_ID] VARCHAR(50)
		,[QTY] NUMERIC(18,6)
		,[IS_POSTED_ERP] INT
		,[ERP_REFERENCE] VARCHAR(50)
		,[POSTED_RESPONSE] VARCHAR(4000)
	)
	--
	CREATE INDEX [IN_TEMP_PICKING_DEMAND_DOC_NUM]
	ON [#PICKING_DEMAND]
		([DOC_NUM]) INCLUDE([PICKING_DEMAND_HEADER_ID],[WAVE_PICKING_ID],[LINE_NUM],[MATERIAL_ID],[QTY],[IS_POSTED_ERP],[ERP_REFERENCE],[POSTED_RESPONSE]);
	
	--
	CREATE TABLE [#RESULT] (
		[SOURCE] [VARCHAR](250)
		,[SALES_ORDER_ID] [INT] NOT NULL
		,[POSTED_DATETIME] [DATETIME]
		,[DELIVERY_DATE] [DATETIME]
		,[QTY_WAVE_PICKING] [INT]
		,[CLIENT_CODE] [VARCHAR](250)
		,[CLIENT_NAME] [VARCHAR](250)
		,[CODE_SELLER] [VARCHAR](250)
		,[SELLER_NAME] [VARCHAR](250)
		,[STATE_CODE] VARCHAR(250)
		,[SKU] [VARCHAR](250)
		,[DESCRIPTION_SKU] [VARCHAR](MAX)
		,[LINE_SEQ] [INT] NOT NULL
		,[IS_MASTER_PACK] INT
		,[IS_MASTER_PACK_DESCRIPTION] [VARCHAR](250)
		,[WAVE_PICKING_ID] [INT]
		,[QTY] [NUMERIC](18, 2)
		,[QTY_PENDING] [NUMERIC](21, 4)
		,[QTY_SWIFT] [DECIMAL](38, 4)
		,[OPEN_QTY] [NUMERIC](18, 6)
		,[DOC_STATUS] VARCHAR(50)
		,[DOC_STATUS_DESCRIPTION] [VARCHAR](250) NOT NULL
		,[IS_POSTED_ERP] [INT]
		,[IS_POSTED_ERP_DESCRIPTION] [VARCHAR](4000) NOT NULL
		,[CANCELED] [VARCHAR](250) NOT NULL
		,[WEIGHT] [DECIMAL](18, 6) NOT NULL
		,[WEIGHT_SALE_ORDER] [NUMERIC](38, 6)
		,[WEIGHT_SWIFT] [DECIMAL](38, 6)
		,[MANIFEST_HEADER_ID] [INT]
		,[DRIVER] [VARCHAR](250)
		,[VEHICLE] [VARCHAR](250)
		,[ERP_REFERENCE] [VARCHAR](250)
		,[POSTED_RESPONSE] [VARCHAR](4000)
		,[MATERIAL_IN_SWIFT] INT
		,[USE_PICKING_LINE] INT
		,[IS_BONUS] INT
	);

	-- ------------------------------------------------------------------------------------
    -- Obtiene las fuentes externas
    -- ------------------------------------------------------------------------------------
    INSERT INTO #EXTERNAL_SOURCE
    SELECT
      [ES].[EXTERNAL_SOURCE_ID]
     ,[ES].[SOURCE_NAME]
     ,[ES].[DATA_BASE_NAME]
     ,[ES].[SCHEMA_NAME] 
    FROM [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]

	-- ------------------------------------------------------------------------------------
	-- Obtiene los detalles de las demandas
	-- ------------------------------------------------------------------------------------
	INSERT INTO [#PICKING_DEMAND]
			(
				[DOC_NUM]
				,[PICKING_DEMAND_HEADER_ID]
				,[WAVE_PICKING_ID]
				,[LINE_NUM]
				,[MATERIAL_ID]
				,[QTY]
				,[IS_POSTED_ERP]
				,[ERP_REFERENCE]
				,[POSTED_RESPONSE]
			)
	SELECT
		[DH].[DOC_NUM]
		,[DH].[PICKING_DEMAND_HEADER_ID]
		,[DH].[WAVE_PICKING_ID]
		,[DD].[LINE_NUM]
		,[DD].[MATERIAL_ID]
		,[DD].[QTY]
		,[DD].[IS_POSTED_ERP]
		,[DD].[ERP_REFERENCE]
		,[DD].[POSTED_RESPONSE]
	FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH]
	INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [DD] ON ([DD].[PICKING_DEMAND_HEADER_ID] = [DH].[PICKING_DEMAND_HEADER_ID])
	WHERE [DH].[PICKING_DEMAND_HEADER_ID] > 0
		AND [DH].[IS_FROM_SONDA] = 1


	-- ------------------------------------------------------------------------------------
	-- Ciclo para obtener las ordenes de venta de todas las fuentes externas
	-- ------------------------------------------------------------------------------------
	PRINT '--> Inicia el ciclo';
	--
	WHILE EXISTS ( SELECT TOP 1 1 FROM [#EXTERNAL_SOURCE] )
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
		FROM [#EXTERNAL_SOURCE] [SO]
		ORDER BY [SO].[EXTERNAL_SOURCE_ID];
		--
		PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME;
		PRINT '----> @DATA_BASE_NAME: ' + @DATA_BASE_NAME;
		PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME;

    -- ------------------------------------------------------------------------------------
    -- Obtiene el detalle de la ordenes de venta de la fuente externa
    -- ------------------------------------------------------------------------------------
		SELECT
			@QUERY = N'
			INSERT INTO #RESULT
            SELECT
				CAST(''SONDA'' AS VARCHAR(50)) SOURCE
				,SOH.SALES_ORDER_ID SALES_ORDER_ID
				,MAX(SOH.POSTED_DATETIME) POSTED_DATETIME
				,MAX(SOH.DELIVERY_DATE) DELIVERY_DATE
				,COUNT(DD.PICKING_DEMAND_HEADER_ID) QTY_WAVE_PIKING
				,MAX(SOH.CLIENT_ID) CLIENT_CODE
				,MAX(C.NAME_CUSTOMER) CLIENT_NAME
				,MAX(S.SELLER_CODE) CODE_SELLER
				,MAX(S.SELLER_NAME) SELLER_NAME
				,CAST(NULL AS VARCHAR(250)) STATE_CODE
				,(MAX(SKU.OWNER) + ''/'' + SKU.OWNER_ID) SKU
				,MAX(SKU.DESCRIPTION_SKU) DESCRIPTION_SKU
				,SOD.LINE_SEQ
				,MAX(M.IS_MASTER_PACK) IS_MASTER_PACK
				,CASE WHEN MAX(M.IS_MASTER_PACK) = 1 THEN ''SI'' ELSE ''NO'' END IS_MASTER_PACK_DESCRIPTION
				,DD.WAVE_PICKING_ID
				,SOD.QTY
				,(SOD.QTY - ISNULL(DD.QTY,0)) QTY_PENDING
				,SUM(ISNULL(DD.QTY,0)) QTY_SWIFT
				,CAST(0 AS NUMERIC(18,6)) OPEN_QTY
				,MAX(SOH.IS_VOID) DOC_STATUS
				,CASE WHEN MAX(IS_VOID) = 1 THEN ''CANCELADA'' ELSE ''ABIERTA'' END DOC_STATUS_DESCRIPTION
				,MAX(DD.IS_POSTED_ERP) IS_POSTED_ERP
				,CASE
					WHEN MAX(DD.IS_POSTED_ERP) = 1 THEN ''ENVIADA''
					WHEN MAX(DD.IS_POSTED_ERP) = -1 THEN ''CON ERROR''
					ELSE ''NO ENVIADA''
				END IS_POSTED_ERP_DESCRIPTION
				,CASE WHEN MAX(IS_VOID) = 1 THEN ''SI'' ELSE ''NO'' END CANCELED
				,ISNULL(MAX(M.WEIGTH),0) WEIGTH
				,(ISNULL(MAX(M.WEIGTH),0) * SUM(ISNULL(SOD.QTY,0))) WEIGTH_SALE_ORDER
				,(ISNULL(MAX(M.WEIGTH),0) * SUM(ISNULL(DD.QTY,0))) WEIGTH_SWIFT
				,MAX(MD.MANIFEST_HEADER_ID) MANIFEST_HEADER_ID
				,MAX(P.NAME) + MAX(P.LAST_NAME) DRIVER
				,MAX(V.PLATE_NUMBER) VEHICLE
				,MAX(DD.ERP_REFERENCE) ERP_REFERENCE
				,MAX(DD.POSTED_RESPONSE) POSTED_RESPONSE
				,CASE 
					WHEN MAX(M.MATERIAL_ID) IS NULL THEN 0
					ELSE 1
			   END MATERIAL_IN_SWIFT
			   ,MAX(M.USE_PICKING_LINE) USE_PICKING_LINE
			   ,MIN(SOD.IS_BONUS) IS_BONUS
			FROM ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.SONDA_SALES_ORDER_HEADER SOH
			INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.SONDA_SALES_ORDER_DETAIL SOD ON (SOD.SALES_ORDER_ID = SOH.SALES_ORDER_ID)
			INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.USERS U ON (U.LOGIN = SOH.POSTED_BY)
			INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.SWIFT_SELLER S ON (S.SELLER_CODE = U.RELATED_SELLER)
			INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.SWIFT_VIEW_ALL_SKU SKU ON (SKU.CODE_SKU = SOD.SKU)
			INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.SWIFT_VIEW_ALL_COSTUMER C ON (C.CODE_CUSTOMER = SOH.CLIENT_ID)
			INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.SWIFT_WAREHOUSES W ON (U.PRESALE_WAREHOUSE = W.CODE_WAREHOUSE)
			LEFT JOIN [wms].OP_WMS_MATERIALS M ON (M.MATERIAL_ID = (SKU.OWNER + ''/'' + SKU.OWNER_ID))
			LEFT JOIN #PICKING_DEMAND DD ON (
				DD.DOC_NUM = SOH.SALES_ORDER_ID
				AND SOD.LINE_SEQ = DD.LINE_NUM
			)
			LEFT JOIN [wms].OP_WMS_MANIFEST_DETAIL MD ON (
				MD.PICKING_DEMAND_HEADER_ID = DD.PICKING_DEMAND_HEADER_ID
				AND MD.LINE_NUM = DD.LINE_NUM
				AND MD.MATERIAL_ID = DD.MATERIAL_ID
			)
			LEFT JOIN [wms].OP_WMS_MANIFEST_HEADER MH ON (MH.MANIFEST_HEADER_ID = MD.MANIFEST_HEADER_ID)
			LEFT JOIN [wms].OP_WMS_VEHICLE V ON (V.VEHICLE_CODE = MH.VEHICLE)
			LEFT JOIN [wms].OP_WMS_PILOT P ON (P.PILOT_CODE = MH.DRIVER)
			WHERE SOH.DELIVERY_DATE BETWEEN ''' + CAST(@START_DATE AS VARCHAR) + ''' AND ''' + CAST(@END_DATE AS VARCHAR) + '''
				AND SOH.IS_READY_TO_SEND = 1
				AND SOH.IS_VOID = 0
				AND W.CODE_WAREHOUSE_3PL = ''' + @WAREHOUSE + '''
			GROUP BY 
				SOH.SALES_ORDER_ID
				,SKU.OWNER_ID
				,SOD.SKU
				,SOD.LINE_SEQ
				,DD.WAVE_PICKING_ID
				,SOD.QTY
				,(SOD.QTY - ISNULL(DD.QTY,0))
			ORDER BY
				SOH.SALES_ORDER_ID
				,SOD.SKU
				,SOD.LINE_SEQ
				,DD.WAVE_PICKING_ID';
		--
		PRINT '--> @QUERY: ' + @QUERY;
		--
		EXEC (@QUERY);

		-- ------------------------------------------------------------------------------------
		-- Se elimina la fuente externa
		-- ------------------------------------------------------------------------------------
		DELETE FROM [#EXTERNAL_SOURCE]
		WHERE [EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID;
	END;
	--
	PRINT 'Fin de ciclo';

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado final
	-- ------------------------------------------------------------------------------------
	SELECT
		[R].[SOURCE]
		,[R].[SALES_ORDER_ID]
		,[R].[POSTED_DATETIME]
		,[R].[DELIVERY_DATE]
		,[R].[QTY_WAVE_PICKING]
		,[R].[CLIENT_CODE]
		,[R].[CLIENT_NAME]
		,[R].[CODE_SELLER]
		,[R].[SELLER_NAME]
		,[R].[STATE_CODE]
		,[R].[SKU]
		,[R].[DESCRIPTION_SKU]
		,[R].[LINE_SEQ]
		,[R].[IS_MASTER_PACK_DESCRIPTION]
		,[R].[WAVE_PICKING_ID]
		,[R].[QTY]
		,[R].[QTY_PENDING]
		,[R].[QTY_SWIFT]
		,[R].[OPEN_QTY]
		,[R].[DOC_STATUS]
		,[R].[DOC_STATUS_DESCRIPTION]
		,[R].[IS_POSTED_ERP]
		,[R].[IS_POSTED_ERP_DESCRIPTION]
		,[R].[CANCELED]
		,[R].[WEIGHT]
		,[R].[WEIGHT_SALE_ORDER]
		,[R].[WEIGHT_SWIFT]
		,[R].[MANIFEST_HEADER_ID]
		,[R].[DRIVER]
		,[R].[VEHICLE]
		,[R].[ERP_REFERENCE]
		,[R].[POSTED_RESPONSE]
		,[R].[MATERIAL_IN_SWIFT]
		,ISNULL([R].[USE_PICKING_LINE],0) [USE_PICKING_LINE]
		,[R].[IS_BONUS]
	FROM [#RESULT] [R]

	-- ------------------------------------------------------------------------------------
	-- Agrega log
	-- ------------------------------------------------------------------------------------
	INSERT INTO [wms].[OP_WMS_LOG_REPORT]
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
				,'CUMPLIMIENTO DE DEMANDA - SONDA'  -- REPORT_NAME - varchar(250)
				,@LOGIN  -- PARAMETER_LOGIN - varchar(50)
				,@WAREHOUSE  -- PARAMETER_WAREHOUSE - varchar(50)
				,@START_DATE  -- PARAMETER_START_DATETIME - datetime
				,@END_DATE  -- PARAMETER_END_DATETIME - datetime
				,NULL  -- EXTRA_PARAMETER - varchar(max)
			)
END;