
CREATE VIEW [wms].[OP_WMS_VIEW_INVENTORY_DETAIL_ALMGEN_HIST]
AS
SELECT     (SELECT     CLIENT_NAME
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
                              WHERE     (CODIGO_POLIZA = B.CODIGO_POLIZA)), '0') AS FECHA_LLEGADA, A.DDMMYYYY, A.LICENSE_ID, A.TERMS_OF_TRADE, C.MATERIAL_ID, 
                      C.BARCODE_ID, A.BARCODE_ID AS ALTERNATE_BARCODE, A.MATERIAL_NAME, A.QTY, B.CLIENT_OWNER, B.REGIMEN, B.CODIGO_POLIZA, 
                      B.CURRENT_LOCATION, ISNULL(C.VOLUME_FACTOR, 0) AS VOLUMEN, ISNULL(C.VOLUME_FACTOR, 0) * A.QTY AS TOTAL_VOLUMEN, B.LAST_UPDATED_BY
FROM         [wms].OP_WMS_INV_X_LICENSE_HIST AS A INNER JOIN
                      [wms].OP_WMS_LICENSES AS B ON A.LICENSE_ID = B.LICENSE_ID INNER JOIN
                      [wms].OP_WMS_MATERIALS AS C ON A.MATERIAL_ID = C.MATERIAL_ID
WHERE     (B.REGIMEN = 'GENERAL')