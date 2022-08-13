-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-09-04 @ Team REBORN - Sprint 
-- Description:	        Valida si todos los materiales de la licencia tienen el mismo estado

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_VALIDATE_STATUS_IN_MATERIALS_LICENSE] @LICENSE = 32166
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_STATUS_IN_MATERIALS_LICENSE] (@LICENSE NUMERIC)
AS
BEGIN
  SET NOCOUNT ON;
  --

  DECLARE @STATUS VARCHAR(50) = ''
         ,@LOCATION VARCHAR(25)

  SELECT
  TOP 1
    @STATUS = [S].[STATUS_NAME]
   ,@LOCATION = [S].[TARGET_LOCATION]
  FROM [wms].[OP_WMS_INV_X_LICENSE] [IXL]
  INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [S]
    ON [IXL].[STATUS_ID] = [S].[STATUS_ID]
  WHERE [IXL].[LICENSE_ID] = @LICENSE

  -- ----------------------------------------------------------------------------------
  -- Se valida si la ubicacon existe
  -- ----------------------------------------------------------------------------------

  IF NOT EXISTS (SELECT
        1
      FROM [wms].[OP_WMS_SHELF_SPOTS] [S]
      WHERE [S].[LOCATION_SPOT] = @LOCATION)
    AND @LOCATION <> ''
  BEGIN
    SELECT
      -1 AS [Resultado]
     ,'Ubicacion configurada en Estado: ' + @STATUS + ', no existe' [Mensaje]
     ,0 [Codigo]
     ,'' [DbData];
    RETURN;
  END


  IF EXISTS (SELECT
      TOP 1
        [S].[STATUS_NAME]
      FROM [wms].[OP_WMS_INV_X_LICENSE] [IXL]
      INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [S]
        ON [IXL].[STATUS_ID] = [S].[STATUS_ID]
      WHERE [IXL].[LICENSE_ID] = @LICENSE
      AND [S].[STATUS_NAME] <> @STATUS)
  BEGIN
    SELECT
      -1 AS [Resultado]
     ,'Uno o varios materiales tienen estado diferente' [Mensaje]
     ,0 [Codigo]
     ,'' [DbData];
    RETURN;

  END

  SELECT
    1 AS [Resultado]
   ,'Proceso Exitoso' [Mensaje]
   ,0 [Codigo]
   ,@LOCATION [DbData];


END