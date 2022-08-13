-- =============================================
-- Autor:	        rudi.garcia
-- Fecha de Creacion: 	2018-01-09 @ Team REBORN - Sprint Ramsey
-- Description:	        devuelve el detalle por numero de series de una entrega de despacho

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_DELIVERED_DISPATCH_DETAIL_OF_SERIAL_NUMBER] @DELIVERED_DISPATCH_HEADER_ID = 1
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_DELIVERED_DISPATCH_DETAIL_OF_SERIAL_NUMBER] (@DELIVERED_DISPATCH_HEADER_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --

  SELECT
    [PLS].[LABEL_ID]
   ,[PLS].[SERIAL_NUMBER]
  FROM [wms].[OP_WMS_DELIVERED_DISPATCH_DETAIL] [DD]
  INNER JOIN [wms].[OP_WMS_PICKING_LABELS] [PL]
    ON [PL].[LABEL_ID] = [DD].[LABEL_ID]
  INNER JOIN [wms].[OP_WMS_PICKING_LABELS_BY_SERIAL_NUMBER] [PLS]
    ON (
    [PLS].[LABEL_ID] = [PL].[LABEL_ID]
    )
  WHERE [DELIVERED_DISPATCH_HEADER_ID] = @DELIVERED_DISPATCH_HEADER_ID;


END;