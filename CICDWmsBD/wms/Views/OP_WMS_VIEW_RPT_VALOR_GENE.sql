
/*WHERE
	A.QTY > 0*/
CREATE VIEW [wms].[OP_WMS_VIEW_RPT_VALOR_GENE]
AS
SELECT     CLIENT_NAME, CLIENT_OWNER, NUMERO_ORDEN, LICENSE_ID, BARCODE_ID, MATERIAL_NAME, QTY, CURRENT_LOCATION, SUBSTRING(CURRENT_LOCATION, 
                      1, 3) AS BODEGA, ISNULL
                          ((SELECT     VALOR_UNITARIO
                              FROM         [wms].OP_WMS_FUNC_GET_SKU_VALOR_UNITARIO_ALMGEN(A.CODIGO_POLIZA, '%' + A.BARCODE_ID + '%') 
                                                    AS OP_WMS_FUNC_GET_SKU_VALOR_UNITARIO_ALMGEN_2), 1.00) AS VALOR_UNITARIO, ISNULL
                          ((SELECT     VALOR_UNITARIO
                              FROM         [wms].OP_WMS_FUNC_GET_SKU_VALOR_UNITARIO_ALMGEN(A.CODIGO_POLIZA, '%' + A.BARCODE_ID + '%') 
                                                    AS OP_WMS_FUNC_GET_SKU_VALOR_UNITARIO_ALMGEN_1), 1.00) * QTY AS TOTAL_VALOR, VOLUMEN, VOLUMEN * QTY AS TOTAL_VOLUMEN, 
                      TERMS_OF_TRADE
FROM         [wms].OP_WMS_VIEW_RPT_ALMGEN AS A