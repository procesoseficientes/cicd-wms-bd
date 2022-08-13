-- =============================================
-- Autor:					rudi.garcia
-- Fecha de Creacion: 		04-Jun-2019 G-Force@Berlin-Swift3PL
-- Description:			    SP que obtiene los materiales por bodega y zona

/*
-- Ejemplo de Ejecucion:
        EXEC [wms].[OP_WMS_SP_GET_MATERIALS_BY_WAREHOUSE_AND_ZONE]			
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_GET_MATERIALS_BY_WAREHOUSE_AND_ZONE] (@LOGIN VARCHAR(25)
, @WAREHOUSE_XML XML
, @ZONE_XML XML)
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
   ,[MATERIAL_NAME] VARCHAR(150)
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
  -- Obtenemos los materiales filtrados por bodega y zona
  -- -----------------------------------------------------------------
  INSERT INTO @MATERIAL_TABLE ([MATERIAL_CODE], [MATERIAL_NAME])
    SELECT
      [IL].[MATERIAL_ID]
     ,[IL].[MATERIAL_NAME]
    FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]
    INNER JOIN [wms].[OP_WMS_LICENSES] [L]
      ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
    INNER JOIN @LOCATION_TABLE [LT]
      ON ([L].[CURRENT_LOCATION] = [LT].[LOCATION])
    WHERE [IL].[QTY] > 0
    GROUP BY [IL].[MATERIAL_ID]
            ,[IL].[MATERIAL_NAME]

  -- -----------------------------------------------------------------
  -- Retornamos el resultado de la busqueda
  -- -----------------------------------------------------------------
  SELECT
    [MATERIAL_CODE]
   ,[MATERIAL_NAME]
  FROM @MATERIAL_TABLE
END