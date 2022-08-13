-- =============================================
	-- Autor:	        hector.gonzalez
	-- Fecha de Creacion: 	2017-04-04 @ Team ERGON - Sprint HYPER 
	-- Description:	        SP QUE TRAE LOS CLIENTES DEL CANAL MODERNO POR FUENTE EXTERNA

	-- Modificacion 8/8/2017 @ NEXUS-Team Sprint Banjo-Kazooie
						-- rodrigo.gomez
						-- Se agregan las columnas para INTERCOMPANY

	-- Modificacion 9/21/2017 @ NEXUS-Team Sprint DuckHunt
						-- rodrigo.gomez
						-- Se agrego campo de direccion y departamento

	-- Modificacion 10/4/2017 @ NEXUS-Team Sprint ewms
						-- rodrigo.gomez
						-- Se agrega el cambio para la lectura de external_source desde erp

	-- Modificacion 25-07-2019 @ Nexus Team Sprint 
						-- pablo.aguilar
						-- Se modifica para contemplar docnum y docentry como varchar

	-- Autor:				marvin.solares
	-- Fecha de Creacion: 	21-Ago-2019 @ G-Force-Team Sprint FlorencioVarela
	-- Descripcion:			Obtengo el valor de tolerancia de fecha de expiracion configurado para el cliente

	/*
	-- Ejemplo de Ejecucion:
				EXEC  [wms].[OP_WMS_GET_ERP_CLIENTS_FOR_CHANNEL_MODERN] @START_DATE='2021-04-22 00:00:00',@END_DATE='2021-04-22 23:59:59',@WAREHOUSE_CODE=N'BODEGA_SPS'
	*/
	-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_ERP_CLIENTS_FOR_CHANNEL_MODERN] (
		@START_DATE DATETIME
		,@END_DATE DATETIME
		,@WAREHOUSE_CODE VARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;
		--
	DECLARE
		@EXTERNAL_SOURCE_ID INT
		,@SOURCE_NAME VARCHAR(50)
		,@DATA_BASE_NAME VARCHAR(50)
		,@SCHEMA_NAME VARCHAR(50)
		,@QUERY NVARCHAR(MAX)
		,@DELIMITER CHAR(1) = '|'
		,@ERP_WAREHOUSE VARCHAR(50);
		--
	CREATE TABLE [#CLIENTS] (
		[SALES_ORDER_ID] VARCHAR(50) NOT NULL
		,[CLIENT_ID] [VARCHAR](50) NULL
		,[CUSTOMER_NAME] VARCHAR(150) NULL
		,[DOC_NUM] VARCHAR(50) NULL
		,[DOC_ENTRY] VARCHAR(50) NOT NULL
		,[EXTERNAL_SOURCE_ID] INT NOT NULL
		,[SOURCE_NAME] VARCHAR(50) NOT NULL
		,[OWNER] VARCHAR(50)
		,[DELIVERY_DATE] DATETIME
		,[ADDRESS_CUSTOMER] VARCHAR(254)
		,[STATE_CODE] INT
		,[MIN_DAYS_EXPIRATION_DATE] INT 
		--,PRIMARY KEY ([DOC_ENTRY], [EXTERNAL_SOURCE_ID])
	 );

	--  CREATE INDEX [IN_TEMP_SALES_ORDER_HEADER] ON [#SALES_ORDER_HEADER] ([DOC_ENTRY],[EXTERNAL_SOURCE_ID])
	  --
	--  ALTER TABLE [#SALES_ORDER_HEADER]
	--  ADD CONSTRAINT PK_TEMP_SALES_ORDER PRIMARY KEY ([SALES_ORDER_ID])
	  -- ------------------------------------------------------------------------------------
	  -- Obtiene las fuentes externas
	  -- ------------------------------------------------------------------------------------
	SELECT
		[ES].[EXTERNAL_SOURCE_ID]
		,[ES].[SOURCE_NAME]
		,[ES].[DATA_BASE_NAME]
		,[ES].[SCHEMA_NAME]
		,[ES].[INTERFACE_DATA_BASE_NAME]
	INTO
		[#EXTERNAL_SOURCE]
	FROM
		[wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
	WHERE
		[ES].[EXTERNAL_SOURCE_ID] > 0
		AND [ES].[READ_ERP] = 1;

	  --ALTER TABLE [#EXTERNAL_SOURCE]
	  --ADD CONSTRAINT PK_TEMP_EXTERNAL_SOURCE PRIMARY KEY ([EXTERNAL_SOURCE_ID])
	
	SELECT
		@ERP_WAREHOUSE = [ERP_WAREHOUSE]
	FROM
		[wms].[OP_WMS_WAREHOUSES]
	WHERE
		[WAREHOUSE_ID] COLLATE DATABASE_DEFAULT = @WAREHOUSE_CODE COLLATE DATABASE_DEFAULT;
	  -- ------------------------------------------------------------------------------------
	  -- Ciclo para obtener las ordenes de venta de todas las fuentes externas
	  -- ------------------------------------------------------------------------------------
	PRINT '--> Inicia el ciclo';
		--
	WHILE EXISTS ( SELECT TOP 1
						1
					FROM
						[#EXTERNAL_SOURCE]
					WHERE
						[EXTERNAL_SOURCE_ID] > 0 )
	BEGIN
			-- ------------------------------------------------------------------------------------
			-- Se toma la primera fuente extermna
			-- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@EXTERNAL_SOURCE_ID = [ES].[EXTERNAL_SOURCE_ID]
			,@SOURCE_NAME = [ES].[SOURCE_NAME]
			,@DATA_BASE_NAME = [ES].[INTERFACE_DATA_BASE_NAME]
			,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
			,@QUERY = N''
		FROM
			[#EXTERNAL_SOURCE] [ES]
		WHERE
			[ES].[EXTERNAL_SOURCE_ID] > 0
		ORDER BY
			[ES].[EXTERNAL_SOURCE_ID];
			--
		PRINT '----> @EXTERNAL_SOURCE_ID: '
			+ CAST(@EXTERNAL_SOURCE_ID AS VARCHAR);
		PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME;
		PRINT '----> @DATA_BASE_NAME: ' + @DATA_BASE_NAME;
		PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME;

			-- ------------------------------------------------------------------------------------
			-- Obtiene las ordenes de venta de la fuente externa
			-- ------------------------------------------------------------------------------------
		SELECT
			@QUERY = N'DECLARE @SEQUENCE INT
				EXEC ' + @DATA_BASE_NAME + '.'
			+ @SCHEMA_NAME
			+ '.[ERP_SP_INSERT_SALES_ORDER_HEADER]
						@START_DATE = '''
			+ CAST(@START_DATE AS VARCHAR) + '''
						,@END_DATE = '''
			+ CAST(@END_DATE AS VARCHAR) + '''
						, @WAREHOUSE = ''' + @ERP_WAREHOUSE
			+ '''
						,@SEQUENCE = @SEQUENCE OUTPUT

						INSERT INTO [#CLIENTS]
						SELECT DISTINCT
							[SO].[DOCNUM] AS [SALES_ORDER_ID]
							,[SO].[U_MasterIDCustomer] AS [CLIENT_ID]
							,[SO].[CardName] AS [CUSTOMER_NAME]				
							,[SO].[DOCNUM] [DOC_NUM]   
							,[SO].DOCENTRY [DOC_ENTRY]
				
							,'
			+ CAST(@EXTERNAL_SOURCE_ID AS VARCHAR)
			+ ' [EXTERNAL_SOURCE_ID]
							,''' + @SOURCE_NAME
			+ ''' [SOURCE_NAME]						
							,[SO].[Owner] [OWNER]
							,[SO].[DocDueDate] [DELIVERY_DATE]
							,[SO].[Address2]
							,[SO].[ShipToState] [STATE_CODE]
							,[SO].[MIN_DAYS_EXPIRATION_DATE]
						FROM ' + @DATA_BASE_NAME + '.'
			+ @SCHEMA_NAME
			+ '.[ERP_SALES_ORDER_HEADER_CHANNEL_MODERN] [SO] WITH(NOLOCK)
						WHERE [SO].[Sequence] = @SEQUENCE 
								
	
						EXEC ' + @DATA_BASE_NAME + '.'
			+ @SCHEMA_NAME
			+ '.[ERP_SP_DELETE_SALES_ORDER_BY_SEQUENCE]
							@SEQUENCE = @SEQUENCE  -- int


				';
			--
		PRINT '--> @QUERY: \n' + @QUERY;
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
	END;

	SELECT
		[SOH].[DOC_ENTRY]
		,[SOH].[CLIENT_ID]
		,[SOH].[CLIENT_ID] [MASTER_ID]
		,[SOH].[CUSTOMER_NAME] [CLIENT_NAME]
		,[SOH].[EXTERNAL_SOURCE_ID]
		,[SOH].[OWNER]
		,[SOH].[DELIVERY_DATE]
		,[SOH].[ADDRESS_CUSTOMER]
		,[SOH].[STATE_CODE]
		,[SOH].[MIN_DAYS_EXPIRATION_DATE]
	INTO
		[#DOCUMENTS]
	FROM
		[#CLIENTS] [SOH]
	LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [P] ON (
											[SOH].[DOC_ENTRY] COLLATE DATABASE_DEFAULT = [P].[DOC_ENTRY]
											AND [SOH].[EXTERNAL_SOURCE_ID] = [P].[EXTERNAL_SOURCE_ID]
											AND [P].[OWNER] = [SOH].[OWNER] COLLATE DATABASE_DEFAULT
											)
	GROUP BY
		[SOH].[DOC_ENTRY]
		,[SOH].[CLIENT_ID]
		,[SOH].[CUSTOMER_NAME]
		,[SOH].[EXTERNAL_SOURCE_ID]
		,[SOH].[OWNER]
		,[SOH].[DELIVERY_DATE]
		,[SOH].[ADDRESS_CUSTOMER]
		,[SOH].[STATE_CODE]
		,[SOH].[MIN_DAYS_EXPIRATION_DATE]
	HAVING
		ISNULL(MAX([P].[IS_COMPLETED]), 0) = 0;

	SELECT
		[SOH].[CLIENT_ID]
		,[SOH].[CLIENT_ID] [MASTER_ID]
		,[SOH].[CLIENT_NAME] [CLIENT_NAME]
		,[SOH].[EXTERNAL_SOURCE_ID]
		,[SOH].[OWNER]
		,[SOH].[ADDRESS_CUSTOMER]
		,[SOH].[STATE_CODE]
		,MAX([SOH].[DELIVERY_DATE]) [DELIVERY_DATE]
		,[SOH].[MIN_DAYS_EXPIRATION_DATE]
	FROM
		[#DOCUMENTS] [SOH]
	GROUP BY
		[SOH].[CLIENT_ID]
		,[SOH].[CLIENT_NAME]
		,[SOH].[EXTERNAL_SOURCE_ID]
		,[SOH].[OWNER]
		,[SOH].[ADDRESS_CUSTOMER]
		,[SOH].[STATE_CODE]
		,[SOH].[MIN_DAYS_EXPIRATION_DATE];

END;