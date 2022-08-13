-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 22-08-2016
-- Description:			Sp que obtiene los detalles de poliza dumental disponibles para un egreso fiscal

/*
  -- Ejemplo de Ejecucion:
				-- 
				EXEC [wms].OP_WMS_SP_GET_INVENTORY_BY_DOCS
        
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_INVENTORY_BY_DOCS]
AS
DECLARE @VALOR1 AS NUMERIC(38, 4) = 1;
SELECT DISTINCT
       [T].[VIN],
       [VID].[NUMERO_ORDEN],
       [VID].[WAREHOUSE_REGIMEN],
       [VID].[CODIGO_POLIZA],
       [VID].[NUMERO_DUA],
       [VID].[CLIENT_CODE],
       [VID].[CONSIGNATARIO_CODIGO],
       [VID].[CONSIGNATARIO_NAME],
       CASE
           WHEN [T].[VIN] IS NULL OR T.[VIN] = '' THEN
               [VID].[BULTOS]
           ELSE
               1

       END    AS [BULTOS],
       CASE
           WHEN [T].[VIN] IS NULL OR T.[VIN] = ''  THEN
               [VID].[QTY]
           ELSE
               1

       END  AS  [QTY],
       --[VID].[BULTOS],
       --[VID].[QTY],
       [VID].[CUSTOMS_AMOUNT],
       [VID].[DAI],
       [VID].[IVA],
       [VID].[TOTAL],
       [VID].[SAC_CODE],
       [VID].[SKU_DESCRIPTION],
       [VID].[NET_WEIGTH],
       [VID].[WEIGTH_UNIT],
       [VID].[VOLUME],
       [VID].[VOLUME_UNIT],
       [VID].[QTY_UNIT],
       [VID].[FECHA_DOCUMENTO],
       [VID].[LINE_NUMBER],
       [VID].[DOC_ID],
       [VID].[TAX]
     --  [VID].[MATERIAL_ID]
	 INTO #prueba
FROM [wms].[OP_WMS_VIEW_INVENTORY_X_DOCS] [VID]
    INNER JOIN [wms].[OP_WMS3PL_POLIZA_TRANS_MATCH] [PTM]
        ON (
               [VID].[DOC_ID] = [PTM].[DOC_ID]
               AND [VID].[LINE_NUMBER] = [PTM].[LINENO_POLIZA]
           )
    INNER JOIN [wms].[OP_WMS_TRANS] [T]
        ON (
               [T].[SERIAL_NUMBER] = [PTM].[TRANS_ID]
               AND [PTM].[MATERIAL_CODE] = [T].[MATERIAL_CODE]
           )
WHERE [VID].[QTY] > 0
      AND [VID].[BULTOS] > 0;


	SELECT [VIN],
           [NUMERO_ORDEN],
           [WAREHOUSE_REGIMEN],
           [CODIGO_POLIZA],
           [NUMERO_DUA],
           [CLIENT_CODE],
           [CONSIGNATARIO_CODIGO],
           [CONSIGNATARIO_NAME],
           [BULTOS],
           [QTY],
           [CUSTOMS_AMOUNT],
           [DAI],
           [IVA],
           [TOTAL],
           [SAC_CODE],
           [SKU_DESCRIPTION],
           [NET_WEIGTH],
           [WEIGTH_UNIT],
           [VOLUME],
           [VOLUME_UNIT],
           [QTY_UNIT],
           [FECHA_DOCUMENTO],
           [LINE_NUMBER],
           [DOC_ID],
           [TAX] FROM [#prueba]