-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	17-Aug-17 @ Nexus Team Sprint Banjo-Kazooie 
-- Description:			SP que obtiene las solicitudes de transferencia del ERP

-- Modificacion 10/4/2017 @ NEXUS-Team Sprint ewms
					-- rodrigo.gomez
					-- Se agrega el cambio para la lectura de external_source desde erp

-- Modificacion 09-Apr-18 @ Nexus Team Sprint  Buho
					-- pablo.aguilar
					-- se agrega el projecto. 

-- Autor:				marvin.solares
-- Creacion: 			12/8/2019 G-Force@FlorencioVarela
-- Bug 31163: Duplicidad en lineas de traslado de bodegas
-- Description:	       se modifica tipo de datos para columnas docentry y docnum

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_GET_ERP_TRANSFER_REQUEST_HEADER_BY_DATE]
					@WAREHOUSE_ID = 'C001'
					,@START_DATETIME = '2016-12-01 00:00:00.000'
					,@END_DATETIME = '2016-12-18 00:00:00.000'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_ERP_TRANSFER_REQUEST_HEADER_BY_DATE] (
		@WAREHOUSE_ID VARCHAR(25)
		,@START_DATETIME DATETIME
		,@END_DATETIME DATETIME
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
		,@DELIMITER CHAR(1) = '|';
	--
	CREATE TABLE [#PICKING_DOCUMENT] (
		[SALES_ORDER_ID] VARCHAR(50) NOT NULL
		,[POSTED_DATETIME] [DATETIME] NULL
		,[CLIENT_ID] [VARCHAR](50) NULL
		,[CUSTOMER_NAME] VARCHAR(100)
		,[TOTAL_AMOUNT] [MONEY] NULL
		,[CODE_ROUTE] [VARCHAR](25) NULL
		,[login] [VARCHAR](25) NULL
		,[DOC_SERIE] [VARCHAR](100) NULL
		,[DOC_NUM] VARCHAR(50) NULL
		,[COMMENT] [VARCHAR](250) NULL
		,[EXTERNAL_SOURCE_ID] INT NOT NULL
		,[SOURCE_NAME] VARCHAR(50) NOT NULL
		,[SELLER_OWNER] VARCHAR(50)
		,[MASTER_ID_SELLER] VARCHAR(50)
		,[CODE_SELLER] VARCHAR(50)
		,[CLIENT_OWNER] VARCHAR(50)
		,[MASTER_ID_CLIENT] VARCHAR(50)
		,[OWNER] VARCHAR(50)
		,[DELIVERY_DATE] DATE
		,[FROM_WAREHOUSE_ID] VARCHAR(25)
		,[TO_WAREHOUSE_ID] VARCHAR(25)
		,[IS_FROM_SONDA] INT
		,[PROJECT] VARCHAR(25)
		,PRIMARY KEY
			([SALES_ORDER_ID], [EXTERNAL_SOURCE_ID])
	);
	--
	DECLARE	@EXTERNAL_SOURCE TABLE (
			[EXTERNAL_SOURCE_ID] INT NOT NULL
										PRIMARY KEY
			,[SOURCE_NAME] VARCHAR(50)
			,[DATA_BASE_NAME] VARCHAR(50)
			,[SCHEMA_NAME] VARCHAR(50)
			,[INTERFACE_DATA_BASE_NAME] VARCHAR(50)
		);
	--
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Obtiene las fuentes externas
		-- ------------------------------------------------------------------------------------
		INSERT	INTO @EXTERNAL_SOURCE
				(
					[EXTERNAL_SOURCE_ID]
					,[SOURCE_NAME]
					,[DATA_BASE_NAME]
					,[SCHEMA_NAME]
					,[INTERFACE_DATA_BASE_NAME]
				)
		SELECT
			[ES].[EXTERNAL_SOURCE_ID]
			,[ES].[SOURCE_NAME]
			,[ES].[DATA_BASE_NAME]
			,[ES].[SCHEMA_NAME]
			,[ES].[INTERFACE_DATA_BASE_NAME]
		FROM
			[wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
		WHERE
			[ES].[EXTERNAL_SOURCE_ID] > 0
			AND [ES].[READ_ERP] = 1;

		-- ------------------------------------------------------------------------------------
		-- Ciclo para obtener las ordenes de venta de todas las fuentes externas
		-- ------------------------------------------------------------------------------------
		PRINT '--> Inicia el ciclo';
		--
		WHILE EXISTS ( SELECT TOP 1
							1
						FROM
							@EXTERNAL_SOURCE
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
				@EXTERNAL_SOURCE [ES]
			WHERE
				[ES].[EXTERNAL_SOURCE_ID] > 0
			ORDER BY
				[ES].[EXTERNAL_SOURCE_ID];
			--
			PRINT '----> @EXTERNAL_SOURCE_ID: '
				+ CAST(@EXTERNAL_SOURCE_ID AS VARCHAR);
			PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME;
			PRINT '----> @DATA_BASE_NAME: '
				+ @DATA_BASE_NAME;
			PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME;

			-- ------------------------------------------------------------------------------------
			-- Obtiene las ordenes de venta de la fuente externa
			-- ------------------------------------------------------------------------------------
			SELECT
				@QUERY = N'INSERT INTO [#PICKING_DOCUMENT]
					SELECT
						CAST([TRH].[DOC_ENTRY]AS VARCHAR(50))
						,[TRH].[DOC_DATE]
						,[TRH].[CLIENT_ID]
						,[TRH].[CLIENT_NAME]
						,NULL
						,NULL
						,NULL
						,NULL
						,NULL
						,NULL
						,'
				+ CAST(@EXTERNAL_SOURCE_ID AS VARCHAR)
				+ ' [EXTERNAL_SOURCE_ID]
						,''' + @SOURCE_NAME
				+ ''' [SOURCE_NAME]
						,NULL
						,NULL
						,NULL
						,NULL
						,NULL
						,[TRH].[SOURCE]
						,[TRH].[DOC_DUE_DATE]
						,[W1].[WAREHOUSE_ID] [FROM_WAREHOUSE_ID]
						,[W2].[WAREHOUSE_ID] [TO_WAREHOUSE_ID]
						,0
						, [TRH].[PROJECT]
					FROM ' + @DATA_BASE_NAME + '.'
				+ @SCHEMA_NAME
				+ '.[ERP_VW_TRANSFER_REQUEST_HEADER] [TRH]
					INNER JOIN [wms].[OP_WMS_WAREHOUSES] [W1] ON ([W1].[ERP_WAREHOUSE] = [TRH].[FROM_WAREHOUSE_CODE] COLLATE DATABASE_DEFAULT)
					INNER JOIN [wms].[OP_WMS_WAREHOUSES] [W2] ON ([W2].[ERP_WAREHOUSE] = [TRH].[TO_WAREHOUSE_CODE] COLLATE DATABASE_DEFAULT)
					WHERE [W1].[WAREHOUSE_ID] = '''
				+ @WAREHOUSE_ID + '''
						AND [TRH].[DOC_DATE] BETWEEN '''
				+ CONVERT(VARCHAR, @START_DATETIME, 121)
				+ ''' AND '''
				+ CONVERT(VARCHAR, @END_DATETIME, 121)
				+ '''';
			--
			PRINT '--> @QUERY: ' + @QUERY;
			--
			EXEC (@QUERY);
			-- ------------------------------------------------------------------------------------
			-- Eleminamos la fuente externa
			-- ------------------------------------------------------------------------------------
			DELETE FROM
				@EXTERNAL_SOURCE
			WHERE
				[EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID;
			--
		END;

		-- ------------------------------------------------------------------------------------
		-- Se crean indice a [#PICKING_DOCUMENT]
		-- ------------------------------------------------------------------------------------
		CREATE INDEX [IN_TEMP_PICKING_DOCUMENT]
		ON [#PICKING_DOCUMENT]
		([SALES_ORDER_ID],[EXTERNAL_SOURCE_ID]) INCLUDE(
		[DOC_NUM]
		,[POSTED_DATETIME]
		,[CLIENT_ID]
		,[CUSTOMER_NAME]
		,[TOTAL_AMOUNT]
		,[CODE_ROUTE]
		,[login]
		,[DOC_SERIE]
		,[COMMENT]
		,[SOURCE_NAME]
		,[IS_FROM_SONDA]
		,[SELLER_OWNER]
		,[MASTER_ID_SELLER]
		,[CODE_SELLER]
		,[CLIENT_OWNER]
		,[MASTER_ID_CLIENT]
		,[DELIVERY_DATE]
		,[OWNER]
		,[FROM_WAREHOUSE_ID]
		,[TO_WAREHOUSE_ID]
		);

		-- ------------------------------------------------------------------------------------
		-- Muestra el resultado
		-- ------------------------------------------------------------------------------------
		SELECT DISTINCT
			[PD].[SALES_ORDER_ID]
			,[PD].[POSTED_DATETIME]
			,[PD].[CLIENT_ID]
			,[PD].[CUSTOMER_NAME]
			,[PD].[TOTAL_AMOUNT]
			,[PD].[CODE_ROUTE]
			,[PD].[login]
			,[PD].[DOC_SERIE]
			,[PD].[DOC_NUM]
			,[PD].[COMMENT]
			,[PD].[EXTERNAL_SOURCE_ID]
			,[PD].[SOURCE_NAME]
			,[PD].[IS_FROM_SONDA]
			,[PD].[SELLER_OWNER]
			,[PD].[MASTER_ID_SELLER]
			,[PD].[CODE_SELLER]
			,[PD].[CLIENT_OWNER]
			,[PD].[MASTER_ID_CLIENT]
			,[PD].[OWNER]
			,[PD].[DELIVERY_DATE]
			,'WT - ERP' [SOURCE]
			,[PD].[FROM_WAREHOUSE_ID]
			,[PD].[TO_WAREHOUSE_ID]
			,[PD].[PROJECT]
			,[PD].[TO_WAREHOUSE_ID] [ADDRESS_CUSTOMER]
		FROM
			[#PICKING_DOCUMENT] [PD]
		LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [P] ON (
											[PD].[SALES_ORDER_ID] = [P].[DOC_NUM]
											AND [PD].[EXTERNAL_SOURCE_ID] = [P].[EXTERNAL_SOURCE_ID]
											)
		GROUP BY
			[PD].[DOC_NUM]
			,[PD].[SALES_ORDER_ID]
			,[PD].[POSTED_DATETIME]
			,[PD].[CLIENT_ID]
			,[PD].[CUSTOMER_NAME]
			,[PD].[TOTAL_AMOUNT]
			,[PD].[CODE_ROUTE]
			,[PD].[login]
			,[PD].[DOC_SERIE]
			,[PD].[COMMENT]
			,[PD].[EXTERNAL_SOURCE_ID]
			,[PD].[SOURCE_NAME]
			,[PD].[IS_FROM_SONDA]
			,[PD].[SELLER_OWNER]
			,[PD].[MASTER_ID_SELLER]
			,[PD].[CODE_SELLER]
			,[PD].[CLIENT_OWNER]
			,[PD].[MASTER_ID_CLIENT]
			,[PD].[DELIVERY_DATE]
			,[PD].[OWNER]
			,[PD].[FROM_WAREHOUSE_ID]
			,[PD].[TO_WAREHOUSE_ID]
			,[PD].[PROJECT]
		HAVING
			ISNULL(MAX([P].[IS_COMPLETED]), 0) = 0;
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;
END;