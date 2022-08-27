﻿-- =============================================
-- Autor:	rudi.garcia
-- Fecha de Creacion: 	10-Dic-2018 @ Team G-Force - Sprint Ornitorinco
-- Description:	 Sp que obtiene el despacho general para reporte.

/*
-- Ejemplo de Ejecucion:
EXEC [wms].OP_WMS_SP_GET_DISPATCH_GENERAL_FOR_REPORT @POLICY_CODE = '1'
*/
-- =============================================

CREATE PROCEDURE [wms].OP_WMS_SP_GET_DISPATCH_GENERAL_FOR_REPORT (@POLICY_CODE VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --  

  SELECT
    [TL].[WAVE_PICKING_ID]
   ,[TL].[TASK_SUBTYPE]
   ,[TL].[TASK_ASSIGNEDTO]
   ,[TL].[REGIMEN]
   ,[TL].[SERIAL_NUMBER]
   ,[TL].[ASSIGNED_DATE]
   ,[TL].[COMPLETED_DATE]
   ,[TL].[QUANTITY_PENDING]
   ,[TL].[QUANTITY_ASSIGNED]
   ,[TL].[MATERIAL_ID]
   ,[TL].[BARCODE_ID]
   ,[TL].[MATERIAL_NAME]
   ,[TL].[CODIGO_POLIZA_TARGET]
   ,[TL].[CODIGO_POLIZA_SOURCE]
   ,[PHS].[NUMERO_ORDEN] AS [NUMERO_ORDEN_SOURCE]
   ,[PHT].[NUMERO_ORDEN] AS [NUMERO_ORDEN_TARGET]
   ,(CASE
      WHEN [TL].[CANCELED_BY] IS NULL THEN 0
      ELSE 1
    END) AS [CANCELED_BY]
   ,ISNULL((SUM(T.QUANTITY_UNITS * -1)), 0) AS [QUANTITY_UNITS]
   ,[TL].[CLIENT_NAME]
   ,ISNULL([PDS].[UNITARY_PRICE], 1) AS [VALOR_UNITARIO]
   ,ISNULL([PDS].[UNITARY_PRICE], 1) * ISNULL((SUM(T.QUANTITY_UNITS * -1)), 0) AS [TOTAL_VALOR]
  FROM [wms].OP_WMS_TASK_LIST AS [TL]
  INNER JOIN [wms].[OP_WMS_TRANS] [T]
    ON ([TL].CODIGO_POLIZA_TARGET = [T].[CODIGO_POLIZA]
    AND [TL].[LICENSE_ID_SOURCE] = [T].[LICENSE_ID]
    AND [TL].[MATERIAL_ID] = [T].[MATERIAL_CODE]
    AND [T].[TRANS_SUBTYPE] = 'DESPACHO_GENERAL'
    )
  INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PHS]
    ON (
    [TL].[CODIGO_POLIZA_SOURCE] = [PHS].[CODIGO_POLIZA]
    )
  INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PHT]
    ON (
    [TL].[CODIGO_POLIZA_TARGET] = [PHT].[CODIGO_POLIZA]
    )
  LEFT JOIN [wms].[OP_WMS_POLIZA_DETAIL] [PDS]
    ON (
    [PHS].[DOC_ID] = [PDS].[DOC_ID]
    AND [PDS].[MATERIAL_ID] = [TL].[MATERIAL_ID]
    )
  WHERE [TL].[REGIMEN] = 'GENERAL'
  AND [TL].[CODIGO_POLIZA_TARGET] = @POLICY_CODE
  GROUP BY [TL].[WAVE_PICKING_ID]
          ,[TL].[TASK_SUBTYPE]
          ,[TL].[TASK_ASSIGNEDTO]
          ,[TL].[REGIMEN]
          ,[TL].[SERIAL_NUMBER]
          ,[TL].[ASSIGNED_DATE]
          ,[TL].[COMPLETED_DATE]
          ,[TL].[QUANTITY_PENDING]
          ,[TL].[QUANTITY_ASSIGNED]
          ,[TL].[MATERIAL_ID]
          ,[TL].[BARCODE_ID]
          ,[TL].[MATERIAL_NAME]
          ,[TL].[CODIGO_POLIZA_TARGET]
          ,[TL].[CODIGO_POLIZA_SOURCE]
          ,[PHS].[NUMERO_ORDEN]
          ,[PHT].[NUMERO_ORDEN]
          ,[TL].[CANCELED_BY]
          ,[TL].[CLIENT_NAME]
          ,[PDS].[UNITARY_PRICE]
  ORDER BY [TL].[ASSIGNED_DATE]


END;