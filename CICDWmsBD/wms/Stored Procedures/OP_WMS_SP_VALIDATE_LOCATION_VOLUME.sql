-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	31-Jan-2018 @ Reborn-Team Sprint Trotzdem
-- Description:			Sp que valida el volumen de la ubicacion y licencia para el ingreso

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_VALIDATE_LOCATION_VOLUME] @LOCATION= 'BSA-01', @LICENSE_ID = 123
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_LOCATION_VOLUME] (@LOCATION VARCHAR(25)
, @LICENSE_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY
    DECLARE @VOLUME_TOTAL NUMERIC(18, 4) = 0;
    DECLARE @IS_RACK INT = 0;


    SELECT
      @IS_RACK = 1
    FROM [wms].[OP_WMS_SHELF_SPOTS] [ss]
    WHERE [ss].[SPOT_TYPE] = 'RACK'
    AND [ss].[LOCATION_SPOT] = @LOCATION

    IF @IS_RACK = 1
    BEGIN
      SELECT TOP 1
        @VOLUME_TOTAL = [SS].[VOLUME]
      FROM [wms].[OP_WMS_SHELF_SPOTS] [SS]
      WHERE [SS].[LOCATION_SPOT] = @LOCATION


      IF @VOLUME_TOTAL < ([wms].[OP_WMS_FN_GET_VOLUMEN_FROM_LICENCE](@LICENSE_ID) + [wms].[OP_WMS_FN_GET_VOLUMEN_FROM_LOCATION](@LOCATION))
      BEGIN
        SELECT
          2 AS Resultado
         ,'El volumen de la licencia sobrepasa lo de la ubicación. ¿Desea continuar?' Mensaje
         ,0 Codigo;
        RETURN
      END
    END

    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo;
  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,CASE CAST(@@error AS VARCHAR)
        WHEN '2627' THEN ''
        ELSE ERROR_MESSAGE()
      END Mensaje
     ,@@error Codigo;
  END CATCH;
END;