-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	13-Jul-17 @ Nexus TEAM Sprint AgeOfEmpires
-- Description:			SP que obtiene los componentes del detalle de picking que exploto para enviar al ERP

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_PICKING_MASTERPACK_DETAIL]
					@PICKING_DEMAND_HEADER_ID = 4190
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_PICKING_MASTERPACK_DETAIL](
	@PICKING_DEMAND_HEADER_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		CAST([H].[PICKING_DEMAND_HEADER_ID] AS VARCHAR(50)) AS [Ref2]
		,[wms].[OP_WMS_GET_STRING_FROM_CHAR]([C].[COMPONENT_MATERIAL], '/') AS [ItemCode]
		,([D].[QTY_IMPLODED] * [C].[QTY]) AS [Quantity]
		,[W].[ERP_WAREHOUSE] AS [WarehouseCode]
		,[D].[PRICE]
	FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [D]
	INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H] ON ([H].[PICKING_DEMAND_HEADER_ID] = [D].[PICKING_DEMAND_HEADER_ID])
	INNER JOIN [wms].[OP_WMS_WAREHOUSES] [W] ON ([W].[WAREHOUSE_ID] = [H].[CODE_WAREHOUSE])
	INNER JOIN [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [C] ON ([C].[MASTER_PACK_CODE] = [D].[MATERIAL_ID])
	WHERE [D].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
		AND [D].[WAS_IMPLODED] = 1
		AND [D].[QTY_IMPLODED] > 0
END