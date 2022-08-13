-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	28-Oct-16 @ A-TEAM Sprint 4 
-- Description:			SP para obtener las ordenes de venta de fuenes externas

-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	31-Ene-17 @ErgonTeam Sprint Ergon II
-- Description:			    Se agrego Left Join a tabla [OP_WMS_NEXT_PICKING_DEMAND_HEADER] para que no traiga las ordenes con estado completed


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-01 Team ERGON - Sprint ERGON IV
-- Description:	 Se agrega parámetro de bodega para filtrar unicamente ordenes de venta de una bodega.

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-20 Team ERGON - Sprint ERGON V
-- Description:	 Se agrega filtro en SONDA_SALE_ORDER_HEADER por [IS_READY_TO_SEND] = 1


-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-08-08 Nexus@Banjo-Kazooie
-- Description:	 Se agrega que devuelva campos necesarios para manejo de intercompany. 

-- Modificacion 16-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
					-- alberto.ruiz
					-- Se agrega el campo SOURCE en el select final

-- Modificacion 9/20/2017 @ NEXUS-Team Sprint DuckHunt
					-- rodrigo.gomez
					-- Se agrega direccion de cliente.

-- Modificacion 9/21/2017 @ NEXUS-Team Sprint DuckHunt
					-- rodrigo.gomez
					-- Se filtra por fecha de entrega en vez de fecha de posteo

-- Modificacion 03-Nov-17 @ Nexus Team Sprint F-Zero
					-- alberto.ruiz
					-- Se agrega descuento

-- Modificacion 11/6/2017 @ NEXUS-Team Sprint F-Zero
					-- rodrigo.gomez
					-- Se agrega filtro de poligonos

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_SALES_ORDER_BY_DATE_FROM_EXTERNAL_SOURCE]
					@START_DATETIME = '20160719 00:00:00.000'
					,@END_DATETIME = '20181115 23:59:59.000'
					,@SOURCE_CODE_ROUTE = '1|1|2'
					,@CODE_ROUTE = '44|001|011201'
          ,@CODE_WAREHOUSE = 'BODEGA_01'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_SALES_ORDER_BY_DATE_FROM_EXTERNAL_SOURCE] (
	@START_DATETIME DATETIME
	,@END_DATETIME DATETIME
	,@SOURCE_CODE_ROUTE VARCHAR(MAX)
	,@CODE_ROUTE VARCHAR(MAX)
	,@CODE_WAREHOUSE VARCHAR(25)
	,@POLYGON VARCHAR(MAX) = NULL
	,@EXTERNAL_SOURCE_POLYGON VARCHAR(MAX) = NULL
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
	CREATE TABLE [#SALES_ORDER_HEADER] (
		[SALES_ORDER_ID] [INT] NOT NULL
		,[POSTED_DATETIME] [DATETIME] NULL
		,[CLIENT_ID] [VARCHAR](50) NULL
		,[CUSTOMER_NAME] VARCHAR(100)
		,[TOTAL_AMOUNT] [MONEY] NULL
		,[CODE_ROUTE] [VARCHAR](25) NULL
		,[login] [VARCHAR](25) NULL
		,[DOC_SERIE] [VARCHAR](100) NULL
		,[DOC_NUM] [INT] NULL
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
		,[ADDRESS_CUSTOMER] VARCHAR(100)
		,[DISCOUNT] NUMERIC(18,6)
		,PRIMARY KEY ([SALES_ORDER_ID],[EXTERNAL_SOURCE_ID])
	);
	--
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Obtiene las fuentes externas
		-- ------------------------------------------------------------------------------------
		SELECT
			[ES].[EXTERNAL_SOURCE_ID]
			,[ES].[SOURCE_NAME]
			,[ES].[DATA_BASE_NAME]
			,[ES].[SCHEMA_NAME]
		INTO [#EXTERNAL_SOURCE]
		FROM [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
		WHERE [ES].[EXTERNAL_SOURCE_ID] > 0;
		--
		ALTER TABLE [#EXTERNAL_SOURCE]
		ADD CONSTRAINT [PK_TEMP_EXTERNAL_SOURCE] PRIMARY KEY ([EXTERNAL_SOURCE_ID]);
		
		-- ------------------------------------------------------------------------------------
		-- Obtiene las rutas con su respectiva fuente
		-- ------------------------------------------------------------------------------------
		SELECT
			[SCR].[ID] [ORDER]
			,CAST([SCR].[VALUE] AS INT) [EXTERNAL_SOURCE_ID]
			,[CR].[VALUE] [CODE_ROUTE]
		INTO
			[#ROUTE]
		FROM
			[wms].[OP_WMS_FN_SPLIT](@SOURCE_CODE_ROUTE,
										@DELIMITER) [SCR]
		INNER JOIN [wms].[OP_WMS_FN_SPLIT](@CODE_ROUTE,
											@DELIMITER) [CR] ON ([CR].[ID] = [SCR].[ID]);
		-- ------------------------------------------------------------------------------------
		-- Ciclo para obtener las ordenes de venta de todas las fuentes externas
		-- ------------------------------------------------------------------------------------
		PRINT '--> Inicia el ciclo';
		--
		WHILE EXISTS (SELECT TOP 1 1 FROM [#EXTERNAL_SOURCE] WHERE [EXTERNAL_SOURCE_ID] > 0 )
		BEGIN
			-- ------------------------------------------------------------------------------------
			-- Se toma la primera fuente extermna
			-- ------------------------------------------------------------------------------------
			SELECT TOP 1
				@EXTERNAL_SOURCE_ID = [ES].[EXTERNAL_SOURCE_ID]
				,@SOURCE_NAME = [ES].[SOURCE_NAME]
				,@DATA_BASE_NAME = [ES].[DATA_BASE_NAME]
				,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
				,@QUERY = N''
			FROM [#EXTERNAL_SOURCE] [ES]
			WHERE [EXTERNAL_SOURCE_ID] > 0
			ORDER BY [ES].[EXTERNAL_SOURCE_ID];
			--
			PRINT '----> @EXTERNAL_SOURCE_ID: ' + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR);
			PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME;
			PRINT '----> @DATA_BASE_NAME: ' + @DATA_BASE_NAME;
			PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME;

			-- ------------------------------------------------------------------------------------
			-- Obtiene las ordenes de venta de la fuente externa
			-- ------------------------------------------------------------------------------------
			SELECT
				@QUERY = N'INSERT INTO [#SALES_ORDER_HEADER]
				SELECT 
					[SOH].[SALES_ORDER_ID] 
					,[SOH].[POSTED_DATETIME]
					,[SOH].[CLIENT_ID]	
					,[C].[NAME_CUSTOMER] [CUSTOMER_NAME] 
					,[SOH].[TOTAL_AMOUNT]
					,[SOH].[POS_TERMINAL] [CODE_ROUTE]
					,[SOH].[POSTED_BY] [LOGIN]
					,[SOH].[DOC_SERIE]
					,[SOH].[SALES_ORDER_ID] [DOC_NUM] 
					,[SOH].[COMMENT]
					,' + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR)
							+ ' [EXTERNAL_SOURCE_ID]
					,''' + @SOURCE_NAME + ''' [SOURCE_NAME]
					,[S].[OWNER] SELLER_OWNER
					,[S].[SELLER_CODE] MASTER_ID_SELLER
					,[S].[SELLER_CODE] CODE_SELLER
					,[C].[OWNER] [CLIENT_OWNER]		
					,[C].[CODE_CUSTOMER] MASTER_ID_CLIENT
					,[C].[OWNER] [OWNER]
					,[SOH].[DELIVERY_DATE] 					
					,[C].[ADRESS_CUSTOMER]
					,[SOH].[DISCOUNT_BY_GENERAL_AMOUNT]
				FROM ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SONDA_SALES_ORDER_HEADER] [SOH]
				INNER JOIN  ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SWIFT_VIEW_ALL_COSTUMER] [C] ON [C].[CODE_CUSTOMER] = [SOH].[CLIENT_ID]
				INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[USERS] [U] ON [U].[SELLER_ROUTE] = [SOH].[POS_TERMINAL]
				INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SWIFT_SELLER] [S] ON [S].[SELLER_CODE] = [U].[RELATED_SELLER]
				INNER JOIN  ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SWIFT_WAREHOUSES] [W] ON [SOH].[WAREHOUSE] = [W].[CODE_WAREHOUSE] 
				INNER JOIN #ROUTE [R] ON (
					[R].[EXTERNAL_SOURCE_ID] = ' + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR) + '
					AND [R].[CODE_ROUTE] = [SOH].[POS_TERMINAL]
				)
				WHERE [SOH].[SALES_ORDER_ID] > 0
					AND [SOH].[IS_READY_TO_SEND] = 1
					AND [SOH].[IS_VOID] = 0
					AND [SOH].[IS_DRAFT] = 0        
					AND ISNULL([SOH].[HAVE_PICKING],0) = 0
					AND [W].[CODE_WAREHOUSE_3PL] = ''' + @CODE_WAREHOUSE + '''
					AND [SOH].[DELIVERY_DATE] BETWEEN ''' + CONVERT(VARCHAR, @START_DATETIME, 121) + ''' AND ''' + CONVERT(VARCHAR, @END_DATETIME, 121) + '''';
			--
			PRINT '--> @QUERY: ' + @QUERY;
			--
			EXEC (@QUERY);

			-- ------------------------------------------------------------------------------------
			-- Eleminamos la fuente externa
			-- ------------------------------------------------------------------------------------
			DELETE FROM [#EXTERNAL_SOURCE]
			WHERE [EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID;
			--
			DELETE FROM [#ROUTE]
			WHERE [EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID;
		END;
		--
		PRINT '--> Termino el ciclo';

		-- ------------------------------------------------------------------------------------
		-- Muestra el resultado
		-- ------------------------------------------------------------------------------------
		SELECT DISTINCT
			[SOH].[SALES_ORDER_ID]
			,[SOH].[POSTED_DATETIME]
			,[SOH].[CLIENT_ID]
			,[SOH].[CUSTOMER_NAME]
			,[SOH].[TOTAL_AMOUNT]
			,[SOH].[CODE_ROUTE]
			,[SOH].[login]
			,[SOH].[DOC_SERIE]
			,[SOH].[DOC_NUM]
			,[SOH].[COMMENT]
			,[SOH].[EXTERNAL_SOURCE_ID]
			,[SOH].[SOURCE_NAME]
			,1 [IS_FROM_SONDA]
			,[SOH].[SELLER_OWNER]
			,[SOH].[MASTER_ID_SELLER]
			,[SOH].[CODE_SELLER]
			,[SOH].[CLIENT_OWNER]
			,[SOH].[MASTER_ID_CLIENT]
			,[SOH].[OWNER]
			,[SOH].[DELIVERY_DATE]
			,'SO - SONDA' [SOURCE]
			,[SOH].[ADDRESS_CUSTOMER]
			,[SOH].[DISCOUNT]
		FROM [#SALES_ORDER_HEADER] [SOH]
		LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [P] ON (
			[SOH].[SALES_ORDER_ID] = [P].[DOC_NUM]
			AND [SOH].[EXTERNAL_SOURCE_ID] = [P].[EXTERNAL_SOURCE_ID]
		)
		GROUP BY
			[SOH].[DOC_NUM]
			,[SOH].[SALES_ORDER_ID]
			,[SOH].[POSTED_DATETIME]
			,[SOH].[CLIENT_ID]
			,[SOH].[CUSTOMER_NAME]
			,[SOH].[TOTAL_AMOUNT]
			,[SOH].[CODE_ROUTE]
			,[SOH].[login]
			,[SOH].[DOC_SERIE]
			,[SOH].[COMMENT]
			,[SOH].[EXTERNAL_SOURCE_ID]
			,[SOH].[SOURCE_NAME]
			,[SOH].[SELLER_OWNER]
			,[SOH].[MASTER_ID_SELLER]
			,[SOH].[CODE_SELLER]
			,[SOH].[CLIENT_OWNER]
			,[SOH].[MASTER_ID_CLIENT]
			,[SOH].[DELIVERY_DATE]
			,[SOH].[OWNER]
			,[SOH].[ADDRESS_CUSTOMER]
			,[SOH].[DISCOUNT]
		HAVING ISNULL(MAX([P].[IS_COMPLETED]), 0) = 0;
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;
END;