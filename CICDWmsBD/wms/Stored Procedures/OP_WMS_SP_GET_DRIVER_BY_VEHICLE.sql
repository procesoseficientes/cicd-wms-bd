-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-17 @ Team REBORN - Sprint Drache
-- Description:	        SP que trae el piloto asinado al vehiculo que le manden 

/*
-- Ejemplo de Ejecucion:
      SELECT * FROM [wms].OP_WMS_VEHICLE
			EXEC [wms].OP_WMS_SP_GET_DRIVER_BY_VEHICLE @VEHICLE_CODE = 8
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_DRIVER_BY_VEHICLE (@VEHICLE_CODE INT)
AS
BEGIN
  SET NOCOUNT ON;
  --

  SELECT
    [P].[PILOT_CODE]
   ,[P].[NAME]
   ,[P].[LAST_NAME]
   ,[P].[IDENTIFICATION_DOCUMENT_NUMBER]
   ,[P].[LICENSE_NUMBER]
   ,[P].[LICESE_TYPE]
   ,[P].[LICENSE_EXPIRATION_DATE]
   ,[P].[ADDRESS]
   ,[P].[TELEPHONE]
   ,[P].[MAIL]
   ,[P].[COMMENT]
   ,[P].[LAST_UPDATE]
   ,[P].[LAST_UPDATE_BY]
  FROM [wms].[OP_WMS_PILOT] [P]
  INNER JOIN [wms].[OP_WMS_VEHICLE] [V]
    ON [P].[PILOT_CODE] = [V].[PILOT_CODE]
  WHERE [V].[VEHICLE_CODE] = @VEHICLE_CODE

END