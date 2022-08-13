
-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	12-May-18 @ G_FORCE Team Sprint Capibara 
-- Description:			SP que consulta licencias con inventario no bloqueado de una poliza. 
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_INVENTORY_POLICY] @CODIGO_POLIZA = '11370'
				SELECT * FROM [wms].[OP_WMS_LICENSES]
				
				*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_INVENTORY_POLICY] (@CODIGO_POLIZA VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [L].[LICENSE_ID]
   ,[IL].[MATERIAL_ID]
   ,[M].[BARCODE_ID]
   ,[M].[ALTERNATE_BARCODE]
   ,[M].[MATERIAL_NAME]
   ,([IL].[QTY] - ISNULL([C].[COMMITED_QTY], 0)) [QTY_AVAILABLE]
   ,([IL].[QTY] - ISNULL([C].[COMMITED_QTY], 0)) [QTY_DISPATCH]
   ,[IL].[BATCH]
   ,[IL].[DATE_EXPIRATION]
   ,[T].[TONE]
   ,[T].[CALIBER]
  FROM [wms].[OP_WMS_LICENSES] [L]
  INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL]
    ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
  INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
    ON ([M].[MATERIAL_ID] = [IL].[MATERIAL_ID])
  LEFT JOIN [wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [C]
    ON [C].[LICENCE_ID] = [L].[LICENSE_ID]
    AND [C].[MATERIAL_ID] = [IL].[MATERIAL_ID]
  LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [T]
    ON [IL].[TONE_AND_CALIBER_ID] = [T].[TONE_AND_CALIBER_ID]
  WHERE [L].[CODIGO_POLIZA] = @CODIGO_POLIZA
  AND ([IL].[QTY] - ISNULL([C].[COMMITED_QTY], 0)) > 0



END;