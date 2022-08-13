
-- =============================================
-- Autor:                pablo.aguilar
-- Fecha de Creacion:     2017-09-02 @ NEXUS-Team Sprint@Command&Conquer 
-- Description:            Genera información de etiqueta a imprimir en picking
/*
-- Ejemplo de Ejecucion:
                EXEC [wms].[OP_WMS_SP_GET_PICKING_TAG] @WAVE_PICKING_ID = 4685 , @LOGIN = 'ACAMACHO'
          SELECT * FROM [wms].[OP_WMS_TASK_LIST] [OWTL] ORDER BY 1 DESC
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_PICKING_TAG (@WAVE_PICKING_ID NUMERIC
, @LOGIN VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [TL].[TASK_SUBTYPE] [SUB_TYPE]
   ,ISNULL('WT-DESTINO ' + [TR].[WAREHOUSE_TO], 'BODEGA ' + [TL].[WAREHOUSE_SOURCE]) WAREHOUSE_TARGET
   ,[L].[LOGIN_NAME] LOGIN_NAME
   ,GETDATE() DATE_TIME
   ,ISNULL([H].[CLIENT_NAME], [TL].[CLIENT_NAME]) CLIENT_NAME
   ,ISNULL([H].[CLIENT_CODE], [TL].[CLIENT_OWNER]) CLIENT_CODE
   ,[TL].[WAVE_PICKING_ID] WAVE_PICKING_ID
   ,NULL LICENSE_ID
   ,CASE
      WHEN [TR].[TRANSFER_REQUEST_ID] IS NULL THEN ''
      ELSE 'WT-' + CAST([TR].[TRANSFER_REQUEST_ID] AS VARCHAR)
    END [TRANSFER_REQUEST_ID]
  FROM [wms].[OP_WMS_TASK_LIST] [TL]
  INNER JOIN [wms].[OP_WMS_LOGINS] [L]
    ON [L].[LOGIN_ID] = @LOGIN
  LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H]
    ON [TL].[WAVE_PICKING_ID] = [H].[WAVE_PICKING_ID]
  LEFT JOIN [wms].[OP_WMS_TRANSFER_REQUEST_HEADER] [TR]
    ON [TL].[TRANSFER_REQUEST_ID] = [TR].[TRANSFER_REQUEST_ID]
  WHERE [TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID

END