
-- =============================================
-- Author: <@ProcesosEficientes, Gildardo.Alvarado>
-- Create date: <19/02/2021>
-- Description: Obtiene todas las bodegas asociadas a un usuario
-- =============================================

/*
SELECT * FROM [wms].[OP_WMS_FUNC_GET_WAREHOUSE_BY_USER]('ADMIN')
*/
CREATE FUNCTION [wms].[OP_WMS_FUNC_GET_WAREHOUSE_BY_USER]
(
@pLOGIN_ID VARCHAR(50)
)
RETURNS TABLE
AS
RETURN
(
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
WHERE [WB].[LOGIN_ID] = @pLOGIN_ID
)
