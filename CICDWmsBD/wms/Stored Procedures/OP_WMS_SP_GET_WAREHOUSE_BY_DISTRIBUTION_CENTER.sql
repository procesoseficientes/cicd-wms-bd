-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-01-30 @ Team ERGON - Sprint ERGON II
-- Description:	 Obtiene todas las bodegas asociadas a un centro de distribución que no esten ya asociadas a un usuario




/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_WAREHOUSE_BY_DISTRIBUTION_CENTER] @DISTRIBUTION_CENTER = '0001', @LOGIN_ID = 'ACAMACHO'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_WAREHOUSE_BY_DISTRIBUTION_CENTER] (@DISTRIBUTION_CENTER VARCHAR(50), @LOGIN_ID VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [W].[WAREHOUSE_ID]
   ,[W].[NAME]
   ,[W].[COMMENTS]
   ,[W].[ERP_WAREHOUSE]
   ,[W].[ALLOW_PICKING]
   ,[W].[DEFAULT_RECEPTION_LOCATION]
   ,[W].[SHUNT_NAME]
   ,[W].[WAREHOUSE_WEATHER]
   ,[W].[WAREHOUSE_STATUS]
   ,[W].[IS_3PL_WAREHUESE]
   ,[W].[WAHREHOUSE_ADDRESS]
   ,[W].[GPS_URL]
   ,[W].[DISTRIBUTION_CENTER_ID]
   , 0 [IS_SELECT]
 FROM [wms].[OP_WMS_WAREHOUSES] [W]
    LEFT JOIN [wms].[OP_WMS_WAREHOUSE_BY_USER] [WU] ON [W].[WAREHOUSE_ID] = [WU].[WAREHOUSE_ID] AND [WU].[LOGIN_ID] = @LOGIN_ID
  WHERE [W].[DISTRIBUTION_CENTER_ID] = @DISTRIBUTION_CENTER AND   [WU].[WAREHOUSE_BY_USER_ID] IS NULL 
    
END