-- =============================================
-- Autor:	              rudi.garcia
-- Fecha de Creacion: 	2017-05-25 @ Team ERGON - Sprint Sheik
-- Description:	        Obtiene las polizas pendientes por costear


/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_GET_POLIZA_DETAIL_PENDING_AUTHORIZED] @CODE_POLIZA = 28841
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_POLIZA_DETAIL_PENDING_AUTHORIZED] (
  @CODE_POLIZA VARCHAR(25)
)
AS
BEGIN
  SET NOCOUNT ON;
  --  

  SELECT
   [T].[MATERIAL_CODE] AS [MATERIAL_ID]
   ,MAX([T].[MATERIAL_DESCRIPTION]) AS [SKU_DESCRIPTION]
   ,SUM([T].[QUANTITY_UNITS]) AS QTY
   ,ISNULL(MAX([PD].[UNITARY_PRICE]),0) AS [UNITARY_PRICE]
   ,ISNULL(MAX([PD].[UNITARY_PRICE]),0) * SUM([T].[QUANTITY_UNITS]) AS [CUSTOMS_AMOUNT]
  FROM  [wms].[OP_WMS_TRANS] [T] 
  INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH] ON(
    [T].[CODIGO_POLIZA] = [PH].[CODIGO_POLIZA]
  )
  LEFT JOIN [wms].[OP_WMS_POLIZA_DETAIL] [PD] ON(
    [PH].[DOC_ID] = [PD].[DOC_ID]
    AND [PD].[MATERIAL_ID] = [T].[MATERIAL_CODE]
  )
  WHERE [T].[CODIGO_POLIZA] = @CODE_POLIZA
    AND ([T].[TRANS_TYPE] = 'INICIALIZACION_GENERAL'
    OR [T].[TRANS_TYPE] = 'INGRESO_GENERAL')
  AND [T].[STATUS] = 'PROCESSED'
  GROUP BY [T].[MATERIAL_CODE]

END