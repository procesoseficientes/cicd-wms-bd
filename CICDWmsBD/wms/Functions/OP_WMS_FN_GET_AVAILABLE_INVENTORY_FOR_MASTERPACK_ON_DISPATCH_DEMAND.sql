-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		7/12/2017 @ NEXUS-Team Sprint AgeOfEmpires
-- Description:			    Obtiene el inventario disponible de los masterpacks para la demanda despacho

-- Modificacion 26-Nov-18 @ G-Force Team Sprint ornitorinco
-- rudi.garcia
-- Historia: Product Backlog Item 25517: Demanda de despacho con estados por linea
-- Se agrego la condicion de estado del matarial

/*
-- Ejemplo de Ejecucion:
        SELECT [wms].[OP_WMS_FN_GET_AVAILABLE_INVENTORY_FOR_MASTERPACK_ON_DISPATCH_DEMAND]('wms/SKUPRUEBA','BODEGA_01')
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_AVAILABLE_INVENTORY_FOR_MASTERPACK_ON_DISPATCH_DEMAND] (@MASTER_PACK_CODE VARCHAR(50)
, @WAREHOUSE_ID VARCHAR(25)
, @STATUS_CODE VARCHAR(50) = NULL)
RETURNS INT
AS
BEGIN
  DECLARE @COMPONENT_INVENTORY TABLE (
    MATERIAL_ID VARCHAR(50)
   ,QTY INT
   ,QTY_NEEDED INT
   ,REAL_QTY INT
  )
  DECLARE @QTYMP INT = 0
         ,@QTYCOMPS INT = 0
         ,@DISPATCH_BY_STATUS INT = 0;

  SELECT
    @DISPATCH_BY_STATUS = CONVERT(INT, [P].[VALUE])
  FROM [wms].[OP_WMS_PARAMETER] [P]
  WHERE [P].[GROUP_ID] = 'PICKING_DEMAND'
  AND [P].[PARAMETER_ID] = 'DISPATCH_BY_STATUS'
  -- ------------------------------------------------------------------------------------
  -- Se obtiene el inventario fisico que se tiene del masterpack
  -- ------------------------------------------------------------------------------------
  SELECT
    @QTYMP = SUM(ISNULL([AVAILABLE_QTY], 0))
  FROM [wms].[OP_WMS_VIEW_INVENTORY_FOR_PICKING] WITH (NOLOCK)
  WHERE [MATERIAL_ID] = @MASTER_PACK_CODE
  AND @WAREHOUSE_ID = [CURRENT_WAREHOUSE]
  -- ------------------------------------------------------------------------------------
  -- Se insertan todos los componentes en una tabla temporal.
  -- ------------------------------------------------------------------------------------
  IF (@DISPATCH_BY_STATUS = 0
    OR @STATUS_CODE IS NULL)
  BEGIN
    INSERT INTO @COMPONENT_INVENTORY ([MATERIAL_ID]
    , [QTY]
    , [QTY_NEEDED]
    , [REAL_QTY])
      SELECT
        [CXMP].[COMPONENT_MATERIAL]
       ,SUM(ISNULL([IXW].[AVAILABLE_QTY], 0))
       ,[CXMP].[QTY] [QTY_NEEDED]
       ,CAST(SUM(ISNULL([IXW].[AVAILABLE_QTY], 0)) / [CXMP].[QTY] AS INT) REAL_QTY
      FROM [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [CXMP] WITH (NOLOCK)
      LEFT JOIN [wms].[OP_WMS_VIEW_INVENTORY_FOR_PICKING] [IXW] WITH (NOLOCK)
        ON [IXW].[MATERIAL_ID] = [CXMP].[COMPONENT_MATERIAL]
        AND [IXW].[CURRENT_WAREHOUSE] = @WAREHOUSE_ID
      WHERE [CXMP].[MASTER_PACK_CODE] = @MASTER_PACK_CODE
      GROUP BY [CXMP].[COMPONENT_MATERIAL]
              ,[CXMP].[QTY]
  END
  ELSE
  BEGIN
    INSERT INTO @COMPONENT_INVENTORY ([MATERIAL_ID]
    , [QTY]
    , [QTY_NEEDED]
    , [REAL_QTY])
      SELECT
        [CXMP].[COMPONENT_MATERIAL]
       ,SUM(ISNULL([IXW].[AVAILABLE_QTY], 0))
       ,[CXMP].[QTY] [QTY_NEEDED]
       ,CAST(SUM(ISNULL([IXW].[AVAILABLE_QTY], 0)) / [CXMP].[QTY] AS INT) REAL_QTY
      FROM [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [CXMP] WITH (NOLOCK)
      LEFT JOIN [wms].[OP_WMS_VIEW_INVENTORY_FOR_PICKING_BY_STATUS_MATERIAL] [IXW] WITH (NOLOCK)
        ON ([IXW].[MATERIAL_ID] = [CXMP].[COMPONENT_MATERIAL]
        AND [IXW].[CURRENT_WAREHOUSE] = @WAREHOUSE_ID
        AND [IXW].[STATUS_CODE] = @STATUS_CODE)
      WHERE [CXMP].[MASTER_PACK_CODE] = @MASTER_PACK_CODE
      GROUP BY [CXMP].[COMPONENT_MATERIAL]
              ,[CXMP].[QTY]
  END

  -- ------------------------------------------------------------------------------------
  -- Obtenemos la cantidad minima de masterpacks a ensamblar
  -- ------------------------------------------------------------------------------------
  SELECT TOP 1
    @QTYCOMPS = ISNULL([REAL_QTY], 0)
  FROM @COMPONENT_INVENTORY
  ORDER BY [REAL_QTY] ASC

  --
  RETURN ISNULL(@QTYCOMPS, 0) + ISNULL(@QTYMP, 0)
END