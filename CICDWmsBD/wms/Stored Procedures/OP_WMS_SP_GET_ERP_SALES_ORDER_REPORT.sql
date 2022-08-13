-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	11/15/2017 @ NEXUS-Team Sprint F-Zero 
-- Description:			Obtiene los datos necesarios para el reporte por vendedores de la orden de venta

/*
-- Ejemplo de Ejecucion:
				--	
				EXEC [wms].[OP_WMS_SP_GET_ERP_SALES_ORDER_REPORT]
					@START_DATETIME = '2017-11-15 15:11:25.147'
					,@END_DATETIME = '2017-11-17 15:11:25.147'
					,@CODE_WAREHOUSE = 'BODEGA_01'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_ERP_SALES_ORDER_REPORT](
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
		,@DELIMITER CHAR(1) = '|'
		,@ERP_WAREHOUSE VARCHAR(50);
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
       ,[ES].[INTERFACE_DATA_BASE_NAME]
    INTO [#EXTERNAL_SOURCE]
    FROM
        [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
    WHERE
        [ES].[EXTERNAL_SOURCE_ID] > 0
        AND [ES].[READ_ERP] = 1;


	SELECT @ERP_WAREHOUSE = [ERP_WAREHOUSE] 
	FROM [wms].[OP_WMS_WAREHOUSES] WHERE [WAREHOUSE_ID] = @CODE_WAREHOUSE
	-- ------------------------------------------------------------------------------------
	-- Ciclo para obtener las ordenes de venta de todas las fuentes externas
	-- ------------------------------------------------------------------------------------
	PRINT '-> Inicia ciclo'
	WHILE EXISTS (SELECT TOP 1 1 FROM [#EXTERNAL_SOURCE] WHERE [EXTERNAL_SOURCE_ID] > 0)
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
		FROM [#EXTERNAL_SOURCE] [ES]
		WHERE [ES].[EXTERNAL_SOURCE_ID] > 0
		ORDER BY [ES].[EXTERNAL_SOURCE_ID];
		--
		PRINT '----> @EXTERNAL_SOURCE_ID: ' + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR);
		PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME;
		PRINT '----> @DATA_BASE_NAME: ' + @DATA_BASE_NAME;
		PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME;
		--
		SELECT
			@QUERY = N'
					DECLARE @SEQUENCE INT
					EXEC ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[ERP_SP_INSERT_SALES_ORDER_HEADER]
							@START_DATE = ''' + CAST(@START_DATETIME AS VARCHAR) + '''
							,@END_DATE = ''' + CAST(@END_DATETIME AS VARCHAR) + '''
							,@SEQUENCE = @SEQUENCE OUTPUT

					INSERT INTO [#SALES_ORDER]
					SELECT DISTINCT
						[SO].[DocNum] 
						,[SO].[CardCode]
						,[SO].[DocDate] 
						,[SO].[DocDueDate]
						,''ERP'' [Source]
						,ISNULL([SO].[MasterIdSlp], [SO].[SlpCode]) [SlpCode] 
						,[SO].[SlpName]
						,[SO].[DocTotal]
						,[SO].[Owner]
						,' + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR) + ' [EXTERNAL_SOURCE_ID]
						,''' + @SOURCE_NAME + ''' [SOURCE_NAME]
					FROM ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[ERP_SALES_ORDER_HEADER_CHANNEL_MODERN] [SO] WITH(NOLOCK)
					WHERE [SO].[Sequence] = @SEQUENCE 
						AND [SO].[WhsCode] = ''' + @ERP_WAREHOUSE +'''
	
					EXEC ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[ERP_SP_DELETE_SALES_ORDER_BY_SEQUENCE]
						@SEQUENCE = @SEQUENCE  -- int
			';
		--
		PRINT '--> @QUERY: \n' + @QUERY;
		--
		EXEC (@QUERY);
		-- ------------------------------------------------------------------------------------
		-- Eleminamos la fuente externa
		-- ------------------------------------------------------------------------------------
		DELETE FROM [#EXTERNAL_SOURCE]
		WHERE [EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID;
	END

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