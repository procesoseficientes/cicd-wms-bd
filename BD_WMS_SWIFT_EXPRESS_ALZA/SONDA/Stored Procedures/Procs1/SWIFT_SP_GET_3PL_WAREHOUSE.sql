-- ======================================================
-- Autor:				        diego.as
-- Fecha de Creacion: 	10-01-2017 @ A-TEAM Sprint Balder
-- Description:			SP que obtiene las bodegas de 3PL
/*
  Ejemplo de Ejecucion:
  --
    EXEC [SONDA].SWIFT_SP_GET_3PL_WAREHOUSE
      @CODE_WAREHOUSE = 'BOD.503'
*/

-- ======================================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_3PL_WAREHOUSE
(
  @CODE_WAREHOUSE VARCHAR(50) = NULL
  )
  AS
BEGIN
  SELECT 
 W.[CODE_WAREHOUSE]
 ,[oww].[WAREHOUSE_ID]
 ,[oww].[NAME]
 ,[oww].[COMMENTS]
 ,[oww].[ERP_WAREHOUSE]
 ,[oww].[ALLOW_PICKING]
 ,[oww].[DEFAULT_RECEPTION_LOCATION]
 ,[oww].[SHUNT_NAME]
 ,[oww].[WAREHOUSE_WEATHER]
 ,[oww].[WAREHOUSE_STATUS]
 ,[oww].[IS_3PL_WAREHUESE]
 ,[oww].[WAHREHOUSE_ADDRESS]
 ,[oww].[GPS_URL]
 ,[oww].[DISTRIBUTION_CENTER_ID]
 FROM [SONDA].[OP_WMS_WAREHOUSES] [oww]
  LEFT JOIN [SONDA].[SWIFT_WAREHOUSES] [W] ON (
    [oww].[WAREHOUSE_ID] = [W].[CODE_WAREHOUSE_3PL]
  )
  WHERE (W.[CODE_WAREHOUSE] = @CODE_WAREHOUSE OR W.[CODE_WAREHOUSE] IS NULL)
  END
