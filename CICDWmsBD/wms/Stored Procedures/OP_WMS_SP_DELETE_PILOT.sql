
-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-09 @ Team REBORN - Sprint Drache
-- Description:	        SP que borra un Piloto

-- Modificacion 10/16/2017 @ REBORN - Sprint Drache
					-- hector.gonzales
					-- Se agrega descripcion en el momento de eliminar el piloto y este se encuentre asociado a un vehiculo

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].OP_WMS_SP_DELETE_PILOT @PILOT_CODE = 1
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_DELETE_PILOT (@PILOT_CODE INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY

    DELETE [wms].[OP_WMS_USER_X_PILOT] 
    WHERE [PILOT_CODE] = @PILOT_CODE;

    DELETE [wms].[OP_WMS_PILOT]
    WHERE [PILOT_CODE] = @PILOT_CODE;

    SELECT
      1 AS [Resultado]
     ,'Proceso Exitoso' [Mensaje]
     ,0 [Codigo]
     ,CAST(@PILOT_CODE AS VARCHAR) [DbData];

  END TRY
  BEGIN CATCH
    SELECT
      -1 AS [Resultado]
     ,CASE @@error
        WHEN 547 THEN 'No se puede eliminar el piloto debido a que se encuentra asociado al vehiculo con placas: ' + (SELECT V.[PLATE_NUMBER] FROM [wms].[OP_WMS_VEHICLE] AS V WHERE V.[PILOT_CODE] = @PILOT_CODE AND V.[VEHICLE_CODE] > 0)
        ELSE ERROR_MESSAGE()
      END [Mensaje]
     ,@@error [Codigo];
  END CATCH;


END