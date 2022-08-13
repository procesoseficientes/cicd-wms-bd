-- =============================================
-- Autor:	        rudi.garcia
-- Fecha de Creacion: 	08-Nov-17 @ Team REBORN - Sprint Eberhard
-- Description:	        Sp que obtiene los numeros de serie.

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_GET_CERTIFICATION_DETAIL_OF_SERIAL_NUMBER] @CERTIFICATION_HEADER_ID = 1150
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_CERTIFICATION_DETAIL_OF_SERIAL_NUMBER] (@CERTIFICATION_HEADER_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT
    [PLS].[LABEL_ID]
   ,[CD].[CERTIFICATION_TYPE]
   ,[CSN].[MATERIAL_ID]
   ,[CSN].[SERIAL_NUMBER]
  FROM [wms].[OP_WMS_CERTIFICATION_BY_SERIAL_NUMBER] [CSN]
  INNER JOIN [wms].[OP_WMS_CERTIFICATION_DETAIL] [CD]
    ON (
    [CD].[CERTIFICATION_HEADER_ID] = [CSN].[CERTIFICATION_HEADER_ID]
    AND [CD].[MATERIAL_ID] = [CSN].[MATERIAL_ID]
    )
  LEFT JOIN [wms].[OP_WMS_PICKING_LABELS_BY_SERIAL_NUMBER] [PLS]
    ON (
    [PLS].[LABEL_ID] = [CD].[LABEL_ID]
    AND [PLS].[SERIAL_NUMBER] = [CSN].[SERIAL_NUMBER]
    )
  WHERE [CSN].[CERTIFICATION_HEADER_ID] = @CERTIFICATION_HEADER_ID
END