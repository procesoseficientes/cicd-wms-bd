-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-12 @ Team REBORN - Sprint Drache
-- Description:	        SP que asocia un piloto a un vehiculo

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].OP_WMS_ASSOCIATE_VEHICLE_TO_PILOT   @VEHICLE_CODE = 1, @PILOT_CODE = 1, @LAST_UPDATE_BY = 'RD'

  SELECT * FROM [wms].[OP_WMS_VEHICLE] 
  SELECT * FROM [wms].[OP_WMS_PILOT]

*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_ASSOCIATE_VEHICLE_TO_PILOT (@VEHICLE_CODE INT, @PILOT_CODE INT, @LAST_UPDATE_BY VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --

  BEGIN TRY

    DECLARE @ID INT

    UPDATE [wms].[OP_WMS_VEHICLE]
    SET [PILOT_CODE] = @PILOT_CODE
       ,[LAST_UPDATE_BY] = @LAST_UPDATE_BY
       ,[LAST_UPDATE] = GETDATE()
    WHERE [VEHICLE_CODE] = @VEHICLE_CODE

    SET @ID = SCOPE_IDENTITY()

    SELECT
      1 AS [Resultado]
     ,'Proceso Exitoso' [Mensaje]
     ,0 [Codigo]
     ,CAST(@ID AS VARCHAR) [DbData];

  END TRY
  BEGIN CATCH
    SELECT
      -1 AS [Resultado]
     ,CASE @@error
        WHEN 2627 THEN 'No se puede asignar el mismo piloto a dos vehiculos.'
        WHEN 547 THEN 'El piloto que desea asignar no existe'
        ELSE ERROR_MESSAGE()
      END [Mensaje]
     ,@@error [Codigo];
  END CATCH;

END