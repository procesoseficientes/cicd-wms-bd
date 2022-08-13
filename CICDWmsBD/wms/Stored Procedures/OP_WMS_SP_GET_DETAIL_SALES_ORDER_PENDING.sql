
-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-02-14 @ Team ERGON - Sprint ERGON III
-- Description:	 Procedimiento que obtiene las ordenes de ventas con despachos pendientes de SONDA.


-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-05-22 ErgonTeam@Sheik
-- Description:	 Se actualize para que filtre por fecha de picking y no del documento

-- Modificacion 9/29/2017 @ NEXUS-Team Sprint DuckHunt
					-- rodrigo.gomez
					-- Se ajusta para intercompany

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_DETAIL_SALES_ORDER_PENDING]	@START_DATETIME = '2015-02-15 08:34:17.976'
														,@END_DATETIME = '2017-02-15 08:34:17.976'
														,@SOURCE_CODE_ROUTE = '1|'
														,@CODE_ROUTE = '001'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_DETAIL_SALES_ORDER_PENDING] (
		@START_DATETIME DATETIME
		,@END_DATETIME DATETIME
		,@SOURCE_CODE_ROUTE VARCHAR(MAX)
		,@CODE_ROUTE VARCHAR(MAX)
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

	CREATE TABLE [#SALE_ORDER_DETAIL] (
		[DOC_NUM] INT
		,[POSTED_DATE] DATETIME
		,[CLIENT_CODE] VARCHAR(50)
		,[CLIENT_NAME] VARCHAR(100)
		,[MATERIAL_ID] VARCHAR(50)
		,[MATERIAL_NAME] VARCHAR(100)
		,[TOTAL_QUANTITY] INT
		,[PROCESS_QUANTITY] INT
		,[DIFERENCE] INT
		,[PRICE] MONEY
		,[UNSOLD_PRICE] MONEY
		,[TOTAL_LINE] MONEY
		,[ORIGIN] VARCHAR(50)
		,[LINE_SEQ] INT
		,[EXTERNAL_SOURCE_ID] INT
		,[SOURCE_NAME] VARCHAR(50)
		,[CODE_ROUTE] VARCHAR(50)
		,[SELLER] VARCHAR(50)
		,[MATERIAL_IN_SWIFT] VARCHAR(10)
	);

	SELECT
		[H].[DOC_NUM]
		,[D].[MATERIAL_ID]
		,[D].[LINE_NUM]
		,SUM([D].[QTY]) [QTY]
		,MAX([D].[PRICE]) [PRICE]
		,MAX([H].[IS_COMPLETED]) [IS_COMPLETED]
	INTO
		[#PICKING_DEMAND_DETAIL]
	FROM
		[wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [D]
	INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H] ON [D].[PICKING_DEMAND_HEADER_ID] = [H].[PICKING_DEMAND_HEADER_ID]
	WHERE
		[H].[IS_FROM_SONDA] = 1
	GROUP BY
		[H].[DOC_NUM]
		,[D].[MATERIAL_ID]
		,[D].[LINE_NUM]
	HAVING
		MAX([H].[IS_COMPLETED]) = 0;

	SELECT
		[H].[DOC_NUM]
		,MIN([H].[LAST_UPDATE]) [PICKING_DATE]
		,[H].[CLIENT_CODE]
		,[H].[CLIENT_NAME]
		,[H].[EXTERNAL_SOURCE_ID]
	INTO
		[#SALES_ORDERS]
	FROM
		[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H]
	WHERE
		[H].[IS_FROM_SONDA] = 1
	GROUP BY
		[H].[DOC_NUM]
		,[H].[CLIENT_CODE]
		,[H].[CLIENT_NAME]
		,[H].[EXTERNAL_SOURCE_ID]
	HAVING
		MAX([H].[IS_COMPLETED]) = 0;

	BEGIN TRY
    -- ------------------------------------------------------------------------------------
    -- Obtiene las fuentes externas
    -- ------------------------------------------------------------------------------------
		SELECT
			[ES].[EXTERNAL_SOURCE_ID]
			,[ES].[SOURCE_NAME]
			,[ES].[DATA_BASE_NAME]
			,[ES].[SCHEMA_NAME]
		INTO
			[#EXTERNAL_SOURCE]
		FROM
			[wms].[OP_SETUP_EXTERNAL_SOURCE] [ES];

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
		WHILE EXISTS ( SELECT TOP 1
							1
						FROM
							[#EXTERNAL_SOURCE] )
		BEGIN
      -- ------------------------------------------------------------------------------------
      -- Se toma la primera fuente externa
      -- ------------------------------------------------------------------------------------
			SELECT TOP 1
				@EXTERNAL_SOURCE_ID = [ES].[EXTERNAL_SOURCE_ID]
				,@SOURCE_NAME = [ES].[SOURCE_NAME]
				,@DATA_BASE_NAME = [ES].[DATA_BASE_NAME]
				,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
				,@QUERY = N''
			FROM
				[#EXTERNAL_SOURCE] [ES]
			ORDER BY
				[ES].[EXTERNAL_SOURCE_ID];
      --
			PRINT '----> @EXTERNAL_SOURCE_ID: '
				+ CAST(@EXTERNAL_SOURCE_ID AS VARCHAR);
			PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME;
			PRINT '----> @DATA_BASE_NAME: '
				+ @DATA_BASE_NAME;
			PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME;
			SELECT
				@QUERY = N'INSERT INTO [#SALE_ORDER_DETAIL]
		SELECT
        [D].[SALES_ORDER_ID] [DOC_NUM]
       ,[S].[PICKING_DATE] [POSTED_DATE]
       ,[S].[CLIENT_CODE] [CLIENT_CODE]
       ,[C].[NAME_CUSTOMER] 
       ,[M].[MATERIAL_ID]
       ,[M].[MATERIAL_NAME]
       ,[D].[QTY] TOTAL_QUANTITY
       ,ISNULL([PD].[QTY], 0) PROCESS_QUANTITY
       ,[D].[QTY] - ISNULL([PD].[QTY], 0) DIFERENCE
       ,[D].[PRICE]
       ,([D].[QTY] - ISNULL([PD].[QTY], 0))  * [D].[PRICE]  [UNSOLD_PRICE] 
       , ISNULL([PD].[QTY], 0) * [D].[PRICE] TOTAL_LINE        
       ,''SONDA'' ORIGIN
       ,[D].[LINE_SEQ]
       ,' + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR)
				+ ' [EXTERNAL_SOURCE_ID]
			 ,''' + @SOURCE_NAME + ''' [SOURCE_NAME]
       ,[SOH].[POS_TERMINAL] [CODE_ROUTE]
       ,[SOH].[POSTED_BY] [SELLER]
	   ,CASE WHEN [M].[MATERIAL_ID] IS NULL
	   THEN ''NO''
	   ELSE ''SI''
	   END [MATERIAL_IN_SWIFT]

      FROM ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
				+ '.[SONDA_SALES_ORDER_DETAIL] [D]
		INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
				+ '.[SONDA_SALES_ORDER_HEADER] [SOH]
			ON [SOH].[SALES_ORDER_ID] = [D].[SALES_ORDER_ID]
		INNER JOIN  ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
				+ '.[SWIFT_VIEW_ALL_COSTUMER] [C]
			ON [C].[CODE_CUSTOMER] = [SOH].[CLIENT_ID]
		INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
				+ '.[SWIFT_VIEW_ALL_SKU] [VAS] ON [VAS].[CODE_SKU] = [D].[SKU]
		INNER JOIN #SALES_ORDERS [S]
			ON [D].[SALES_ORDER_ID] = [S].[DOC_NUM] AND [S].[EXTERNAL_SOURCE_ID] = '
				+ CAST(@EXTERNAL_SOURCE_ID AS VARCHAR)
				+ '
		LEFT JOIN [wms].[OP_WMS_MATERIALS] [M]
			ON [M].[MATERIAL_ID] = VAS.[OWNER] + ''/'' + [VAS].[OWNER_ID]
 ' + CASE	WHEN @CODE_ROUTE IS NULL
					OR @CODE_ROUTE = '' THEN ''
			ELSE '	  INNER JOIN #ROUTE [R] ON (
				[R].[EXTERNAL_SOURCE_ID] = '
					+ CAST(@EXTERNAL_SOURCE_ID AS VARCHAR)
					+ '
				AND [R].[CODE_ROUTE] = [SOH].[POS_TERMINAL]
			)    '
		END + '
      LEFT JOIN [#PICKING_DEMAND_DETAIL] [PD]
        ON [D].[SALES_ORDER_ID] = [PD].[DOC_NUM]
        AND [PD].[MATERIAL_ID] = [M].[MATERIAL_ID]
        AND [D].[LINE_SEQ] = [PD].[LINE_NUM]
      WHERE 
			 [S].PICKING_DATE BETWEEN '''
				+ CONVERT(VARCHAR, @START_DATETIME, 121)
				+ ''' AND '''
				+ CONVERT(VARCHAR, @END_DATETIME, 121)
				+ '''';

      --
			PRINT '--> @QUERY: ' + @QUERY;
      --
			EXEC (@QUERY);

      -- ------------------------------------------------------------------------------------
      -- Eliminamos la fuente externa
      -- ------------------------------------------------------------------------------------
			DELETE FROM
				[#EXTERNAL_SOURCE]
			WHERE
				[EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID;
      --
			DELETE FROM
				[#ROUTE]
			WHERE
				[EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID;
		END;
    --
		PRINT '--> Termino el ciclo';
		SELECT
			*
		FROM
			[#SALE_ORDER_DETAIL] [SOD];

	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;

END;

/* 

SELECT
 [D].[SALES_ORDER_ID] [DOC_NUM]
,[S].[PICKING_DATE] [POSTED_DATE]
,[S].[CLIENT_CODE] [CLIENT_CODE]
,[S].[CLIENT_NAME]
,[M].[MATERIAL_ID]
,[M].[MATERIAL_NAME]
,[D].[QTY] TOTAL_QUANTITY
,ISNULL([PD].[QTY], 0) PROCESS_QUANTITY
,[D].[QTY] - ISNULL([PD].[QTY], 0) DIFERENCE
,[D].[PRICE]
,ISNULL([PD].[QTY], 0) * [D].[PRICE] TOTAL_LINE
,'SONDA' ORIGIN
,[D].[LINE_SEQ]
FROM [SWIFT_EXPRESS].[wms].[SONDA_SALES_ORDER_DETAIL] [D]
INNER JOIN [SWIFT_EXPRESS].[wms].[SONDA_SALES_ORDER_HEADER] [SOH]
 ON [SOH].[SALES_ORDER_ID] = [D].[SALES_ORDER_ID]
INNER JOIN #SALES_ORDERS [S]
 ON [D].[SALES_ORDER_ID] = [S].[DOC_NUM]
INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
 ON [M].[MATERIAL_ID] = 'wms/' + [D].[SKU]
LEFT JOIN [#PICKING_DEMAND_DETAIL] [PD]
 ON [D].[SALES_ORDER_ID] = [PD].[DOC_NUM]
 AND [PD].[MATERIAL_ID] = [M].[MATERIAL_ID]
 AND [D].[LINE_SEQ] = [PD].[LINE_NUM]
WHERE [S].[EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID
*/