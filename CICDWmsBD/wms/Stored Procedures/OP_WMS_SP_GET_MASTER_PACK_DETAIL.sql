-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-01-26 @ Team ERGON - Sprint ERGON II
-- Description:	        Sp que devuelve un detalle de master pack 

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-10 Team ERGON - Sprint ERGON V
-- Description:	Cambio para eliminar los joins a la tabla de empaque que masterpack ya no utiliza.



/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_MASTER_PACK_DETAIL] @MASTER_PACK_HEADER_ID  = 1
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_MASTER_PACK_DETAIL] (@MASTER_PACK_HEADER_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [MPD].[MASTER_PACK_DETAIL_ID]
   ,[MPD].[MASTER_PACK_HEADER_ID]
   ,[MPD].[MATERIAL_ID]
   ,[M].[MATERIAL_NAME]
   ,[M].[CLIENT_OWNER] [CLIENT_CODE]
   ,[C].[CLIENT_NAME]
   ,[M].[BARCODE_ID]
   ,[MPD].[QTY]
   ,[MPD].[BATCH]
   ,[MPD].[DATE_EXPIRATION]      
  FROM [wms].[OP_WMS_MASTER_PACK_DETAIL] [MPD]
  INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
    ON [MPD].[MATERIAL_ID] = [M].[MATERIAL_ID]  
  INNER JOIN [wms].[OP_WMS_VIEW_CLIENTS] [C]
    ON [M].[CLIENT_OWNER] = [C].[CLIENT_CODE]
  WHERE [MPD].[MASTER_PACK_HEADER_ID] = @MASTER_PACK_HEADER_ID

END