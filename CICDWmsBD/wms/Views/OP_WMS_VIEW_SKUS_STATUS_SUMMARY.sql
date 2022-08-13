
CREATE VIEW [wms].[OP_WMS_VIEW_SKUS_STATUS_SUMMARY]
AS
SELECT     COUNT(1) AS SIN_BC,
                          (SELECT     COUNT(1) AS Expr1
                            FROM          [wms].OP_WMS_MATERIALS
                            WHERE      (MATERIAL_NAME IS NULL) OR
                                                   (MATERIAL_NAME = '') AND (CLIENT_OWNER <> '1')) AS SIN_DESC,
                          (SELECT     COUNT(1) AS Expr1
                            FROM          [wms].OP_WMS_MATERIALS AS OP_WMS_MATERIALS_3
                            WHERE      (ALTERNATE_BARCODE IS NULL) OR
                                                   (ALTERNATE_BARCODE = '') AND (CLIENT_OWNER <> '1')) AS SIN_ALT,
                          (SELECT     COUNT(1) AS Expr1
                            FROM          [wms].OP_WMS_MATERIALS AS OP_WMS_MATERIALS_2
                            WHERE      (ALTERNATE_BARCODE IS NOT NULL OR
                                                   ALTERNATE_BARCODE <> '') AND (BARCODE_ID IS NOT NULL OR
                                                   BARCODE_ID <> '') AND (MATERIAL_NAME IS NOT NULL OR
                                                   MATERIAL_NAME <> '') AND (CLIENT_OWNER <> '1')) AS ALLSET
FROM         [wms].OP_WMS_MATERIALS AS OP_WMS_MATERIALS_1
WHERE     (BARCODE_ID IS NULL) OR
                      (BARCODE_ID = '') AND (CLIENT_OWNER <> '1')