




/*
--	12/28/2020		Gildardo Alvarado
					Se intercambiaron nombres de las columnas [DispWMS] y [Total Wms]

					SELECT * FROM [wms].[OP_WMS_VIEW_AVAILABLE_VS_ERP_CONSOLIDATE]
*/ 

-- =============================================
create VIEW [wms].[OP_WMS_VIEW_AVAILABLE_VS_ERP_CONSOLIDATE]
AS
SELECT 
    ISNULL([A].[CURRENT_WAREHOUSE], '') AS [Bodega]
	,ISNULL([A].[MATERIAL_ID], '') AS [Codigo]
	,[A].[MATERIAL_NAME] AS [Nombre]
	,ISNULL([A].[AVAILABLE], 0)
	 AS [DispWMS]
	,ISNULL([A].[INVENTORY_IN_RECEPTION], 0) [Pendiente por recepcionar]
	--,ISNULL([A].[PICKED_PENDING_ERP], 0) [Inventario Preparado] hace referencia al inventario en licencias de despacho que no se han envaido a sae
	--,ISNULL([A].[PICKED_PENDING_ERP_WT], 0) [Inventario Preparado WT]
	,[A].[EN_TRANSITO] AS [Inventario En Transito]
	--,ISNULL([A].[AVAILABLE], 0)  as AVAILABLE
	--,ISNULL([A].[INVENTORY_IN_RECEPTION], 0) as RECEPTION
	--,ISNULL([A].[PICKED_PENDING_ERP], 0) AS PENDING_ERP
	--,ISNULL([A].[PICKED_PENDING_ERP_WT], 0) 
	--  AS [Total Wms]

FROM
	[wms].[OP_WMS_VIEW_GET_CONSOLIDATE_WMS_INVENTORY_STATUS_BY_WH] [A]
--full outer JOIN [SWIFT_INTERFACES_ONLINE].[wms].[ERP_VIEW_INVENTORY_ONLINE_WS_01] [X] ON (
--											[X].[CODE_WAREHOUSE] = [A].[ERP_WAREHOUSE]
--											AND [X].[CODE_SKU] = [wms].[OP_WMS_FN_SPLIT_COLUMNS]([A].[MATERIAL_ID],
--											2, '/')
--											)
--LEFT JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([X].[CODE_SKU] =  [M].[ITEM_CODE_ERP])
	
