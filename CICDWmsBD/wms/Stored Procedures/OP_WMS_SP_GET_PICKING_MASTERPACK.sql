-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	13-Jul-17 @ Nexus TEAM Sprint AgeOfEmpires
-- Description:			SP que obtiene el detalle picking que exploto para enviar al ERP

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_PICKING_MASTERPACK]
					@PICKING_DEMAND_HEADER_ID = 4182
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_PICKING_MASTERPACK](
	@PICKING_DEMAND_HEADER_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		CAST([H].[PICKING_DEMAND_HEADER_ID] AS VARCHAR(50)) AS [Ref2]
		,[wms].[OP_WMS_GET_STRING_FROM_CHAR]([D].[MATERIAL_ID], '/') AS [ItemCode]
		,[D].[QTY_IMPLODED] AS [Quantity]
		,[W].[ERP_WAREHOUSE] AS [WarehouseCode]
		,[D].[PRICE]
	FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [D]
	INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H] ON ([H].[PICKING_DEMAND_HEADER_ID] = [D].[PICKING_DEMAND_HEADER_ID])
	INNER JOIN [wms].[OP_WMS_WAREHOUSES] [W] ON ([W].[WAREHOUSE_ID] = [H].[CODE_WAREHOUSE])
	WHERE [D].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
		AND [D].[WAS_IMPLODED] = 1
		AND [D].[QTY_IMPLODED] > 0
END