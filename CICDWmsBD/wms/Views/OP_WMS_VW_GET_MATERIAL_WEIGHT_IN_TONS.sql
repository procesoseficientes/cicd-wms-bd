-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creación: 	2017-05-30 ErgonTeam@SHEIK
-- Description:	 convierte el peso de cada SKU a toneladas


/*
-- Ejemplo de Ejecucion:
			SELECT * FROM [wms].OP_WMS_VW_GET_MATERIAL_WEIGHT_IN_TONS
*/
-- =============================================
CREATE VIEW [wms].OP_WMS_VW_GET_MATERIAL_WEIGHT_IN_TONS
AS
SELECT
  [wms].[OP_WMS_FN_CONVERT_FROM_WEIGHT_MEASURE_UNIT_TO_DEFAULT](MAX([M].[WEIGTH]), MAX(M.[WEIGHT_MEASUREMENT])) * SUM([IL].[QTY]) [WEIGHT_TONS]
 ,[M].[MATERIAL_ID]
 ,[IL].[LICENSE_ID]
FROM [wms].[OP_WMS_MATERIALS] [M]
INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL]
  ON [IL].[MATERIAL_ID] = [M].[MATERIAL_ID]
  AND [IL].[QTY] > 0
GROUP BY [M].[MATERIAL_ID]
        ,[IL].[LICENSE_ID]