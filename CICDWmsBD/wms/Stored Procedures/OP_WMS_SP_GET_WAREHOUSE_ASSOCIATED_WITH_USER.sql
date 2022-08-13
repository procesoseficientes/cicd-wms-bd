-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-01-30 @ Team ERGON - Sprint ERGON II
-- Description:	 Obtiene todas las bodegas asociadas a un usuario




/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_WAREHOUSE_ASSOCIATED_WITH_USER] @LOGIN_ID = 'ACAMACHO'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_WAREHOUSE_ASSOCIATED_WITH_USER] (@LOGIN_ID VARCHAR(50))
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
   ,[WB].[WAREHOUSE_BY_USER_ID]
  FROM [wms].[OP_WMS_WAREHOUSES] [W]
  INNER JOIN [wms].[OP_WMS_WAREHOUSE_BY_USER] [WB]
    ON [W].[WAREHOUSE_ID] = [WB].[WAREHOUSE_ID]
  WHERE [WB].[LOGIN_ID] = @LOGIN_ID
END