
-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-12 @ Team REBORN - Sprint Drache
-- Description:	        SP que borra un Vehiculo

/*
-- Ejemplo de Ejecucion:
  SELECT * FROM [wms].[OP_WMS_VEHICLE] [owv]
			EXEC  [wms].OP_WMS_SP_DELETE_VEHICLE @VEHICLE_CODE = 3
  SELECT * FROM [wms].[OP_WMS_VEHICLE] [owv]
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_DELETE_VEHICLE (@VEHICLE_CODE INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY

    DECLARE @IS_IN_MANIFEST INT;

    SELECT
      @IS_IN_MANIFEST = 1
    FROM [wms].[OP_WMS_MANIFEST_HEADER] [MH]
    INNER JOIN [wms].[OP_WMS_VEHICLE] [V]
      ON [MH].[VEHICLE] = [V].[VEHICLE_CODE]
    WHERE [V].[VEHICLE_CODE] = @VEHICLE_CODE

    IF EXISTS (SELECT
        TOP 1
          1
        FROM [wms].[OP_WMS_MANIFEST_HEADER] [MH]
        INNER JOIN [wms].[OP_WMS_VEHICLE] [V]
          ON [MH].[VEHICLE] = [V].[VEHICLE_CODE]
        WHERE [V].[VEHICLE_CODE] = @VEHICLE_CODE)
    BEGIN
      RAISERROR ('No se puede eliminar un vehiculo que este asignado a un manifiesto', 16, 1)
    END


    DELETE [wms].[OP_WMS_VEHICLE]
    WHERE [VEHICLE_CODE] = @VEHICLE_CODE;

    SELECT
      1 AS [Resultado]
     ,'Proceso Exitoso' [Mensaje]
     ,0 [Codigo]
     ,CAST(@VEHICLE_CODE AS VARCHAR) [DbData];

  END TRY
  BEGIN CATCH
    SELECT
      -1 AS [Resultado]
     ,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '547' THEN 'No se puede eliminar el vehiculo porque ya tiene esta asociado a un manifiesto de carga'
			ELSE ERROR_MESSAGE() 
		END [Mensaje]
     ,@@error [Codigo];
  END CATCH;

END