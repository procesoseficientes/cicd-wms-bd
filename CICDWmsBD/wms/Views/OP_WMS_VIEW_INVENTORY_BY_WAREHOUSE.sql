

-- =============================================
-- Autor:					rudi.garcia
-- Fecha de Creacion: 		2017-03-24 @ Team ERGON Sprint Hyper
-- Description:			    Vista que trae el inventario disponible por bodega

/*
-- Ejemplo de Ejecucion:
		SELECT * FROM [wms].OP_WMS_VIEW_INVENTORY_BY_WAREHOUSE
*/
-- =============================================

CREATE VIEW [wms].[OP_WMS_VIEW_INVENTORY_BY_WAREHOUSE]
AS

SELECT
  [L].[CURRENT_WAREHOUSE]
 ,[IL].[MATERIAL_ID]
 ,[IL].[MATERIAL_NAME]
 ,SUM([IL].[QTY]) - MAX(ISNULL([IR].[QTY_RESERVED], 0)) QTY
 ,((SELECT ERP_WAREHOUSE FROM wms.OP_WMS_WAREHOUSES WHERE WAREHOUSE_ID = [L].CURRENT_WAREHOUSE)) AS ERP_WAREHOUSE
FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]
INNER JOIN [wms].[OP_WMS_LICENSES] [L]
  ON (
    [IL].[LICENSE_ID] = [L].[LICENSE_ID]
    )
LEFT JOIN [wms].[OP_WMS_FUNC_GET_INVENTORY_RESERVED]() [IR]
  ON (
      [IR].[CODE_WAREHOUSE] = [L].[CURRENT_WAREHOUSE]
      AND [IR].[CODE_MATERIAL] = [IL].[MATERIAL_ID]
    )
WHERE [L].[CURRENT_WAREHOUSE] IS NOT NULL
GROUP BY [L].[CURRENT_WAREHOUSE]
        ,[IL].[MATERIAL_ID]
        ,[IL].[MATERIAL_NAME]