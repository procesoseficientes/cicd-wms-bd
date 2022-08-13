-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-04-19 @ Team ERGON - Sprint EPONA
-- Description:	 Validar que si el existe un material masterpack o componente en la licencia no pueda contener el mismo tipo de producto por ejemplo unidades de producto A y cajas de producto A 

/*
-- Ejemplo de Ejecucion:
  SELECT * FROM [wms].[OP_WMS_INV_X_LICENSE] [OWIXL] WHERE [OWIXL].LICENSE_ID = 22717
   DECLARE @RES INT
   EXEC  [wms].OP_WMS_SP_VALIDATE_MASTER_PACK_MATERIAL_IS_IN_LICENCE @LICENCE_ID = 22717, @MATERIAL_ID = 'C00030/LECHAUST' , @RESULT = @RES OUTPUT
   SELECT @RES  
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_MASTER_PACK_MATERIAL_IS_IN_LICENCE] (@LICENCE_ID NUMERIC, @MATERIAL_ID VARCHAR(50), @RESULT INT OUTPUT)
AS
BEGIN
  ---------------------------------------------------------------------------------
  -- VALIDAR PADRES
  ---------------------------------------------------------------------------------  
  SELECT
    [C].[MASTER_PACK_CODE] PARENT INTO #PADRES
  FROM [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [C]
  WHERE [C].[COMPONENT_MATERIAL] = @MATERIAL_ID
  DECLARE @COUNT_PADRES INT
  SELECT
    @COUNT_PADRES = COUNT(*)
  FROM #PADRES

  WHILE @COUNT_PADRES <> (SELECT
        @COUNT_PADRES + COUNT(*)
      FROM [#PADRES] [P]
      INNER JOIN [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [C]
        ON [C].[COMPONENT_MATERIAL] = P.[parent]
      WHERE NOT EXISTS (SELECT TOP 1
          1
        FROM [#PADRES] [P1]
        WHERE [P1].[parent] = [C].[MASTER_PACK_CODE]))
  BEGIN
    INSERT INTO [#PADRES]
      SELECT
        [MASTER_PACK_CODE]
      FROM [#PADRES] [P]
      INNER JOIN [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [C]
        ON [C].[COMPONENT_MATERIAL] = P.[parent]
      WHERE NOT EXISTS (SELECT TOP 1
          1
        FROM [#PADRES] [P1]
        WHERE [P1].[parent] = [C].[MASTER_PACK_CODE])

    SELECT
      @COUNT_PADRES = COUNT(*)
    FROM #PADRES
  END

  IF EXISTS (SELECT TOP 1
        1
      FROM [#PADRES] [P]
      INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL]
        ON [IL].[LICENSE_ID] = @LICENCE_ID
        AND [IL].[MATERIAL_ID] = P.[parent])
  BEGIN
    SELECT
      @RESULT = 0
    RETURN
  END

  SELECT
    [C].[COMPONENT_MATERIAL] CHILD INTO #HIJOS
  FROM [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [C]
  WHERE [C].[MASTER_PACK_CODE] = @MATERIAL_ID
  DECLARE @COUNT_HIJOS INT
  SELECT
    @COUNT_HIJOS = COUNT(*)
  FROM #HIJOS

  WHILE @COUNT_HIJOS <> (SELECT
        @COUNT_HIJOS + COUNT(*)
      FROM [#HIJOS] [H]
      INNER JOIN [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [C]
        ON [C].[MASTER_PACK_CODE] = [H].[CHILD]
      WHERE NOT EXISTS (SELECT TOP 1
          1
        FROM [#HIJOS] [H1]
        WHERE [H1].[CHILD] = [C].[COMPONENT_MATERIAL]))
  BEGIN
    INSERT INTO [#HIJOS]
      SELECT
        [C].[COMPONENT_MATERIAL]
      FROM [#HIJOS] [H]
      INNER JOIN [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [C]
        ON [C].[MASTER_PACK_CODE] = [H].[CHILD]
      WHERE NOT EXISTS (SELECT TOP 1
          1
        FROM [#HIJOS] [H1]
        WHERE [H1].[CHILD] = [C].[COMPONENT_MATERIAL])

    SELECT
      @COUNT_HIJOS = COUNT(*)
    FROM [#HIJOS] [H]
  END

  IF EXISTS (SELECT TOP 1
        1
      FROM [#HIJOS] H
      INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL]
        ON [IL].[LICENSE_ID] = @LICENCE_ID
        AND [IL].[MATERIAL_ID] = H.[CHILD])
  BEGIN
    SELECT
      @RESULT = 0
    RETURN
  END

  SELECT
    @RESULT = 1
  RETURN
END