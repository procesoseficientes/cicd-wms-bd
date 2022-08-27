-- =============================================
-- Autor:				        ----
-- Fecha de Creacion: 	----
-- Description:			    ----

-- Modificacion:        hector.gonzalez
-- Fecha de Creacion: 	27-03-2017 Team Ergon SPRINT Hyper
-- Description:			    Se agrego Warehouse

-- Modificacion 18-Jul-17 @ Nexus Team Sprint AgeOfEmpires
					-- alberto.ruiz
					-- Se agregaron los ajuste de Rudi en wms

/*
-- Ejemplo de Ejecucion:
			SELECT * FROM [wms].OP_WMS_VIEW_INVENTORY_DETAIL_ALMGEN
*/
-- =============================================
CREATE VIEW [wms].OP_WMS_VIEW_INVENTORY_DETAIL_ALMGEN
AS
/*SELECT     (SELECT     CLIENT_NAME
                       FROM          [wms].OP_WMS_VIEW_CLIENTS
                       WHERE      (CLIENT_CODE = B.CLIENT_OWNER COLLATE DATABASE_DEFAULT)) AS CLIENT_NAME, ISNULL
                          ((SELECT     TOP (1) NUMERO_ORDEN
                              FROM         [wms].OP_WMS_POLIZA_HEADER AS C
                              WHERE     (CODIGO_POLIZA = B.CODIGO_POLIZA)), '0') AS NUMERO_ORDEN, ISNULL
                          ((SELECT     TOP (1) NUMERO_DUA
                              FROM         [wms].OP_WMS_POLIZA_HEADER AS C
                              WHERE     (CODIGO_POLIZA = B.CODIGO_POLIZA)), '0') AS NUMERO_DUA, ISNULL
                          ((SELECT     TOP (1) CONVERT(varchar(20), FECHA_LLEGADA) AS Expr1
                              FROM         [wms].OP_WMS_POLIZA_HEADER AS C
                              WHERE     (CODIGO_POLIZA = B.CODIGO_POLIZA)), '0') AS FECHA_LLEGADA,
							  A.DATE_EXPIRATION,
							  A.BATCH,
							  A.VIN,  
							  A.LICENSE_ID, A.TERMS_OF_TRADE, C.MATERIAL_ID, C.BARCODE_ID, 
                      A.BARCODE_ID AS ALTERNATE_BARCODE, A.MATERIAL_NAME, A.QTY, C.MATERIAL_CLASS, B.CLIENT_OWNER, B.REGIMEN, B.CODIGO_POLIZA, 
                      B.CURRENT_LOCATION,
                          (SELECT     TOP (1) DOC_ID
                            FROM          [wms].OP_WMS_POLIZA_HEADER AS Z
                            WHERE      (CODIGO_POLIZA = B.CODIGO_POLIZA) AND (WAREHOUSE_REGIMEN = 'GENERAL')) AS DOC_ID, ISNULL(C.VOLUME_FACTOR, 0) AS VOLUMEN, 
                      ISNULL(C.VOLUME_FACTOR, 0) * A.QTY AS TOTAL_VOLUMEN, B.LAST_UPDATED_BY, [B].[CURRENT_WAREHOUSE]
FROM         [wms].OP_WMS_INV_X_LICENSE AS A INNER JOINñ
                      [wms].OP_WMS_LICENSES AS B ON A.LICENSE_ID = B.LICENSE_ID INNER JOIN
                      [wms].OP_WMS_MATERIALS AS C ON A.MATERIAL_ID = C.MATERIAL_ID
WHERE     (B.REGIMEN = 'GENERAL')*/
	SELECT
		[C].[CLIENT_NAME]
		,[PH].[NUMERO_ORDEN]
		,[PH].[NUMERO_DUA]
		,[PH].[FECHA_LLEGADA]
		,[I].[DATE_EXPIRATION]
		,[I].[BATCH]
		,[I].[VIN]
		,[I].[LICENSE_ID]
		,[I].[TERMS_OF_TRADE]
		,[M].[MATERIAL_ID]
		,[M].[BARCODE_ID]
		,[I].[BARCODE_ID] AS [ALTERNATE_BARCODE]
		,[I].[MATERIAL_NAME]
		,[I].[QTY]
		,[M].[MATERIAL_CLASS]
		,[L].[CLIENT_OWNER]
		,[L].[REGIMEN]
		,[L].[CODIGO_POLIZA]
		,[L].[CURRENT_LOCATION]
		,[PH].[DOC_ID]
		,ISNULL([M].[VOLUME_FACTOR], 0) AS [VOLUMEN]
		,ISNULL([M].[VOLUME_FACTOR], 0) * [I].[QTY] AS [TOTAL_VOLUMEN]
		,[L].[LAST_UPDATED_BY]
		,[L].[CURRENT_WAREHOUSE]
	FROM [wms].[OP_WMS_INV_X_LICENSE] AS [I]
	INNER JOIN [wms].[OP_WMS_LICENSES] AS [L] ON ([I].[LICENSE_ID] = [L].[LICENSE_ID])
	INNER JOIN [wms].[OP_WMS_MATERIALS] AS [M] WITH(INDEX (wms.IN_OP_WMS_MATERIALS_MATERIAL_ID)) ON ([I].[MATERIAL_ID] = [M].[MATERIAL_ID])
	INNER JOIN [wms].[OP_WMS_VIEW_CLIENTS] [C] ON ([C].[CLIENT_CODE] = [L].[CLIENT_OWNER])
	INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH] ON ([L].[CODIGO_POLIZA] = [PH].[CODIGO_POLIZA])
	WHERE [L].[REGIMEN] = 'GENERAL';
