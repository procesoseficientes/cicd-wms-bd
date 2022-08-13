-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-04 @ Team REBORN - Sprint Collin
-- Description:	        Sp que valida si existe una ubicacion

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].OP_WMS_SP_VALIDATE_IF_LOCATION_EXISTS @LOCATION_SPOT = 'a1lk213'
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_VALIDATE_IF_LOCATION_EXISTS (@LOCATION_SPOT VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --

  SELECT
    [SH].[WAREHOUSE_PARENT]
   ,[SH].[ZONE]
   ,[SH].[LOCATION_SPOT]
   ,[SH].[SPOT_TYPE]
   ,[SH].[SPOT_ORDERBY]
   ,[SH].[SPOT_AISLE]
   ,[SH].[SPOT_COLUMN]
   ,[SH].[SPOT_LEVEL]
   ,[SH].[SPOT_PARTITION]
   ,[SH].[SPOT_LABEL]
   ,[SH].[ALLOW_PICKING]
   ,[SH].[ALLOW_STORAGE]
   ,[SH].[ALLOW_REALLOC]
   ,[SH].[AVAILABLE]
   ,[SH].[LINE_ID]
   ,[SH].[SPOT_LINE]
   ,[SH].[LOCATION_OVERLOADED]
   ,[SH].[MAX_MT2_OCCUPANCY]
   ,[SH].[MAX_WEIGHT]
   ,[SH].[SECTION]
  FROM [wms].[OP_WMS_SHELF_SPOTS] [SH]
  WHERE [SH].[LOCATION_SPOT] = @LOCATION_SPOT

END