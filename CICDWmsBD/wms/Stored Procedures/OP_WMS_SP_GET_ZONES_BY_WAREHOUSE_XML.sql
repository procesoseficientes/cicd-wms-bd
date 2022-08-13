-- =============================================
-- Autor:					rudi.garcia
-- Fecha de Creacion: 		03-Jun-2019 G-Force@Berlin-Swift3PL
-- Description:			    SP que obtiene las zones de las bodegas enviadas

/*
-- Ejemplo de Ejecucion:
        EXEC [wms].[OP_WMS_SP_GET_ZONES_BY_WAREHOUSE]
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_GET_ZONES_BY_WAREHOUSE_XML] (@LOGIN VARCHAR(25)
, @WAREHOUSE_XML XML)
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

  -- -----------------------------------------------------------------
  -- Obtemos las bodegas enviadas
  -- -----------------------------------------------------------------

  INSERT INTO @WAREHOUSE_TABLE ([CODE_WAREHOUSE])
    SELECT
      [x].[Rec].[query]('./WAREHOUSE_ID').[value]('.', 'VARCHAR(25)')
    FROM @WAREHOUSE_XML.[nodes]('/ArrayOfBodega/Bodega')
    AS [x] ([Rec]);

  -- -----------------------------------------------------------------
  -- Obtenemos las zones de por la bodegas enviadas
  -- -----------------------------------------------------------------
  INSERT INTO @ZONE_TABLE ([ZONE])
    SELECT
      [SS].[ZONE]
    FROM [wms].[OP_WMS_SHELF_SPOTS] [SS]
    INNER JOIN @WAREHOUSE_TABLE [WT]
      ON ([SS].[WAREHOUSE_PARENT] = [WT].[CODE_WAREHOUSE])
    GROUP BY [SS].[ZONE]

-- -----------------------------------------------------------------
  -- Retornamos el resultado de la busqueda
  -- -----------------------------------------------------------------
  SELECT
    [ZT].[ZONE]
  FROM @ZONE_TABLE [ZT]
END