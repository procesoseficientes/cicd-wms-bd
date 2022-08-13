-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	11/15/2017 @ NEXUS-Team Sprint F-Zero 
-- Description:			Obtiene los datos necesarios para el reporte por vendedores de la orden de venta

/*
-- Ejemplo de Ejecucion:
				--
				EXEC [wms].[OP_WMS_SP_GET_SONDA_SALES_ORDER_REPORT]
					@START_DATETIME = '2017-11-15 15:11:25.147'
					,@END_DATETIME = '2017-11-17 15:11:25.147'
					,@CODE_WAREHOUSE = 'BODEGA_01'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_SONDA_SALES_ORDER_REPORT](
	@START_DATETIME DATETIME
	,@END_DATETIME DATETIME
	,@CODE_WAREHOUSE VARCHAR(50)
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
	CREATE TABLE [#SALES_ORDER_TOTAL]
	(
	    [SALES_ORDER_ID] [INT] NOT NULL
		,[TOTAL_AMOUNT] DECIMAL(18,6) NOT NULL
		,PRIMARY KEY ([SALES_ORDER_ID])
	)
	--
	CREATE TABLE #SALES_ORDER(
		[SALES_ORDER_ID] [INT] NOT NULL
		,[CLIENT_CODE] VARCHAR(50) NOT NULL
		,[POSTED_DATETIME] [DATETIME] NULL
		,[DELIVERY_DATETIME] DATETIME NULL
		,[SOURCE] VARCHAR(50) NULL
		,[SELLER_CODE] VARCHAR(50) NULL
		,[SELLER_NAME] VARCHAR(50) NULL
		,[DOC_TOTAL] DECIMAL(18, 6) NULL
		,[OWNER] VARCHAR(50) NULL
		,[EXTERNAL_SOURCE_ID] INT NOT NULL
		,[SOURCE_NAME] VARCHAR(50) NOT NULL

		,PRIMARY KEY([SALES_ORDER_ID],[EXTERNAL_SOURCE_ID])
	)
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
			@QUERY = N'

			INSERT INTO [#SALES_ORDER_TOTAL]
			SELECT DISTINCT
				[S].[SALES_ORDER_ID]
				,MAX([S].[TOTAL] - ([S].[TOTAL] * (ISNULL([S].[DISCOUNT_BY_GENERAL_AMOUNT], 0) / 100))) TOTAL_AMOUNT
			FROM
				(SELECT
					[SD].[SALES_ORDER_ID]
					,CASE WHEN [SD].[DISCOUNT_TYPE] = ''MONETARY''
							THEN (SUM([SD].[TOTAL_LINE]) - SUM([SD].[DISCOUNT] * [SD].[QTY]))
							ELSE (SUM([SD].[TOTAL_LINE]) - SUM([SD].[TOTAL_LINE] * ([SD].[DISCOUNT] / 100)))
					END TOTAL
					,[SH].[DISCOUNT_BY_GENERAL_AMOUNT]
					FROM ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SONDA_SALES_ORDER_HEADER] [SH]
					INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SONDA_SALES_ORDER_DETAIL] [SD] ON [SD].[SALES_ORDER_ID] = [SH].[SALES_ORDER_ID]
					WHERE [SH].[DELIVERY_DATE] BETWEEN ''' + CONVERT(VARCHAR, @START_DATETIME, 121) + ''' AND ''' + CONVERT(VARCHAR, @END_DATETIME, 121) + '''
					GROUP BY
					[SD].[SALES_ORDER_ID]
					,[SD].[DISCOUNT_TYPE]
					,[SH].[DISCOUNT_BY_GENERAL_AMOUNT]
				) AS S
			GROUP BY [S].[SALES_ORDER_ID];
			--
			INSERT INTO [#SALES_ORDER]
			SELECT DISTINCT
				[SH].[SALES_ORDER_ID]
				,[SH].[CLIENT_ID]
				,[SH].[POSTED_DATETIME]
				,[SH].[DELIVERY_DATE]
				,''SONDA'' [SOURCE]
				,[VAS].[SELLER_CODE]
				,[VAS].[SELLER_NAME]
				,[T].[TOTAL_AMOUNT]
				,[VAC].[OWNER]
				,' + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR) + ' [EXTERNAL_SOURCE_ID]
				,''' + @SOURCE_NAME + ''' [SOURCE_NAME]
			FROM ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SONDA_SALES_ORDER_HEADER] [SH]
			INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SONDA_SALES_ORDER_DETAIL] [SD] ON [SD].[SALES_ORDER_ID] = [SH].[SALES_ORDER_ID]
			INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[USERS] [U] ON [SH].[POSTED_BY] = [U].[LOGIN]
			INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SWIFT_VIEW_ALL_SELLERS] [VAS] ON [VAS].[SELLER_CODE] = [U].[RELATED_SELLER]
			INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SWIFT_VIEW_ALL_COSTUMER] [VAC] ON [VAC].[CODE_CUSTOMER] = [SH].[CLIENT_ID]
			INNER JOIN #SALES_ORDER_TOTAL [T] ON [T].[SALES_ORDER_ID] = [SH].[SALES_ORDER_ID]
			INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SWIFT_WAREHOUSES] [W] ON [W].[CODE_WAREHOUSE] = [SH].[WAREHOUSE]
			WHERE [SH].[SALES_ORDER_ID] > 0
				AND [SH].[IS_READY_TO_SEND] = 1
				AND [SH].[IS_VOID] = 0
				AND [SH].[IS_DRAFT] = 0        
				AND [W].[CODE_WAREHOUSE_3PL] = ''' + @CODE_WAREHOUSE + '''
				AND [SH].[DELIVERY_DATE] BETWEEN ''' + CONVERT(VARCHAR, @START_DATETIME, 121) + ''' AND ''' + CONVERT(VARCHAR, @END_DATETIME, 121) + '''';
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
		DELETE FROM [#SALES_ORDER_TOTAL]
	END;

	SELECT [SALES_ORDER_ID]
          ,[CLIENT_CODE]
          ,[POSTED_DATETIME]
          ,[DELIVERY_DATETIME]
          ,[SOURCE]
          ,[SELLER_CODE]
          ,[SELLER_NAME]
          ,[DOC_TOTAL]
          ,[OWNER]
          ,[EXTERNAL_SOURCE_ID]
          ,[SOURCE_NAME]
	FROM [#SALES_ORDER]
END