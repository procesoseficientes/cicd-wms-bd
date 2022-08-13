-- =============================================
-- Autor:					rudi.garcia
-- Fecha de Creacion: 		08-03-2017 @ Team ERGON - Sprint V ERGON
-- Description:			    Obtiene la ubiacion

-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_LOCATION] (@LOCATION VARCHAR(25))
AS
BEGIN

  --
  SELECT
    [SS].[WAREHOUSE_PARENT]
   ,[SS].[ZONE]
   ,[SS].[LOCATION_SPOT]
   ,[SS].[SPOT_TYPE]
   ,[SS].[SPOT_ORDERBY]
   ,[SS].[SPOT_AISLE]
   ,[SS].[SPOT_COLUMN]
   ,[SS].[SPOT_LEVEL]
   ,[SS].[SPOT_PARTITION]
   ,[SS].[SPOT_LABEL]
   ,[SS].[ALLOW_PICKING]
   ,[SS].[ALLOW_STORAGE]
   ,[SS].[ALLOW_REALLOC]
   ,[SS].[AVAILABLE]
   ,[SS].[LINE_ID]
   ,[SS].[SPOT_LINE]
   ,[SS].[LOCATION_OVERLOADED]
   ,[SS].[MAX_MT2_OCCUPANCY]
  FROM [wms].[OP_WMS_SHELF_SPOTS] [SS]
  WHERE [SS].[LOCATION_SPOT] = @LOCATION
--

END