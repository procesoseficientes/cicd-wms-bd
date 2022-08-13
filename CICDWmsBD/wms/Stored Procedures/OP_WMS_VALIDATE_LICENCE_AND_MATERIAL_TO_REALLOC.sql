-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-04-04 @ Team ERGON - Sprint ERGON HYPER
-- Description:	 


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-04-19 Team ERGON - Sprint ERGON EPONA
-- Description:	 Validar si la ubicación origen de la licencia actual esta en una ubicación de no re ubicación en dado caso retornar error indicando que no puede re-ubicar en esa ubicación origen.

-- Modificación: hector.gonzalez
-- Fecha de Creacion: 	2017-06-21 Team ERGON - Sprint ERGON BreathOfTheWild
-- Description:	 Se agrego if de LICENCIA SIN UBICACION

-- Modificación:      rudi.garcia
-- Fecha de Creacion: 	2017-09-13 Team Reborn - Sprint@Collin
-- Description:	 Se agrego el tono y calibre

/*
-- Ejemplo de Ejecucion:

  declare @s as varchar(250)
			EXEC [wms].[OP_WMS_VALIDATE_LICENCE_AND_MATERIAL_TO_REALLOC] @SOURCE_LICENCE_ID = 217715
                                                                ,@MATERIAL_ID = 'wms/01272016'
                                                                ,@pResult = @s OUTPUT
  select @s
  SELECT * FROM [wms].OP_WMS_TASK_LIST
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_VALIDATE_LICENCE_AND_MATERIAL_TO_REALLOC (@SOURCE_LICENCE_ID INT
, @MATERIAL_ID VARCHAR(50)
, @pResult VARCHAR(250) OUTPUT)
AS
BEGIN
  SET NOCOUNT ON;
  --

  DECLARE @WAVEPICKING_ID INT = 0
         ,@OPERADOR_TASK VARCHAR(50)
         ,@pCURRENT_LOCATION VARCHAR(50)
         ,@ALLOW_REALLOC INT = 0
         ,@QTY NUMERIC(18, 4)
  SELECT
    @pResult = 'OK'

  --SE OBTIENE LA UBICACION DE LA LICENCIA
  SELECT TOP 1
    @pCURRENT_LOCATION = [CURRENT_LOCATION]
  FROM [wms].[OP_WMS_LICENSES]
  WHERE [LICENSE_ID] = @SOURCE_LICENCE_ID

  IF (@pCURRENT_LOCATION IS NULL)
  BEGIN
    SELECT
      @pResult = 'LICENCIA SIN UBICACION'
    SELECT
      @pResult
    RETURN -1
  END

  SELECT TOP 1
    @ALLOW_REALLOC = [S].[ALLOW_REALLOC]
  FROM [wms].[OP_WMS_SHELF_SPOTS] [S]
  WHERE [S].[LOCATION_SPOT] = @pCURRENT_LOCATION

  IF (@ALLOW_REALLOC = 0)
  BEGIN
    SELECT
      @pResult = 'UBICACION ' + @pCURRENT_LOCATION + ' NO ESTA DISPONIBLE PARA REUBICACION '
    SELECT
      @pResult
    RETURN -1
  END

  IF NOT EXISTS (SELECT
        1
      FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]
      WHERE [IL].[LICENSE_ID] = @SOURCE_LICENCE_ID
      AND [IL].[MATERIAL_ID] = @MATERIAL_ID)
  BEGIN
    SELECT
      @pResult = 'SKU ' + @MATERIAL_ID + ' No existe en licencia origen ' + @SOURCE_LICENCE_ID
    SELECT
      @pResult
    RETURN -1
  END

  SELECT
    @QTY = ([IL].[QTY] - ISNULL([CIL].[COMMITED_QTY], 0))
  FROM [wms].[OP_WMS_INV_X_LICENSE] AS [IL]
  LEFT JOIN [wms].OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE() AS [CIL]
    ON (
    [IL].[LICENSE_ID] = [CIL].[LICENCE_ID]
    AND [IL].[MATERIAL_ID] = [CIL].[MATERIAL_ID]
    )
  WHERE [IL].[MATERIAL_ID] = @MATERIAL_ID
  AND [IL].[LICENSE_ID] = @SOURCE_LICENCE_ID

  IF (@QTY <= 0)
  BEGIN
    SELECT
      @pResult = 'El material no tiene inventario disponible'
    SELECT
      @pResult
    RETURN
  END


  SELECT
    @QTY AS [QTY]
   ,[IL].[BATCH]
   ,[IL].[DATE_EXPIRATION]
   ,[IL].[VIN]
   ,[S].[STATUS_CODE]
   ,[S].[STATUS_NAME]
   ,[TCM].[TONE]
   ,[TCM].[CALIBER]
  FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]
  INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
    ON (
    [M].[MATERIAL_ID] = [IL].[MATERIAL_ID]
    )
  INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [S]
    ON (
    [IL].[STATUS_ID] = [S].[STATUS_ID]
    )
  LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM] ON(
    [IL].[TONE_AND_CALIBER_ID] = [TCM].[TONE_AND_CALIBER_ID]
  )
  WHERE [IL].[LICENSE_ID] = @SOURCE_LICENCE_ID
  AND [IL].[MATERIAL_ID] = @MATERIAL_ID

END