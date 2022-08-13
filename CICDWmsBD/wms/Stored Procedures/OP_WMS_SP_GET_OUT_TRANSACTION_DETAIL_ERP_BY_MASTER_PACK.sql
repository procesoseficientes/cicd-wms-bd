-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-01-27 @ Team ERGON - Sprint ERGON II
-- Description:	        Sp que obtiene el detalle de la transaccion de salida de lo valores de la tabla OP_WMS_MASTER_PACK_HEADER  consultando por MASTER_PACK_HEADER_ID

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-13 Team ERGON - Sprint ERGON V
-- Description:	 Se agrega la cantidad de masterpack de salida 

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_GET_OUT_TRANSACTION_DETAIL_ERP_BY_MASTER_PACK] @MASTER_PACK_HEADER_ID = 15
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_OUT_TRANSACTION_DETAIL_ERP_BY_MASTER_PACK](
    @MASTER_PACK_HEADER_ID INT
)
AS
BEGIN
    SET NOCOUNT ON;
	--
	SELECT  CAST([MPH].[MASTER_PACK_HEADER_ID] AS VARCHAR) AS Ref2 ,
			[wms].[OP_WMS_GET_STRING_FROM_CHAR]([M].[MATERIAL_ID], '/') AS ItemCode ,
			[MPH].[QTY] AS Quantity ,
			[W].[ERP_WAREHOUSE] AS WarehouseCode ,
			[M].[ERP_AVERAGE_PRICE] [Price]
	FROM    [wms].[OP_WMS_MASTER_PACK_HEADER] [MPH]
			INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON [MPH].[LICENSE_ID] = [L].[LICENSE_ID]
			INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [MPH].[MATERIAL_ID] = [M].[MATERIAL_ID]
			INNER JOIN [wms].[OP_WMS_WAREHOUSES] [W] ON [W].[WAREHOUSE_ID] = [L].[CURRENT_WAREHOUSE]
	WHERE   [MPH].[MASTER_PACK_HEADER_ID] = @MASTER_PACK_HEADER_ID;
	
END;