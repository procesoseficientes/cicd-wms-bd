


-- =============================================
-- Autor:				Gustavo.Garcia
-- Fecha de Creacion: 	10/05/20201

-- =============================================
CREATE VIEW [wms].[ViEW_INVENTORY_ONLINE_GRUPED]
AS
	SELECT * 
	FROM OPENQUERY(ERP_SERVER, 'EXEC  OP_WMS_ALZA.[wms].[OP_WMS_SP_GET_INVENTORY_ONLINE_INVENTORY] @LOGIN = ''ADMIN''')