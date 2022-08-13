-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-02-19 @ Team ERGON - Sprint ERGON III
-- Description:	 Consultar ubicaciones por bodega y zona 

-- Modificacion 6/26/2017 
-- rodrigo.gomez
-- Se castea la columna AVAILABLE como varchar para que se apegue a la estructura de la entidad


/*
-- Ejemplo de Ejecucion:
		EXEC 	[wms].[OP_WMS_SP_GET_LOCATION_BY_ZONE_OR_WAREHOUSE] @WAREHOUSE = 'BODEGA_04|BODEGA_05', @ZONE = 'BODEGA_04_PASILLO'
  SELECT * FROM [wms].[OP_WMS_SHELF_SPOTS] [S] 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_LOCATION_BY_ZONE_OR_WAREHOUSE] (@WAREHOUSE VARCHAR(MAX),
@ZONE VARCHAR(MAX) = NULL)
AS
BEGIN
  SET NOCOUNT ON;


  SELECT
    [W].[VALUE] [CODE_WAREHOUSE] INTO #WAREHOUSE
  FROM [wms].[OP_WMS_FN_SPLIT](@WAREHOUSE, '|') [W]

  SELECT
    [Z].[VALUE] [CODE_ZONE] INTO #ZONE
  FROM [wms].[OP_WMS_FN_SPLIT](@ZONE, '|') [Z]
  --
  SELECT 
  [S].[WAREHOUSE_PARENT]
 ,[S].[ZONE]
 ,[S].[LOCATION_SPOT]
 ,[S].[SPOT_TYPE]
 ,[S].[SPOT_ORDERBY]
 ,[S].[SPOT_AISLE]
 ,[S].[SPOT_COLUMN]
 ,[S].[SPOT_LEVEL]
 ,[S].[SPOT_PARTITION]
 ,[S].[SPOT_LABEL]
 ,[S].[ALLOW_PICKING]
 ,[S].[ALLOW_STORAGE]
 ,[S].[ALLOW_REALLOC]
 ,CAST([S].[AVAILABLE] AS VARCHAR(5)) [AVAILABLE]
 ,[S].[LINE_ID]
 ,[S].[SPOT_LINE]
 ,[S].[LOCATION_OVERLOADED]
 ,[S].[MAX_MT2_OCCUPANCY]
  FROM [wms].[OP_WMS_SHELF_SPOTS] [S]
  INNER JOIN [#WAREHOUSE] [W]
    ON [S].[WAREHOUSE_PARENT] = [W].[CODE_WAREHOUSE]
  LEFT JOIN [#ZONE] [Z]
    ON [Z].[CODE_ZONE] = [S].[ZONE]
  WHERE (@ZONE IS NULL
  OR [Z].[CODE_ZONE] IS NOT NULL)



END