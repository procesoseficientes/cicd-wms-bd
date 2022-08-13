-- =============================================
-- Autor:	rudi.garcia
-- Fecha de Creacion: 	13-Feb-2019 @ Team G-Force - Sprint Suricata
-- Description:	 Sp que obtiene las olas de picking pendientes de despacho

/*
-- Ejemplo de Ejecucion:
EXEC [wms].OP_WMS_SP_GET_WAVE_PICKING_PENDING_TO_DISPATCH @LOGIN = 'RD'
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_GET_WAVE_PICKING_PENDING_TO_DISPATCH] (@LOGIN VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    [TL].[WAVE_PICKING_ID]
   ,MAX([TL].[PRIORITY]) AS [PRIORITY]
   ,MAX([TL].[COMPLETED_DATE]) AS [COMPLETED_DATE]
   ,CASE
      WHEN MAX([PDH].[PICKING_DEMAND_HEADER_ID]) IS NULL THEN MAX([TL].[CLIENT_NAME])
      WHEN MAX([PDH].[IS_CONSOLIDATED]) = 1 THEN 'CONSOLIDADO'
      ELSE MAX([PDH].[CLIENT_NAME])
    END [CLIENT_NAME]
   ,CASE
      WHEN MAX([PDH].[PICKING_DEMAND_HEADER_ID]) IS NULL THEN 0
      WHEN MAX([PDH].[IS_CONSOLIDATED]) = 1 THEN 0
      ELSE MAX([PDH].[DOC_NUM])
    END [DOC_NUM]
  FROM [wms].[OP_WMS_TASK_LIST] [TL]
  INNER JOIN [wms].[OP_WMS_LICENSES] [L]
    ON (  l.[LICENSE_ID] > 0  AND  [TL].[WAVE_PICKING_ID] = [L].[WAVE_PICKING_ID])
  LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
    ON ([TL].[WAVE_PICKING_ID] = [PDH].[WAVE_PICKING_ID])
  GROUP BY [TL].[WAVE_PICKING_ID]
  HAVING MIN([TL].[IS_COMPLETED]) = 1000064   -- cambio temporal para que no muestre valores 
  AND MIN([TL].[DISPATCH_LICENSE_EXIT_COMPLETED]) = 5654654654
  ORDER BY MAX([TL].[PRIORITY]) DESC, MAX([TL].[COMPLETED_DATE]) DESC
END;