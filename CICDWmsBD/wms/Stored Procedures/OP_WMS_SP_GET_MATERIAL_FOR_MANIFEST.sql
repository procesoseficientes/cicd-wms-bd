-- =============================================
-- Autor:	        rudi.garcia
-- Fecha de Creacion: 	2017-10-24 @ Team REBORN - Sprint Drache
-- Description:	        Obtiene el material del manifiesto 

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].OP_WMS_SP_GET_MATERIAL_FOR_MANIFEST @MANIFEST_HEADER_ID = 1119, @BARCODE_ID = 'arium/100089'


*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_MATERIAL_FOR_MANIFEST (@MANIFEST_HEADER_ID INT
, @BARCODE_ID VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT TOP 1
   [PL].[MATERIAL_ID]
   ,[PL].[MATERIAL_NAME]
   ,ISNULL([M].[SERIAL_NUMBER_REQUESTS], 0) AS [SERIAL_NUMBER_REQUESTS]
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
  INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON(
    [M].[MATERIAL_ID] = [PL].[MATERIAL_ID]
  )
  WHERE [MD].[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID
  --AND [PL].[CLIENT_CODE] = [M].[CLIENT_OWNER]
  AND ([M].[BARCODE_ID] = @BARCODE_ID OR [M].[ALTERNATE_BARCODE] =@BARCODE_ID OR [M].[MATERIAL_ID] = @BARCODE_ID )
  

END