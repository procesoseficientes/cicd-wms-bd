
-- =============================================
-- Autor:	--
-- Fecha de Creación: 	--
-- Description:	 --

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-05-31 ErgonTeam@Sheik
-- Description:	 Se agrega que retorne el material id 

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-09-05 @ Team REBORN - Sprint 
-- Description:	   Se agrega columnas de Estado

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-09-16 @ Team REBORN - Sprint 
-- Description:	   Se agrega tono y calibre


/*
-- Ejemplo de Ejecucion:
	SELECT COUNT(*) FROM 		[wms].[OP_WMS_VIEW_VALORIZACION_FISCAL]
*/
-- =============================================

CREATE VIEW [wms].[OP_WMS_VIEW_VALORIZACION_FISCAL]
AS
SELECT
  CLIENT_NAME
 ,CLIENT_OWNER
 ,NUMERO_ORDEN
 ,LICENSE_ID
 ,BARCODE_ID
 ,MATERIAL_NAME
 ,QTY
 ,CURRENT_LOCATION
 ,SUBSTRING(CURRENT_LOCATION,
  1, 3) AS BODEGA
 ,ISNULL
  ((SELECT
      VALOR_UNITARIO
    FROM [wms].OP_WMS_FUNC_GET_SKU_VALOR_UNITARIO(A.CODIGO_POLIZA, '%' + A.BARCODE_ID + '%')
    AS OP_WMS_FUNC_GET_SKU_VALOR_UNITARIO_2)
  , 1.00) AS VALOR_UNITARIO
 ,ISNULL
  ((SELECT
      VALOR_UNITARIO
    FROM [wms].OP_WMS_FUNC_GET_SKU_VALOR_UNITARIO(A.CODIGO_POLIZA, '%' + A.BARCODE_ID + '%')
    AS OP_WMS_FUNC_GET_SKU_VALOR_UNITARIO_1)
  , 1.00) * QTY AS TOTAL_VALOR
 ,VOLUMEN
 ,VOLUMEN * QTY AS TOTAL_VOLUMEN
 ,TERMS_OF_TRADE
  --Cambio
 ,A.CODIGO_POLIZA
 ,A.BATCH
 ,A.DATE_EXPIRATION
 ,A.VIN
 ,A.[CURRENT_WAREHOUSE]
 ,A.[MATERIAL_ID]
 ,[A].[STATUS_NAME]
 ,[A].[BLOCKS_INVENTORY]
 ,[A].[COLOR]
 ,[A].[TONE]
  ,[A].[CALIBER]
FROM [wms].OP_WMS_VIEW_INVENTORY_DETAIL_FISCAL AS A
WHERE (QTY > 0)