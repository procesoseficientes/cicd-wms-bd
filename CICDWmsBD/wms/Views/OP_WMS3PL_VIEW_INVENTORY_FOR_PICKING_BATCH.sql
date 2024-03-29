﻿
CREATE VIEW [wms].[OP_WMS3PL_VIEW_INVENTORY_FOR_PICKING_BATCH]
AS
SELECT MAX(LIC.REGIMEN) AS REGIMEN, MAX(LIC.CLIENT_OWNER) AS CLIENT_OWNER
		, MAX(LIC.CODIGO_POLIZA) AS CODIGO_POLIZA
		, MAX(LIC.CURRENT_LOCATION) AS CURRENT_LOCATION
		, MAX(LIC.CURRENT_WAREHOUSE) AS CURRENT_WAREHOUSE
		, LIC.LICENSE_ID
		, INV.BARCODE_ID
		, INV.MATERIAL_ID
		, MAX(INV.MATERIAL_NAME) AS MATERIAL_NAME, MAX(INV.QTY) AS QTY
		, INV.BATCH
		, INV.DATE_EXPIRATION
FROM [wms].OP_WMS_LICENSES AS LIC 
	INNER JOIN [wms].OP_WMS_INV_X_LICENSE AS INV ON INV.LICENSE_ID = LIC.LICENSE_ID
WHERE (LIC.STATUS = 'ALLOCATED')
GROUP BY LIC.LICENSE_ID, INV.BARCODE_ID, INV.MATERIAL_ID, INV.BATCH, INV.DATE_EXPIRATION