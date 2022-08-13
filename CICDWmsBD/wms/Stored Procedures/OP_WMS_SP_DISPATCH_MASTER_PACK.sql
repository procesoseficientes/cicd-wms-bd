-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-03-10 @ Team ERGON - Sprint ERGON V
-- Description:	 Creación de SP para registrar despacho de un masterpack 




/*
-- Ejemplo de Ejecucion:

  exec [wms].[OP_WMS_SP_DISPATCH_MASTER_PACK] (@MATERIAL_ID = 'wms/PT0001'
, @LICENCE_ID  = 177672
, @QTY_DISPATCH = 20

			select * from [wms].[OP_WMS_MASTER_PACK_HEADER]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_DISPATCH_MASTER_PACK] (@MATERIAL_ID VARCHAR(50)
, @LICENCE_ID INT
, @QTY_DISPATCH INT)
AS
BEGIN
  SET NOCOUNT ON;
  --

  UPDATE [wms].[OP_WMS_MASTER_PACK_HEADER]
  SET [QTY] = [QTY] - @QTY_DISPATCH
  WHERE [LICENSE_ID] = @LICENCE_ID
  AND [MATERIAL_ID] = @MATERIAL_ID;

END