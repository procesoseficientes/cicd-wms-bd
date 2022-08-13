-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-12 @ Team REBORN - Sprint Drache
-- Description:	        SP que desasocia un piloto de un vehiculo

/*
-- Ejemplo de Ejecucion:
  
  SELECT * FROM [wms].[OP_WMS_VEHICLE]   
			EXEC  [wms].OP_WMS_DISSASOCIATE_VEHICLE_FROM_PILOT @VEHICLE_COE = 7 ,@LAST_UPDATE_BY= 'ADMIN'
  SELECT * FROM [wms].[OP_WMS_VEHICLE] 
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_DISSASOCIATE_VEHICLE_FROM_PILOT (@VEHICLE_CODE INT, @LAST_UPDATE_BY VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY

    UPDATE [wms].[OP_WMS_VEHICLE]
    SET [PILOT_CODE] = NULL
       ,[LAST_UPDATE_BY] = @LAST_UPDATE_BY
       ,[LAST_UPDATE] = GETDATE()
    WHERE [VEHICLE_CODE] = @VEHICLE_CODE

    SELECT
      1 AS [Resultado]
     ,'Proceso Exitoso' [Mensaje]
     ,0 [Codigo]
     ,'0' [DbData];

  END TRY
  BEGIN CATCH
    SELECT
      -1 AS [Resultado]
     ,ERROR_MESSAGE() [Mensaje]
     ,@@error [Codigo];
  END CATCH;

END