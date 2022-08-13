-- =============================================
-- Autor:	rudi.garcia
-- Fecha de Creacion: 	26-Nov-2017 @ Team Reborn - Sprint Nach
-- Description:	 Sp que obtiene el encabezado del pase de salida

/*
-- Ejemplo de Ejecucion:
EXEC [wms].[OP_WMS_SP_GET_PASS] @PASS_HEADER_ID = 12, @LOGIN_ID = 'RUDI', @DISTRIBUTION_CENTER_ID = 'MAJADAS'
EXEC [wms].[OP_WMS_SP_GET_PASS] @PASS_HEADER_ID = 12, @LOGIN_ID = 'RUDI', @DISTRIBUTION_CENTER_ID = 'MAJADAS'
                                     

			
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_GET_PASS] (@PASS_HEADER_ID INT, @LOGIN_ID VARCHAR(25), @DISTRIBUTION_CENTER_ID VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --

  DECLARE @LOGINS TABLE (
    [LOGIN_ID] VARCHAR(25)
 
  );

  INSERT INTO @LOGINS([LOGIN_ID])
  SELECT DISTINCT
    [WU].[LOGIN_ID]
  FROM [wms].[OP_WMS_WAREHOUSES] [W]
  INNER JOIN [wms].[OP_WMS_WAREHOUSE_BY_USER] [WU] ON(
    [W].[WAREHOUSE_ID] = [WU].[WAREHOUSE_ID]
  )  
  WHERE [W].[DISTRIBUTION_CENTER_ID] = @DISTRIBUTION_CENTER_ID
 
  SELECT DISTINCT
    [P].[CLIENT_CODE]
   ,[P].[CLIENT_NAME]
   ,[P].[PASS_ID]
   ,[P].[LAST_UPDATED_BY]
   ,[P].[LAST_UPDATED]
   ,[P].[ISEMPTY]
   ,[P].[VEHICLE_PLATE]
   ,[P].[VEHICLE_DRIVER]
   ,[P].[VEHICLE_ID]
   ,[P].[DRIVER_ID]
   ,[P].[AUTORIZED_BY]
   ,[P].[HANDLER]
   ,[P].[CARRIER]
   ,[P].[TXT]
   ,[P].[LOADUNLOAD]
   ,[P].[LOADWITH]
   ,[P].[AUDIT_ID]
   ,[P].[CREATED_DATE]
   ,[P].[CREATED_BY]
   ,[P].[STATUS]
   ,[P].[TYPE]
   ,[P].[LICENSE_NUMBER]
  FROM [wms].[OP_WMS3PL_PASSES] [P]
  INNER JOIN @LOGINS [L] ON(
    ([L].[LOGIN_ID] = [P].[CREATED_BY] OR [L].[LOGIN_ID] =[P].[LAST_UPDATED_BY])
  ) 
  
  WHERE [P].[PASS_ID] = @PASS_HEADER_ID


END