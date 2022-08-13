-- =============================================
-- Autor:	        rudi.garcia
-- Fecha de Creacion: 	21-Aug-2018 G-Force@Jaguarundi
-- Description:	        Sp que obtenemos la informacion del picking de despacho.

-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_WAVE_PICKING_FOR_LICENSE_DISPATCH] (@NUMBER INT, @TYPE VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;

  --'DISPATCH_LICENSE'--'WAVE_PICKING' --'DOC_NUM'
  -- ----------------------
  -- Declaramos la variables que vamos a utilizar
  -- ----------------------
  DECLARE @WAVE_PICKING_ID INT

  -- ----------------------
  -- Validamos de que tipo es la busquda y obtenemos la ola de picking
  -- ----------------------
  IF @TYPE = 'DISPATCH_LICENSE'
  BEGIN
    SELECT TOP 1
      @WAVE_PICKING_ID = [L].[WAVE_PICKING_ID]
    FROM [wms].[OP_WMS_LICENSES] [L]
    WHERE [L].[LICENSE_ID] = @NUMBER
  END
  ELSE
  IF @TYPE = 'DOC_NUM'
  BEGIN
    SELECT TOP 1
      @WAVE_PICKING_ID = [PDH].[WAVE_PICKING_ID]
    FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
    WHERE [PDH].[DOC_NUM] = @NUMBER
  END
  ELSE
  BEGIN
    SET @WAVE_PICKING_ID = @NUMBER
  END

  SELECT
    @WAVE_PICKING_ID = 0
  FROM [wms].[OP_WMS_TASK_LIST] [TL]
  WHERE [TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
  AND [TL].[IS_COMPLETED] = 0

  SELECT
    @WAVE_PICKING_ID = 0
  FROM [wms].[OP_WMS_TASK_LIST] [TL]
  WHERE [TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
  AND [TL].[DISPATCH_LICENSE_EXIT_COMPLETED] = 1

  -- ----------------------
  -- Retornamos los registros necesarios.
  -- ----------------------
  SELECT TOP 1
    [TL].[WAVE_PICKING_ID]
   ,CASE
      WHEN [PDH].[PICKING_DEMAND_HEADER_ID] IS NULL THEN [TL].[CLIENT_NAME]
      WHEN [PDH].[IS_CONSOLIDATED] = 1 THEN 'CONSOLIDADO'
      ELSE [PDH].[CLIENT_NAME]
    END [CLIENT_NAME]
   ,CASE
      WHEN [PDH].[PICKING_DEMAND_HEADER_ID] IS NULL THEN 0
      WHEN [PDH].[IS_CONSOLIDATED] = 1 THEN 0
      ELSE [PDH].[DOC_NUM]
    END [DOC_NUM]
   ,CASE
      WHEN [PDH].[PICKING_DEMAND_HEADER_ID] IS NULL THEN GETDATE()
      WHEN [PDH].[IS_CONSOLIDATED] = 1 THEN GETDATE()
      ELSE [PDH].[DEMAND_DELIVERY_DATE]
    END [DELIVERY_DATE]
  FROM [wms].[OP_WMS_TASK_LIST] [TL]
  LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
    ON ([TL].[WAVE_PICKING_ID] = [PDH].[WAVE_PICKING_ID])
  WHERE [TL].[WAVE_PICKING_ID] = 3216549879865498765432165---@WAVE_PICKING_ID cambio temporal para que no traiga resultado los despachos de licencia

END;