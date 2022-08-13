-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-12 @ Team REBORN - Sprint Drache
-- Description:	        SP que obteniene los pilotos que no esten asociados a un vehiculo y ya tengan un usuario asociado

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-12-21 @REBORN-Team - Sprint 
-- Description:	   Se modifica INNER JOIN a  LEFT JOIN para que traiga tambien pilotos que no tengan usuarios asignados

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_GET_PILOT_UNASSOCIATED_TO_VEHICLE]
			@PILOT_CODE = 2
			--
			EXEC  [wms].[OP_WMS_GET_PILOT_UNASSOCIATED_TO_VEHICLE]
			@PILOT_CODE = NULL
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_PILOT_UNASSOCIATED_TO_VEHICLE] (@PILOT_CODE INT = NULL)
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
   ,[UXP].[USER_CODE]
  FROM [wms].[OP_WMS_PILOT] [P]
  LEFT JOIN [wms].[OP_WMS_USER_X_PILOT] [UXP]
    ON ([P].[PILOT_CODE] = [UXP].[PILOT_CODE])
  LEFT JOIN [wms].[OP_WMS_VEHICLE] [V]
    ON ([P].[PILOT_CODE] = [V].[PILOT_CODE])
  WHERE ([V].[VEHICLE_CODE] IS NULL
  OR [V].[PILOT_CODE] = @PILOT_CODE)
  AND [P].[PILOT_CODE] > 0
  AND ([V].[VEHICLE_CODE] > 0
  OR [V].[VEHICLE_CODE] IS NULL)
END