-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creación: 	2017-05-30 ErgonTeam@SHEIK
-- Description:	 Este debe de devolver las ubicaciones de shelspots Hacer que devuelva una columna con nombre WEIGTH_PERCENT que indique el porcentaje de cuanto peso tiene ocupado con los materiales que tiene la ubicacion
--               Hacer que devuelva la columna IS_OVERWEIGHT que devuelva un SI si tiene mas del %100 de peso ocupado




/*
-- Ejemplo de Ejecucion:
			SELECT * FROM [wms].[OP_WMS_VW_GET_LOCATIONS_WITH_WEIGHT] 
  SELECT COUNT(IS_OVERWEIGHT),IS_OVERWEIGHT FROM [wms].[OP_WMS_VW_GET_LOCATIONS_WITH_WEIGHT] GROUP BY IS_OVERWEIGHT
*/
-- =============================================
CREATE VIEW [wms].OP_WMS_VW_GET_LOCATIONS_WITH_WEIGHT
AS
SELECT
  [S].[LOCATION_SPOT]
 ,[S].[WAREHOUSE_PARENT]
 ,[S].[ZONE]
 ,SUM([M].[WEIGHT_TONS]) WEIGHT_IN_TONS
 ,MAX(ISNULL([S].[MAX_WEIGHT], 0)) [MAX_WEIGHT]
 ,CASE
    WHEN MAX(ISNULL([S].[MAX_WEIGHT], 1)) = 0 THEN 0
    ELSE (SUM([M].[WEIGHT_TONS]) / MAX(ISNULL([S].[MAX_WEIGHT], 1))) * 100
  END [WEIGHT_PERCENT]
 ,CASE
    WHEN SUM([M].[WEIGHT_TONS]) > MAX(ISNULL(S.[MAX_WEIGHT], 0)) THEN 1
    ELSE 0
  END IS_OVERWEIGHT
FROM [wms].[OP_WMS_SHELF_SPOTS] [S]
LEFT JOIN [wms].[OP_WMS_LICENSES] [L]
  ON [L].[CURRENT_LOCATION] = [S].[LOCATION_SPOT]
LEFT JOIN [wms].[OP_WMS_VW_GET_MATERIAL_WEIGHT_IN_TONS] M
  ON M.[LICENSE_ID] = [L].[LICENSE_ID]
GROUP BY [S].[LOCATION_SPOT]
        ,[S].[WAREHOUSE_PARENT]
        ,[S].[ZONE]