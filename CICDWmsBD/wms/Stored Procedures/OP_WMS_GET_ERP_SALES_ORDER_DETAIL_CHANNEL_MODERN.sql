
-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-02-01 @ Team ERGON - Sprint ERGON 
-- Description:	        Sp que trae el detalle de las ordenes de venta del canal moderno de sap


-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-07-14 Nexus@AgeOfEmpires
-- Description:	 Se agrega para que devuelva si el producto es masterpack . 


/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_GET_ERP_SALES_ORDER_DETAIL_CHANNEL_MODERN] @DOC_NUM = 1, @EXTERNAL_SOURCE_ID = 1
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_GET_ERP_SALES_ORDER_DETAIL_CHANNEL_MODERN (@DOC_NUM INT, @EXTERNAL_SOURCE_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @SOURCE_NAME VARCHAR(50)
         ,@DATA_BASE_NAME VARCHAR(50)
         ,@SCHEMA_NAME VARCHAR(50)
         ,@QUERY NVARCHAR(MAX)
  -- ------------------------------------------------------------------------------------
  -- Obtiene la fuente externa
  -- ------------------------------------------------------------------------------------
  SELECT
    @SOURCE_NAME = [ES].[SOURCE_NAME]
   ,@DATA_BASE_NAME = [ES].[INTERFACE_DATA_BASE_NAME]
   ,@SCHEMA_NAME = [ES].[schema_name]
  FROM [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
  WHERE [ES].[EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID
  --
  PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME
  PRINT '----> @DATA_BASE_NAME: ' + @DATA_BASE_NAME
  PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME

  SELECT
    [H].[DOC_NUM]
   ,[D].[MATERIAL_ID]
   ,SUM([D].[QTY]) [QTY] INTO #PICKING_DEMAND_DETAIL
  FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [D]
  INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H]
    ON [D].[PICKING_DEMAND_HEADER_ID] = [H].[PICKING_DEMAND_HEADER_ID]
  WHERE [H].[DOC_NUM] = @DOC_NUM
  AND [H].[EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID
  AND [H].[IS_FROM_ERP] = 1
  GROUP BY [H].[DOC_NUM]
          ,[D].[MATERIAL_ID]
  -- ------------------------------------------------------------------------------------
  -- Obtiene el detalle de la ordenes de venta de la fuente externa
  -- ------------------------------------------------------------------------------------
  SELECT
    @QUERY = N'
  SELECT
    [SOD].[DocDate] AS POSTED_DATETIME
   ,[SOD].[DOCNUM] AS SALES_ORDER_ID
   ,[SOD].[U_Serie]
   ,[SOD].[U_NoDocto]
   ,[SOD].[CardCode] AS CLIENT_ID
   ,[SOD].[CardName] AS NAME_CUSTOMER
   ,[SOD].[SLPNAME]
   ,[SOD].[U_OPER] AS CODE_SELLER
   ,''' + @SOURCE_NAME + '/'' +[SOD].[ItemCode] AS SKU
   ,[SOD].[Dscription] AS DESCRIPTION_SKU
   ,[M].[BARCODE_ID]
   ,[M].[ALTERNATE_BARCODE] 
   ,CEILING([SOD].[Quantity] - ISNULL([DD].[QTY], 0)) [QTY]
   ,CEILING([SOD].[Quantity] - ISNULL([DD].[QTY], 0)) [QTY_PENDING]
   ,CEILING([SOD].[Quantity]) [QTY_ORIGINAL]
   ,[SOD].[PRECIO_CON_IVA] AS PRICE
   ,[SOD].[TOTAL_LINEA_SIN_DESCUENTO] AS TOTAL_LINE
   ,[SOD].[TOTAL_LINEA_CON_DESCUENTO_APLICADO]
   ,[SOD].[WhsCode] AS CODE_WAREHOUSE
   ,[SOD].[DESCUENTO_FACTURA] AS DISCOUNT
   ,[SOD].[NUMERO_LINEA] AS LINE_SEQ
   ,' + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR) + ' [EXTERNAL_SOURCE_ID]
	 ,''' + @SOURCE_NAME + ''' [SOURCE_NAME]
  ,[M].[IS_MASTER_PACK] 
  FROM ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[ERP_VIEW_SALES_ORDER_DETAIL_CHANNEL_MODERN] [SOD]
  INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON (
				''' + @SOURCE_NAME + '/'' + [SOD].[ItemCode] = [M].[MATERIAL_ID] COLLATE SQL_Latin1_General_CP1_CI_AS
  )
  LEFT JOIN #PICKING_DEMAND_DETAIL [DD]
          ON ([SOD].[DOCNUM] = [DD].[DOC_NUM]
          AND [M].[MATERIAL_ID] = [DD].[MATERIAL_ID])
  WHERE [SOD].[DOCNUM] = ' + CAST(@DOC_NUM AS VARCHAR) + ' 
  AND CEILING([SOD].[Quantity] - ISNULL([DD].[QTY], 0)) > 0'
  --
  PRINT '--> @QUERY: ' + @QUERY
  --
  EXEC (@QUERY)
END