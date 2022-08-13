-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-02-14 @ Team ERGON - Sprint ERGON III
-- Description:	 Procedimiento que obtiene las ordenes de ventas con despachos pendientes de ERP.

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-05-22 ErgonTeam@Sheik
-- Description:	 Se actualize para que filtre por fecha de picking y no del documento

-- Modificacion 9/29/2017 @ NEXUS-Team Sprint Duckhunt
					-- rodrigo.gomez
					-- Se modifica filtro de material ownre para intercompany

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20190204 GForce@Rinoceronte
-- Description:			Se modifica para que consuma sps que no dependan de la bodega

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_ERP_DETAIL_SALES_ORDER_CHANNEL_MODERN_PENDING]	@START_DATE = '2017-09-29 00:34:17.976'
														,@END_DATE = '2017-09-29 23:34:17.976'
													
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_ERP_DETAIL_SALES_ORDER_CHANNEL_MODERN_PENDING] (
		@START_DATE DATETIME
		,@END_DATE DATETIME
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
		,[TOTAL_LINE] MONEY
		,[UNSOLD_PRICE] MONEY
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
		[H].[IS_FROM_ERP] = 1
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
		,[H].[OWNER]
	INTO
		[#SALES_ORDERS]
	FROM
		[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H]
	WHERE
		[H].[IS_FROM_ERP] = 1
	GROUP BY
		[H].[DOC_NUM]
		,[H].[CLIENT_CODE]
		,[H].[CLIENT_NAME]
		,[H].[EXTERNAL_SOURCE_ID]
		,[H].[OWNER]
	HAVING
		MAX([H].[IS_COMPLETED]) = 0;

	BEGIN TRY
    -- ------------------------------------------------------------------------------------
    -- Obtiene las fuentes externas
    -- ------------------------------------------------------------------------------------
		SELECT
			[ES].[EXTERNAL_SOURCE_ID]
			,[ES].[SOURCE_NAME]
			,[ES].[INTERFACE_DATA_BASE_NAME] [DATA_BASE_NAME]
			,[ES].[SCHEMA_NAME]
		INTO
			[#EXTERNAL_SOURCE]
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
				@QUERY = N'
		
			
DECLARE @SEQUENCE_HEADER INT  = 0 , 
@SEQUENCE_DETAIL INT  = 0


EXEC ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
				+ '.[ERP_SP_INSERT_SALES_ORDER_HEADER_WITHOUT_WAREHOUSE] @START_DATE = '''
				+ CONVERT(VARCHAR, @START_DATE, 121)
				+ ''', -- varchar(100)
	@END_DATE = ''' + CONVERT(VARCHAR, @END_DATE, 121)
				+ ''', -- varchar(100)
	@SEQUENCE = @SEQUENCE_HEADER OUTPUT -- int

EXEC ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
				+ '.[ERP_SP_INSERT_SALES_ORDER_DETAIL_WITHOUT_WAREHOUSE] @START_DATE = '''
				+ CONVERT(VARCHAR, @START_DATE, 121)
				+ ''', -- varchar(100)
	@END_DATE = ''' + CONVERT(VARCHAR, @END_DATE, 121)
				+ ''', -- varchar(100)
	@SEQUENCE = @SEQUENCE_DETAIL OUTPUT  -- int


		
		INSERT INTO [#SALE_ORDER_DETAIL]
          	SELECT
           [SOD].[DOCNUM]  [DOC_NUM]
          ,[SOD].[DocDate] [POSTED_DATE]
          ,[SOD].[CardCode] [CLIENT_CODE]
          ,[SOD].[CardName] [CLIENT_NAME]
          ,[M].[MATERIAL_ID]
          ,[M].[MATERIAL_NAME]
          ,[SOD].[Quantity]  TOTAL_QUANTITY
          ,ISNULL([PD].[QTY], 0) PROCESS_QUANTITY
          ,[SOD].[Quantity] - ISNULL([PD].[QTY], 0) DIFERENCE
          ,[SOD].[PRECIO_CON_IVA] [PRICE]
          ,ISNULL([PD].[QTY], 0) * [SOD].[PRECIO_CON_IVA] TOTAL_LINE
          , ([SOD].[Quantity] - ISNULL([PD].[QTY], 0))  * [SOD].[PRECIO_CON_IVA][UNSOLD_PRICE] 
          ,''ERP'' ORIGIN
          ,[SOD].[NUMERO_LINEA]
       ,' + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR)
				+ ' [EXTERNAL_SOURCE_ID]
			 ,''' + @SOURCE_NAME + ''' [SOURCE_NAME]
       ,NULL [CODE_ROUTE]
       ,[SOH].[U_OPER] [LOGIN]
	   ,CASE WHEN [M].[MATERIAL_ID] IS NULL
	   THEN ''NO''
	   ELSE ''SI''
	   END [MATERIAL_IN_SWIFT]


      FROM ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
				+ '.[ERP_SALES_ORDER_DETAIL_CHANNEL_MODERN] [SOD] 
      INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
				+ '.[ERP_SALES_ORDER_HEADER_CHANNEL_MODERN] [SOH]
        ON [SOH].[DOCNUM] = [SOD].[DOCNUM] AND SOH.Owner = SOD.Owner
      INNER JOIN #SALES_ORDERS [S]
        ON  [SOD].[DOCNUM] = [S].[DOC_NUM] AND [S].[EXTERNAL_SOURCE_ID] = '
				+ CAST(@EXTERNAL_SOURCE_ID AS VARCHAR)
				+ '
      LEFT JOIN [wms].[OP_WMS_MATERIALS] [M]
        ON [M].[MATERIAL_ID] = [SOD].[U_OwnerSKU] +	''/'' +  [SOD].[ItemCode] COLLATE SQL_Latin1_General_CP1_CI_AS
 
      LEFT JOIN [#PICKING_DEMAND_DETAIL] [PD]
        ON [SOH].[DOCNUM] = [PD].[DOC_NUM]
         AND [PD].[MATERIAL_ID] = [M].[MATERIAL_ID]
         AND [SOD].[NUMERO_LINEA] = [PD].[LINE_NUM]
      WHERE 
			 [S].[PICKING_DATE] BETWEEN '''
				+ CONVERT(VARCHAR, @START_DATE, 121)
				+ ''' AND ''' + CONVERT(VARCHAR, @END_DATE, 121)
				+ '''
			 AND  @SEQUENCE_HEADER = [SOH].[Sequence] AND SOD.[Sequence] = @SEQUENCE_DETAIL
			 
	

		EXEC ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
				+ '.[ERP_SP_DELETE_SALES_ORDER_BY_SEQUENCE] @Sequence =@SEQUENCE_HEADER -- int
		EXEC ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
				+ '.[ERP_SP_DELETE_SALES_ORDER_BY_SEQUENCE] @Sequence = @SEQUENCE_DETAIL -- int
			 
			 ';

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
