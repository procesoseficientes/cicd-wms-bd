-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	28-Oct-16 @ A-TEAM Sprint 4
-- Description:			SP que obtiene el detalle de una fuente externa

-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	31-Ene-17 @ ErgonTeam Sprint ERGON II
-- Description:			Se agrego validacion para que reste los materiales pickeados 


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-02-14 Team ERGON - Sprint ERGON III
-- Description:	  Se agrega por problema en group by de materiales pickeados. 



/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_SALE_ORDER_DETAIL_FROM_EXTERNAL]
					@EXTERNAL_SOURCE_ID = 1
					,@SALES_ORDER_ID = 34743
				--
				EXEC [wms].[OP_WMS_SP_GET_SALE_ORDER_DETAIL_FROM_EXTERNAL]
					@EXTERNAL_SOURCE_ID = 2
					,@SALES_ORDER_ID = 22
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_SALE_ORDER_DETAIL_FROM_EXTERNAL (@EXTERNAL_SOURCE_ID INT
, @SALES_ORDER_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @SOURCE_NAME VARCHAR(50)
         ,@DATA_BASE_NAME VARCHAR(50)
         ,@SCHEMA_NAME VARCHAR(50)
         ,@QUERY NVARCHAR(MAX)

  BEGIN TRY
    -- ------------------------------------------------------------------------------------
    -- Obtiene la fuente externa
    -- ------------------------------------------------------------------------------------
    SELECT TOP 1
      @SOURCE_NAME = [ES].[SOURCE_NAME]
     ,@DATA_BASE_NAME = [ES].[DATA_BASE_NAME]
     ,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
    FROM [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
    WHERE [ES].[EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID
    --
    PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME
    PRINT '----> @DATA_BASE_NAME: ' + @DATA_BASE_NAME
    PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME



    SELECT
      [H].[DOC_NUM]
     ,[D].[MATERIAL_ID]
     ,[D].[LINE_NUM]
     ,SUM([D].[QTY]) [QTY] INTO #PICKING_DEMAND_DETAIL
    FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [D]
    INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H]
      ON [D].[PICKING_DEMAND_HEADER_ID] = [H].[PICKING_DEMAND_HEADER_ID]
    WHERE [H].[DOC_NUM] = @SALES_ORDER_ID
    GROUP BY [H].[DOC_NUM]
            ,[D].[MATERIAL_ID]
            ,[D].[LINE_NUM]



    -- ------------------------------------------------------------------------------------
    -- Obtiene el detalle de la ordenes de venta de la fuente externa
    -- ------------------------------------------------------------------------------------
    SELECT
      @QUERY = N'SELECT
				[SOD].[SALES_ORDER_ID]
				,''' + @SOURCE_NAME + '/'' + [SOD].[SKU] [SKU]
				,[SOD].[LINE_SEQ]
			  ,CEILING([SOD].[QTY] - ISNULL([DD].[QTY], 0)) [QTY]
        ,CEILING([SOD].[QTY] - ISNULL([DD].[QTY], 0)) [QTY_PENDING]
        ,CEILING([SOD].[QTY]) [QTY_ORIGINAL]
				,[SOD].[PRICE]
				,[SOD].[DISCOUNT]
				,[SOD].[TOTAL_LINE]
				,[SOD].[POSTED_DATETIME]
				,[SOD].[SERIE]
				,[SOD].[SERIE_2]
				,[SOD].[REQUERIES_SERIE]
				,[SOD].[COMBO_REFERENCE]
				,[SOD].[PARENT_SEQ]
				,[SOD].[IS_ACTIVE_ROUTE]
				,[SOD].[CODE_PACK_UNIT]
				,[SOD].[IS_BONUS]
				,[M].[MATERIAL_NAME] [DESCRIPTION_SKU]
				,[M].[BARCODE_ID]
				,[M].[ALTERNATE_BARCODE]
				,' + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR) + ' [EXTERNAL_SOURCE_ID]
				,''' + @SOURCE_NAME + ''' [SOURCE_NAME]
        , -1 [ERP_OBJECT_TYPE]
			FROM ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SONDA_SALES_ORDER_DETAIL] [SOD]			
			INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON (
				''' + @SOURCE_NAME + '/'' + [SOD].[SKU] = [M].[MATERIAL_ID]
			)
      LEFT JOIN #PICKING_DEMAND_DETAIL [DD]
          ON ([SOD]. [SALES_ORDER_ID] = [DD].[DOC_NUM]
          AND [M].[MATERIAL_ID] = [DD].[MATERIAL_ID] AND  [DD].[LINE_NUM] = [SOD].[LINE_SEQ])
			WHERE [SOD].[SALES_ORDER_ID] = ' + CAST(@SALES_ORDER_ID AS VARCHAR) + '
        AND CEILING([SOD].[QTY] - ISNULL([DD].[QTY], 0)) > 0'
    --
    PRINT '--> @QUERY: ' + @QUERY
    --
    EXEC (@QUERY)
  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@ERROR Codigo
  END CATCH
END