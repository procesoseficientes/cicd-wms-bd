-- =============================================
-- Autor:					rudi.garcia
-- Fecha de Creacion: 		04-Jun-2019 G-Force@Berlin-Swift3PL
-- Description:			    SP que obtiene el IDLE

/*
-- Ejemplo de Ejecucion:
        EXEC [wms].OP_WMS_SP_GET_IDLE			
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_GET_IDLE] (@LOGIN VARCHAR(25)
, @WAREHOUSE_XML XML
, @ZONE_XML XML
, @MATERIAL_XML XML)
AS
BEGIN
  SET NOCOUNT ON;
  -- -----------------------------------------------------------------
  -- Declaramos las variables necesarias
  -- -----------------------------------------------------------------

  DECLARE @WAREHOUSE_TABLE TABLE (
    [CODE_WAREHOUSE] VARCHAR(25)
  )


  DECLARE @ZONE_TABLE TABLE (
    [ZONE] VARCHAR(25)
  )

  DECLARE @LOCATION_TABLE TABLE (
    [LOCATION] VARCHAR(25)
   ,[ZONE] VARCHAR(25)
  )


  DECLARE @MATERIAL_TABLE TABLE (
    [MATERIAL_CODE] VARCHAR(50)
  )

  -- -----------------------------------------------------------------
  -- Obtemos las bodegas enviadas
  -- -----------------------------------------------------------------

  INSERT INTO @WAREHOUSE_TABLE ([CODE_WAREHOUSE])
    SELECT
      [x].[Rec].[query]('./WAREHOUSE_ID').[value]('.', 'VARCHAR(25)')
    FROM @WAREHOUSE_XML.[nodes]('/ArrayOfBodega/Bodega')
    AS [x] ([Rec]);


  -- -----------------------------------------------------------------
  -- Obtemos las zonas enviadas
  -- -----------------------------------------------------------------

  INSERT INTO @ZONE_TABLE ([ZONE])
    SELECT
      [x].[Rec].[query]('./ZONE').[value]('.', 'VARCHAR(25)')
    FROM @ZONE_XML.[nodes]('/ArrayOfZona/Zona')
    AS [x] ([Rec]);

  -- -----------------------------------------------------------------
  -- Obtemos las materiales enviadas
  -- -----------------------------------------------------------------

  INSERT INTO @MATERIAL_TABLE ([MATERIAL_CODE])
    SELECT
      [x].[Rec].[query]('./MATERIAL_CODE').[value]('.', 'VARCHAR(25)')
    FROM @MATERIAL_XML.[nodes]('/ArrayOfMaterial/Material')
    AS [x] ([Rec]);

  -- -----------------------------------------------------------------
  -- Validamos si enviaron bodegas para filtrar
  -- -----------------------------------------------------------------
  IF NOT EXISTS (SELECT
        1
      FROM @WAREHOUSE_TABLE)
  BEGIN

    -- -----------------------------------------------------------------
    -- Si no enviarion bodegas para filtrar buscamos las de el usuario
    -- -----------------------------------------------------------------
    INSERT INTO @WAREHOUSE_TABLE ([CODE_WAREHOUSE])
      SELECT
        [WU].[WAREHOUSE_ID]
      FROM [wms].[OP_WMS_WAREHOUSE_BY_USER] [WU]
      INNER JOIN [wms].[OP_WMS_WAREHOUSES] [W]
        ON (
        [W].[WAREHOUSE_ID] = [WU].[WAREHOUSE_ID]
        )
      WHERE [WU].[LOGIN_ID] = @LOGIN
  END

  -- -----------------------------------------------------------------
  -- Validamos si enviaron zonas para filtrar
  -- -----------------------------------------------------------------
  IF NOT EXISTS (SELECT
        1
      FROM @ZONE_TABLE)
  BEGIN

    -- -----------------------------------------------------------------
    -- Si no enviarion zonas para filtrar buscamos por las bodegas establecidas
    -- -----------------------------------------------------------------
    INSERT INTO @ZONE_TABLE ([ZONE])
      SELECT
        [SS].[ZONE]
      FROM [wms].[OP_WMS_SHELF_SPOTS] [SS]
      INNER JOIN @WAREHOUSE_TABLE [WT]
        ON ([SS].[WAREHOUSE_PARENT] = [WT].[CODE_WAREHOUSE])
      GROUP BY [SS].[ZONE]
  END

  -- -----------------------------------------------------------------
  -- Ya que tenemos las bodegas y zonas obtemos las ubicaciones
  -- -----------------------------------------------------------------
  INSERT INTO @LOCATION_TABLE ([LOCATION], [ZONE])
    SELECT
      [SS].[LOCATION_SPOT]
     ,[SS].[ZONE]
    FROM [wms].[OP_WMS_SHELF_SPOTS] [SS]
    INNER JOIN @WAREHOUSE_TABLE [WT]
      ON ([SS].[WAREHOUSE_PARENT] = [WT].[CODE_WAREHOUSE])
    INNER JOIN @ZONE_TABLE [ZT]
      ON ([SS].[ZONE] = [ZT].[ZONE])

  -- -----------------------------------------------------------------
  -- Validamos si materiales para filtrar
  -- -----------------------------------------------------------------
  IF NOT EXISTS (SELECT
        1
      FROM @MATERIAL_TABLE)
  BEGIN

    -- -----------------------------------------------------------------
    -- Si no enviarion materiales para filtrar buscamos por las ubicaciones establecidas
    -- -----------------------------------------------------------------
    INSERT INTO @MATERIAL_TABLE ([MATERIAL_CODE])
      SELECT
        [IL].[MATERIAL_ID]
      FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]
      INNER JOIN [wms].[OP_WMS_LICENSES] [L]
        ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
      INNER JOIN @LOCATION_TABLE [LT]
        ON ([L].[CURRENT_LOCATION] = [LT].[LOCATION])
      WHERE [IL].[QTY] > 0
      GROUP BY [IL].[MATERIAL_ID]
  END

  -- -----------------------------------------------------------------
  -- Si no enviarion materiales para filtrar buscamos por las bodegas y zonas establecidas
  -- -----------------------------------------------------------------

  SELECT
    [L].[CURRENT_WAREHOUSE]
   ,[LT].[ZONE]
   ,[L].[CURRENT_LOCATION]
   ,[L].[LICENSE_ID]
   ,[IL].[MATERIAL_ID]
   ,[IL].[BARCODE_ID]
   ,[IL].[MATERIAL_NAME]
   ,[IL].[QTY]
   ,[IL].[IDLE]
   ,[IL].[NUMBER_OF_COMPLETE_RELOCATIONS]
   ,[IL].[NUMBER_OF_PARTIAL_RELOCATIONS]
   ,[IL].[NUMBER_OF_PHYSICAL_COUNTS]
  FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]
  INNER JOIN [wms].[OP_WMS_LICENSES] [L]
    ON ([IL].[LICENSE_ID] = [L].[LICENSE_ID])
  INNER JOIN @LOCATION_TABLE [LT]
    ON ([L].[CURRENT_LOCATION] = [LT].[LOCATION])
  INNER JOIN @MATERIAL_TABLE [MT]
    ON ([IL].[MATERIAL_ID] = [MT].[MATERIAL_CODE])
  WHERE [IL].[QTY] > 0
  ORDER BY [IL].[IDLE] DESC
END