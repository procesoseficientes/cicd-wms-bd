-- =============================================
-- Autor:	        rudi.garcia
-- Fecha de Creacion: 	2017-10-21 @ Team REBORN - Sprint Drache
-- Description:	        Obtien la informacion de la etiqueta ya asociado con el manifiesto

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].OP_WMS_SP_GET_LABEL_DATA_FOR_MANIFEST @MANIFEST_HEADER_ID = 18, @LABEL_ID = 4


*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_LABEL_DATA_FOR_MANIFEST (@MANIFEST_HEADER_ID INT
, @LABEL_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [PL].[LABEL_ID]
   ,[PL].[LOGIN_ID]
   ,[PL].[LICENSE_ID]
   ,[PL].[MATERIAL_ID]
   ,[PL].[MATERIAL_NAME]
   ,[PL].[QTY]
   ,[PL].[CODIGO_POLIZA]
   ,[PL].[SOURCE_LOCATION]
   ,[PL].[TARGET_LOCATION]
   ,[PL].[TRANSIT_LOCATION]
   ,[PL].[BATCH]
   ,[PL].[VIN]
   ,[PL].[TONE]
   ,[PL].[CALIBER]
   ,[PL].[SERIAL_NUMBER]
   ,[PL].[STATUS]
   ,[PL].[WEIGHT]
   ,[PL].[WAVE_PICKING_ID]
   ,[PL].[TASK_SUBT_YPE]
   ,[PL].[WAREHOUSE_TARGET]
   ,[PL].[CLIENT_NAME]
   ,[PL].[CLIENT_CODE]
   ,[PL].[STATE_CODE]
   ,[PL].[REGIMEN]
   ,[PL].[TRANSFER_REQUEST_ID]   
  FROM [wms].[OP_WMS_PICKING_LABEL_BY_MANIFEST] [PLM]
  INNER JOIN [wms].[OP_WMS_MANIFEST_DETAIL] [MD]
    ON (
    [MD].[MANIFEST_DETAIL_ID] = [PLM].[MANIFEST_DETAIL_ID]
    )
  INNER JOIN [wms].[OP_WMS_MANIFEST_HEADER] [MH]
    ON (
    [MH].[MANIFEST_HEADER_ID] = [MD].[MANIFEST_HEADER_ID]
    )
  INNER JOIN [wms].[OP_WMS_PICKING_LABELS] [PL]
    ON (
    [PL].[LABEL_ID] = [PLM].[LABEL_ID]
    )
  WHERE [MD].[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID
  AND [PLM].[LABEL_ID] = @LABEL_ID


END