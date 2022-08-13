-- =============================================
-- Autor:					rudi.garcia
-- Fecha de Creacion: 		08-03-2017 @ Team ERGON - Sprint V ERGON
-- Description:			    Obtiene el material

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_GET_MATERIAL]
          @CODE_MATERIAL = 'C00330/110472'
          
*/
-- 
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_MATERIAL] (@CODE_MATERIAL VARCHAR(50))
AS
BEGIN

  --
  SELECT
    [M].[CLIENT_OWNER]
   ,[M].[MATERIAL_ID]
   ,[M].[BARCODE_ID]
   ,[M].[ALTERNATE_BARCODE]
   ,[M].[MATERIAL_NAME]
   ,[M].[SHORT_NAME]
   ,[M].[VOLUME_FACTOR]
   ,[M].[MATERIAL_CLASS]
   ,[M].[HIGH]
   ,[M].[LENGTH]
   ,[M].[WIDTH]
   ,[M].[MAX_X_BIN]
   ,[M].[SCAN_BY_ONE]
   ,[M].[REQUIRES_LOGISTICS_INFO]
   ,[M].[WEIGTH]
   ,[M].[IMAGE_1]
   ,[M].[IMAGE_2]
   ,[M].[IMAGE_3]
   ,[M].[LAST_UPDATED]
   ,[M].[LAST_UPDATED_BY]
   ,[M].[IS_CAR]
   ,[M].[MT3]
   ,[M].[BATCH_REQUESTED]
   ,[M].[SERIAL_NUMBER_REQUESTS]
   ,[M].[IS_MASTER_PACK]
   ,[M].[ERP_AVERAGE_PRICE]
  FROM [wms].[OP_WMS_MATERIALS] [M]
  WHERE ([M].[MATERIAL_ID] = @CODE_MATERIAL
  OR [M].[BARCODE_ID] = @CODE_MATERIAL
  OR [M].[ALTERNATE_BARCODE] = @CODE_MATERIAL)
--

END