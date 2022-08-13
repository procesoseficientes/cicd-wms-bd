-- =============================================
-- Autor:	--
-- Fecha de Creación: 	--
-- Description:	 --

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-05-31 ErgonTeam@SHEIK
-- Description:	 se aagregar material_id al resultado. 


-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-06-28 Nexus@AgeOfEmpires
-- Description:	Se agrega que valide primero por material id si no encuentra valor si busca el valor por descripción de material




/*
-- Ejemplo de Ejecucion:
			select * from [wms].OP_WMS_VIEW_VALORIZACION_ALMGEN
*/
-- =============================================
CREATE VIEW [wms].OP_WMS_VIEW_VALORIZACION_ALMGEN
AS
(SELECT
    CLIENT_NAME
   ,CLIENT_OWNER
   ,A.NUMERO_ORDEN
   ,LICENSE_ID
   ,BARCODE_ID
   ,MATERIAL_NAME
   ,A.QTY
   ,CURRENT_LOCATION
   ,SUBSTRING(CURRENT_LOCATION,
    1, 3) AS BODEGA
   ,COALESCE(D.UNITARY_PRICE, (SELECT
        VALOR_UNITARIO
      FROM [wms].OP_WMS_FUNC_GET_SKU_VALOR_UNITARIO_ALMGEN(A.DOC_ID, '%' + A.BARCODE_ID + '%')
      AS OP_WMS_FUNC_GET_SKU_VALOR_UNITARIO_ALMGEN_2)
    , 1.00) AS VALOR_UNITARIO
   ,COALESCE(D.UNITARY_PRICE, (SELECT
        VALOR_UNITARIO
      FROM [wms].OP_WMS_FUNC_GET_SKU_VALOR_UNITARIO_ALMGEN(A.DOC_ID, '%' + A.BARCODE_ID + '%')
      AS OP_WMS_FUNC_GET_SKU_VALOR_UNITARIO_ALMGEN_2)
    , 1.00) * A.QTY AS TOTAL_VALOR
   ,VOLUMEN
   ,VOLUMEN * A.QTY AS TOTAL_VOLUMEN
   ,TERMS_OF_TRADE
   ,A.CODIGO_POLIZA
   ,A.BATCH
   ,A.DATE_EXPIRATION
   ,A.VIN
   ,A.[CURRENT_WAREHOUSE]
   ,A.[MATERIAL_ID]
  FROM [wms].OP_WMS_VIEW_INVENTORY_DETAIL_ALMGEN AS A
  LEFT JOIN [wms].OP_WMS_POLIZA_HEADER H
    ON H.CODIGO_POLIZA = A.CODIGO_POLIZA
  LEFT JOIN [wms].OP_WMS_POLIZA_DETAIL D
    ON D.DOC_ID = H.DOC_ID
    AND A.MATERIAL_ID = D.MATERIAL_ID)